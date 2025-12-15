# Nacos 配置

- [Nacos官网](https://nacos.io/)
- [文档主页](https://nacos.io/docs/latest/overview/?spm=5238cd80.2ef5001f.0.0.3f613b7c2XV8jV)
- [Nacos 融合 Spring Cloud，成为注册配置中心](https://nacos.io/docs/latest/ecology/use-nacos-with-spring-cloud/?spm=5238cd80.2ef5001f.0.0.3f613b7c2XV8jV)
- [Nacos cloud 启动服务发现](https://nacos.io/docs/latest/ecology/use-nacos-with-spring-cloud/?spm=5238cd80.2ef5001f.0.0.3f613b7c2XV8jV#%E5%90%AF%E5%8A%A8%E6%9C%8D%E5%8A%A1%E5%8F%91%E7%8E%B0)



## 安装引入

#### 导入platform pom

> [Spring Cloud Alibaba Github docs](https://github.com/alibaba/spring-cloud-alibaba/blob/2023.x/README-zh.md)
>
> [Spring Cloud Alibaba 版本发布说明](https://sca.aliyun.com/docs/2023/overview/version-explain/?spm=7145af80.1ef41eac.0.0.5ff22d5btvltpb)
>
> [maven central repository](https://central.sonatype.com/artifact/com.alibaba.cloud/spring-cloud-alibaba-dependencies/2025.0.0.0-preview)

[![Maven Central](https://camo.githubusercontent.com/10047ef7bfe5c3df053d22d286721d74b6b0d804ea20fd666b6d8f97bce73e21/68747470733a2f2f696d672e736869656c64732e696f2f6d6176656e2d63656e7472616c2f762f636f6d2e616c69626162612e636c6f75642f737072696e672d636c6f75642d616c69626162612d646570656e64656e636965732e7376673f6c6162656c3d4d6176656e25323043656e7472616c)](https://search.maven.org/search?q=g:com.alibaba.cloud AND a:spring-cloud-alibaba-dependencies)

### maven

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-alibaba-dependencies</artifactId>
            <version>2023.0.1.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### gradle

```groovy
implementation(platform("com.alibaba.cloud:spring-cloud-alibaba-dependencies:2025.0.0.0-preview"))
```

或者使用插件

```groovy
plugins {
    id("io.spring.dependency-management")
}

dependencyManagement {
    imports {
        mavenBom("com.alibaba.cloud:spring-cloud-alibaba-dependencies:2025.0.0.0-preview")
    }
}
```



## 引入依赖

### Nacos 配置

```groovy
implementation("com.alibaba.cloud:spring-alibaba-nacos-config")
```

### Nacos Spring Cloud 配置

```groovy
implementation("com.alibaba.cloud:spring-cloud-starter-alibaba-nacos-config")
```

### Nacos Spring Cloud 服务发现

```groovy
implementation("com.alibaba.cloud:spring-cloud-starter-alibaba-nacos-discovery")
```



## 配置服务发现

### application.properties

```properties
server.port=8070
spring.application.name=service-provider

spring.cloud.nacos.discovery.server-addr=127.0.0.1:8848
```

### application.yml

```yaml
server:
	port: 8070
spring:
	application:
		name: service-provider
	cloud:
		nacos:
			discovery:
				server-addr: 127.0.0.1:8848
```



### 启动服务发现

```java
@SpringBootApplication
@EnableDiscoveryClient
public class NacosProviderApplication {

  public static void main(String[] args) {
    SpringApplication.run(NacosProviderApplication.class, args);
  }

  @RestController
  class EchoController {
    @RequestMapping(value = "/echo/{string}", method = RequestMethod.GET)
    public String echo(@PathVariable String string) {
      return "Hello Nacos Discovery " + string;
    }
  }
}
```





















