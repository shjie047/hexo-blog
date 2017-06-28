title: MyBatis 配置
date: 2017-06-28 14:13:32
tags:
    - Java
    - Mybatis
    - Translate
---

[原文链接](http://www.mybatis.org/mybatis-3/configuration.html)

MyBatis的配置包含了设置和属性，他们对MyBatis的行为有很大的影响。MyBatis的配置文件层次结构如下：
* configuration
    * properties
    * settings
    * typeAliases
    * typeHandlers
    * objectFactory
    * plugins
    * environments
        * environment
            * transactionManager
            * dataSource
    * databaseIdProvider
    * mappers

### properties
可以通过一个典型的Java Properties 类实例配置可替换的外部属性，也可以通过子元素传递这些配置属性，例如
```
<properties resource="org/mybatis/example/config.properties">
  <property name="username" value="dev_user"/>
  <property name="password" value="F2Fa3!33TYyg"/>
</properties>
```
然后这些配置属性就可以应用于配置文件中需要动态配置的其他属性。例如：
```
<dataSource type="POOLED">
  <property name="driver" value="${driver}"/>
  <property name="url" value="${url}"/>
  <property name="username" value="${username}"/>
  <property name="password" value="${password}"/>
</dataSource>
```
在这个例子中的username和password将会被properties的配置属性替换。driver和url属性会被config.properties的配置替换。这个为配置提供了很多的选项。    
Properties同样可以直传入SqlSessionFactoryBuild.build() 方法中，例如：
```
SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(reader, props);

// ... or ...

SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(reader, environment, props);
```
如果同一个属性同时配置到不同的位置，MyBatis按照如下的顺序加载它们：    
1. 在Properties内的子元素首先被加载。     
2. 其次从resource classpath和url中加载属性并覆盖已存在的属性。    
3. 作为方法参数的属性最后被加载，并且覆盖前面两次相同的属性。

因此，优先级最高的是直接作为参数传入方法，其次是从resource classpath或者url加载的配置文件，最后是Properties中的子元素定义的属性。    
MyBatis 3.4.2 之后可以如下使用默认占位符。
```
<dataSource type="POOLED">
  <!-- ... -->
  <property name="username" value="${username:ut_user}"/> <!-- If 'username' property not present, username become 'ut_user' -->
</dataSource>
```
这个功能默认是无效的，如果要开启这个功能，需要在配置属性中如下开启：
```
<properties resource="org/mybatis/example/config.properties">
  <!-- ... -->
  <property name="org.apache.ibatis.parsing.PropertyParser.enable-default-value" value="true"/> <!-- Enable this feature -->
</properties>
```
注意：如果已经使用了“：”作为属性的键例如：`db:username`，或者是在sql的定义中使用了OGNL的三元符，例如：`${tableName != null ? tableName : 'global_constants'}`那么就需要修改默认的分隔符，如下：
```
<properties resource="org/mybatis/example/config.properties">
  <!-- ... -->
  <property name="org.apache.ibatis.parsing.PropertyParser.default-value-separator" value="?:"/> <!-- Change default value of separator -->
</properties>
```
```
<dataSource type="POOLED">
  <!-- ... -->
  <property name="username" value="${db:username?:ut_user}"/>
</dataSource>
```