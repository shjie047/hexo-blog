title: Linux 如何查找Java 程序CPU负载过高
date: 2017-3-25 11:20:26
tags:
    - CPU
    - Java
    - Linux
---


&emsp;&emsp;准备程序：
```
package test;

public class Test{
    public static void main(String[] args){
        new Thread(new Runnable(){
            public void run(){
                while(true){

                }
            }
        }).start();
    }
}
```
&emsp;&emsp;其中一个线程回导致一直占用CPU，编译运行。通过`top` 获取CPU占用信息
![top cpu](https://raw.githubusercontent.com/mashuai/hexo-blog/master/images/top.png)
可以看到占用最高的 pid是 25955
通过`top -p 25955 -H` 获取进程内部线程的CPU使用率。
![topph](https://raw.githubusercontent.com/mashuai/hexo-blog/master/images/tophp.png)
可以发现占用最高的线程ID是 `25965` 将其转换为16进制`python -c 'print hex(25965)'` 得到的值是`0x656d` 
使用 `jstack -l 25955 > jstack.log` 得到Java进程的Thread dump，通过 `grep -i 0x656d -A 30 jstack.log` 获取Java Thread id为0x656d的线程的thread dump。
![jstack](https://raw.githubusercontent.com/mashuai/hexo-blog/master/images/jstack.png)
然后就可以定位相应代码查找代码占用CPU过高问题。