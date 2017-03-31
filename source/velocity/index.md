title: velocity 用户指南 -- 简介
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
#### Velocity 可以为我做什么
#####　一个泥土店的例子
&emsp;&emsp;假设你是一个为专门卖泥土的店设计网上商店的设计师。暂且叫作“泥土网店”。店铺生意兴旺。客户订购了各种各样的大量泥浆。他们通过使用用户名和密码来登录网站，浏览订单，购买更多的泥浆。现在非常流行的赤陶土泥正在开卖，少数顾客购买了同样买卖的明亮的红色的泥，这个没有那么流行，所以就放到了网页边缘。顾客的信息记录在数据库中，那么问题来了，为什么不使用Velocity直接给那些喜欢不同泥土的客户推送他们感兴趣的泥土呢？  
&emsp;&emsp;Velocity可以很容易的为你的用户定制页面。作为泥土屋的网页设计师，你希望用户登录之后就可以看到他们想要的页面。  
&emsp;&emsp;你在公司见到了开发人员，并且每个人都同意使用`$customer `来保持用户登录之后用户的相关信息，使用`$mudsOnSpecial`来表示当前正在买的泥土的所有类型。`$flogger`对象包含了用来推广的方法。对现在手头上的任务，我们只需要关心这三个引用。记住，你不需要考虑程序员如何从数据库取得这些信息，你只需要知道，他可以工作就可以了。这样你就可以专注于自己的工作，程序员也可以专注于自己的工作。
&emsp;&emsp;下面这个例子可能就是你要嵌入网页的的VTL的语句    
```
<html>
  <body>
    Hello $customer.Name!
    <table>
    #foreach( $mud in $mudsOnSpecial )
      #if ( $customer.hasPurchased($mud) )
        <tr>
          <td>
            $flogger.getPromo( $mud )
          </td>
        </tr>
      #end
    #end
    </table>
  </body>
</html>
```
&emsp;&emsp;`foreach`的细节稍后会进行深入的描述；现在重要的是这段脚本对你网页的影响。当一个喜欢明亮红土的人登录网站，将会看到明亮的红土突出显示在网页中售卖。当一个一直购买赤陶土泥的用户登录的时候他将会看见赤陶土泥正在网页的中央。Velocity的潜力和限制只和你的创造力相关。
&emsp;&emsp;VTL文档中还有很多其他的Velocity的元素，这些元素可以让你更加轻松的设计网页。当你熟悉了这些元素之后就会释放Velocity所有的强大的能力。