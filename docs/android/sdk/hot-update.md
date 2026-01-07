# 代码热更新

> 热更新无法彻底代理升级，在很多方面存在限制和风险，需要自行把控。

Android热更新（也称为热修复）的核心原理是**通过修改类加载器的加载顺序，让修复后的类优先被加载**，从而在不重新发布应用的情况下修复BUG或添加功能。

## 详细原理

### 1. Android类加载机制

- Android中默认使用`PathClassLoader`作为类加载器
- `PathClassLoader`继承自`BaseDexClassLoader`，重写了`findClass()`方法
- 类加载过程：
	1. 系统遍历`dexElements`数组（`DexPathList`类的属性）
	2. 从第一个dex文件开始查找类
	3. 一旦找到匹配的类，就立即返回，不再继续查找

### 2. 热更新实现原理

热更新的关键在于**让修复后的类在类加载时优先被加载**，具体实现方式：

1. 将修复后的类打包成一个独立的dex文件（补丁文件）
2. 通过反射修改系统默认的`PathClassLoader.pathList.dexElements`
3. 将补丁dex的`dexElements`插入到系统默认的`dexElements`数组最前面

这样，当系统加载类时，会优先从补丁dex中加载，从而覆盖原有有问题的类。

### 3. 具体实现步骤

1. 下发补丁（包含修复好的class）到用户手机
2. 使用`DexClassLoader`加载补丁dex文件
3. 通过反射获取`DexClassLoader.pathList.dexElements`
4. 将获取到的`dexElements`插入到系统默认ClassLoader的`dexElements`数组最前面
5. 系统优先加载补丁中的类，实现热修复

### 4. 实现示例代码

```java
// 创建DexClassLoader加载补丁dex
DexClassLoader dexClassLoader = new DexClassLoader(
    patchDexPath, 
    getOptimizedDexPath(context), 
    null, 
    getClassLoader()
);

// 获取补丁dex的dexElements
Field pathListField = BaseDexClassLoader.class.getDeclaredField("pathList");
pathListField.setAccessible(true);
Object pathList = pathListField.get(dexClassLoader);
Field dexElementsField = DexPathList.class.getDeclaredField("dexElements");
dexElementsField.setAccessible(true);
Object[] patchDexElements = (Object[]) dexElementsField.get(pathList);

// 获取系统默认ClassLoader的dexElements
Field systemClassLoaderField = ClassLoader.class.getDeclaredField("pathList");
systemClassLoaderField.setAccessible(true);
Object systemPathList = systemClassLoaderField.get(ClassLoader.getSystemClassLoader());
Object[] systemDexElements = (Object[]) dexElementsField.get(systemPathList);

// 将补丁dexElements插入到系统dexElements最前面
Object[] combinedDexElements = (Object[]) Array.newInstance(
    patchDexElements.getClass().getComponentType(), 
    patchDexElements.length + systemDexElements.length
);
System.arraycopy(patchDexElements, 0, combinedDexElements, 0, patchDexElements.length);
System.arraycopy(systemDexElements, 0, combinedDexElements, patchDexElements.length, systemDexElements.length);

// 通过反射修改系统ClassLoader的dexElements
dexElementsField.set(systemPathList, combinedDexElements);
```

## 热更新的优缺点

### 优点

- 无需重新发版，及时修复问题
- 用户无感知修复，无需下载新应用
- 修复成功率高，把损失降到最低

### 局限性

- 无法修改AndroidManifest文件
- 不能修复所有类型的修改（如资源文件、布局等）
- 需要处理兼容性问题（不同厂商对Android的修改）
- 需要重启应用才能生效（部分框架如AndFix不需要重启）

## 常见热修复框架

- **Nuwa**：可以新增类和字段，兼容到Android 6.0
- **AndFix**：通过Native替换方法指针实现，不需要重启
- **HotFix**：基于类加载器实现
- **Dexposed**：支持AOP编程和热修复

热更新技术虽然能解决紧急BUG修复的问题，但因其涉及Android底层实现，开发维护难度较大。