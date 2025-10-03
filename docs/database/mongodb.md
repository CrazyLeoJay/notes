# MongoDB 数据库

- [MongoDB官方文档](https://www.mongodb.com/zh-cn/docs/)
- Docker Image: [mongodb/mongodb-community-server](https://hub.docker.com/r/mongodb/mongodb-community-server)
- [安装 MongoDB](https://www.mongodb.com/zh-cn/docs/manual/installation/)
- 

| 平台    | Tutorial                                                     |
| :------ | :----------------------------------------------------------- |
| Linux   | [Install MongoDB Enterprise Edition on Red Hat or CentOS](https://www.mongodb.com/zh-cn/docs/manual/tutorial/install-mongodb-enterprise-on-red-hat/)[Install MongoDB Enterprise Edition on Ubuntu](https://www.mongodb.com/zh-cn/docs/manual/tutorial/install-mongodb-enterprise-on-ubuntu/)[Install MongoDB Enterprise Edition on Debian](https://www.mongodb.com/zh-cn/docs/manual/tutorial/install-mongodb-enterprise-on-debian/)[Install MongoDB Enterprise Edition on SUSE](https://www.mongodb.com/zh-cn/docs/manual/tutorial/install-mongodb-enterprise-on-suse/)[Install MongoDB Enterprise Edition on Amazon Linux](https://www.mongodb.com/zh-cn/docs/manual/tutorial/install-mongodb-enterprise-on-amazon/) |
| macOS   | [在 macOS 上安装 MongoDB Enterprise](https://www.mongodb.com/zh-cn/docs/manual/tutorial/install-mongodb-enterprise-on-os-x/) |
| Windows | [在 Windows 上安装 MongoDB Enterprise 版](https://www.mongodb.com/zh-cn/docs/manual/tutorial/install-mongodb-enterprise-on-windows/) |
| Docker  | [使用 Docker 安装 MongoDB Enterprise Edition](https://www.mongodb.com/zh-cn/docs/manual/tutorial/install-mongodb-enterprise-with-docker/#std-label-docker-mongodb-enterprise-install) |

## Docker Compose 配置

```yml
services:
  db_mongodb:
    image: mongodb/mongodb-community-server:8.2-ubi9
    restart: always
    ports:
      - 27017:27010
```



# 代码链接

- [使用 Kotlin 的 MongoDB](https://www.mongodb.com/zh-cn/docs/languages/kotlin/)
- 



## SpringBoot 配置

* [Spring Data MongoDB](https://docs.spring.io/spring-boot/3.5.6/reference/data/nosql.html#data.nosql.mongodb)
* [Spring Data Reactive MongoDB](https://docs.spring.io/spring-boot/3.5.6/reference/data/nosql.html#data.nosql.mongodb)

































