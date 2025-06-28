# Native-客户端-Win开发

> React 本身并不具备Win或者MacOs开发能力，但了可以使用微软开发插件 [react-native-windows](https://microsoft.github.io/react-native-windows/)进行开发，



## 文档链接

- [Recat Win 开发文档](https://learn.microsoft.com/zh-cn/windows/dev-environment/javascript/react-overview)

- [react-native-windows](https://microsoft.github.io/react-native-windows/)
- [React win开发文档](https://microsoft.github.io/react-native-windows/docs/getting-started)



## 创建项目

> 如果要使用yarn可以执行以下命令进行全局安装
>
> ```sh
> npm install --global yarn
> ```
>
> 在win上，可能会碰到无法加载 `yarn.ps1`文件的问题，这个是win的策略限制问题，在管理员模式下，执行命令：
>
> ```sh
> set-ExecutionPolicy RemoteSigned
> ```
>
> 选择是即可

执行以下命令创建一个新项目

```sh
npx --yes @react-native-community/cli@latest init <projectName> --version "^0.79.0"
```

不指定版本，直接使用默认最新

```sh
npx --yes @react-native-community/cli@latest init <projectName>
```



## 添加依赖

执行命令（官方推荐使用 yarn )

```sh
yarn add react-native-windows@^0.79.0
```

或者使用npm

```sh
npm install --save react-native-windows@^0.79.0
```



## 初始化项目

```sh
npx react-native init-windows --overwrite
```

> 注意：metro.config.js 文件会被重置，如果有个人修改，需要重新添加



## 运行项目

### 不使用 Visual Studio

```sh
npx react-native run-windows
```

### 使用 Visual Studio

```sh
npx react-native autolink-windows
```

### 使用VsCode

> 需要按照以下步骤
>
> - 安装插件  [React Native Tools](https://marketplace.visualstudio.com/items?itemName=msjsdiag.vscode-react-native)
> - 在根目录下创建文件：`.vscode/launch.json`，添加以下json内容。
> - 点击F5 或者在调试界面（Debug Windows）点击绿色按钮即可运行。

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Windows",
      "cwd": "${workspaceFolder}",
      "type": "reactnative",
      "request": "launch",
      "platform": "windows"
    }
  ]
}
```



