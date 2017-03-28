title: 实现一个高效的Money类
date: 2017-03-26 19:00:06
tags:
    - Java
    - Performance
    - Money
    - 金融
---

[原文链接](http://java-performance.info/high-performance-money-class/)
&emsp;&emsp;这篇文章主要讨论如何用Java高效实现Money类。这篇文章接上篇[double/long vs BigDecimal 在货币计算中如何选择](http://java-performance.info/bigdecimal-vs-double-in-financial-calculations/)。
#### 介绍
&emsp;&emsp;正如以前所介绍，在货币计算中不要使用浮点类型。我们可以使用`long`类型来代替，使用当前使用货币的最小的单位。不幸的是，这里有几个小问题：
 * 我们可能在与其他保存货币值的软件通信是仍然需要使用`double`值。
 * 我们可能想要和非0的数值，例如0.015相乘，或者除以一个任何类型的数值，这样得到一个非0的值。

&emsp;&emsp;处理算数问题最简单的方式就是全部使用`BigDecimal`类。不幸的是，`BigDecimal`对已经出错的`double`无能为力。例如下面这个例子将会得出这个结果：`0.7999999999999999`
```
System.out.println( new BigDecimal( 0.7 + 0.1, MathContext.DECIMAL64 ) );
```
&esmp;&emsp;因此我们可以认为**BigDecimal操作如果有正确的参数就可以得出正确的结果**。但是对于`double`我们不能得出这样的结论。
&emsp;&emsp;`double`操作可能得出一个正确的结果，或者是和正确结果有点出入的结果。导致这个问题的原因是因为CPU执行`double`操作的时候使用了高精确度，然后得到一个舍入的结果。我们要得到正确的结果观察三个值（结果值，结果需要加上的一个值，这个值也叫做ulp，结果需要减去的ulp)。其中一个就是正确的值。说容易说，但是很难高效的实现。

#### Money-conversion 库
##### MoneyFactory

&emsp;&emsp;我开发了一个`money-conversion`的库，可以在[这里](https://github.com/mikvor/money-conversio)下载。它定义了一个`Money`的接口和一个`MoneyFactory`类，它可以让你把各种类型转换为高效的`Money`实现。下面是所支持的格式：
 * BigDecimal
 * 指定精度的`double`
 * 指定精度的`long`
 * String
 * CharSequence
 * 部分char数组
 * 部分byte数组
 &emsp;&emsp;术语精度在这个库中的意思是小数点之后的数字数量。必须是正数。例如一个值 `value=1234`，`precision=2` 表示`12.34`。
 &emsp;&emsp;`String/CharSequence/char[]/byte[]`支持相同的输入格式：可选的正负号，紧跟着是有个可选的小数点'.'的ASCII的数字(code:48-57)。例如：`-12.34`。
 ##### Money
 &emsp;&emsp;`Money`有两个实现（虽然没有一个是public的)
  * 基于`long`的`MoneyLong`，代表一个使用最小货币单位的的值，和当前实例的精度。这个实现尽可能的快。
  * 基于`BigDecimal`的`MoneyBigDecimal`操作结果的精度和所需要精度不负（或者精度超过15，这个精度是`MoneyLong`所能表示的最大精度)时可以安全的执行。这个类的操作会很慢（因为`BigDecimal`的性能问题），但是我们总是会尝试将它的操作结果转为`LongMoney`。
  &emsp;&emsp;两个实现都是不可变的。
 
 

