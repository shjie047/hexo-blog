title: Git - 分支管理
date: 2017-03-24 11:32:02
tags:
  - Git
  - Git分支
  - Git分支原理
  - Git commit
---

### 分支概要(Nutshell)

&emsp;&emsp; 几乎每个版本管理系统（*VCS*）都对分支有一些支持。分支就是从开发的主线分开，在其他地方继续开发，这样不至于和主线的开发产生混乱。在大多的VCS工具里，分支管理是一个复杂的流程，经常需要你为源代码目录创建一份拷贝，对于一些大型项目这会花费大量时间。

&emsp;&emsp; 真正理解分支首先需要明白**Git**是如何存储数据的：**Git**不会储存不同的或变化的点，而是保存一个快照（snapshot）。

&emsp;&emsp; 当你提交一个commit，**Git**会存储一个commit对象，这个对象包含：
  - 指向当前内容的快照的引用（pointer）
  - 作者的姓名、邮件地址和提交的信息
  - 指向上一次提交的commit的引用 （如果上一次操作是多个分支的merge操作，那么会储存多个指向不同的commit的引用；如果当前提交是首次commit，因为没有上一次commit，所以不会存储任何指向上一次commit的引用；正常的commit，会储存一个指向上次commit的引用）

&emsp;&emsp; 视觉化地理解这个流程就是：假设你有一个包含三个文件的目录，添加（add操作）这三个文件后commit。添加文件时会为每个文件生成一个校验码(SHA-1 hash)，在**Git**的仓库(*repo*)存储文件的版本，同时添加校验码到添加的文件：
```
$ git add README test.rb LICENSE
$ git commit -m 'The initial commit of my project'
```

&emsp;&emsp; 当你执行`git commit`后提交这个commit，**Git**会校验和每个子目录（在这个case里，只有项目的根目录），同时在**Git repo**里存储这些树对象。Git之后会创建一个commit对象，这个对象包含元数据和一个指向根项目树的引用 -- 可以再次创建项目快照。

&emsp;&emsp; 你的**Git repo**现在包含5个对象：
  - 对应3个文件内容的3个二进制对象
  - 一个树对象，呈现目录的内容和详细说明文件名和二进制对象的对应关系
  - 一个commit对象，包含指向根树的引用，和commit对象的所有元数据

&emsp;&emsp; 如下图所示：

![Interceptors](https://git-scm.com/book/en/v2/images/commit-and-tree.png)

&emsp;&emsp; 如果文件做了变动，再次提交，这次提交会存储一个指向上一次提交的引用

![Interceptors](https://git-scm.com/book/en/v2/images/commits-and-parents.png)

&emsp;&emsp; **Git**的分支就是一个的简单的、轻量的、可移动的、指向这些个commit的引用。

