title: Ansible 入门指南
date: 2015-11-09 18:26:35
tags:
  - Ansible
  - Translate
---

[原文地址](http://docs.ansible.com/ansible/intro_getting_started.html)

## 快速入门

### 前言

&emsp;&emsp; 现在你已经知道如何[安装](http://docs.ansible.com/ansible/intro_installation.html)Ansible了，现在可以深入并开始使用Ansible的一些命令了。
&emsp;&emsp; 我们开始展示的并不是Ansible强大的配置、部署、调度的功能。这些功能由其他章节要讲的Playbook来处理。
&emsp;&emsp; 这个章节是关于如何快速入门的。等你了解了Ansible的这些概念之后，就可以阅读[特别命令简介](http://docs.ansible.com/ansible/intro_adhoc.html)来学习更多细节，接着你就可以深入理解Playbook，并且浏览更多的有趣功能。

### 远程连接信息

&emsp;&emsp; 在我们开始学习之前，理解Ansible是如何通过SSH连接到远程服务器是很重要的。
&emsp;&emsp; 默认情况下，如果可以，Ansible 1.3 及其后续版本会使用原生的OpenSSh来连接远程服务器。这样就可以在~/.ssh/config下开启ControPersist(一个高性能的功能),Kerbos和其他选项，例如跳板机设置。然后，如果使用了Enterprise Linux 6(Red Hat Enterprise Linux 和其衍生版本，例如CentOS) 系统作为控制机，OpenSSH的版本可能过低导致无法开启ControlPersist功能。在这些操作系统中，Ansible将会回退到使用“paramiko”，他是OpenSSH的一个高质量的Python实现。如果你想使用像Kerberized SSH 等这样的功能，那么可以使用Federa，OSX或者Ubuntu作为你的控制机，直到你使用的平台有了更新的OpenSSH，或者你可以开启加速功能。[加速功能](http://docs.ansible.com/ansible/playbooks_acceleration.html)。
&emsp;&emsp; 如果使用的版本小于等于1.2，那么默认使用的就是paramiko，如果想要使用原生的SSH，那么需要加上-c ssh 选项或者再配置文件中配置。
&emsp;&emsp; 可能偶尔在某些机器上不支持SFTP协议，虽然这种情况很少，但是也可能发生，这个时候可以在[配置文件](http://docs.ansible.com/ansible/intro_configuration.html)中切换到SCP模式。
&emsp;&emsp; 当需要和远程主机会话是，Ansible默认假设你使用SSH keys。Ansible鼓励使用SSH 免密码登陆，但是使用密码登陆也是可以的，在使用的时候加上参数`--ask-pass`。如果需要使用sudo权限，那么也要提供`--ask-sudo-pass`参数。
&emsp;&emsp; 任何管理系统运行时离被管理的系统越近越好。虽然这是个常识，但是还是值得分享的。如果你在云端使用Ansible，那么就把Ansible运行在云端。在大多数情况下，它都比直接在公共网络上运行更好。
&emsp;&emsp; 作为一个高级话题，Ansible并不仅仅通过SSH连接主机。连接系统是可插拔的，有很多配置选项可以用来本地管理，例如管理chroot，lxc，jail container。一个叫做“Ansible-pull”的模式可以反转系统。通过配置好的git checkout 从中央存储库pull配置文件获取系统的“phone home”。

### 第一个命令

&emsp;&emsp; 目前为止，已经安装好Ansible了，现在可以开始运行一些简单的命令了。
&emsp;&emsp; 编辑（或者创建）`/etc/ansible/hosts`文件，向其添加一个或者多个远程主机地址。本机的public ssh key 应该已经追加到远程主机的`authorized_keys`文件中。

```
192.168.1.50
aserver.example.org
bserver.example.org
```

&emsp;&emsp; 这是一个清单文件，同样会再[主机清单](http://docs.ansible.com/ansible/intro_inventory.html)中介绍。
&emsp;&emsp; 假设你使用的是SSH授权方式，设置ssh angent 防止重复输入密码。

```
ssh-agent bash
ssh-add ~/.ssh/id_rsa
```

(根据你的设置，你可能需要使用`--private-key`选项来制定一个pem文件)
&emsp;&emsp; 现在可以ping一下所有的主机了。

```
ansible all -m ping
```

&emsp;&emsp; Ansible会想SSH那样使用你本机的用户名去连接远程机器，如果不想使用本机用户名，可以加上`-u`的选项。
&emsp;&emsp; 如果你想使用sudo权限，同样也可以将上`--sudo`选项。

```
# as bruce
$ ansible all -m ping -u bruce
# as bruce sudoing to root
$ ansible all -m ping -u bruce --sudo
# as bruce, sudoing to batman
$ ansible all -m ping -u bruce --sudo --sudo-user batman

# With latest version of ansible `sudo` is deprecated so use become
# as bruce, sudoing to root
$ ansible all -m ping -u bruce -b
# as bruce, sudoing to batman
$ ansible all -m ping -u bruce -b --become-user batman
```

(如果你突然想改变sudo 用户，可以再配置文件中修改。传递给sudo的标记例如-H也可以在那修改。)

&emsp;&emsp; 现在在你所有的节点上运行一个实时的命令。

```
$ ansible all -a "/bin/echo hello"
```

&emsp;&emsp; 太棒了，刚刚通过Ansible与远程主机会话了。很快就可以阅读[更多命令介绍](http://docs.ansible.com/ansible/intro_adhoc.html)来学习更多的实际例子，浏览各个模块都可以做什么，以及学习Ansible [Playbooks](http://docs.ansible.com/ansible/playbooks.html)的语法。Ansible不仅仅只能用来运行命令，他还有强大的配置管理系统和部署功能。还有许多需要学习的知识，但是你现在已经有一个完全可以运行的环境了。

### 主机密钥检查

&emsp;&emsp; Ansible 1.2.1 及其之后的版本，默认是有主机密钥检查功能的。
&emsp;&emsp; 如果远程主机成新安装并且在`know_hosts`下有一个不同的key，直到修复之前，Ansible会一直返回错误。如果主机没有在`know_hosts`文件中，那么会出现提示来确认密钥。这样就会有一个你不希望的提示。
&emsp;&emps; 如果你知道这个功能的影响，并且希望关闭这个功能，可以修改`/etc/ansible/ansible.cfg`或者是`~/.ansible.cfg`来关闭这个功能。

```
[default]
host_key_checking = False
```

&emsp;&emsp; 同样也可以通过环境变量来修改。

```
$ export ANSIBLE_HOST_KEY_CHECKING=False
```

&emsp;&emsp; 同时要注意主机密钥检查再paramiko模式中是很慢的，所以如果要使用这个功能最好使用ssh模式。
&emsp;&emsp; 除非Ansible的任务被标记为"no_log:True"，否则Ansible会再远程注意的syslog中记录一些有用的信息。这个稍后再做解释。
&emsp;&emsp; 如果要再本机开启log可以查看[配置章节](http://docs.ansible.com/ansible/intro_configuration.html)来设置“log_path”开启。企业用户可能会对[Ansible Tower](http://docs.ansible.com/ansible/tower.html)。Tower提供了一个健壮的数据库记录日志的功能，这样就可以随时通过图形界面或者REST API 来查看主机，项目，特殊的列表的日志。
