title: Go Web 架构
date: 2015-11-10 19:01:21
tags:
  - Go
  - Architecture
  - Translate
---

[原文地址](https://larry-price.com/blog/2015/06/25/architecture-for-a-golang-web-app)

&emsp;&emsp; 使用Golang来创建Web项目是一件很麻烦的事情。如果你使用Rails，那么你可能不会有这个感触。我在[Refer Madness](https://www.refer-madness.com/)中使用了下面这个架构。

```
-public/
-views/
-models/
-utils/
-controllers/
-web/
-main.go
```

&emsp;&emsp; 我将打破这个体系，介绍各个目录的作用。在每个目录下，文件只能访问其同级或者上一级。这就意味着`utils`只能访问他自己和`models`，`web`只能访问它自己，`controllers`，`utils`，`models`。`models`只能访问它自己。我这么做是为了让层次清晰，防止出现递归依赖。现在来分析每一个目录，文件的作用。

#### main.go

&emsp;&emsp; `main.go`是创建依赖，获取环境变量，启动服务的主要文件。下面是它的实例。

```
package main

import (
  "github.com/larryprice/refermadness/utils"
  "github.com/larryprice/refermadness/web"
  "github.com/stretchr/graceful"
  "os"
)

func main() {
  isDevelopment := os.Getenv("ENVIRONMENT") == "development"
  dbURL := os.Getenv("MONGOLAB_URI")
  if isDevelopment {
    dbURL = os.Getenv("DB_PORT_27017_TCP_ADDR")
  }

  dbAccessor := utils.NewDatabaseAccessor(dbURL, os.Getenv("DATABASE_NAME"), 0)
  cuAccessor := utils.NewCurrentUserAccessor(1)
  s := web.NewServer(*dbAccessor, *cuAccessor, os.Getenv("GOOGLE_OAUTH2_CLIENT_ID"),
    os.Getenv("GOOGLE_OAUTH2_CLIENT_SECRET"), os.Getenv("SESSION_SECRET"),
    isDevelopment, os.Getenv("GOOGLE_ANALYTICS_KEY"))

  port := os.Getenv("PORT")
  if port == "" {
    port = "3000"
  }

  graceful.Run(":"+port, 0, s)
}

```

&emsp;&emsp; 因为`main.go`实在最低的层级，所以它可以访问所有的目录：在这个例子里是`web`和`utils`。在这里获取了所有的环境变量并把它们注入到合适的地方。在`main.go`中创建了服务器，注入依赖，并且在配置的端口启动服务器。

#### web

&emsp;&emsp; `web`目录下是主要的服务代码，同时也包括了中间件代码。下面是`web`目录的内部结构：

```
-web/
|-middleware/
|-server.go
```

&emsp;&emsp; `server.go`包含了web server的定义。这个web server 创建了所有的web controller并且给negroni添加了中间件。下面是他的例子：

```
package web

import (
  "github.com/codegangsta/negroni"
  "github.com/goincremental/negroni-sessions"
  "github.com/goincremental/negroni-sessions/cookiestore"
  "github.com/gorilla/mux"
  "github.com/larryprice/refermadness/controllers"
  "github.com/larryprice/refermadness/utils"
  "github.com/larryprice/refermadness/web/middleware"
  "github.com/unrolled/secure"
  "gopkg.in/unrolled/render.v1"
  "html/template"
  "net/http"
)

type Server struct {
  *negroni.Negroni
}

func NewServer(dba utils.DatabaseAccessor, cua utils.CurrentUserAccessor, clientID, clientSecret,
  sessionSecret string, isDevelopment bool, gaKey string) *Server {
  s := Server{negroni.Classic()}
  session := utils.NewSessionManager()
  basePage := utils.NewBasePageCreator(cua, gaKey)
  renderer := render.New()

  router := mux.NewRouter()

  // ...

  accountController := controllers.NewAccountController(clientID, clientSecret, isDevelopment, session, dba, cua, basePage, renderer)
  accountController.Register(router)

  // ...

  s.Use(sessions.Sessions("refermadness", cookiestore.New([]byte(sessionSecret))))
  s.Use(middleware.NewAuthenticator(dba, session, cua).Middleware())
  s.UseHandler(router)
  return &s
}
```

&emsp;&emsp; `Server`结构体是一个`negroni.Negroni`的web server，在这个文件里有对`utils`和其他第三方包的引用，创建了一个router，一些controller，并且将controller注册到当前router。同时也引入了必要的中间件。说到中间件，下面是它的代码：

```
package middleware

import (
  "github.com/codegangsta/negroni"
  "github.com/larryprice/refermadness/utils"
  "net/http"
)

type Database struct {
  da utils.DatabaseAccessor
}

func NewDatabase(da utils.DatabaseAccessor) *Database {
  return &Database{da}
}

func (d *Database) Middleware() negroni.HandlerFunc {
  return func(rw http.ResponseWriter, r *http.Request, next http.HandlerFunc) {
    reqSession := d.da.Clone()
    defer reqSession.Close()
    d.da.Set(r, reqSession)
    next(rw, r)
  }
}
```

&emsp;&emsp; 这个是通过HTTP router访问数据库session的标注中间件。基本文件是从[Brian Gesiak’s blog post on RESTful Go](http://modocache.svbtle.com/restful-go)中得到，将其修改为适合我的文件。

#### controllers/

&emsp;&emsp; 这里的controller与Rails里的controller的概念很像。Controller注册自己的router，设置自己的函数调用。一个简短的例子如下：

```
package controllers

import (
  "encoding/json"
  "errors"
  "github.com/gorilla/mux"
  "github.com/larryprice/refermadness/models"
  "github.com/larryprice/refermadness/utils"
  "gopkg.in/mgo.v2/bson"
  "gopkg.in/unrolled/render.v1"
  "html/template"
  "net/http"
  "strings"
)

type ServiceControllerImpl struct {
  currentUser utils.CurrentUserAccessor
  basePage    utils.BasePageCreator
  renderer    *render.Render
  database    utils.DatabaseAccessor
}

func NewServiceController(currentUser utils.CurrentUserAccessor, basePage utils.BasePageCreator,
  renderer *render.Render, database utils.DatabaseAccessor) *ServiceControllerImpl {
  return &ServiceControllerImpl{
    currentUser: currentUser,
    basePage:    basePage,
    renderer:    renderer,
    database:    database,
  }
}

func (sc *ServiceControllerImpl) Register(router *mux.Router) {
  router.HandleFunc("/service/{id}", sc.single)
  // ...
}

// ...

type serviceResult struct {
  *models.Service
  RandomCode *models.ReferralCode
  UserCode   *models.ReferralCode
}

type servicePage struct {
  utils.BasePage
  ResultString string
}

func (sc *ServiceControllerImpl) single(w http.ResponseWriter, r *http.Request) {
  data, err := sc.get(w, r)

  if len(r.Header["Content-Type"]) == 1 && strings.Contains(r.Header["Content-Type"][0], "application/json") {
    if err != nil {
      sc.renderer.JSON(w, http.StatusBadRequest, map[string]string{
        "error": err.Error(),
      })
      return
    }
    sc.renderer.JSON(w, http.StatusOK, data)
    return
  } else if err != nil {
    http.Error(w, err.Error(), http.StatusBadRequest)
  }

  resultString, _ := json.Marshal(data)
  t, _ := template.ParseFiles("views/layout.html", "views/service.html")
  t.Execute(w, servicePage{sc.basePage.Get(r), string(resultString)})
}
```

#### utils/

&emsp;&emsp; 在`utils`目录下的文件提供了一些底层功能用来支持其他的代码。在这个例子中，主要是定义一个结构体来访问请求的上下文，处理session，定义一个特别的页面来继承。下面是通过访问上下文设置用户的例子：

```
package utils

import (
  "github.com/gorilla/context"
  "github.com/larryprice/refermadness/models"
  "net/http"
)

type CurrentUserAccessor struct {
  key int
}

func NewCurrentUserAccessor(key int) *CurrentUserAccessor {
  return &CurrentUserAccessor{key}
}

func (cua *CurrentUserAccessor) Set(r *http.Request, user *models.User) {
  context.Set(r, cua.key, user)
}

func (cua *CurrentUserAccessor) Clear(r *http.Request) {
  context.Delete(r, cua.key)
}

func (cua *CurrentUserAccessor) Get(r *http.Request) *models.User {
  if rv := context.Get(r, cua.key); rv != nil {
    return rv.(*models.User)
  }
  return nil
}
```

#### models/

&emsp;&emsp; model 是为了描述数据库中的数据的数据结构。在这个例子中使用model来访问数据库，创建一个空的model，然后通过查询数据库为其赋值。下面是一个例子：

```
package models

import (
  "gopkg.in/mgo.v2"
  "gopkg.in/mgo.v2/bson"
  "strings"
  "time"
)

type Service struct {
  // identification information
  ID          bson.ObjectId `bson:"_id"`
  Name        string        `bson:"name"`
  Description string        `bson:"description"`
  URL         string        `bson:"url"`
  Search      string        `bson:"search"`
}

func NewService(name, description, url string, creatorID bson.ObjectId) *Service {
  url = strings.TrimPrefix(strings.TrimPrefix(url, "http://"), "https://")
  return &Service{
    ID:            bson.NewObjectId(),
    Name:          name,
    URL:           url,
    Description:   description,
    Search:        strings.ToLower(name) + ";" + strings.ToLower(description) + ";" + strings.ToLower(url),
  }
}

func (s *Service) Save(db *mgo.Database) error {
  _, err := s.coll(db).UpsertId(s.ID, s)
  return err
}

func (s *Service) FindByID(id bson.ObjectId, db *mgo.Database) error {
  return s.coll(db).FindId(id).One(s)
}

func (*Service) coll(db *mgo.Database) *mgo.Collection {
  return db.C("service")
}

type Services []Service

func (s *Services) FindByIDs(ids []bson.ObjectId, db *mgo.Database) error {
  return s.coll(db).Find(bson.M{"_id": bson.M{"$in": ids}}).Sort("name").All(s)
}

func (*Services) coll(db *mgo.Database) *mgo.Collection {
  return db.C("service")
}

```

#### views/

&emsp;&emsp; 将Golang的模板文件放到`views`目录下。这样，不管用什么样的模板引擎都可以直接放到`views`下。

#### public/

&emsp;&emsp; 跟以前一样，这个文件都是放公开的文件的，例如`css`,`img`,`scripts`。

#### 如何运行

&emsp;&emsp; 毫无疑问，我最喜欢的就是[docker](https://www.docker.com/)，因此我将使用他来运行这个应用。如果不使用docker，那么可以将文件放到`$GOPATH/src/github.com/larryprice/refermadness`,运行`go get`来获取所有的依赖，然后运行 `go run main.go`或者`go build; ./refermadness`运行程序。如果你也喜欢使用docker，那么可以直接通过`Dockerfile`来运行。

```
FROM golang:1.4

RUN go get github.com/codegangsta/gin

ADD . /go/src/github.com/larryprice/refermadness
WORKDIR /go/src/github.com/larryprice/refermadness
RUN go get
```

&emsp;&emsp; 同时我也很喜欢[compose](https://github.com/docker/compose)，所以我也通过compose 文件来运行所有的应用。我用了JSC ，SASS和mongodb，所以一下是我的`docker-compose.yml`文件。

```
main:
  build: .
  command: gin run
  env_file: .env
  volumes:
    - ./:/go/src/github.com/larryprice/refermadness
  working_dir: /go/src/github.com/larryprice/refermadness
  ports:
    - "3000:3000"
  links:
    - db
sass:
  image: larryprice/sass
  volumes:
    - ./public/css:/src
jsx:
  image: larryprice/jsx
  volumes:
    - ./public/scripts:/src
db:
  image: mongo:3.0
  command: mongod --smallfiles --quiet --logpath=/dev/null
  volumes_from:
    - dbvolume
dbvolume:
  image: busybox:ubuntu-14.04
  volumes:
    - /data/db
```

&emsp;&emsp; 然后运行`docker-compose up`来运行所有的容器并启动服务器。


