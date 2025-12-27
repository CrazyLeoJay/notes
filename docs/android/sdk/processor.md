# 注解编程在SDK开发中应用

可以参考项目：https://github.com/CrazyLeoJay/sdk-auto-services/tree/master

## 什么是注解编程

注解编程是在代码编译时，会采集代码中特定注解注释的类、方法、参数等，自动生成模板代码的过程。

比如我定义注解：

 ```kotlin
@Retention(AnnotationRetention.RUNTIME)
@Target(AnnotationTarget.CLASS)
@MustBeDocumented
annotation class SDKModule
 ```

然后配置注解处理器：

```kotlin
@AutoService(Processor::class)
class SingleProcessor : AbstractProcessor() {
    override fun process(
        annotations: Set<TypeElement?>?,
        roundEnv: RoundEnvironment?,
    ): Boolean {
        // 通过 roundEnv 获取注解了 SDKModule 的实体
        // 编写类生成过程
        // 通过 super.processingEnv 获取工具实例。有element工具和类工具等，还可以通过这个工具写入生成的类文件
        return true
    } 
    
    override fun getSupportedAnnotationTypes(): Set<String?> {
        return setOf(
            SDKModule::class.java.canonicalName,
            ...
        )
    }
}
```

这里用到了 `@AutoService(Processor::class)`，它会自动生成`classpath:META-INF/services/javax.annotation.processing.Processor`文件，这个文件中会生成`SingleProcessor`类全路径。这样在依赖时使用 annotationProcessor 或者 kapt（主要针对Kotlin语言） 导入时，会执行process方法。

## 依赖

注解使用了以下库，根据需要生成的语言进行自主选择：

- Google的Auto库 ：https://github.com/google/auto/tree/main/service
- Square的KotlinPoet库：https://square.github.io/kotlinpoet/
- Square的JavaPoet库：https://github.com/square/javapoet

我是用的时Gradle构建项目，并且是8.0.0版本，一般习惯于配置文件`libs.versions.toml`文件：

> 截止日期：2025年12月27日（如果时间太久可以自己去[仓库](https://central.sonatype.com/)搜索一下最新版本，由于是注解编程，库代码并不会加载到最终代码中，所以可以随心所欲加入方便的库和更新版本。）

```toml
[libraries]
squareup-java-poet = { module = "com.squareup:javapoet", version = "1.13.0" }
squareup-kotlin-poet = { module = "com.squareup:kotlinpoet", version = "2.2.0" }
squareup-kotlin-poet-ksp = { module = "com.squareup:kotlinpoet-ksp", version = "2.2.0" }
squareup-kotlin-poet-metadata = { module = "com.squareup:kotlinpoet-metadata", version = "2.2.0" }
# https://central.sonatype.com/search?q=com.google.auto.service
auto-service = { module = "com.google.auto.service:auto-service", version = "1.1.1" }
auto-service-annotations = { module = "com.google.auto.service:auto-service-annotations", version = "1.1.1" }

```

Processor build.gradle 文件中导入：

```groovy
plugins {
    ...
    kotlin("jvm")
    kotlin("kapt")
}

dependencies {
   ...
    // 生成kotlin类文件
    implementation(libs.squareup.kotlin.poet)
    // 下面两个库可以直接看官方文档
    // https://square.github.io/kotlinpoet/interop-ksp/
    implementation(libs.squareup.kotlin.poet.ksp)
    // https://square.github.io/kotlinpoet/interop-kotlin-metadata/
    implementation(libs.squareup.kotlin.poet.metadata)
    // 如果使用java，使用这个依赖
//    implementation(libs.squareup.java.poet)
    
    
    // 引入注解工具的基础类
    implementation(libs.auto.service.annotations)
    // 通过注解加载工具
    kapt(libs.auto.service)
}
```

## 实现

这里不具体描述怎么编写，具体可以看[官方文档](https://square.github.io/kotlinpoet/code-control-flow/)，非常详细。这里主要讲一下项目结构和一些注意事项。

首先，创建两个Library，一个 **processor** 和 **utils**，定义的注解和一些引入的工具类需要放在 utils lib 中。具体的 AbstractProcessor 实现在项目 processor 中。类似于google auto service 引入一样。







