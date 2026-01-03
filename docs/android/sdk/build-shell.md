# APK 反编译构建脚本

## 目的

脚本的目的是，将两个定义了统一接口的APK文件，通过反编译、代码合并资源整合、重新构建的方式合二为一，构建新的APK。实现：

- 修复bug
- 更新SDK
- 注入新功能

等目的。

## 依赖库

> 这里提到的库，分别在脚本和分析代码中有用到。

- [ApkTool](https://github.com/iBotPeaches/Apktool)：反编译和构建的主要工具
- [Android SDK tools](https://developer.android.google.cn/tools?hl=zh-cn): Android SDK 库和命令行工具，[下载](https://developer.android.google.cn/studio?hl=zh-cn)，而且有些库工具我们需要从这里获取。
	- [AAPT2](https://developer.android.google.cn/tools/aapt2?hl=zh-cn)：资源打包工具。exe/bin文件，在ApkTool中已经集成。
	- [apksigner](https://developer.android.google.cn/tools/apksigner?hl=zh-cn)： 签名工具。jar文件。在目录`Android-SDK\build-tools\{工具版本，比如:28.0.3}\lib\apksigner.jar`
	- [sdkmanager](https://developer.android.google.cn/tools/sdkmanager?hl=zh-cn)：SDK管理工具，可以通过这个命令去加载SDK资源。
- [dex2jar](https://sourceforge.net/projects/dex2jar/files/)：dex转jar
- [jd-gui](http://jd.benow.ca/)：对Jar进行反编译
- [baksmali](https://github.com/JesusFreke/smali)：将dex文件编译成smali文件

## 脚本-反编译

反编译部分比较简单，引入`apktool.jar`，直接解析ApkTool源代码。解析命令*`apktool d file.apk {options}`*部分，可以构建一个Builder对象来代理实现。

后面会讲反编译apk获取到的文件称为反编译资源。

## 脚本-代码合并

首先，将渠道apk包资源和目标apk包资源进行代码合并。

- 渠道apk包资源：接入SDK的Demo，提供了最新的SDK代码。
- 目标apk包资源：接入SDK的游戏或者其它三方平台包。接入了某个版本的SDK，不一定是最新，但接入的接口必须和最新的SDK保持一致。也成为三方资源包。

> 这里，我将合并后的资源称为**三方渠道合并资源**

### 代码合并

这里主要是讲反编译后得到的Smali代码进行合并，注意需要保证各自服务的包名要保持独立，且包不能混淆，或者是关键接口类不可以混淆。

这里由于三方资源包情况不受控制，所以在合并时，用三方资源包作为基础，尽可能不去修改。

### 资源合并

将两个资源包res目录下的文件，除了`/res/values`下的xml，按照目录依次合并，冲突文件以渠道包为准。

合并`/res/values/*.xml`文件时（public.xml除外），需要读取其内容，然后合并条目，写入新文件。

public.xml涉及到资源ID分配，下一节会讲到。

### 合并的资源ID处理

将不同资源包的res、assets资源合并后，还需要处理代码或者`*.xml`中引用的资源ID。

一些名词定义：

- 资源名称：定义一传代码中引用的名称。
- 资源路径：实际资源存放路径。并且在`/res/values/{type}.xml`定义与资源名称的关联关系。
- 资源ID：每个资源的唯一方位id。在 `/res/values/public.xml`中定义与资源名称的对应关系。
- 资源类型：根据Android的资源分类进行划分。有：drawable、color、attrs、layout、mipmap、arrays、id、dimen、interger、string、style、string-array。基本涵括，但也不保证会有新的类型，可以去官方文档或者实际开发情况去调整。

> **由于存在资源合并情况，渠道包的资源名称和三方资源名称不能有冲突，需要在开发时各自添加独立的标识，用以区分，防止合并时导致资源丢失！！！**

在Android系统中，构建代码时，会给每个资源分配一个资源ID，并且会在代码中存在`R.java`文件中，反编译成`R.smali`或者`R$`开头的其他Samli文件，并且在目录`/res/values/public.xml`中记录ID和资源的关系。`style.xml`中定义的属性和资源关系，会按照类型名称存在`/res/values/{type}.xml`，文件中。

ID是三部分组成的32位整数。转为16进制为八位，例如：`0x7f010001`。

1. **包ID (Package ID) - 8位**：标识资源所属的应用包。在宿主应用中，通常为`0x7F`，即127。但也不能保证三方资源包中的id使用这个数，所以一般从资源包中获取id来解析这个值。
2. **类型ID (Type ID) - 8位**：标识资源类型，例如drawable、string、layout等。系统会为每种资源类型分配一个唯一的类型ID。由于每次打包都可能不一致，所以也是从三方资源包中解析类型id，如果某些类型没有，则按照已有的id加一后赋予。
3. **条目ID (Entry ID) - 16位**：标识资源在该类型中的唯一标识。例如，对于string资源，条目ID就是字符串在string资源中的唯一标识。

```txt
┌─────────────┬──────────────┬─────────────────┐
│  包ID (8位) │  类型ID (8位) │  条目ID (16位)  │
└─────────────┴──────────────┴─────────────────┘
```

在合并资源时，定义一个数据类型`Map<String, Map<String, Long>>`，用来保存资源ID数据。

- 第一层map的key表示资源类型，直接使用资源名称。
- 第二层map的key表示资源名称
- 第二层map的value表示资源ID

比对两个类型数据集，分析渠道包数据并根据以下规则合并数据获得唯一的资源ID数据集。

- 以三方资源包的类型数据集为基准。
- 先通过资源ID分析获取数据类型对应的**类型ID**并且保存记录为`Map<String,Long>`类型ID关联数据集。
- 由于每个类型的资源ID分配最后四位时按照十六进制流水号分配，则还需要一个数据集保存每个类型中，最大流水号是多少，并且在新增时+1后合并组成新的ID分配个资源。
- 分析渠道包资源ID
	- 如果三方资源ID中存在同名资源，则忽略该资源id
	- 如果三方资源ID中不存在，且没有该数据类型，则新建立一个类型，并且在类型ID中注册，设置一个唯一类型ID。并且该类型的标记从1开始，比如新定义的类型为`2E`，则起始ID为：`0x7f2E0001`
	- 如果三方资源ID中不存在，但有数据类型，则取当前类型最大的流水号+1作为当前资源的新ID，并保存到结果ID。
- **保存资源新ID时，需要记录旧ID**（可以将Long改为数据实体存储。），便于在后续中，根据旧ID去修改代码中的引用为新资源ID。

获取到合并后的资源ID数据集后。重新将结果按照指定格式写入`res/values/public.xml`文件。

然后遍历smali代码。修改R文件中引用的资源ID代码。

> 修改代码中的资源id时，会有一些id是成组的存在，也有一些id是和其他资源的新ID一样，然后造成冲突，所以在保证三方资源包数据不变的情况下，代码建议是先修改渠道包的资源ID，保证每个文件仅修改一次。然后再进行合并，基本能解决大部分问题。

### 合并AndroidManifest.xml

这个没啥可说的，直接按照[官方逻辑合并](https://developer.android.google.cn/build/manage-manifests?hl=zh-cn)。

我找到了官方的合并脚本，可以直接使用。下载SDK后需要下载`Android-SDK-Command-line Tools`。

然后在目录：`sdk/cmdline-tools/latest/lib/build-system/`中可以获取。还有其他的工具可自行研究。

> 由于三方资源包接入过SDK，所以会存在冲突，所以在合并前需要修改渠道AndroidManifest文件的参数，根据官方文档，配置一些合并时可能存在冲突的参数。



## 脚本-参数配置

实际构建中，最后构建时，需要写入特定的一套参数。我将这些数据抽象为一个数据实体，根据不同的数据类型修改：

- 应用名称
- 应用ICON
- AndroidManifest文件中的参数配置
- 修改string.xml中的参数
- 。。。

基本上每种不同的参数修改都需要写一个配套的代码，Android开发的基本功了属于是，这里就不作阐述了。

如果需要支持多种方式获取参数，那么还需要注意数据类型的结构，是使用Json、properties或者是xml都可以。

最理想的方法是，直接让服务器后端直接开放接口，通过一个唯一标识，直接获取到所有的配置数据，减少文本或者人工传递可能产生的错误情况。

> 后端情况比较复杂，有时候牵扯到多个系统之间的参数维护，所以需要有一端能够统一获取采集数据后汇总出配置参数，为了方便其他职位同事理解也可以称为物料。



## 脚本-重新构建APK

使用Apktool直接将处理好的三方渠道合并资源构建成APK文件。

> Tip：如果渠道包和三方包没有更新，可以使用其中一个构建好的apk作为公共资源包，反复反编译、修改参数、构建也是可以的，不必每次都去走合并流程。

## 脚本-签名

签名是必须的，但也没啥可说的，直接看[官网](https://developer.android.google.cn/tools/apksigner?hl=zh-cn)。

```shell
apksigner sign --ks keystore.jks --key key.pk8 --cert cert.x509.pem [signer_options] app-name.apk
```

验证：

```shell
apksigner verify [options] app-name.apk
```

脚本中引入jar。直接使用main函数，或者解析原理，可以使用。

这里需要注意的点是需要关注下签名版本和签名工具的版本，后面Walle二次分发时会有影响。

## Walle 二次分发（美团渠道包参数写入）

- https://tech.meituan.com/2017/01/13/android-apk-v2-signature-scheme.html
- https://github.com/Meituan-Dianping/walle

由于Walle写入会影响到签名，所以对于不同版本的签名工具，可能会出现不支持的情况，轻则导致无法获取，重则导致Apk无法安装，在选定版本后，需要做多次的测试，确保是可以正常使用的。



