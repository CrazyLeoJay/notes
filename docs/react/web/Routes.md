# React Route

- [官网](https://reactrouter.com/home)



## 安装

```sh
npm install react-router-dom
```



## 使用

> 安装完成后，通常在应用的入口文件（如 `index.js`）中，使用 `BrowserRouter`（或你选择的其他路由模式）来包裹你的主组件，这样整个应用就可以使用路由功能了

```react
// index.js
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom'; // 1. 引入 BrowserRouter
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <BrowserRouter> {/* 2. 使用 BrowserRouter 包裹 App */}
    <App />
  </BrowserRouter>
);
```



## 定义路由















