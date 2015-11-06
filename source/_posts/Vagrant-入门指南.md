title: Vagrant 入门指南
date: 2015-11-06 16:49:47
tags:
  - Vagrant 
  - Translate
---

## 开始

&emsp;&emsp;Vagrant 入门指南将会引导你完成你的第一个Vagrant项目，并且会向你展示Vagrant提供的基本的特色功能。  
&emsp;&emsp;如果你好奇Vagrant提供了什么好的功能，你可以阅读一下[Why Vagrant](https://docs.vagrantup.com/v2/why-vagrant/)。  
&emsp;&emsp;这篇入门指南将会基于[VirtualBox][1]来使用Vagrant，因为它免费，支持主流平台，并且Vagrant内建支持。当你完成这篇指南的时候，可以参考更多的[提供商](https://docs.vagrantup.com/v2/getting-started/providers.html)

> 更喜欢读书？如果你更喜欢读实体书，那么你可能对由Vagrant作者编写，O'Reilly 出版的[Vagrant: Up and Running](http://www.amazon.com/gp/product/1449335837/ref=as_li_qf_sp_asin_il_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1449335837&linkCode=as2&tag=vagrant-20) 更感兴趣，

## 启动运行

```
$ vagrant init hashicorp/precise32
$ vagrant up
```

&emsp;&emsp;运行了上面两个命令之后，会得到一个运行在[VirtualBox][1]虚拟机上的Ubuntu 12.04 LTS 32-bit。你可以通过`vagrant ssh` 以ssh的方式登陆，当你王城所有的操作的时候，也可以使用`vagrant destory`来删除所有的痕迹。  
&emsp;&emsp;现在想象 一下，以前你所有工作过的项目，都可以通过这个简单的方式来设置了。    
&emsp;&emsp;通过使用Vagrant,对于任何项目来说`vagrant up` 是你唯一需要你用到的命令，例如，安装项目依赖，设置网络和同步文件夹，仍然可以很舒服的使用本机系统。    
&emsp;&emsp;指南剩下的内容将会引导你设置更复杂的项目，涵盖跟多的Vagrant的特色。  

[1]: https://www.virtualbox.org/


