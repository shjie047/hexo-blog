title: OKHttp https
date: 2017-03-23 13:32:29
tags:
    - Translate
    - Java
    - OKHttp
    - HTTP
---

[原文链接](https://github.com/square/okhttp/wiki/HTTPS)

&emsp;&emsp;OKHttp尝试平衡两个相互矛盾的内容：
 * 连接尽可能多的主机。包括使用[boringssl](https://boringssl.googlesource.com/boringssl/)的高级的主机和一些使用[openssl](https://www.openssl.org/)的过时的主机。
 * 连接的安全性。包括验证远程主机的证书，通过强密码进行数据交换。

&emsp;&emsp;协商连接到HTTPS的时候，OKHttp需要知道需要提供的[TLS版本](http://square.github.io/okhttp/3.x/okhttp/okhttp3/TlsVersion.html)和[密码套件](http://square.github.io/okhttp/3.x/okhttp/okhttp3/CipherSuite.html)。如果一个客户端需要最大化链接就需要包含过时的TLS版本和弱设计的密码组合。一个严格的客户端想要最大化安全就需要只包含最新的TLS版本和强密码套件。
&emsp;&emsp;安全和连接规范具体是由[ConnectionSpec](http://square.github.io/okhttp/3.x/okhttp/okhttp3/ConnectionSpec.html)实现的。OKHttp包含三个内置的规范：
 * `MODERN_TLS` 是连接现代HTTPS服务器的配置。
 * `COMPATIBLE_TLS` 是连接非现代，但安全的HTTPS服务器的配置。
 * `CLEARTEXT` 是非安全的http的配置。

&emsp;&emsp;默认OKHttp会尝试使用`MODERN_TLS`连接，如果现代配置失败，回到使用`COMPATIBLE_TLS`配置。
&emsp;&emsp;TLS版本和密码套件在任一一个发布版本的人一个规范中都可能改变。例如，在OKHttp2.2，因为[POODLE](http://googleonlinesecurity.blogspot.ca/2014/10/this-poodle-bites-exploiting-ssl-30.html)攻击就移除了SSL 3.0的支持。在OKHttp 3.0，移除了[RC4](http://en.wikipedia.org/wiki/RC4#Security)的支持。同桌面浏览器一样，使用罪行的OKHttp版本可以获得最好的安全保障。
&emsp;&emsp;也可以根据一组定制的TLS 版本和密码套件构建自己的规范。例如，下面这个配置要求使用三组高强度的密码套件。它的缺点就是必须是Android5.0+或者是最新的浏览器。
```
ConnectionSpec spec = new ConnectionSpec.Builder(ConnectionSpec.MODERN_TLS)  
    .tlsVersions(TlsVersion.TLS_1_2)
    .cipherSuites(
          CipherSuite.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
          CipherSuite.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
          CipherSuite.TLS_DHE_RSA_WITH_AES_128_GCM_SHA256)
    .build();

OkHttpClient client = new OkHttpClient.Builder() 
    .connectionSpecs(Collections.singletonList(spec))
    .build();
```
#### 证书锁定
&emsp;&emsp;默认情况下OKHttp信任主机平台的证书颁发机构。这个策略可以最大化连接，但是也有可能收到权威证书攻击，例如[2011 DigiNotar attack](http://www.computerworld.com/article/2510951/cybercrime-hacking/hackers-spied-on-300-000-iranians-using-fake-google-certificate.html)。同样也假设你的证书是权威机构颁发的。
&emsp;&emsp;使用[CertificatePinner](http://square.github.io/okhttp/3.x/okhttp/okhttp3/CertificatePinner.html)限制了哪些证书和证书颁发机构值得信任。使用证书锁定可以提高安全性，但是限制了服务端团队升级他们的TLS证书。**在没的到服务端团队的许可的时候不要使用证书锁定**。
```
  public CertificatePinning() {
    client = new OkHttpClient.Builder()
        .certificatePinner(new CertificatePinner.Builder()
            .add("publicobject.com", "sha256/afwiKY3RxoMmLkuRW1l7QsPZTJPwDS2pdDROQjXw8ig=")
            .build())
        .build();
  }

  public void run() throws Exception {
    Request request = new Request.Builder()
        .url("https://publicobject.com/robots.txt")
        .build();

    Response response = client.newCall(request).execute();
    if (!response.isSuccessful()) throw new IOException("Unexpected code " + response);

    for (Certificate certificate : response.handshake().peerCertificates()) {
      System.out.println(CertificatePinner.pin(certificate));
    }
  }
```
#### 定制信任证书
&emsp;&emsp;下面所有的代码展示了如何使用你自己的配置代替服务端的证书配置。正如上述所言，**在没的到服务端团队的许可的时候不要使用定制证书*。
```
  private final OkHttpClient client;

  public CustomTrust() {
    SSLContext sslContext = sslContextForTrustedCertificates(trustedCertificatesInputStream());
    client = new OkHttpClient.Builder()
        .sslSocketFactory(sslContext.getSocketFactory())
        .build();
  }

  public void run() throws Exception {
    Request request = new Request.Builder()
        .url("https://publicobject.com/helloworld.txt")
        .build();

    Response response = client.newCall(request).execute();
    System.out.println(response.body().string());
  }

  private InputStream trustedCertificatesInputStream() {
    ... // Full source omitted. See sample.
  }

  public SSLContext sslContextForTrustedCertificates(InputStream in) {
    ... // Full source omitted. See sample.
  }
```