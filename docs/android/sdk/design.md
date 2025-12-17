# 手游SDK 设计

## 困境和设计思路

> 主要是讲解设计架构的必要和思路来源，可以跳过。

讨论设计之前，先说一下我的日常工作经验。在日常开发过程中，经常会出现各种功能在不同场景下的需要展示不同的样式或者逻辑需求，比如不同环境下，登录是否显示，样式，请求的网站都有不同，一帮情况下，从零到一的开发，都是有什么需求写什么功能，所以会导致一种情况，一些细小的功能会频繁出现嵌套的 if else

```kotlin
if(...){
} else if(...){
} else if(...){
} else if(...){
} else if(...){
} else if(...){
} else ...
```

或者when语句等，如果从需求角度出发，就是所有的场景逻辑都放在一条逻辑线上，给代码维护和的迭代都带来极大的风险，俗称shi山上堆shi。所以，聪明的人就会开始重构，一知半解的半吊子就会觉是你技术太差。

根据经验，这个时候就可以用到二十四种设计模式中的**抽象工厂模式**和**工厂模式**了。并且，所有的设计都是围绕这两个模式展开。



## SDKFactory 定义SDK

首先，SDK的入口，即像是普通程序main入口一样，SDK的入口是**被调用的API**。被调用的API一般是会通过**单例**创建一个**进程唯一**的**对象**，通过这个对象提供SDK能力或者服务。

先定义接口，即SDK要提供哪些功能对外，这个是一切的基础。并且我一般是使用枚举去实现单例，例如：

```kotlin
class SDKSingleInstance {
    fun instance() : SDKFactory = Singler.INSTANCE.factory
    
    enum Singler(val factory: SDKFactory) {
        INSTANCE(SDKFactory());
    }
}

interface SDKFactory {
    ...
}
```

SDKSingleInstance 可以换成你想要的任何SDK名称，不过我后面会讲到如何通过**注解编程**动态生成这个类文件。

但其实，对于SDKFactory，我更建议的是，它仅仅需要定义`initApplication(app:Application)`和`init(context:Activity)`两个方法即可，其他功能定义可以通过其他接口定义，通过继承方式添加到`SDKFactory`上，比如：

```kotlin
interface SDKFactory : AuthFactory, FloatBatFactory, ...{
    fun initApplicatoin(application:Application)
    fun init(context:Activity)
}

/**
 * 账户验证模块
 */
interface AuthFactory {
    fun init(context:Activity)
    fun login(listener:OnLoginListener) // 登录
    fun register() // 注册
    fun logout() // 登出
}

/**
 * 悬浮球
 */
interface FloatBatFactory {
    fun init(context:Activity)
    fun showFloatBat(context:Context)
    fun hideFloatBat()
}

...
```

可以注意到，在实际定义中，有些我定义了重复的方法，这个不是错误，是设计，后面调用时会讲到。



## AbstractSDKFactory  抽象SDK实现

这里建议实现所有的SDK功能，作为保底，之所以定义为Abstract是为了

1. 防止被三方SDK直接引用
2. 如果对外接口有差异，但功能基本没有变化，就改一下链接，这里可以直接设置抽象方法获取链接配置，然后直接以最小代价进行拓展。

先展示示例代码：

```kotlin
abstract class AbstractSDKFactory : SDKFactory, InvocationHandler, ...{
    
    val sdkInvocationHandler = SDKInvocationHandler.Builder()
    	...
    	.build()
    
    fun invoke(Object proxy, Method method, Object[] args) : Object {
        // 拦截器，在调用SDK相应方法之前，都会调用此处，此方法中，避免写业务代码
        return sdkInvocationHandler.invoke(proxy, method, args);
    }

    ... 
    // SDKFactory 实现
}
```

这里我实现了 InvocationHandler 接口，这个是整个SDK插件化的关键。





























