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
      # 添加字符集环境变量
      MYSQL_CHARSET: "utf8mb4"
      MYSQL_COLLATION: "utf8mb4_unicode_ci"
    ports:
      - 3306:3306
    volumes:
      - sql_db_mysql:/var/lib/mysql
volumes:
  sql_db_mysql:
```



## SpringBoot 配置

- [SpringBoot Sql 配置文档](https://docs.spring.io/spring-boot/reference/data/sql.html)





## 管理工具

### Phpmyadmin

> 老牌工具，功能齐全

```yml
services:
  db_manage:
    image: phpmyadmin:5.2.2
    restart: always
    links: # 链接数据库
      - db_mysql:db
    ports:
      - "8080:80"
    environment:
      #      - PMA_ARBITRARY=1
      - PMA_HOST=db_mysql
      - MYSQL_ROOT_PASSWORD=password
      
```



无密码直接登录

```yml
services:
  db_manage:
    image: phpmyadmin:5.2.3
    restart: always
    links: # 链接数据库
      - db_mysql:mysql
    ports:
      - "8080:80"
    environment:
      #      - PMA_ARBITRARY=1
      #      - PMA_HOST=db_mysql
      MYSQL_ROOT_PASSWORD: password
      PMA_HOST: mysql # 使用 MySQL 服务的容器名作为主机
      PMA_USER: root  # 自动登录的用户名
      PMA_PASSWORD: password # 自动登录的密码，与上方 MySQL 的 root 密码一致
      # 设置 phpMyAdmin 字符集
      PMA_CHARSET: "utf8mb4"
```



