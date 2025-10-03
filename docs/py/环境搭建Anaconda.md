# 环境搭建 Conda

网站：

- https://www.anaconda.com/
- https://github.com/ContinuumIO
- 下载路径：https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/



## 环境变量配置

`C:\ProgramData\anaconda3\Scripts`

## 配置文件

路径 user_home/.condarc

示例：

```txt
always_yes: true
channels:
  - defaults
ssl_verify: true
show_channel_urls: true

default_channels:
  - https://mirrors.aliyun.com/anaconda/pkgs/main
  - https://mirrors.aliyun.com/anaconda/pkgs/r
  - https://mirrors.aliyun.com/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.aliyun.com/anaconda/cloud
  msys2: https://mirrors.aliyun.com/anaconda/cloud
  bioconda: https://mirrors.aliyun.com/anaconda/cloud
  menpo: https://mirrors.aliyun.com/anaconda/cloud
  pytorch: https://mirrors.aliyun.com/anaconda/cloud
  simpleitk: https://mirrors.aliyun.com/anaconda/cloud

```

清华大学镜像

```
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  deepmodeling: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/
```





## 查看conda版本

```none
conda -V		
4.10.1
```

## 查看各种虚拟环境

```none
conda info -e		
# conda environments:
#
base                  *  F:\ProgramData\Anaconda3
```

##  创建一个虚拟的 python3.7环境 名字叫enviroment_name

```none
conda create -n enviroment_name python=3.7
```

文件在Anaconda3\envs

虚拟环境 python3.7 与 原生python3.7 完全一致

你甚至可以利用快捷方式创建一个虚拟环境 python3.7的IDLE。与上面的方法一致。

## 虚拟环境的进入与退出

```none
# To activate this environment, use
#
#     $ conda activate py37
#
# To deactivate an active environment, use
#
#     $ conda deactivate
```

这两条命令可以随时进入(退出)这个虚拟的环境，一旦进入，任何操作都与整体Python环境无关。包括下载包。

可以看到这个环境里只有四个包。很简单。

```shell
(py37) C:\Users\hp四核>pip list
Package      Version
------------ -------------------
certifi      2021.5.30
pip          21.0.1
setuptools   52.0.0.post20210125
wheel        0.37.0
wincertstore 0.2
```

## 虚拟环境的删除

```none
conda remove -n py37 --all
```

删除所有的环境相关文件。

