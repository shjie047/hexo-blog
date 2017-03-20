title: OKHttp connections
date: 2017-03-18 19:05:48
tags:
    - OKHttp
    - Translate
    - Java
    - HTTP
---

[原文地址](https://github.com/square/okhttp/wiki/Connections)
&emsp;&emsp;虽然只提供了URL，但是OKHttp会使用URL，Address，Route三种方式来连接服务器。

#### URLS
&emsp;&emsp;URLs例如（https://github.com/square/okhttp) 是HTTP和Internet的基础。除了是一个表示互联网一切的命名方案，也指定了如何访问Web资源。
URLs是抽象的：
  * 它指出，调用可以是纯文本（http）或者加密（https），但是并没有指定一种加密算法。也没有指定如何验证各个端点的证书([HostnameVerifier](http://developer.android.com/reference/javax/net/ssl/HostnameVerifier.html))，或者是哪个证书可信([SSLSocketFactory](http://developer.android.com/reference/org/apache/http/conn/ssl/SSLSocketFactory.html))
  * 它为指定是否需要使用代理服务器以及代理服务器如何授权。
 &emsp;&emsp;它也是具体的，每个URL标识一个具体的路径（/square/okhttp)和查询（?q=sharks&lang=en)。每个服务器有很多URL。

 #### Addresses
 &emsp;&emsp;Address指定了一个服务器（例如：github.com），以及连接服务器必要的所有的静态配置，包括：端口号，HTTPS设置，优先协议（例如，HTTP／2，SPDY）。
 &emsp;&emsp;URL使用了相同的Address，底层也可能实用了相同的TCP链接。复用连接可以提高性能：低延迟，高吞吐（[TCP 慢启动](http://www.igvita.com/2011/10/20/faster-web-vs-tcp-slow-start/))，低电量。OKHttp使用[ConnectionPool](http://square.github.io/okhttp/3.x/okhttp/okhttp3/ConnectionPool.html)自动复用HTTP／1.x连接，多路复用HTT／2和SPDY的连接。
 &emsp;&emsp;在OKHttp，address的一些字段来源于URL（协议，主机名，端口），剩下的来自[OKHttpClient](http://square.github.io/okhttp/3.x/okhttp/okhttp3/OkHttpClient.html)。
 #### Routes
 &emsp;&emsp;Route提供了连接服务器必要的动态信息。包括，具体的IP地址（通过DNS查询），具体使用那个代理（[ProxySelector](http://developer.android.com/reference/java/net/ProxySelector.html)），协n哪个TLS版本（HTTPS).
 &emsp;&emsp;一个服务器可能有多条路有信息。例如：多台服务器部署在多个数据中心，DNS查询返回多个IP地址。
 #### Connections
 &emsp;&emsp;当发起一个URL的请求的时候：
   1. 使用URL和OKHttpCLient确定具体的**Address**。这个地址明确如何连接服务器。
   2. 尝试从**连接池**中查找具体Address的连接。
   3. 如果未找到有效的连接，使用Route来尝试获取。一般这样意味着通过DNS或去IP地址。然后，如果需要，选择一个TLS的版本和代理服务器。
   4. 如果是一个新的Route，要么使用Socket直连，TLS隧道（HTTS方式），或者直接使用TLS。也会进行必要的TLS握手。
   5. 发送请求，接受响应。
 &emsp;&emsp;如果连接发生错误，OKHttp会选择另一个路由重试。这样OKHttp就可以在服务器端一些地址无法访问的时候恢复访问。同时如果连接池的连接失效或者常识的TLS 版本不支持也很有用。
 &emsp;&emsp;当响应接收到了之后，连接会放回到连接池以便之后使用。连接在一段时间过期后回被移除连接池。

