title: http.Handler 与Go的错误处理
date: 2015-11-12 21:24:57
tags:
  - Go
  - Translate
---

[原文地址](http://elithrar.github.io/article/http-handler-error-handling-revisited/)

&emsp;&emsp; 在之前我写过一篇关于通过使用`http.HandlerFunc`来实现一个定制handler类型用来避免一些平常的错误的[文章](http://elithrar.github.io/article/custom-handlers-avoiding-globals/)。`func MyHandler(w http.ResponseWriter, r *http.Request)`的签名经常可以看到。这是一个有用的通用的包含一些基本功能的handler类型，但是和其他事情一样，也有一些不足：
* 当你想要在一个handler中停止处理的时候，必须记得显示的调用一个return。这个在当你想要跑出一个从定向（301、302），未找到（404）或者服务器端错误（500）的状态的时候是很平常的。如果不这么做可能会引起一些微妙的错误（函数会继续执行），因为函数不需要一个返回值，编译器也不会警告你。
* 不容易传递额外的参数（例如，数据库连接池，配置）。你最后不得不实用一系列的全局变量（不算太坏，但是跟踪他们会导致难以扩展）或者将他们存到请求上下文中，然后每次都从其取出。这样做很笨重。
* 一直在不断的重复同样的语句。想要记录数据库包返回的错误？既可以再每个查询方法中调用`log.Printf`，也可以再每个handler中返回错误。如果你的handler可以返回给一个集中记录错误的函数，并且跑出一个500的错误就更好了。

&emsp;&emsp; 我以前的方法中使用了`func(http.ResponseWriter, *http.Request)`签名。这已经被证明是一个简介的方式，但是有个奇怪的地方是，返回一个无错误的状态，例如，200,302,303往往是多余的，因为要么你已经在其他地方设置了，要么就是没用的。例如：

```
func SomeHandler(w http.ResponseWriter, r *http.Request) (int, error) {
    db, err := someDBcall()
    if err != nil {
        // This makes sense.
        return 500, err
    }

    if user.LoggedIn {
        http.Redirect(w, r, "/dashboard", 302)
        // Superfluous! Our http.Redirect function handles the 302, not 
        // our return value (which is effectively ignored).
        return 302, nil
    }

}
```

&emsp;&emsp;看起来还行，但是我们可以做的更好

### 一些区别

&emsp;&emsp; 那么我们应该如何改进它？我们先列出代码：

```
package handler

// Error represents a handler error. It provides methods for a HTTP status 
// code and embeds the built-in error interface.
type Error interface {
    error
    Status() int
}

// StatusError represents an error with an associated HTTP status code.
type StatusError struct {
    Code int
    Err  error
}

// Allows StatusError to satisfy the error interface.
func (se StatusError) Error() string {
    return se.Err.Error()
}

// Returns our HTTP status code.
func (se StatusError) Status() int {
    return se.Code
}

// A (simple) example of our application-wide configuration.
type Env struct {
    DB   *sql.DB
    Port string
    Host string
}

// The Handler struct that takes a configured Env and a function matching
// our useful signature.
type Handler struct {
    *Env
    H func(e *Env, w http.ResponseWriter, r *http.Request) error
}

// ServeHTTP allows our Handler type to satisfy http.Handler.
func (h Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    err := h.H(h.Env, w, r)
    if err != nil {
        switch e := err.(type) {
        case Error:
            // We can retrieve the status here and write out a specific
            // HTTP status code.
            log.Printf("HTTP %d - %s", e.Status(), e)
            http.Error(w, e.Error(), e.Status())
        default:
            // Any error types we don't specifically look out for default
            // to serving a HTTP 500
            http.Error(w, http.StatusText(http.StatusInternalServerError),
                http.StatusInternalServerError)
        }
    }
}
```

&emsp;&emsp; 上面的代码不言自明，但是要说明一下一些突出的观点：

* 我们自定义了一个`Error`类型（接口），他内嵌了Go的内建的error接口，同时提供了一个`Status() int`方法。
* 我们提供了一个简单的`StatusError`类型（结构体），它满足`handler.Error`的接口。StatusError接受一个HTTP的状态码（int类型），一个可以让我们包装错误用来记录或者查询的error类型。
* 我们的`ServeHTTP`方法包好了一个"e := err.(type)"的类型断言，它可以测试我们需要处理的错误，允许我们处理那些特别的错误。在这个例子中，他是只是一个`handler.Error`类型。其他的错误，例如其他包中的错误想net.Error，或者其他我们定义的额外的错误，如果想要检查，同样也可以检查。

&emsp;&emsp; 如果我们不想捕捉那些错误，那么`default`将会默认捕捉到。记住一点，`ServeHTTP`可以使我们的Handler类型满足http.Handler接口，这样他就可以在任何使用http.Handler的地方使用了，例如Go的net/http包或者所有的其他的第三方框架。这样使得定制的handler更有用，他们用起来很灵活。
&emsp;&emsp; 注意 net 包处理事情很简单。它又一个net.Error的接口，内嵌了内建的error接口。一些具体的类型实现了它。函数返回的具体类型跟错误的类型相同（DNS错误，解析错误等）。再datastore 包中定义的DBError有一个Query() string 方法，可以很好的解释。

### 所有示例

&emsp;&emsp; 它最后是什么样子的？我们是否可以将其分到不同的包中？

```
package handler

import (
    "net/http"
)

// Error represents a handler error. It provides methods for a HTTP status 
// code and embeds the built-in error interface.
type Error interface {
    error
    Status() int
}

// StatusError represents an error with an associated HTTP status code.
type StatusError struct {
    Code int
    Err  error
}

// Allows StatusError to satisfy the error interface.
func (se StatusError) Error() string {
    return se.Err.Error()
}

// Returns our HTTP status code.
func (se StatusError) Status() int {
    return se.Code
}

// A (simple) example of our application-wide configuration.
type Env struct {
    DB   *sql.DB
    Port string
    Host string
}

// The Handler struct that takes a configured Env and a function matching
// our useful signature.
type Handler struct {
    *Env
    H func(e *Env, w http.ResponseWriter, r *http.Request) error
}

// ServeHTTP allows our Handler type to satisfy http.Handler.
func (h Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    err := h.H(h.Env, w, r)
    if err != nil {
        switch e := err.(type) {
        case Error:
            // We can retrieve the status here and write out a specific
            // HTTP status code.
            log.Printf("HTTP %d - %s", e.Status(), e)
            http.Error(w, e.Error(), e.Status())
        default:
            // Any error types we don't specifically look out for default
            // to serving a HTTP 500
            http.Error(w, http.StatusText(http.StatusInternalServerError),
                http.StatusInternalServerError)
        }
    }
}

func GetIndex(env *Env, w http.ResponseWriter, r *http.Request) error {
    users, err := env.DB.GetAllUsers()
    if err != nil {
        // We return a status error here, which conveniently wraps the error
        // returned from our DB queries. We can clearly define which errors 
        // are worth raising a HTTP 500 over vs. which might just be a HTTP 
        // 404, 403 or 401 (as appropriate). It's also clear where our 
        // handler should stop processing by returning early.
        return StatusError{500, err}
    }

    fmt.Fprintf(w, "%+v", users)
    return nil
}
```

&emsp;&emsp; main包：

```
package main

import (
    "net/http"
    "github.com/you/somepkg/handler"
)

func main() {
    db, err := sql.Open("connectionstringhere")
    if err != nil {
          log.Fatal(err)
    }

    // Initialise our app-wide environment with the services/info we need.
    env := &handler.Env{
        DB: db,
        Port: os.Getenv("PORT"),
        Host: os.Getenv("HOST"),
        // We might also have a custom log.Logger, our 
        // template instance, and a config struct as fields 
        // in our Env struct.
    }

    // Note that we're using http.Handle, not http.HandleFunc. The 
    // latter only accepts the http.HandlerFunc type, which is not 
    // what we have here.
    http.Handle("/", handler.Handler{env, handler.GetIndex})

    // Logs the error if ListenAndServe fails.
    log.Fatal(http.ListenAndServe(":8000", nil))
}
```

&emsp;&emsp; 在实际使用时，会将handler和Env放入不同的包中，这里只是为了简单放在了同一个包中。

