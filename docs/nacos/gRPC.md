# gRPC配置

- [grpc 官网](https://grpc.io/)
- [grpc docs: kotlin](https://grpc.io/docs/languages/kotlin/quickstart/)
- [gRpc-java GitHub](https://github.com/grpc/grpc-java)
- [grpc-spring-boot-starter](https://github.com/LogNet/grpc-spring-boot-starter)

## 导入依赖

```groovy
// build.gradle.kts
dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("com.alibaba.cloud:spring-cloud-starter-alibaba-nacos-discovery")
    implementation("io.github.lognet:grpc-spring-boot-starter:5.2.0") // 这是关键依赖
    
    // 如果你不需要额外的gRPC依赖，这个就够了
    // 如果需要，可以添加：
    // implementation("io.grpc:grpc-netty:1.42.1")
    // implementation("io.grpc:grpc-protobuf:1.42.1")
    // implementation("io.grpc:grpc-stub:1.42.1")
}
```



## **[grpc-java](https://github.com/grpc/grpc-java)**

### 依赖

或者对于Gradle与非Android，添加到您的依赖项:

```groovy
runtimeOnly 'io.grpc:grpc-netty-shaded:1.77.0'
implementation 'io.grpc:grpc-protobuf:1.77.0'
implementation 'io.grpc:grpc-stub:1.77.0'
```

对于Android客户端，请使用grpc-okhttp而不是grpc-netty阴影和grpc-protobuf-lite而不是grpc-protobuf:

```groovy
implementation 'io.grpc:grpc-okhttp:1.77.0'
implementation 'io.grpc:grpc-protobuf-lite:1.77.0'
implementation 'io.grpc:grpc-stub:1.77.0'
```



### 生成的代码

对于与Gradle构建系统集成的基于非Android protobuf的codegen，您可以使用protobuf-gradle-plugin:

```groovy
plugins {
    id 'com.google.protobuf' version '0.9.5'
}

protobuf {
  protoc {
    artifact = "com.google.protobuf:protoc:3.25.8"
  }
  plugins {
    grpc {
      artifact = 'io.grpc:protoc-gen-grpc-java:1.77.0'
    }
  }
  generateProtoTasks {
    all()*.plugins {
      grpc {}
    }
  }
}
```



预构建的protoc-gen-grpc-java二进制文件在Linux上使用glibc。如果你在Alpine Linux上编译，你可能想使用Alpine grpc-java包，它使用musl。

对于与Gradle构建系统集成的基于Android protobuf的codegen，也可以使用protobuf-gradle-plugin，但指定 “lite” 选项:

```groovy
plugins {
    id 'com.google.protobuf' version '0.9.5'
}

protobuf {
  protoc {
    artifact = "com.google.protobuf:protoc:3.25.8"
  }
  plugins {
    grpc {
      artifact = 'io.grpc:protoc-gen-grpc-java:1.77.0'
    }
  }
  generateProtoTasks {
    all().each { task ->
      task.builtins {
        java { option 'lite' }
      }
      task.plugins {
        grpc { option 'lite' }
      }
    }
  }
}
```





## [grpc-spring-boot-starter](https://github.com/LogNet/grpc-spring-boot-starter)

[![grpc spring boot starter](https://camo.githubusercontent.com/1c11705b75315366d4dd209a1bd52fe50127df9973d23f44cd57dbd7160c9fd5/68747470733a2f2f696d672e736869656c64732e696f2f6d6176656e2d63656e7472616c2f762f696f2e6769746875622e6c6f676e65742f677270632d737072696e672d626f6f742d737461727465722e7376673f6c6162656c3d4d6176656e25323043656e7472616c)](https://search.maven.org/search?q=g:"io.github.lognet" AND a:"grpc-spring-boot-starter")

建议Gradle用户应用插件:

```groovy
plugins {
	id "io.github.lognet.grpc-spring-boot" version '5.2.0'
}
```

io.github.lognet.grpc-spring-boot gradle插件大大简化了项目设置。

```groovy
repositories {
  mavenCentral()
  // maven { url "https://oss.sonatype.org/content/repositories/snapshots" } // for snapshot builds
}
dependencies {
  implementation 'io.github.lognet:grpc-spring-boot-starter:5.2.0'
}
```

默认情况下，starter将io.grpc: grpc-nety-shaded作为传递依赖项，如果您被迫使用纯grpc-netty依赖项:

```groovy
implementation ('io.github.lognet:grpc-spring-boot-starter:5.2.0') {
  exclude group: 'io.grpc', module: 'grpc-netty-shaded'
}
implementation 'io.grpc:grpc-netty:1.76.0' // (1)
```

如果您使用的是Spring Boot依赖管理插件，它可能会拉不同的版本，这开始被编译的版本，导致二进制不兼容的问题。
在这种情况下，您需要强制显式设置要使用的grpc版本 (请参阅此处的版本矩阵):

```groovy
configurations.all {
  resolutionStrategy.eachDependency { details ->
    if ("io.grpc".equalsIgnoreCase(details.requested.group)) {
      details.useVersion "1.71.0"
    }
  }
}
```



### 用法



- [enableRefection 启用服务器反射](https://github.com/grpc/ grpc-java/blob/master/documentation/server-reflection-tutorial.md)

```yaml
grpc:
	prot: 6565
	enableRefection: true 	# (可选) 启用服务器反射
	start-up-phase: XXX		# (可选) 设置启动阶段顺序 (默认为Integer.MAX_VALUE)。
	shutdownGrace: 30		# (可选) 设置在正常关闭服务器期间等待先前存在的呼叫完成的秒数。在此期间，新呼叫将被拒绝。负值相当于无限宽限期。默认值为0 (表示不等待)。
	netty-server:
    	keep-alive-time: 30s (1)
    	max-inbound-message-size: 10MB (2)
    	primary-listen-address: 10.10.15.23:0 (3)
    	additional-listen-addresses:
      		- 192.168.0.100:6767 (4)
    	on-collision-prefer-shaded-netty: false (5)
```

- netty-server
  1. 可以使用此处描述的字符串值格式配置持续时间类型属性。
  2. 可以使用此处描述的字符串值配置DataSize类型属性
  3. 暴露在具有自定义端口的外部网络IP上。
     `SocketAddress`类型属性字符串值格式:
     - 主机: 端口 (如果端口值小于1，则使用随机值)
     - 主机 :( 使用默认grpc端口，6565)
  4. 暴露在内部网络IP以及预定义的端口6767。
  5. 如果您在依赖项中同时具有着色库和纯netty库，请选择应创建的NettyServerBuilder类型。这是将传递给GRpcServerBuilderConfigurer的类型 (请参阅自定义gRPC服务器配置)，默认为true (即io.grpc.netty.shaded.io.grpc.net ty.NettyServerBuilder; 如果为false，则io.grpc.net ty.NettyServerBuilder)

















