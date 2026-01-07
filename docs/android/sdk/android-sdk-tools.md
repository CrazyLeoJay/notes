# Android SDK Tools 工具使用

- [Android 中文官网](https://developer.android.google.cn/?hl=zh-cn)
- [Android 命令行工具](https://developer.android.google.cn/tools?hl=zh-cn)

在开发SDK反编译构建脚本时我就在想，既然Android studio已经处理了例如AndroidManifest冲突、dex分包、混淆、签名、压缩、4k对其等工作，并且cmd也支持，那这些工具一定是在AndroidSDKTools中的，然后我翻找目录，这些基本上是通过jar实现的，也有二进制脚本，所以其实不管是开发脚本或者是自动化构建服务，都可以依赖使用。这里会列举一些用到的东西。

> 以前是 tools目录的lib下会有很多jar包，截止2026年1月7日，目前是移动到了 `Sdk\cmdline-tools\19.0\lib`目录下，还可以去下载不同的版本。



## [AAPT2](https://developer.android.google.cn/tools/aapt2?hl=zh-cn)

（官定）AAPT2（Android 资源打包工具）是一种构建工具，Android Studio 和 Android Gradle 插件使用它来编译和打包应用的[资源](https://developer.android.google.cn/guide/topics/resources/providing-resources?hl=zh-cn)。AAPT2 会解析资源、为资源编制索引，并将资源编译为针对 Android 平台进行过优化的二进制格式。

是一个二进制文件，在不同的平台都有不同编译实现，build-tools 目录下。著名的ApkTool就封装了它的实现，并且我们开发中需要注意版本是否适配，需要按需选择版本，并不是越新越好。



## [apksigner](https://developer.android.google.cn/tools/apksigner?hl=zh-cn)

Apk 签名工具，在目录`build-tools\36.1.0\lib`下，不同的版本都会有一个签名工具，但这个jar包有自己的版本号，可以通过-v查看。可以引入脚本项目分析Main然后自己去实现更为复杂的功能。

使用时需要注意签名方案变化，如果使用美团Walle需要注意版本配合，多做测试。

[v2](https://developer.android.google.cn/about/versions/nougat/android-7.0?hl=zh-cn#apk_signature_v2)：Android 7.0时引入。

---

[V3](https://source.android.google.cn/docs/security/features/apksigning/v3?hl=zh-cn)：Android 9 支持 [APK 密钥轮替](https://developer.android.google.cn/about/versions/pie/android-9.0?hl=zh-cn#apk-key-rotation)，这使应用能够在 APK 更新过程中更改其签名密钥。为了实现轮替，APK 必须指示新旧签名密钥之间的信任级别。为了支持密钥轮替，我们将 [APK 签名方案](https://source.android.google.cn/docs/security/features/apksigning/v2?hl=zh-cn)从 v2 更新为 v3，以允许使用新旧密钥。v3 在 APK 签名分块中添加了有关受支持的 SDK 版本和 proof-of-rotation 结构体的信息。

> **注意：****不**建议在 Android 12（API 级别 31）及更低版本中使用 APK 密钥轮替。在 Android 13（API 级别 33）及更高版本中，`checkSignatures` 会识别 proof-of-rotation 并返回最新的签名。注册了 Play 应用签名的开发者可以通过 Play 管理中心请求[密钥升级](https://support.google.com/googleplay/android-developer/answer/9842756?visit_id=637956329958708614-3522265763&rd=1&hl=zh-cn#upgrade&zippy=,request-a-key-upgrade-for-new-installs-not-suitable-for-all-apps,request-a-key-upgrade-for-all-installs-on-android-t-api-level-and-above-recommended)。

---

[v3.1](https://source.android.google.cn/docs/security/features/apksigning/v3-1?hl=zh-cn)：Android 13 支持 APK 签名方案 v3.1，即现有 [APK 签名方案 v3](https://source.android.google.cn/docs/security/features/apksigning/v3?hl=zh-cn) 的改进版本。v3.1 方案解决了 APK 签名方案 v3 在轮替方面的一些已知问题。具体而言，v3.1 签名方案支持 SDK 版本定位功能，这会允许轮替定位到平台的更高版本。

v3.1 签名方案使用在 Android 12 或更低版本中无法识别的分块 ID。因此，平台会应用以下 signer 行为：

- 搭载 Android 13 或更高版本的设备使用 v3.1 分块中的轮替 signer。
- 搭载旧版 Android 的设备会忽略轮替 signer，而使用 v3 分块中的原始 signer。

尚未轮替其签名密钥的应用无需执行任何其他操作。每当这些应用选择轮替时，系统都会默认应用 v3.1 签名方案。

---

[v4](https://source.android.google.cn/docs/security/features/apksigning/v4?hl=zh-cn)：Android 11 通过 APK 签名方案 v4 支持与流式传输兼容的签名方案。v4 签名基于根据 APK 的所有字节计算得出的 Merkle 哈希树。它完全遵循 [fs-verity](https://www.kernel.org/doc/html/latest/filesystems/fsverity.html#merkle-tree) 哈希树的结构（例如，对盐进行零填充，以及对最后一个分块进行零填充。）Android 11 将签名存储在单独的 `.apk.idsig` 文件中。v4 签名需要 [v2](https://source.android.google.cn/docs/security/features/apksigning/v2?hl=zh-cn) 或 [v3](https://source.android.google.cn/docs/security/features/apksigning/v3?hl=zh-cn) 签名作为补充。



## [zipalign](https://developer.android.google.cn/tools/zipalign?hl=zh-cn)

`zipalign` 是一种 zip 归档文件对齐工具，有助于确保归档文件中的所有未压缩文件相对于文件开头对齐。这样一来，您便可直接通过 `mmap(2) `访问这些文件，而无需在 RAM 中复制这些数据并减少了应用的内存用量。

在目录`build-tools/36.1.0/`下是一个二进制文件，没法直接jar调用，根据实际情况调整



## manifest-merger

在目录`Sdk\cmdline-tools\19.0\lib\build-system\tools.manifest-merger.jar`

这个类是处理Manifest文件和合并和冲突处理。它复合[规则](https://developer.android.google.cn/build/manage-manifests?hl=zh-cn)。

所以只需要做简单的处理，就可以高效的合并AndroidManifest文件。





















