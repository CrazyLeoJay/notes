# MySql数据库



## docker compose 部署

- [docker hub](https://hub.docker.com/_/mysql)

```yml
services:
  db_mysql:
    image: mysql:9.4.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
    ports:
      - 3306:3306
  #    volumes:
  #      - "/my/own/datadir:/var/lib/mysql"
```



## SpringBoot 配置

- [SpringBoot Sql 配置文档](https://docs.spring.io/spring-boot/reference/data/sql.html)