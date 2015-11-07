title: 'Vagrant & Ansible 快速入门教程'
date: 2015-11-08 00:39:10
tags:
  - Ansible
  - Translate
  - Vagrant
---

[原文地址](https://adamcod.es/2014/09/23/vagrant-ansible-quickstart-tutorial.html)  

&emsp;&emsp; 就个人而言，我用过Chef，Puppet，简单的Bash脚本等用来配置服务器，其他服务和Vagrant Boxes。虽然Chef社区仍然在快速成长，但是我发布的关于[Chef](https://adamcod.es/2013/01/15/vagrant-is-easy-chef-is-hard-part2.html)的文章仍然是最受欢迎的文章。然而，两个月之前，当我在一个项目中使用Ansible的时候所有的事情都变了。从此之后我再也没用过其他的配置工具，也找不到用其他工具的理由了。  
&emsp;&emsp; 看过了不少关于Ansible的教程，尝试这从中找出相应的模式和最佳实战，然而似乎在知识上有巨大的横沟。你可以用Ansible做很多事情，你也可以同时学习如何使用，但是跟我最新学习的工具一样，却反一个很简单地方入手学习的地方。今天我希望通过使用Vagrant和Ansible配置一个LAMP的技术栈来纠正他。  

## 为什么使用Ansible

&emsp;&emsp; Ansible和其他的配置管理工具最主要的区别就是Ansible是基于SSH的。Chef和Puppet都是有依赖的，而且必须在服务器上安装之后才能使用，而Ansible则不需要。它可以在你本机运行，使用SSH连接相应主机，在其运行相应命令。  
&emsp;&emsp; 为什么不直接使用Bash脚本呢？Ansible之所以比Bash脚本好是因为他简单。Ansible只是运行了一系列使用YAML格式编写的任务。同样Ansible还具有幂等性，这就意味着你可以多次运行同样的任务，并且这些任务的输入会保持一致（例如除非明确要求运行两次否则它不会对同一个任务运行两次）。同样这个可以通过Bash脚本编写，但是会很复杂。

## Ansible 和 Vagrant

&emsp;&emsp; 首先给你要确定已经安装了Ansible和Vagrant。它们的安装文档可以在它们的相关网站找到，它们都很容易安装的。

## 基础

&emsp;&emsp; 我们将会创建一个新的文件夹来开始我们的项目。

```
mkdir -p ~/Projects/vagrant-ansible
cd ~/Projects/vagrant-ansible
```

&emsp;&emsp; 接着我们创建一个基于最新的Ubuntu的Vagrantfile。

```
vagrant init ubuntu/trusty64
```

&emsp;&emsp; 运行完这个命令后在项目目录下会有一个叫`Vagrantfile`的文件。它包含了你想要配置的关于box的一些基本信息和一堆你现在不需要管的注释。删除所有的注释，你就会简单的得到以下的代码：

```
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
end
```

&emsp;&emsp; 我们需要在他配置好的适合访问服务器，所以我们将会吧Vagrant的80端口转发到本机的8080端口，将以下代码添加到`end`之前。

```
config.vm.network "forworded_port", guest: 80, host:8080
```

&emsp;&emsp; 现在Vagrant只需要配置一件事情。我们需要配置Vagrant使用Ansible作为配置器，并且知道去哪里需找这些命令。为了实现这个目的，我们将一下代码加到`Vagrantfile`的`end`之前。

```
config.vm.provision :ansible do |ansible|
  ansible.playbook = "playbook.yml"
end
```

&emsp;&emsp; 以上所有的任务完成之后你的`Vagrantfile`将会是一下的配置。  

```
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.provision :ansible do |ansible|
    ansible.playbook = "playbook.yml"
  end
end
```

## 基本术语

&emsp;&emsp; Ansible再你的服务器上运行一系列的*Tasks*。把Task想象成一个单一的Bash命令。接着是*playbook*，Ansible通过Playbook得知将再服务器上运行什么任务。每一个Task运行一个Ansible的*Module*，Module是Ansible内建的各种命令，例如yun，创建用户等。稍后就会明白这些术语的具体意思。  

## 第一个Playbook

&emsp;&emsp; 创建一个叫`playbook.yml`的文件，这个名字必须和`Vagrantfile`的`ansible.playbook`相同。
&emsp;&emsp; 所有Ansible的Playbook都必须是YAML格式的。传统上YAML文件是以三条横线开头的，但是Ansible并不是强制要求的，不过社区仍然会遵循这个规则。  
&emsp;&emsp; 新建的playbook是一个YAML的列表。这个列表应该包括要管理的host和各种要运行的task，将以下代码添加到`playbook.yml`文件中。

```
---
- host: all
  sudo: true
  tasks:
```

&emsp;&emsp; 我们使用Vagrant并且只有一台主机，所以我们可以使用一个魔法值`all`，意思是在所有的机器上运行任务。然后我们告诉Ansible运行是需要sudo权限，最后我们添加了 `tasks:` 用来添加Task。

&emsp;&emsp; 要安装LAMP技术栈的基本步骤是：  
1. 更新 Apt Cache
2. 安装 Apache
3. 安装 MySQL
4. 安装 PHP

&emsp;&emsp; 这就是所有我们必须的步骤。因为我们用的是Ubuntu的box，所有我们需要Ansible的apt模块。
&emsp;&emsp; 首先我们给每一个task一个`name:`，这个可以是任何描述，它用来描述这个任务，如下:

```
- name: this should be some descriptive text
```

&emsp;&emsp; 接着我们指定一个Ansible的模块作为值，在本例中使用的是apt模块。

```
apt
```

&emsp;&emsp; 紧随其后的是一些`key=value`的由空格分隔的键值对。选择你想要传递给Ansible的键值对，可以通过Ansible的文档来查询所需要的键值对。

&emsp;&emsp; 安装Apache的任务如下：

```
- name: install apache
  apt: name=apache2 state=present
```

&emsp;&emsp; 这样就配置好了，很简单，对吧。我们将继续添加MySQL和PHP的Task到`playbook.yml`中，最后代码如下：

```
---
- hosts: all
  sudo: true
  tasks:
    - name: update apt cache
      apt: update_cache=yes
    - name: install apache
      apt: name=apache2 state=present
    - name: install mysql
      apt: name=mysql-server state=present
    - name: install php
      apt: name=php5 state=present
```

&emsp;&emsp; 现在我们已经配置完了，然后运行`vagrant up`，你将会看到如下图所示：
![result](https://adamcod.es/img/posts/vagrant-ansible-lamp.gif)  

&emsp;&emsp; 这样就搭建好了。如果你想让LAMP运行起来，你就可以ssh到Vagrant，然后将`info.php`文件添加到`/var/www/html`下。
```
<?php phpinfo();?>
```

&emsp;&emsp; 然后在本机浏览器打开http://localhost:8080/info.php，就会看到你想要看到的。

**翻译到此，剩下的就是关于Ansible的使用了，这些可以通过Ansible的官方文档来学习**

