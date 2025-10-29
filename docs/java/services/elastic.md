# Elastic 配置和部署



## kibana、logstash和Elasticsearch DockerCompose 部署配置

> elasticsearch 必须配置 `xpack.security.http.ssl.enabled=false`，否则会存在kibana验证问题
>
> 如果需要安全验证，则需要额外研究 `xpack`的配置原理

```yml
services:
  # 主要做文件索引和日志采集
  elasticsearch:
    image: ${ELASTICSEARCH_HOST}elasticsearch:${ELASTIC_VERSION}
    container_name: ${PREFIX}-elasticsearch
    profiles:
      - elastic
      - all
    ports:
      - "9200:9200"
      - "9300:9300"
    env_file:
      - ./env/elasticsearch.env
#    working_dir: /usr/share/elasticsearch
    environment:
      - "discovery.type=single-node"
      - "ES_JAVA_OPTS=-Xms64m -Xmx512m"
      - "ELASTIC_PASSWORD=changeme"
      - "KIBANA_PASSWORD=changeme"
      # 不使用ssl
      - "xpack.security.http.ssl.enabled=false" 
    volumes:
      - elastic_data:/usr/share/elasticsearch/data
    entrypoint: /bin/bash /usr/local/bin/docker-entrypoint.sh
    networks:
      - elastic_net

  #  elasticsearch 的数据查询分析
  kibana:
    image: ${KIBANA_HOST}kibana:${ELASTIC_VERSION}
    profiles:
      - elastic
      - all
    container_name: ${PREFIX}-kibana
    ports:
      - "5601:5601"
    env_file:
      - ./env/kibana.env
    environment:
      ELASTICSEARCH_HOSTS: '["http://elasticsearch:9200"]'
      ELASTICSEARCH_USERNAME: kibana_system
      ELASTICSEARCH_PASSWORD: rWgkzakBSsI7-9cp+*eT
    volumes:
      - ./certs/certs/newcerts/leojay.site:/certs
    networks:
      - elastic_net

  #  日志采集
  logstash:
    image: ${LOGSTASH_HOST}logstash:${ELASTIC_VERSION}
    container_name: ${PREFIX}-logstash
    profiles:
      - elastic
      - all
    volumes:
      - elastic_data:/usr/share/logstash/data
    networks:
      - elastic_net

volumes:
  elastic_data:
    driver: local

networks:
  elastic_net:
    driver: bridge

```



## kibana 访问问题

使用上述方案构建时，会不定期出无法访问的问题，猜测是

- kibana会使用elastic用户定期去修改elastic上kibana_system的密码。修改成功就可以访问，但大多数时候都失败了



解决方法：

在elasticsearch中执行 

```sh
bin/elasticsearch-reset-password -u kibana_system
```

会自动生成随机密码，并打印，将这个密码打印出来，添加到kibana配置中去

或者使用RESAPI方式，发送请求

```sh
curl -X POST "http://localhost:9200/_security/user/kibana_system/_password" -H 'Content-Type: application/json' -d'
{
  "password" : "changeme"
}
' -u elastic:changeme
```

修改密码



## 证书配置

> 目前只观察了几个文档，还未研究好

- https://www.elastic.co/guide/en/elasticsearch/reference/8.17/security-basic-setup.html#encrypt-internode-communication
- https://cloud.tencent.com/developer/article/2457640