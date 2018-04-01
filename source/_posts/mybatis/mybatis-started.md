title: mybatis 入门
date: 2017-03-21 11:58:14
tags:
    - Java
    - Mybatis
    - Translate
---
[原文链接](http://www.mybatis.org/mybatis-3/getting-started.html)
#### 安装
&emsp;&emsp;使用Mybatis只需要将[mybatis-x.x.x.jar](https://github.com/mybatis/mybatis-3/releases)添加到类路径即可。
&emsp;&emsp;如果使用maven只需要将下列代码添加到pom.xml中。
```
<dependency>
  <groupId>org.mybatis</groupId>
  <artifactId>mybatis</artifactId>
  <version>x.x.x</version>
</dependency>
```
#### 根据XML配置构建SqlSessionFactory
&emsp;&emsp;每一个Mybatis应用都围绕SqlSessionFactory展开。一个SqlSessionFactory实例由SqlSessionFactoryBuilder创建。SqlSessionFacotryBuilder可以通过XML的配置文件或者一个配置好的Configuration类来创建SqlSessionFactory。
&emsp;&emsp;根据XML配置来构建SqlSessionFacotry非常的简单。推荐使用在类路径来配置，但是同样可以使用任何的InputStream实例，包括一个普通的文件路径或者是file:// 的URL。Mybatis有一个叫`Resource`的工具函数，可以很容易的从类路径或者其他文件路径加载资源。
```
String resource = "org/mybatis/example/mybatis-config.xml";
InputStream inputStream = Resources.getResourceAsStream(resource);
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
```
&emsp;&emsp;XML配置文件包含了Mybatis的核心设置，包括对应数据库连接的数据源，同样还有一个事务管理器来决定事务的范围和控制。完整的XML配置稍后会在文档中列出，下面是一个示例配置。
```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
  PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
  <environments default="development">
    <environment id="development">
      <transactionManager type="JDBC"/>
      <dataSource type="POOLED">
        <property name="driver" value="${driver}"/>
        <property name="url" value="${url}"/>
        <property name="username" value="${username}"/>
        <property name="password" value="${password}"/>
      </dataSource>
    </environment>
  </environments>
  <mappers>
    <mapper resource="org/mybatis/example/BlogMapper.xml"/>
  </mappers>
</configuration>
```
&emsp;&emsp;XML配置文件的元素还有很多，上面这个配置只是指出了最重要的一部分。注意XML的header，是用来验证xml文件的。`environment`元素包含了一个事务管理器和一个连接池。`mappers`元素包含了很多`mapper`，mapper可以是xml配置或者只Java 的interface，他们都包含了SQL代码和mapper的定义。
#### 不使用XML构建SqlSessionFactory
&emsp;&emsp;如果你不想使用XML配置或者想自己创建配置构造器，可以直接使用Java来构建配置。MyBatis提供了一个Configuration类可以提供所有XML配置文件所能提供的配置。
```
DataSource dataSource = BlogDataSourceFactory.getBlogDataSource();
TransactionFactory transactionFactory = new JdbcTransactionFactory();
Environment environment = new Environment("development", transactionFactory, dataSource);
Configuration configuration = new Configuration(environment);
configuration.addMapper(BlogMapper.class);
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(configuration);
```
&emsp;&emsp;注意在这个配置中添加了一个mapper类。mapper类包含了一个SQL映射的注解，这样可以避免使用XML配置mapper。但是由于Java注解的限制和一些MyBatis复杂的mapper配置，XML mapper仍然是一些复杂的高级映射的首选（例如，inner join)。因此MyBatis会自动寻找并加载每一个XML配置（在这个例子中BlogMapper.xml将会被从类路径中加载)。更多的稍后介绍。
#### 从SqlSessionFactory获取SqlSession
&emsp;&emsp; 现在你已经有了SqlSessionFactory了，根据名字的提示，可以从它得到一个SqlSession实例。SqlSession包含了所有执行数据库操作的SQL方法。你可以直接通过SqlSession执行映射的SQL。例如：
```
SqlSession session = sqlSessionFactory.openSession();
try {
  Blog blog = session.selectOne("org.mybatis.example.BlogMapper.selectBlog", 101);
} finally {
  session.close();
}
```
&emsp;&emsp;虽然这种方式对于之前的MyBatis的用户来说很熟悉，但是现在有一种跟清晰的方式。使用接口（例如：BlogMapper.class），该接口的方法定义了参数和返回值，这样就可以使用更加清晰的，类型安全的代码，而不再需要容易发生错误的并且去要强制类型转换的代码。例如：
```
SqlSession session = sqlSessionFactory.openSession();
try {
  BlogMapper mapper = session.getMapper(BlogMapper.class);
  Blog blog = mapper.selectBlog(101);
} finally {
  session.close();
}
```
&emsp;&emsp;现在让我们来看一下到底执行了些什么。
#### 探索映射的SQL语句
&emsp;&emsp;现在你可能在想SqlSession和Mapper类到底执行了什么。映射SQL语句这个主题比较大，这个主题差不多占据了此文档的一大部分。但是下面这些语句会展示这些示例到底执行了些什么。
&emsp;&emsp;无论是上面还是下面这些例子，这些语句都可以被定义在XML或者注解上。让我们先使用XML类配置。通过XML映射实现的MyBatis全套功能使得MyBatis流行了很多年。如果你以前用过MyBatis，这些概念你可能很熟悉，但是也有为数众多的对XML映射文档的改进。下面是一个可以满足上面的SqlSesion调用的XML配置的映射语句。
```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
  PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="org.mybatis.example.BlogMapper">
  <select id="selectBlog" resultType="Blog">
    select * from Blog where id = #{id}
  </select>
</mapper>
```
&emsp;&emsp;虽然这个例子对于这个简单的项目看起来很重量级，实际上他是很轻量级的。你可以在一个XML的映射文件中定义许多的映射语句，因此你可以减少很多的XML的header和doctype声明。文件余下的部分完全可以自解释。在命名空间`org.mybatis.example.BlogMapper`中定义了一个名为`selectBlog`的映射语句。他可以让你像例子中那样通过全限定名`org.mybatis.example.BlogMapper.selectBlog`调用他。
```
Blog blog = session.selectOne("org.mybatis.example.BlogMapper.selectBlog", 101);
```
&emsp;&emsp;注意他和调用的Java函数很相似，这么做是有原因的。这个名字可以直接映射具有相同名字的命名空间，函数名，参数，返回值都可以和select语句匹配。这样就可以通过简单的调用Mapper接口的函数来使用映射的SQL语句了。
```
BlogMapper mapper = session.getMapper(BlogMapper.class);
Blog blog = mapper.selectBlog(101);
```
&emsp;&emsp;第二个例子有很多优势，首先他并不依赖于字符串字面量，这样他更加的安全。其次，IDE都有代码补全，当导航到映射一句的时候可以利用这个。
> namespace 的注意事项  
> MyBatis之前的版本**Namespace**是可选的，这样既没用又困惑。现在namespace是必须的，通过一个很长的，全限定名的语句来区分不同的语句。  
> 正如所见，namespace绑定了接口，即使你现在不使用他们，也要遵守这个规则，以防哪天改变想法。从长远来看，使用Namespace将他放在一个Java的package名中可以使代码更清晰，提高可用性。
> 名字解析：为了减少输入，对于所有的命名配置，包括语句，result map， cache，使用下列名字解析规则：
> * 全限定名（例如：com.mypackage.MyMapper.selectAllThings）直接查找，找到后直接使用。
> * 短名字（例如：selectAllThings）可以使用任何明确的条目。然而如果匹配了多了个（例如：com.foo.selectAllThings and com.bar.selectAllThing），那么将会报名字模糊的错误，这个时候必须使用全限定名。

&emsp;&emsp;对于BlogMapper还有一个小诀窍。他们的映射语句完全不需要XML配置文件，可以使用注解来代替。例如下面这个例子就可以代替XML配置：
```
package org.mybatis.example;
public interface BlogMapper {
  @Select("SELECT * FROM blog WHERE id = #{id}")
  Blog selectBlog(int id);
}
```
&emsp;&emsp;注解相对来说更加的简洁，但是由于注解自身的限制和一些复杂语句的复杂性，如果使用复杂的SQL语句最好还是使用XML配置。
&emsp;&emsp;这个完全取决于你和你的团队和定义映射语句的一致性类决定使用哪个方式。也就是说你不需要仅仅选择一个。从注解到XML的迁移是很方便的，反之亦然。
#### 作用域和生命周期
&emsp;&emsp;明白我们现在所讨论的类的作用域和生命周期是很重要的。错误的使用会导致并发错误。
> **对象生命周期和依赖注入框架**    
> 依赖注入框架可以创建线程安全的，带事务管理的SqlSession和mapper并且将它们注入到需要的Bean中，因此你可以直接忽略他的生命周期。如果要熟悉MyBatis和DI 框架的关系可以看一下MyBatis-Spring 和MyBatis-Guice两个项目

##### SqlSessionFactoryBuilder
&emsp;&emsp;这个类被初始化，使用完之后可以直接丢弃了。当你创建完SqlSessionFactory之后就没必要留着他了。因此SqlSessionFactoryBuilder最好的作用域是在方法作用域中（例如一个本地变量）。可以重用SqlSessionFactoryBuilder来创建多个SqlSessionFactory实例，但是最好还是不要保留它，保证所有的XML都被解析用来做更重要的事情。
##### SqlSessionFactory
&emsp;&emsp;当SqlSesslionFactory创建了之后，就应该一直存在你的应用中。一般来说是没有理由重新创建或处理他的。在程序运行的时候最好不要多次重新构建SqlSessionFactory。如果这样做就会有坏代码的味道了。因此SqlSessionFactory的作用域最好是应用作用域。实现的方法有很多，最好的方法就是使用单例模式或者是静态单例模式。
##### SqlSession
&emsp;&emsp;每个线程都应该有自己的SqlSession。SqlSession的示例不能分享且非线程安全。因此最好的作用域是请求作用域和方法作用域。永远不要在静态域或者类实例中引用SqlSession。永远不要将SqlSession放到managed 作用域中，例如Servlet框架的HttpSession。如果使用的是web框架，可以将其放到HTTP 请求的作用域中。换句话说就是，接收到HTTP请求的时候可以打开SqlSesslion连接，响应的时候关闭。关闭SqlSession非常的重要，永远记得将其放在finally块中来关闭他。下面这个例子就是确保在finally中关闭SqlSesslion
```
SqlSession session = sqlSessionFactory.openSession();
try {
  // do work
} finally {
  session.close();
}
```
&emsp;&emsp;使用这个模式可以保证你的代码关闭了数据库的连接。
##### Mapper Instances
&emsp;&emsp;Mappers是你创建用来绑定映射语句的接口。每一个mapper实例都从SqlSession中获取。因此mapper的作用域和获取他们的SqlSession的作用域是一样的。然而mapper最好的租用与是方法作用域。他们应该在一个方法使用时创建，方法结束时丢弃。他们不需要显示的关闭。和SqlSession相同，将它们放到请求作用域中也是没问题的，但是在这个层次上处理如此多的资源会很棘手。所以就简单一点，把mapper实例放到方法作用域中，下面这个例子解释了如何使用他
```
SqlSession session = sqlSessionFactory.openSession();
try {
  BlogMapper mapper = session.getMapper(BlogMapper.class);
  // do work
} finally {
  session.close();
}
```