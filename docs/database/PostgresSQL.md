# PostgresSQL 数据库部署

## 文档

- [Docker Hub](https://hub.docker.com/_/postgres)





## Docker compose

```yml
services:
  db_postgres:
    image: postgres:18.0
    restart: always
    ports:
      - "5432:5432"
    # set shared memory limit when using docker compose
    shm_size: 128mb
    # or set shared memory limit when deploy via swarm stack
#    volumes:
      # 持久化数据
#      - sql_db_postgres:/var/lib/postgresql
      # 挂载初始化脚本（可选）
      # 在目录 /docker-entrypoint-initdb.d 下可以放 sql、sh文件在初始化时可以被执行
#      - ./docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d
    environment:
      POSTGRES_USER: leojay
      POSTGRES_PASSWORD: media_server_leojay

volumes:
  sql_db_postgres:
```







## 管理工具



### adminer

> 官方文档上推荐的工具，但我感觉不好用

#### docker-compose:

```yml
services:
  adminer:
    image: adminer
    restart: always
    ports:
      - "8082:8080"
    links:
      - db_postgres:db
    environment:
      POSTGRES_PASSWORD: example
```



### PgAdmin4

- [官网](https://www.pgadmin.org/)
- [官网-下载](https://www.pgadmin.org/download/)
- [GitHub](https://github.com/pgadmin-org/pgadmin4)
- [Docker 环境变量配置文档](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html)
- [Docker Hub](https://hub.docker.com/r/dpage/pgadmin4)
- [Docker Hub Version](https://hub.docker.com/r/dpage/pgadmin4/tags)

#### docker-compose

```yml
services:
  #  https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html
  mg_postgres:
    image: dpage/pgadmin4:9.9.0
    restart: always
    links:
      - db_postgres:db
    ports:
      - "8082:80"
    environment:
      PGADMIN_DEFAULT_EMAIL: crazyleojay@163.com
      PGADMIN_DEFAULT_PASSWORD: password
    volumes:
      - sql_manage_pgadmin:/var/lib/pgadmin:rw

volumes:
  sql_manage_pgadmin:
```

