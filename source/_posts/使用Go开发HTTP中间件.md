title: 使用Go开发HTTP中间件
date: 2015-11-12 12:07:49
tags:
  - HTTP
  - Go
  - Middleware
---
[原文地址](https://justinas.org/writing-http-middleware-in-go/)

&emsp;&emsp; 再web开发的背景下，“中间件”通常意思是“包装原始应用并添加一些额外的功能的应用的一部分”。这个概念似乎总是不被人理解，但是我认为中间件非常棒。
&emsp;&emsp; 首先，一个好的中间件有一个责任就是可插拔并且自足。这就意味着你可以在接口级别嵌入你的中间件他就能直接运行。它不会影响你编码方式，不是框架，仅仅是你请求处理里面的一层而已。完全没必要重写你的代码，如果你想使用中间件的一个功能，你就帮他插入到那里，如果不想使用了，就可以直接移除。
&emsp;&emsp; 纵观Go语言，中间件是非常普遍的，即使在标准库中。虽然开始的时候不会那么明显，在标准库`net/http`中的函数`StripText`或者`TimeoutHandler`就是我们要定义和的中间件的样子，处理请求和相应的时候他们包装你的handler，并处理一些额外的步骤。
&emsp;&emsp; 我最近写的Go包[nosurf](https://github.com/justinas/nosurf)同样也是个中间件。我特意将他从头开始设计。在大多数情况下，你不需要在应用层担心CSRF攻击，nosurf像其他的中间件一样可以自足，并且和`net/http`的接口无缝衔接。
&emsp;&emsp; 同样你还可以使用中间件做：
* 隐藏长度防止缓冲攻击
* 速度限制
* 屏蔽爬虫
* 提供调试信息
* 添加HSTS，X-Frame-Options头
* 从错误中恢复
* 等等

### 编写一个简单的中间件

&emsp;&emsp; 我们的第一个例子是写一个只允许一个域名下的用户访问的中间件，通过HTTP的`HOST`header实现。这样的中间件可以防止[主机欺骗攻击](http://www.skeletonscribe.net/2013/05/practical-http-host-header-attacks.html)。

### 类型的机构

&emsp;&emsp; 首先我们定义一个结构体，叫做`SingleHost`

```
type SingleHost struct {
    handler     http.Handler
    allowedHost string
}
```

&emsp;&emsp; 它只包含两个field。
* 如果是一个可用的Host，那么我们会调用嵌入的handler。
* allowedHost 就是允许的Host。
&emsp;&emsp; 因为我们将其首字母小写，因此他们只对本包可见。我们需要给它定义已给构造函数。

```
func NewSingleHost(handler http.Handler, allowedHost string) *SingleHost {
    return &SingleHost{handler: handler, allowedHost: allowedHost}
}
```

### 请求处理

&emsp;&emsp; 现在需要实现真正的逻辑功能了。想要实现`http.Handler`，我们只需要实现他的一个方法。

```
type Handler interface {
        ServeHTTP(ResponseWriter, *Request)
}
```

&emsp;&emsp; 实现如下：

```
func (s *SingleHost) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    host := r.Host
    if host == s.allowedHost {
        s.handler.ServeHTTP(w, r)
    } else {
        w.WriteHeader(403)
    }
}
```

`ServeHTTP`只是检查请求的Host：
* 如果Host和配置的allowed一直，那么调用handler的ServeHTTP。
* 如果不一直返回403
&emsp;&emsp;对于后一种情况，不仅不会得到应答，设置不知道有这个请求。
&emsp;&emsp;现在我们已经开发哈了中间件，只需要将其插入到需要的地方。

```
singleHosted = NewSingleHost(myHandler, "example.com")
http.ListenAndServe(":8080", singleHosted)
```

### 另一种方式

&emsp;&emsp; 我们刚刚写的那个中间件很简单，它只有15行代码。写这样的中间件，可以使用样板方法。由于Go支持函数为一等公民和闭包，并且有`http.HandlerFunc`包装函数，我们可以通过他创建一个中间件，而不是将其放入到一个结构体中。下面是这个中间件的写法。
```
func SingleHost(handler http.Handler, allowedHost string) http.Handler {
    ourFunc := func(w http.ResponseWriter, r *http.Request) {
        host := r.Host
        if host == allowedHost {
            handler.ServeHTTP(w, r)
        } else {
            w.WriteHeader(403)
        }
    }
    return http.HandlerFunc(ourFunc)
}
```
&emsp;&emsp; 我们定义了一个简单的函数`SingleHost`，它包装了`Handler`和允许的Host，在其内部我们实现了一个跟上面中间件类似的功能。我们内部的函数就是一个闭包，因此他可以访问外部函数的变量。最终HandlerFunc让我们可以将其变为Handler。
&emsp;&emsp; 觉得是使用HandlerFunc还是自己实现一个http.Handler完全取决于你自己。对于简单的情况，一个简单的函数就完全够了。如果你的中间件越来越多，那么就可以考虑实现自己的结构并把它们分开。
&emsp;&emsp; 同时标准库同时使用了两种功能。`StripPrefix`使用的是HandlerFunc，TimeoutHandler使用的是自定义的结构体。

### 一个更复杂的例子

&emsp;&emsp; 我们的`SingleHost`并不重要，我们只检测一个属性，要么将他传递给其他的handler，要么直接返回。然而存在这种情况，我们的程序需要对处理完进行后续处理。

### 添加数据是简单的

&emsp;&emsp; 如果只是想简单的添加数据，那么使用Write就可以了。

```
type AppendMiddleware struct {
    handler http.Handler
}

func (a *AppendMiddleware) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    a.handler.ServeHTTP(w, r)
    w.Write([]byte("Middleware says hello."))
}
```

&emsp;&emsp; 返回的结构肯定会包含`Middleware says hello.`

### 问题

&emsp;&emsp; 但是操作其他的数据有点困难。例如我们想要在它前面添加数据而不是后面追加。如果我们在原Handler之前调用Write，那么将会失去控制，因为第一个Write已经将他写入了。
&emsp;&emsp; 通过其他方法修改原始输出，例如替换字符串，改变响应header，或者设置状态码都不会起作用，因为当handler返回的时候数据已经返回到客户端了。
&emsp;&emsp; 为了实现这个功能，我们需要一个特殊的ResponseWriter，他可以想buffer一样工作，收集数据，存储以备使用和修改。然后我们将这个ResponseWriter传递给handler，而不是传递真是的RW，这样在其之前我们已经修改了它了。
&emsp;&emsp; 幸运的是在标准库中有这样的一个工具。在`net/http/httptest`包里的ResponseRecorder能做所有我们需要的：保存状态码，一个响应header的map，将body放入byte 缓冲中。虽然它是再测试中中使用的，但是很服务我们的情况。

```
type ModifierMiddleware struct {
    handler http.Handler
}

func (m *ModifierMiddleware) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    rec := httptest.NewRecorder()
    // passing a ResponseRecorder instead of the original RW
    m.handler.ServeHTTP(rec, r)
    // after this finishes, we have the response recorded
    // and can modify it before copying it to the original RW

    // we copy the original headers first
    for k, v := range rec.Header() {
        w.Header()[k] = v
    }
    // and set an additional one
    w.Header().Set("X-We-Modified-This", "Yup")
    // only then the status code, as this call writes out the headers 
    w.WriteHeader(418)

    // The body hasn't been written (to the real RW) yet,
    // so we can prepend some data.
    data := []byte("Middleware says hello again. ")

    // But the Content-Length might have been set already,
    // we should modify it by adding the length
    // of our own data.
    // Ignoring the error is fine here:
    // if Content-Length is empty or otherwise invalid,
    // Atoi() will return zero,
    // which is just what we'd want in that case.
    clen, _ := strconv.Atoi(r.Header.Get("Content-Length"))
    clen += len(data)
    r.Header.Set("Content-Length", strconv.Itoa(clen))

    // finally, write out our data
    w.Write(data)
    // then write out the original body
    w.Write(rec.Body.Bytes())
}
```
&emsp;&emsp;最后僵尸我们中间件的输出：

```
HTTP/1.1 418 I'm a teapot
X-We-Modified-This: Yup
Content-Type: text/plain; charset=utf-8
Content-Length: 37
Date: Tue, 03 Sep 2013 18:41:39 GMT

Middleware says hello again. Success!
```
&emsp;&emsp;这样就开启了一种新的可能，包装的handler完全手控制。

### 和其他handler分享数据

&emsp;&emsp; 在其他例子中，中间件可能需要暴露一些信息给其他中间件或者应用本身。例如nosurf需要给其他用户访问CSRF token的权限。
&emsp;&emsp; 最简单是是使用一个map，但是通常不希望这样。它将http.Request 的指针作为key，其他数据作为value。下面是nosurf的例子，Go的map非线程安全，所以要自己是实现。

```
type csrfContext struct {
    token string
    reason error
}

var (
    contextMap = make(map[*http.Request]*csrfContext)
    cmMutex    = new(sync.RWMutex)
)
```
&emsp;&emsp; 数据由Token设置：

```
func Token(req *http.Request) string {
    cmMutex.RLock()
    defer cmMutex.RUnlock()

    ctx, ok := contextMap[req]
    if !ok {
            return ""
    }

    return ctx.token
}
```
&emsp;&emsp;源码可以再nosurf的项目的[context.go](https://github.com/justinas/nosurf/blob/master/context.go)中找到。


