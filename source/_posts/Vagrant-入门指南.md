title: Vagrant 入门指南
date: 2015-11-06 16:49:47
tags:
  - Vagrant 
  - Translate
---
[原文地址](https://docs.vagrantup.com/v2/getting-started/index.html)
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

## 项目配置

&emsp;&emsp; 任何Vagrant项目配置的第一步都是创建一个[Vagrantfile](https://docs.vagrantup.com/v2/vagrantfile/)。该文件的作用有两个:  
1. 指定项目的根目录。很多Vagrant的配置跟这个目录有关。  
2. 描述项目所需要的机器类型和资源，以及如何安装软件，如何访问。  

&emsp;&emsp; Vagrant 有一个内建的命令`vagrant init`用来初始化项目。出于本指南的目的，请在终端输入一下命令  

```
$ mkdir vagrant_getting_started
$ cd vagrant_getting_started
$ vagrant init
```

&emsp;&emsp; 以上命令将在你的当前目录下创建`Vagrantfile`。查看Vagrantfile会发现里面有各种注释和示例。不要因为他负责而感到恐惧，我们很快就能够修改它了。  
&emsp;&emsp; 同样也可以在一个已存在的目录下运行`vagrant init`，来未一个已有项目设置Vagrant环境。
&emsp;&emsp; 如果你使用版本控制工具，那么Vagrantfile可以提交到版本库中。这样其他与这个项目相关的人就可以无需前期工作了。

## Boxes

&emsp;&emsp; 由于从头构建一个虚拟机是一个费时的过程，所以Vagrant使用一个基本镜像来快速克隆一个虚拟机。这些基本镜像再Vagrant中被称作boxes，而且在创建玩Vagrantfile后的第一步就是为你的Vagrant环境指定一个box。  

###  安装box

&emsp;&emsp; 如果你运行了[开始指南](https://docs.vagrantup.com/v2/getting-started/)的命令，那么你已经在本机安装了一个box，你就不需要再次运行一下命令了。但是这部分仍然是值得阅读的，这样你就可以了解更多关于如何管理box的知识。  
&emsp;&emsp; Boxes 由Vagrant的`vagrant box add`命令添加。这个将box存储在一个指定命名的目录下，这个多个Vagrant的环境可以重复利用。如果你还未添加已给box，那么可以运行一下命令。  

```
$ vagrant box add hashicorp/precise32
```

&emsp;&emsp; 这个将从[HashiCorp's Atlas box catalog](https://atlas.hashicorp.com/boxes/search)下载一个名字为`hashicorp/precise32`的box。你可以从HashiCorp's Atlas box catalog中找到各种box。很容易从HashiCorp's Atlas 下载镜像，同时你也可以通过本地文件，其他URL等添加。
&emsp;&emsp; 已添加的boxes可以被多个环境重复利用。每个环境都是将其作为基础镜像克隆，而不会修改他。这就意味着两个环境同时使用了刚刚添加的`hashicorp/precise32`的box，其中一个主机添加文件并不会影响另一个主机。  

### 使用box

&emsp;&emsp; 现在已经吧box添加到Vagrant了，我们就可以把他作为一个基础镜像使用了。打开Vagrantfile，修改一下代码:

```
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise32"
end
```
&emsp;&emsp; 在这个例子中，"hashicorp/precise32" 的名字必须跟你add box的名字相同。这是Vagrant知道box如何用的方式。如果这个box没有被安装过，那么Vagrant将会自动下载并且当它运行的时候自动添加。  
&emsp;&emsp; 在下一节中我们将启动Vagrant并且与其进行交互。  

### 寻找更多box

&emsp;&emsp; 在本入门指南的后半部分，我们只会使用之前添加的"hashicorp/precise32"的box。但是，结束本指南的时候你的第一个问题可能就是我从南找到更多的box。  
&emsp;&emsp; 寻找更多box的最好的地方是[HashiCorp's Atlas box catalog](https://atlas.hashicorp.com/boxes/search)。HashiCopr 的Altas有一个公共目录，在目录里可以找到各种免费的，可以运行各种平台和技术的box。  
&emsp;&emsp; HashiCorp的Altas同样也有一个很棒的搜索功能，这样就可以更方便的找到需要的box。  
&emsp;&emsp; 除了寻找免费的box外，HashiCorp的Altas还允许你构建自己的box，以及如果你想为自己的组织创建私有box。  

## 启动并且SSH登陆

&emsp;&emsp; 是时候启动你第一个Vagrant环境了。运行一下命令:  

```
vagrant up
```

&emsp;&emsp; 1分钟之内，这个命令运行完后，你就可以得到一个运行Ubuntu的虚拟机了。由于Vagrant运行虚拟机的时候没有UI，所以你不会看到任何输出。你可以SSH登陆到虚拟机来验证虚拟机是否运行：

```
vagrant ssh
```

&emsp;&emsp; 运行完这个命令后你就会进入ssh会话中。继续和机器交互，做任何你想做的事情。虽然是临时的虚拟机，但是还是要小心`rm -rf /` 这种命令，因为Vagrant的`/vagrant`目录与宿主机器共享了包含Vagrantfile的目录，如果运行了会删除所有的文件的。共享目录将会在下节描述。  
&emsp;&emsp; 花一点时间思考一下刚刚发生的事情：通过仅仅1行配置和1行命令，我们就启动了一个功能完整的，可以ssh登陆的虚拟机，太酷了。  
&emsp;&emsp; 当你用完虚拟机的时候，你可以在主机上使用`vagrant destory`来清除你再虚拟机的痕迹。

## 同步文件夹

&emsp;&emsp;虽然这么容易就可以启动一个虚拟机是很爽，但是并不是所有的人都喜欢通过ssh登陆终端修改文件。幸运的是，通过Vagrant，你并不是必须这么做的。通过使用*同步文件夹*Vagrant将会自动的将文件从虚拟机同步或者同步到虚拟机中。  
&emsp;&emsp; 默认情况下，Vagrant是共享你的项目目录（记住，这个是你Vagrantfile所在的目录）到虚拟机的`/vagrant`的。再次运行`vagrant up` 并且ssh到虚拟机。

```
$ vagrant up
...
$ vagrant ssh
...
vagrant@precise32:~$ ls /vagrant
Vagrantfile
```

&emsp;&emsp; 不管相不相信，在虚拟机的这个Vagrantfile和再宿主机上的那个Vagrantfile是同一个。继续创建一个文件证明一下：

```
vagrant@precise32:~$ touch /vagrant/foo
vagrant@precise32:~$ exit
$ ls
foo Vagrantfile
```

&emsp;&emsp; 哇！`foo`已经在你的宿主机里创建了。正如你所见，Vagrant会保持那个文件夹的同步。  
&emsp;&emsp; 通过使用[同步文件夹](https://docs.vagrantup.com/v2/synced-folders/)，你可以继续在你的主机上使用你喜欢的编辑器，文件会自动的同步到虚拟机上的。

## 配置

&emsp;&emsp; 现在我们已经在虚拟机上运行了一份Ubuntu的拷贝，并且我们还可以从宿主机上编辑文件同时同步到虚拟机中。现在让我们通过webserver来提供这些文件。  
&emsp;&emsp; 我们可以SSH到虚拟机然后安装webserver然后提供这些文件，但是这样做，每一个用Vagrant的用户都需要重复相同的事情。不过Vagrant内建提供了自动配置的功能。使用这个功能，Vagrant可以在你`vagrant up`的时候自动安装软件，这样虚拟机就可以被重复创建并且可以直接使用了。  

### 安装Apache

&emsp;&emsp; 对于我们的项目来说可以仅仅使用[Apache](http://httpd.apache.org/)，并且我们是通过一个shell脚本创建的。再Vagrantfile相同的目录下创建一个名字为`bootstrap.sh`的文件。  

```
#!/usr/bin/env bash

apt-get update
apt-get install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi 
```

&emsp;&emsp; 然后，我们需要配置Vagrant，让它在启动的时候运行这个脚本。我们通过修改Vagrantfile来实现这一功能，具体修改如下:

```
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise32"
  config.vm.provision :shell, path: "bootstrap.sh"
end
```

&emsp;&emsp; “provision”这一行是新添加的，告诉Vagrant使用`shell`配置器运行`bootstrap.sh`脚本启动机器。脚本的路径是项目更目录的相对路径。

### 配置

&emsp;&emsp; 在所有的事情都配置好好，运行`vagrant up`来创建机器，Vagrant将会自动的配置它。运行的时候你会在终端看到shell脚本的输出。如果虚拟机已经开始运行了，运行`vagrant reload --provision`, 这个命令可以快速重启虚拟机并且跳过初始的导入步骤。`--provision`表示Vagrant需要运行配置，因为通常Vagrant只运行第一步。
&emsp;&emsp; 当Vagrant完全运行起来的时候，web server同时也启动了。现在还不都能通过宿主机的浏览器看到，但是可以通过ssh到虚拟机进行验证。

```
$ vagrant ssh
...
vagrant@precise32:~$ wget -qO- 127.0.0.1
```

&emsp;&emsp; 这个可以运行成功，因为我们我们已经安装了Apache服务器并且设置默认的`DocumentRoot`指向了`/vagrant`。
&emsp;&emsp; 你可以继续的创建文件，同时再终端里面验证，不过下一节我们将会讲述网络的相关知识，这样你就可以再本机的浏览器验证了。

## 网络

&emsp;&emsp; 目前为止我们运行了一个web server，并且可以再宿主机器上修改，同时自动同步到虚拟机中。然而，简单的从虚拟机的终端访问网页并不方便。在这一节中我们将使用Vagrant的网络特性，这样就可以方便的从宿主机器访问虚拟机了。

### 端口转发

&emsp;&emsp; 一个方法是使用端口转发功能。端口转发允许你指定虚拟机的一个端口跟宿主机的一个端口共享。这样你就可以在宿主机访问宿主机的端口，但是都会转发到虚拟机中。
&emsp;&emsp; 现在我们配置端口来访问虚拟机的Apache服务。修改Vagrantfile如下：

```
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise32"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network :forwarded_port, guest: 80, host: 4567
end
```

&emsp;&emsp; 运行`vagrant reload`，或者如果没有启动过虚拟机运行`vagrant up`。使配置生效。

### 其他的网络配置

&emsp;&emsp; Vagrant也有其他的网络配置，允许你给虚拟机配置固定ip，或者是桥接两台虚拟机。如果你对其感兴趣，可以阅读[networking](https://docs.vagrantup.com/v2/networking/)章节。

## 共享

&emsp;&emsp; 现在我们已经有了一台可运行的服务器，并且可以从本机直接访问，我们构建了一个相当实用的开发环境。但是，除了提供一个开发环境，Vagrant还可以很容易的和其他环境分享和合作。这个主要的功能叫做[Vagrant Share](https://docs.vagrantup.com/v2/share/)。
&emsp;&emsp; Vagrant Share运行你把你的Vagrant环境分享你世界上的每一个人。它将分配给你一个URL，这样世界上任何一台机器都可以实用你的环境了。

### 登录Harshicorp's Altas

&emsp;&emsp; 在分享你的Vagrant环境之前，你需要一个[HashiCorp's Altas](https://atlas.hashicorp.com/)的账号。不必担心，它是免费的。
&emsp;&emsp; 当你有了账号后，你就可以使用`vagrant login`来登陆

```
$ vagrant login
Username or Email: mitchellh
Password (will be hidden):
You're now logged in!
```

### 共享

&emsp;&emsp; 当你登录之后，你就可以使用`vagrant share`来共享环境了。

```
$ vagrant share
...
==> default: Your Vagrant Share is running!
==> default: URL: http://frosty-weasel-0857.vagrantshare.com
...
```

&emsp;&emsp; 你的URL会是不同的，无需上面的URL。复制上面`vagrant share`生成的url到你的浏览器，你会看到我们已经做好的Apache的页面。
&emsp;&emsp; 如果你在共享目录中改动了某个文件，重新刷新URL，你会看到已经更新了。这个URL直接路由到你的Vagrant环境，并且可以直接再世界上任何一台联网的机器上访问。
&emsp;&emsp; 关闭共享只需要使用`Ctrl+C`即可，重新刷新URL，你会发现你的环境已经不再被共享了。
&emsp;&emsp; Vagrant Share比简单的HTTP share 更强大，想要了解更多可以阅读完整的[Vagrant Share](https://docs.vagrantup.com/v2/share/)文档。

## 关闭

&emsp;&emsp; 现在我们已经有一个开发web的基本环境。但是，现在是时候说一下开关了，可能是在运行其他的项目的时候使用，或者是吃午饭的时候使用，或者只是回家的时候。我们应该如何清理我们的开发环境。
&emsp;&emsp; 通过Vagrant，我们可以*suspend*,*halt*或者*destory*虚拟机。每一个都有他们的优缺点，选择最适合你的那个。  
* **suspend** 使用`vagrant suspend`命令，保存当前运行环境并停止。当你想要继续运行的时候可以使用`vagrant up`命令，它会从你上次suspend中恢复。这个命令主要好处是速度非常快，通常关闭，启动都在5到10秒之间。缺点是虚拟机仍然会使用你的硬盘，并且在存储所有的状态的时候需要更大的硬盘。  
* **halting** 使用`vagrant halt`命令实现优雅的关闭虚拟机的操作系统并关闭虚拟机。在你想要使用的时候再次运行`vagrant up`命令启动。这个的好处是可以完全的关闭虚拟机并保留使用的硬盘资源，再下次启动的时候会是一个干净的虚拟机。缺点是冷启动的时候会慢一点，并且仍然会使用硬盘空间。
* **destory** 使用`vagrant destory`命令，将会清楚虚拟机所有的痕迹。它将会停止操作系统，关闭虚拟机，并且清除所使用的磁盘空间。下次使用`vagrant up`的时候会出现问题。好处是不会有任何的残留在你机器上，同事磁盘空间和RAM都会还给本机。坏处是`vagrant up`将会从头开始，这样会花费更长的时间。

## 重新构建

&emsp;&emsp; 当你想重新使用虚拟机的时候，不管是是明天，一周之后，或者是一年之后，都可以通过`vagrant up`来轻松运行他。
&emsp;&emsp; 只需要这样。而且由于你的Vagrant都再Vagrantfile里面配置的，所有你或者你的同事只需要简单的运行`vagrant up`即可重新创建相同的环境。

### Provider

&emsp;&emsp; 在本指南开始的时候，我们的项目一直支持[VirtualBox][1]。但是Vagrant可以与多个后端Provider一起使用，例如[VMware](https://docs.vagrantup.com/v2/vmware/),[AWS](http://github.com/mitchellh/vagrant-aws)等。继续阅读来了解如何它们的更多信息以及如何使用它们。
&emsp;&emsp; 当你安装了其他的Provider的时候,你不需要更改你的Vagrantfile，只需要在启动的时候加个参数即可：

```
$ vagrant up --provider=vmware_fusion
```

准备转移到云端了？使用AWS：

```
$ vagrant up --provider=aws
```

&emsp;&emsp; 当你使用其他Provider运行`vagrant up`的时候，其他的Vagrant命令不行也要指定Provider。Vagrant将会自动的计算出来。所以当你ssh,destory的或者运行其他命令的时候，只需要输入平时的命令即可，例如：`vagrant destory`，无需额外的参数。
&emsp;&emsp; 更多信息请参考[provider](https://docs.vagrantup.com/v2/providers/)。
[1]: https://www.virtualbox.org/


