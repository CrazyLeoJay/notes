# Spring Boot 注解



## `@EnableConfigurationProperties(DataSourceProperties.class)`

>  `@EnableConfigurationProperties(DataSourceProperties.class)` 是 Spring Boot 中一个非常重要的注解，它的作用是**启用并注册 `DataSourceProperties` 类为 Spring 容器中的 Bean，使 Spring Boot 能够将配置文件中的数据库配置自动绑定到这个类**。

### 核心作用

1. **激活配置属性绑定**
    它告诉 Spring Boot："请将配置文件中 `spring.datasource.*` 开头的属性绑定到 `DataSourceProperties` 类的字段上"。
2. **注册为 Spring Bean**
    它使 `DataSourceProperties` 类能够被 Spring 容器管理，成为可注入的 Bean。
3. **提供类型安全的配置**
    通过这种方式，Spring Boot 能够以类型安全的方式处理数据库配置，而不是使用字符串硬编码。



## `@Conditional(MyCustomCondition.class)`





## `@ConditionalOnClass` - 类路径存在性检查

>  **作用**：当类路径中存在指定类时才加载配置

### `@ConditionalOnMissingClass` - 类路径不存在性检查

> **作用**：当类路径中不存在指定类时才加载配置

## `@ConditionalOnProperty` - 配置属性检查

>**作用**：当配置文件中存在特定属性时才加载配置

## `@ConditionalOnMissingBean` - Bean不存在性检查

> **作用**：当容器中没有指定Bean时才创建该Bean











## `@ConditionalOnMissingBean`