title: 为Go Web App 创建一个主页面
date: 2015-11-14 17:59:00
tags:
  - Go
  - Translate
---


[原文地址](http://sanatgersappa.blogspot.com/2013/11/creating-master-page-for-your-go-web-app.html)

&emsp;&emsp; 大多数web app都有一个相同的布局。这个布局可能包含一个header或者footer，甚至可能包含一个导航菜单。Go的标准库提供一个简单的方式来创建这些基本元素，通过被不同的页面重用，创建出模板页的效果。
&emsp;&emsp; 这个简单的例子来解释如何实现的：
&emsp;&emsp; 让我们来创建一个简单的包含两个view的web app，一个是 main 一个是about。这两个view都有相同的header和footer。
&emsp;&emsp; header模板的代码如下：

``` Go
{ { define "header" }}
<!DOCTYPE html>
<html>
    <head>
        <title>{ {.Title}}</title>
        <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css">
        <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap-theme.min.css">
        <style type="text/css">
            body {padding-bottom: 70px;}
            .content {margin:10px;}
        </style>
    </head>
    <body>
        <nav class="navbar navbar-default" role="navigation">
          <div class="navbar-header">
            <a class="navbar-brand" href="/">Go App</a>
          </div>
          <div class="collapse navbar-collapse navbar-ex1-collapse">  
            <ul class="nav navbar-nav">
                <li><a href="/">Main</a></li>
                <li><a href="/about">About</a></li>
            </ul>
          </div>
        </nav>
{ { end }}
```

&emsp;&emsp; footer模板的代码如下：


``` Go
{ { define "footer" }}
        <p class="navbar-text navbar-fixed-bottom">Go Rocks!</p>    
        <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>
    </body>
</html>
{ { end }}

```

&emsp;&emsp; main 模板的代码如下：

```
{ {define "main"}}
{ { template "header" .}}
<div class="content">
    <h2>Main</h2>
    <div>This is the Main page</div>
</div>
{ {template "footer" .}}
{ { end}}
```

&emsp;&emsp; about 模板的代码如下：

```
{ {define "about"}}
{ { template "header" .}}
<div class="content">
    <h2>About</h2>
    <div>This is the About page</div>
</div>
{ {template "footer" .}}
{ { end}}
```

&emsp;&emsp; 服务器代码如下：

```
package main

import (
    "html/template"
    "net/http"
)

//Compile templates on start
var templates = template.Must(template.ParseFiles("header.html", "footer.html", "main.html", "about.html"))

//A Page structure
type Page struct {
    Title string
}

//Display the named template
func display(w http.ResponseWriter, tmpl string, data interface{}) {
    templates.ExecuteTemplate(w, tmpl, data)
}

//The handlers.
func mainHandler(w http.ResponseWriter, r *http.Request) {
    display(w, "main", &Page{Title: "Home"})
}

func aboutHandler(w http.ResponseWriter, r *http.Request) {
    display(w, "about", &Page{Title: "About"})
}

func main() {
    http.HandleFunc("/", mainHandler)
    http.HandleFunc("/about", aboutHandler)

    //Listen on port 8080
    http.ListenAndServe(":8080", nil)
}
```

&emsp;&emsp; 每一个模板页都有一个 `{ { define "name" }}`的命令来定义模板的名字。main和about页面通过`{ { template "name" }}`来包含header和footer。`.` 出入上下文来命名模板。现在，不管main和about页面如何执行，他们的页面都会包含header和footer。
&emsp;&emsp; 两个页面的结果如下：

![main](https://raw.githubusercontent.com/mashuai/hexo-blog/master/goweb/main.png)  
![about](https://raw.githubusercontent.com/mashuai/hexo-blog/master/goweb/about.png)  
