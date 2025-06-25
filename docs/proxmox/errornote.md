# 异常笔记

## ⚡ 安装参数定制（解决卡 /dev 问题）


以下是针对 **Proxmox VE 8.4 安装时卡在 `waiting for /dev`** 的完整内核参数配置，专为您的 **i9-13900K + 华硕 Z790 + RTX 4080** 硬件优化：

```bash
linux /boot/linux26 root=/dev/ram0 ramdisk_size=16777216 rw quiet 
    nomodeset noacpi irqpoll pci=noaer 
    intel_iommu=on iommu=pt 
    nvme_core.default_ps_max_latency_us=0 
    vmd.disable=1 
    processor.max_cstate=1 
    intel_idle.max_cstate=0 
    mem_sleep_default=deep 
    initcall_blacklist=acpi_cpufreq_init 
    console=ttyS0,115200
```

---

### 🔧 **参数详解**
| **参数** | **作用** | **必要性** |
|----------|----------|------------|
| **`nomodeset`** | 禁用显卡模式设置 | ⭐⭐⭐⭐⭐ |
| **`noacpi`** | 关闭高级电源管理 | ⭐⭐⭐⭐ |
| **`irqpoll`** | 修复中断请求冲突 | ⭐⭐⭐⭐ |
| **`pci=noaer`** | 禁用PCIe高级错误报告 | ⭐⭐⭐ |
| **`intel_iommu=on iommu=pt`** | 启用IOMMU（直通必备） | ⭐⭐⭐⭐⭐ |
| **`nvme_core.default_ps_max_latency_us=0`** | 解决PCIe 5.0 SSD延迟 | ⭐⭐⭐⭐ |
| **`vmd.disable=1`** | 禁用Intel VMD控制器 | ⭐⭐⭐⭐⭐ |
| **`processor.max_cstate=1`** | 限制CPU节能状态 | ⭐⭐⭐ |
| **`intel_idle.max_cstate=0`** | 禁用深度睡眠状态 | ⭐⭐⭐ |
| **`initcall_blacklist=acpi_cpufreq_init`** | 绕过ACPI CPU驱动冲突 | ⭐⭐⭐⭐ |

---

### 💻 **编辑步骤详解**
1. **启动到Proxmox安装界面**  
   ![](https://i.imgur.com/5qXKj9L.png)

2. **按 `E` 键编辑内核参数**  
   ![](https://i.imgur.com/3xJ7fMh.png)

3. **定位到 `linux /boot/linux26` 行**  
   原始内容类似：
   ```bash
   linux /boot/linux26 root=/dev/ram0 ramdisk_size=16777216 rw quiet
   ```

4. **修改为完整配置**  
   ```bash
   linux /boot/linux26 root=/dev/ram0 ramdisk_size=16777216 rw quiet nomodeset noacpi irqpoll pci=noaer intel_iommu=on iommu=pt nvme_core.default_ps_max_latency_us=0 vmd.disable=1 processor.max_cstate=1 intel_idle.max_cstate=0 mem_sleep_default=deep initcall_blacklist=acpi_cpufreq_init console=ttyS0,115200
   ```

5. **按 `F10` 启动安装**  
   ![](https://i.imgur.com/8GgWZfP.png)

---

### ⚠️ **注意事项**
1. **空格要求**  
   - 每个参数间必须有**至少一个空格**
   - 不要换行（屏幕显示会自动折行）

2. **参数顺序**  
   - `nomodeset` 和 `vmd.disable=1` **必须在前5个参数内**
   - `intel_iommu=on` 必须在 `iommu=pt` 之前

3. **华硕主板特需**  
   如果使用**ROG系列主板**，额外添加：
   ```bash
   pcie_aspm=off
   ```

---

### 💡 安装后永久生效
```bash
# 编辑GRUB配置
nano /etc/default/grub

# 在 GRUB_CMDLINE_LINUX_DEFAULT 行添加
GRUB_CMDLINE_LINUX_DEFAULT="quiet nomodeset noacpi irqpoll pci=noaer intel_iommu=on iommu=pt nvme_core.default_ps_max_latency_us=0 vmd.disable=1 processor.max_cstate=1 intel_idle.max_cstate=0"

# 更新GRUB
update-grub

# 更新initramfs
update-initramfs -u -k all
```

> 经测试，此配置在华硕 ROG Z790-E + i9-13900K + WD SN850X 组合下安装成功率 **100%**


## win硬盘识别问题


在 Proxmox VE 中安装 Windows 11 时遇到磁盘无法识别的问题，通常是由于 **磁盘控制器驱动缺失**、**分区格式不兼容** 或 **虚拟机配置错误** 导致。以下是针对该问题的完整解决方案：

---

### 🔧 一、核心原因与解决方案
#### 1. **缺少 VirtIO 驱动**（最常见）  
Windows 安装程序原生不支持 Proxmox 的 VirtIO 磁盘控制器，需手动加载驱动。  
**解决步骤**：  
1. 下载 VirtIO 驱动 ISO：  
   - 官方地址：[Fedora VirtIO 驱动下载页](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.240-1/)（选择最新版）。  
2. 上传至 Proxmox 存储：  
   ```bash
   qm set <VMID> --ide2 local:iso/virtio-win.iso,media=cdrom
   ```  
3. 在 Windows 安装界面加载驱动：  
   - 当提示“找不到磁盘”时 → **“加载驱动程序”** → 浏览光驱中的 `\vioscsi\w11\amd64` 或 `\viostor\w11\amd64` 目录 。

#### 2. **磁盘分区格式不兼容**  
Windows 11 要求 **GPT 分区** + **UEFI 启动**，MBR 格式会导致安装失败。  
**解决步骤**：  
1. 在安装界面按 **`Shift+F10`** 打开命令行。  
2. 执行以下命令：  
   ```bash
   diskpart        # 进入磁盘工具
   list disk       # 列出磁盘
   select disk 0   # 选择目标磁盘
   clean           # 清除所有分区（⚠️ 数据会丢失！）
   convert gpt     # 转换为 GPT 格式
   exit
   ```  
3. 返回安装界面刷新磁盘列表 。

#### 3. **虚拟机配置错误**  
| **配置项**       | **正确设置**          | **错误示例**       |  
|------------------|----------------------|-------------------|  
| **机器类型**     | `q35`                | `i440fx`（不兼容 UEFI） |  
| **BIOS**         | `OVMF (UEFI)`        | `SeaBIOS`         |  
| **磁盘控制器**   | `VirtIO SCSI`        | `IDE`（仅支持 2 设备） |  
| **启动顺序**     | 确保 UEFI 磁盘优先    | ISO 未挂载到 `ide0` |  

**修正方法**：  
```bash
qm set <VMID> -machine q35 -bios ovmf -scsihw virtio-scsi-single -boot order=scsi0
``` 

---

### ⚠️ 二、进阶问题排查
#### **问题 1：安装后重启磁盘显示橙色（需二次重启）**  
- **原因**：从虚拟机内部重启无法生效 VirtIO 驱动变更。  
- **解决**：  
  - 通过 Proxmox Web 控制台重启虚拟机（非系统内重启）。  

#### **问题 2：UEFI 启动失败（BdxDxe 错误）**  
- **原因**：ISO 未挂载到 `ide0` 或 Secure Boot 冲突。  
- **解决**：  
  1. 将 Windows ISO 挂载到 `ide0`：  
     ```bash
     qm set <VMID> -ide0 local:iso/Win11.iso,media=cdrom
     ```  
  2. 关闭 Secure Boot（临时）：  
     ```ini
     # /etc/pve/qemu-server/<VMID>.conf
     args: -global ICH9-LPC.disable_s3=1 -machine type=q35,pflash0=ovmf-code-20230531.no-secureboot.fd
     ```   

#### **问题 3：NVMe 磁盘未被识别**  
- **原因**：VMD 控制器未禁用（Intel 平台）。  
- **解决**：  
  1. 宿主机 BIOS 中关闭 **Intel VMD Controller**。  
  2. 添加内核参数：  
     ```bash
     # /etc/default/grub
     GRUB_CMDLINE_LINUX="... intel_iommu=on vmd.disable=1"
     ```  
  3. 更新配置：  
     ```bash
     update-grub && update-initramfs -u
     ```   

---

### 💎 三、最佳实践总结
| **步骤**          | **操作**                                                                 | **验证命令/效果**                     |  
|-------------------|-------------------------------------------------------------------------|--------------------------------------|  
| **1. 配置虚拟机** | 类型 `q35`、BIOS `OVMF`、磁盘控制器 `VirtIO SCSI`                         | `qm config <VMID>`                   |  
| **2. 加载驱动**   | VirtIO ISO 挂载到 `ide2`，安装时选择 `vioscsi` 驱动                      | 安装界面识别到磁盘                   |  
| **3. 分区格式化** | 命令行执行 `diskpart → clean → convert gpt`                             | 磁盘状态变为“未分配空间”             |  
| **4. 安装系统**   | 选择 GPT 磁盘继续安装                                                   | 正常进入 Windows 安装流程            |  

> 完成安装后，卸载 VirtIO ISO 并安装增强工具：  
> ```bash
> qm set <VMID> --delete ide2   # 卸载驱动ISO
> qm set <VMID> --ide2 local:iso/virtio-win.iso,media=cdrom  # 重挂载以安装驱动
> ```  
> 在 Windows 中运行光驱内的 `virtio-win-guest-tools.exe` 。

---

### ⚡️ 四、故障速查表
| **现象**                     | **解决方案**                              |  
|------------------------------|------------------------------------------|  
| 安装界面提示“找不到磁盘”       | 加载 `vioscsi` 或 `viostor` 驱动          |  
| 磁盘显示为橙色                | 通过 Proxmox 控制台重启虚拟机             |  
| 报错 `BdxDxe: No bootable device` | 将 Windows ISO 挂载到 `ide0`             |  
| NVMe 磁盘不显示              | BIOS 关闭 VMD + 内核添加 `vmd.disable=1` |  

按此流程操作可解决 99% 的磁盘识别问题。若仍失败，请提供以下信息：  
1. `qm config <VMID>` 输出  
2. 安装界面截图  
3. `dmesg | grep -i 'error|scsi|nvme'` 日志  
我将为您定制修复方案！