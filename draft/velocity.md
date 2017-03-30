title: velocity 用户指南
date: 2017-03-30 19:55:20
tags:
    - velocity
    - Java
---
[原文链接](http://velocity.apache.org/engine/devel/user-guide.html)

#### 关于此指南
&emsp;&emsp; 这篇指南主要是帮助网页设计师和内容提供商熟悉Velocity和语法简单，但是很强大的Velocity模板语言（VTL）。在这篇指南的很多示例通过使用Velocity向网站中嵌入内容，但是VTL的例子同样适用于其他网页和模板。
&emsp;&emsp; 谢谢选择Velocity。
#### Velocity 是什么
&emsp;&emsp; Velocity是一个基于Java的模板引擎。它允许网页设计师引用在Java中定义的方法。通过MVC的设计模式，网页设计师可以和Java程序员同时开发网站，这意味着设计师可以专注于创作精心设计的网页，程序员也可以专注写一流的代码。Velocity从web页面中分离了Java代码，使得Web站在运行很长时间后仍然很容易维护，同时也提供了 JSP或者PHP的另一种选择。
&emsp;&emsp;Velocity可以用来生成页面，SQL，PostScript和其他可以由模板输出的的东西。它既可以作为生成源码和报表单独使用，也可以和其他系统集成。当完成的时候Velocity将会为turbine web框架提供模板服务。通过使用Velocity+Turbine可以让开发者使用真正的MVC开发模式。

