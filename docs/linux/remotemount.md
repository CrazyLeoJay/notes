# 远程挂载

# NFS挂载

## 服务挂载systemed

> 通过g







## 🔌 NFS服务端配置

> 配置远程NFS链接并让它优先于Docker启动，关键在于理解系统服务依赖和挂载点的管理。下面我来详细说明配置步骤和方法。

首先，你需要确保NFS服务器端已经正确设置并共享了目录。

1.  **安装NFS服务器软件**：在NFS服务器上，你需要安装NFS内核服务器包。对于基于Debian的系统（如Ubuntu），可以使用以下命令：
    ```bash
    sudo apt-get update
    sudo apt-get install nfs-kernel-server
    ```
    对于基于RHEL的系统（如CentOS），使用：
    ```bash
    sudo yum install nfs-utils
    ```
    
2.  **配置共享目录**：编辑NFS服务器的配置文件 `/etc/exports`，指定要共享的目录、允许访问的客户端IP及权限。例如，将 `/data` 目录共享给IP为 `192.168.1.100` 的客户端，并赋予读写权限：
    
    ```bash
    /data 192.168.1.100(rw,sync,no_subtree_check)
    ```

3.  **启动NFS服务并设置开机自启**：
    ```bash
    # 启动NFS服务（对于使用systemd的系统）
    sudo systemctl start nfs-kernel-server
    # 设置NFS服务开机自启
    sudo systemctl enable nfs-kernel-server
    ```
    

## 🖥️ NFS客户端配置与挂载

在客户端机器上，你需要挂载NFS共享目录。

1.  **安装NFS客户端软件**：在客户端机器上，同样需要安装NFS客户端包。
    ```bash
    # Debian/Ubuntu
    sudo apt-get install nfs-common
    # RHEL/CentOS
    sudo yum install nfs-utils
    ```
    
2.  **创建本地挂载点**：在客户端创建一个目录，作为NFS共享目录的挂载点。
    ```bash
    sudo mkdir /mnt/nfs
    ```
    
3.  **手动挂载NFS共享**：你可以先手动挂载进行测试。
    ```bash
    sudo mount -t nfs 192.168.233.150:/data /mnt/nfs -o rw,rsize=32768,wsize=32768,hard
    ```
    

## 🔄 配置开机自动挂载并优先于Docker

要让NFS在开机时自动挂载并确保在Docker之前可用，主要有以下几种方法，我推荐使用**方法一**，因为它能更精确地控制依赖关系。

**方法一：创建自定义systemd服务单元（推荐）**

1.  **创建systemd服务文件**：创建一个新的service文件，例如 `/etc/systemd/system/mnt-nfs.mount`。
    
    > **这里注意，需要文件名和 Mount Where匹配，否则系统会报错**
    
    ```
    [Unit]
    Description=NFS Mount for /mnt/nfs
After=network.target rpcbind.target remote-fs.target
    Before=docker.service
    Requires=network.target rpcbind.target
    
    [Mount]
    What=192.168.233.150:/data
Where=/mnt/nfs
    Type=nfs
    Options=rw,rsize=32768,wsize=32768,hard,_netdev
    
    [Install]
    WantedBy=multi-user.target
    ```
    **关键点说明**：
*   `After=network.target rpcbind.target`：确保在网络和RPC绑定服务就绪后再挂载NFS。
    *   `Before=docker.service`：明确指定此挂载单元在Docker服务之前启动。
    *   `Options=_netdev`：这是一个非常重要的选项，它告诉系统这是一个网络文件系统，避免在网络不可用时无限期等待。
    
2. **重新加载systemd配置并启用新服务**：
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable mnt-nfs.mount
   ```

**方法二：在 `/etc/fstab` 中配置并确保正确依赖**

1.  **编辑 `/etc/fstab` 文件**：在文件中添加NFS挂载信息。
    ```
    192.168.233.150:/data /mnt/nfs nfs rw,rsize=32768,wsize=32768,hard,_netdev 0 0
    ```
    同样，`_netdev` 选项至关重要。

2.  **确保Docker服务依赖本地挂载点**：如果你的Docker容器或镜像依赖于这个NFS挂载点，Docker的默认启动顺序可能仍然过早。一个更稳妥的方法是**配置Docker服务本身，使其在NFS挂载点就绪后才启动**。
    *   为Docker服务创建一个drop-in目录和配置文件：
        ```bash
        sudo mkdir -p /etc/systemd/system/docker.service.d
        ```
    *   创建文件 `/etc/systemd/system/docker.service.d/wait-for-nfs.conf`，内容如下：
        ```
        [Unit]
        After=mnt-nfs.mount network-online.target
        Wants=network-online.target
        ```
        这里假设你使用了方法一创建的mount单元。如果你仅使用fstab，systemd会自动生成对应的挂载单元，名称通常是 `-.mount` 格式的转义路径，例如 `mnt-nfs.mount`。
    *   重新加载systemd配置：
        ```bash
        sudo systemctl daemon-reload
        ```

### 🛠️ 验证与故障排查

配置完成后，务必进行验证和测试。

1.  **验证NFS挂载**：重启客户端机器后，使用 `mount | grep nfs` 或 `df -h` 命令检查NFS共享是否已正确挂载。
2.  **检查启动顺序**：你可以使用以下命令来查看启动过程中各个单元的启动顺序和时间，从而判断NFS挂载是否在Docker之前完成。
    ```bash
    systemd-analyze plot > boot-analysis.svg
    ```
    将此SVG文件在浏览器中打开，可以可视化地查看启动流程。
3.  **常见问题**：
    *   **挂载失败**：检查网络连通性、NFS服务器状态、防火墙设置（确保NFS相关端口如2049、111等是开放的）以及 `/etc/exports` 文件中的权限设置。
    *   **Docker启动时NFS未就绪**：仔细检查你创建的systemd单元文件中的 `Before` 和 `After` 依赖关系是否正确，并确认 `_netdev` 挂载选项已添加。

### 💎 总结

总的来说，要确保NFS挂载优先于Docker启动，最可靠的方法是：

*   **使用systemd mount单元** 明确定义NFS挂载，并配置 `Before=docker.service`。
*   在挂载选项中使用 `_netdev`。
*   **必要时调整Docker服务的依赖关系**，确保其 `After` 相应的NFS挂载点。

希望这些详细的步骤能帮助你成功配置NFS并确保其在Docker之前启动。如果你在操作过程中遇到具体问题，例如特定的错误信息，可以提供更多细节，我很乐意进一步协助。



## `deepseek` 提问

> Q: NFS我该如何挂载，如何在ubuntu中让其注册成为开机自启项目，并且考虑一下是否需要优于docker执行。并且给我取消注册的方式

在Ubuntu中配置NFS挂载并设置为开机自启，同时确保它在Docker之前运行，是一个很实用的需求。下面我将为你详细说明操作步骤。

为了让你对整个过程有清晰的了解，我先用一个表格来汇总主要的操作步骤和关键点：

| 步骤                    | 核心操作               | 关键命令/配置                                                | 说明                                 |
| :---------------------- | :--------------------- | :----------------------------------------------------------- | :----------------------------------- |
| **1. 安装NFS客户端**    | 安装必要软件包         | `sudo apt update && sudo apt install nfs-common`             | 提供挂载NFS共享的能力。              |
| **2. 手动挂载测试**     | 创建挂载点并测试       | `sudo mount -t nfs <服务器IP>:<共享路径> /mnt/nfs`           | 验证挂载是否成功。                   |
| **3. 配置开机自动挂载** | 编辑`/etc/fstab`文件   | 添加：`<服务器IP>:<共享路径> /mnt/nfs nfs defaults 0 0`      | 系统启动时自动挂载。                 |
| **4. 处理Docker依赖**   | 创建systemd服务依赖    | 创建Drop-in文件，添加 `After=remote-fs.target` 和 `Requires=remote-fs.target` | 确保Docker在网络文件系统挂载后启动。 |
| **5. 取消挂载与禁用**   | 卸载文件系统并清理配置 | `sudo umount /mnt/nfs`，然后从`/etc/fstab`中移除对应行       | 彻底取消自动挂载。                   |

### 🔌 安装NFS客户端与手动挂载

首先，你需要在Ubuntu系统上安装NFS客户端软件包：
```bash
sudo apt update
sudo apt install nfs-common
```

安装完成后，创建一个目录作为**挂载点**（Mount Point），例如 `/mnt/nfs`：
```bash
sudo mkdir -p /mnt/nfs
```

接下来，进行**手动挂载测试**，这非常重要，可以确保网络和共享权限都没有问题：
```bash
sudo mount -t nfs <NFS服务器IP>:<共享目录路径> /mnt/nfs
```
例如：`sudo mount -t nfs 192.168.1.100:/data /mnt/nfs`

使用 `df -h` 命令检查挂载是否成功。如果能看到刚刚挂载的NFS共享，说明手动挂载步骤完成。

### 🔄 配置开机自动挂载

要让NFS在开机时自动挂载，需要编辑 `/etc/fstab` 文件。
1. 使用 `sudo nano /etc/fstab` 命令编辑文件。
2. 在文件末尾添加一行配置：
   ```
   <服务器IP>:<共享路径> /mnt/nfs nfs defaults 0 0
   ```
   例如：`192.168.1.100:/data /mnt/nfs nfs defaults 0 0`
3. 保存并退出编辑器。
4. 使用 `sudo mount -a` 测试配置是否正确。这个命令会挂载`fstab`中所有配置项，如果没有报错，说明配置正确。

### 🐳 处理与Docker的启动顺序问题

是的，**你需要确保NFS在Docker服务启动之前完成挂载**。如果Docker先启动，而它依赖的存储卷（如果位于NFS上）还未就绪，会导致容器启动失败。

在使用 `systemd` 的Ubuntu系统上，可以通过为Docker服务创建一个 **"Drop-in文件"** 来修改其启动依赖关系。

1. 创建Drop-in文件目录并编辑文件：
   ```bash
   sudo systemctl edit docker
   ```
2. 在打开的编辑器中，添加以下内容，这会让Docker服务在网络文件系统挂载完成之后才启动：
   ```ini
   [Unit]
   After=remote-fs.target
   Requires=remote-fs.target
   ```
3. 保存并退出。之后重新加载systemd配置并重启Docker使其生效：
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   ```

### ↩️ 取消挂载与禁用开机自启

当你不再需要这个NFS挂载时：

1. **取消挂载**：首先确保没有程序正在使用挂载点下的文件，然后使用 `umount` 命令：
   ```bash
   sudo umount /mnt/nfs
   ```
   如果提示 `device is busy`，可以使用 `lsof /mnt/nfs` 命令查看哪些进程占用了挂载点，关闭相应进程后再卸载。

2. **禁用开机自启**：从 `/etc/fstab` 文件中删除或注释掉（在行首加`#`）之前添加的那行NFS挂载配置即可。

希望这份详细的指南能帮助你顺利完成配置。如果你在操作过程中遇到其他问题，可以随时提问。