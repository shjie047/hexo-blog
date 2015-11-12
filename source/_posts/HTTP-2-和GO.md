title: HTTP/2 和GO
date: 2015-11-12 11:39:21
tags:
  - HTTP/2
  - Translate
  - Go
---
[原文地址](https://www.ianlewis.org/en/http2-and-go)
&emsp;&emsp; HTTP/2是一个添加了一些新功能的HTTP的新版本，这些功能包括连接复用，首部压缩。再Go的标准库中暂时还没有HTTP/2的实现，但是现在有很多正在开发的库可以用来在Go中实现HTTP/2的server和client。
&emsp;&emsp; Brad Fitzpatrick实现了一个[golang.org/x/net/http2](https://godoc.org/golang.org/x/net/http2)的库，这个库甚至最终会加入到标准库中，不过他现在正在开发，所以在其他的库中。因为他现在的开发很活跃，所有情况因人而异，但是如果你想实现HTTP/2的服务器，仍然可以使用这个库。

### 创建HTTP/2服务器

&emsp;&emsp; 使用http2的库写一个服务器是很简单的。http2库和标准库的http包集成在一起，需要调用`http2.ConfigureServer()`来配置一个普通http使用HTTP/2协议。如果需要通过浏览器访问或者降级到HTTP 1.x 协议，那么你需要设置TLS 加密。虽然加密不是必须的，但是现在还没有浏览器支持非加密的HTTP/2协议。

```
package main

import (
    "log"
    "net/http"
    "os"

    "golang.org/x/net/http2"
)

func main() {
    cwd, err := os.Getwd()
    if err != nil {
        log.Fatal(err)
    }

    srv := &http.Server{
        Addr:    ":8000", // Normally ":443"
        Handler: http.FileServer(http.Dir(cwd)),
    }
    http2.ConfigureServer(srv, &http2.Server{})
    log.Fatal(srv.ListenAndServeTLS("server.crt", "server.key"))
}
```

### 创建HTTP/2 客户端

&emsp;&emsp; 现在使用http2的库创建客户端很hacky。虽然它会输出很多调试日志，但是对于大多数情况下运行的很好。可以使用`http2.Transport`对象，将他传给`http`包的client。

```
package main

import (
    "fmt"
    "io/ioutil"
    "log"
    "net/http"

    "golang.org/x/net/http2"
)

func main() {
    client := http.Client{
        // InsecureTLSDial is temporary and will likely be
        // replaced by a different API later.
        Transport: &http2.Transport{InsecureTLSDial: true},
    }

    resp, err := client.Get("https://localhost:8000/")
    if err != nil {
        log.Fatal(err)
    }

    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(string(body))
}
```

### 更多阅读

&emsp;&emsp; 如果你对HTTP/2协议感兴趣，那么可以参考[HTTP/2 主页](https://http2.github.io/)，这个页面有很多其他资料的连接还有其他语言的实现。
&emsp;&emsp; 如果你想知道HTTP/2的服务端和客户端是如何实现的，那么[Jxck's http2 implementation](https://github.com/Jxck/http2)的实现就很值得一读。Jxck通过对标准的HTTP库的TLSNextProto设置一个钩子来实现的。你可以再这里阅读一些[示例](https://github.com/Jxck/http2/blob/master/sample/http.go)。
&emsp;&emsp; grpc-go 库同样也有自己的服务端和客户端的实现。
