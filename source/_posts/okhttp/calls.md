title: OKHttp的调用
date: 2017-03-18 15:10:03
tags:
    - Translate
    - Java
    - OKHttp
    - HTTP
---

[原文地址](https://github.com/square/okhttp/wiki/Calls)

&emsp;&emsp;HTTP客户端的任务是接受请求和产生响应。理论很简单，但是实战的时候就有点棘手了。
#### Requests
&emsp;&emsp;每一个HTTP请求都包含一个URL，一个方法（例如，GET，POST）和一些headers。请求同时可以包含一个特定类型的数据流作为body。
#### Responses
&emsp;&emsp;Response 通过一个一个状态码（例如，200 成功，404未找到），headers，和一个可选的Body来响应请求。
##### 重写请求
&emsp;&emsp;当使用OkHttp发送HTTP请求的时候，可以在高层次描述这个请求：通过这个URL和这些headers来获取响应。为了准确和更高的效率，OKHttp会在发送之前重现请求。
&emsp;&emsp;OkHttp将会添加原请求没有的header，包括`Content-length`,`Transfer-Encoding`,`User-Agent`,`Host`,`Connection`，`Content-Type`。除非已经提供了，否则OKHttp回会添加 `Acceept-Encoding`来压缩响应。如果有Cookie，也会添加`Cookie`。
&emsp;&emsp;有些请求会缓存响应。当被缓存的响应过期后，OKHttp会发送一个有条件的GET请求来获取新的响应，如果新现在的比缓存的响应更新，将会更新缓存过的响应。这要求`If-Modified-Since`和`If-None-Match`添加到headers中。
##### 重写响应
&emsp;&emsp;如果透明压缩启用了，OKHttp将会把`Content-Encoding`和`Content-Length`从headers中移除，因为他们不是用来解压缩的。
&emsp;&emsp;如果条件GET请求成功，从网上下载的响应和缓存的响应根据Spec合并。
##### 后续请求
&emsp;&emsp;当请求的URL被转移了，web server 将会返回一个302的状态码来表示这个文档的新URL，OKHttp将会重定向到新的URL获取最终的响应。
&emsp;&emsp;如果响应需要认证，OKHttp将会使用`Authenticator`（如果提供了一个）来认证。如果认证器提供了凭证，请求回使用凭证重试。
##### 重试请求
&emsp;&emsp;有时连接失败，例如：连接池过期断开链接，或者无法连接服务器。OKHttp会通过不同的可用路由来重试请求。
#### calls
&emsp;&emsp;通过重写，重定向，继续请求和重试，一个简单的请求可能会产生很多请求和响应。OKHttp使用`call`建立一个不管多少中间请求和响应的任务模型。总的来说这不多。但是了解代码将会继续工作，不管是URL重定向或者是转移故障其他IP。
&emsp;&emsp;call有两种工作方
   * 同步：线程将会阻塞道到响应可读。
   * 异步：将请求加入到其他线程的队列，当响应可读诗时，会在其他的线程获取回调。
&emsp;&emsp;请求调用可以在任何线程取消。如果调用未完成，这个请求将会失败。当调用取消时，在先请求踢体或者读响应体的代码将会跑出IOException的异常。
##### 调度
&emsp;&emsp;对于同步调用，将会由自身线程控制多少并发请求。太多并发连接浪费资源，太少又回有高延迟。
&emsp;&emsp;对于异步来说，Dispatcher实现了最大并发的策略。可以设置没个服务器的最大并发（默认是5）和总体的并发（默认64）。