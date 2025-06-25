# 控制帮助手册

## 显示器分配

在虚拟化环境中为指定虚拟机分配显示器，主要通过硬件直通（PCI Passthrough）、虚拟化显示协议（如SPICE）或多显示器配置实现。以下是具体方法及操作步骤，结合不同场景提供解决方案：

---

### ⚙️ 一、**硬件直通（PCI Passthrough）——物理显示器直连**
适用于需独占物理显卡（如游戏/图形设计）的场景，需支持VT-d/IOMMU。
#### **操作步骤：**
1. **启用IOMMU并绑定设备**  
   - 在Proxmox VE宿主机编辑GRUB配置：  
     ```bash
     nano /etc/default/grub
     # Intel平台添加：
     GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
     # AMD平台添加：
     GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"
     ```
   - 更新配置并重启：  
     ```bash
     update-grub && update-initramfs -u -k all && reboot
     ```
   - 验证IOMMU分组：  
     ```bash
     dmesg | grep -i iommu  # 检查是否启用成功
     find /sys/kernel/iommu_groups/ -type l  # 查看分组
     ```

2. **绑定GPU到VFIO驱动**  
   - 获取GPU设备ID（如RTX 4080的ID为`10de:2684`）：  
     ```bash
     lspci -nn | grep NVIDIA
     ```
   - 创建VFIO配置文件：  
     ```bash
     echo "options vfio-pci ids=10de:2684,10de:228b" > /etc/modprobe.d/vfio.conf
     ```

3. **虚拟机配置直通**  
   - 在Proxmox Web界面编辑虚拟机配置（如VMID 102）：  
     ```bash
     qm set 102 -hostpci0 01:00.0,pcie=1,romfile=patched.rom
     qm set 102 -hostpci1 01:00.1  # 音频设备
     ```
   - 添加破解NVIDIA限制的参数（防Code 43错误）：  
     ```ini
     args: -cpu 'host,hv_vendor_id=proxmox'
     ```

4. **连接物理显示器**  
   - 将显示器接入直通显卡的物理接口（如HDMI/DP），启动虚拟机后安装原生显卡驱动。

---

### 🖥️ 二、**虚拟化显示协议（SPICE/QXL）——多虚拟显示器**
适用于无需物理显卡、通过客户端远程访问多显示器的场景。
#### **操作步骤：**
1. **虚拟机配置SPICE协议**  
   - 在Proxmox中设置虚拟机硬件：  
     - 显示类型选择 **SPICE**，内存分配64MB以上  
     - 添加虚拟显卡 **QXL**（支持多屏）  
   - 手动修改配置文件（如VMID 100）：  
     ```bash
     qm set 100 -vga qxl -display spice
     ```

2. **配置多显示器参数**  
   - 编辑虚拟机配置文件（`/etc/pve/qemu-server/100.conf`）：  
     ```ini
     args: -spice 'port=6100,addr=0.0.0.0,password=123456,disable-ticketing=on'
     spice: monitors=2  # 启用2个虚拟显示器
     ```

3. **客户端连接**  
   - 使用 **Virt-Viewer** 或 **Remote Viewer** 连接：  
     - 地址：`spice://<宿主机IP>:6100`  
     - 密码：`123456`  
   - 在客户端内可拖拽窗口到不同显示器。

---

### 🔄 三、**SR-IOV核显虚拟化（Intel GVT-g / AMD MxGPU）**
适用于共享核显给多个虚拟机（如轻量级桌面/容器）。
#### **操作步骤（以Intel核显为例）：**
1. **启用SR-IOV支持**  
   ```bash
   # 编辑GRUB参数
   GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on i915.enable_guc=3 i915.max_vfs=7"
   ```

2. **创建虚拟GPU设备**  
   ```bash
   echo 2 > /sys/devices/pci0000:00/0000:00:02.0/sriov_numvfs  # 创建2个虚拟GPU
   ```

3. **分配VF给虚拟机**  
   ```bash
   qm set 101 -hostpci0 00:02.1  # 分配第一个VF
   qm set 102 -hostpci0 00:02.2  # 分配第二个VF
   ```

---

### 🧩 四、**虚拟机内多显示器设置**
分配后需在虚拟机操作系统中配置显示器布局。
#### **Windows虚拟机：**
1. 右键桌面 → **显示设置** → 识别并排列多显示器  
2. 设置主屏、扩展模式及分辨率。

#### **Linux虚拟机（Ubuntu为例）：**
1. 安装显卡驱动（如NVIDIA）：  
   ```bash
   sudo apt install nvidia-driver-535
   ```
2. 使用 `xrandr` 配置：  
   ```bash
   xrandr --output HDMI-1 --auto --right-of HDMI-2  # 设置HDMI-1在HDMI-2右侧
   ```

---

### 📊 **方案对比与选型建议**
| **方法**           | 适用场景                     | 性能    | 复杂度 | 多屏支持       |
|--------------------|----------------------------|---------|--------|----------------|
| **PCI直通**        | 游戏/3D渲染                | ⭐⭐⭐⭐⭐   | ⭐⭐⭐⭐   | 物理显示器直连 |
| **SPICE/QXL**      | 远程办公/轻量级多任务       | ⭐⭐      | ⭐⭐     | 虚拟多屏       |
| **SR-IOV核显**     | 多虚拟机共享核显            | ⭐⭐⭐     | ⭐⭐⭐    | 有限支持（≤7屏）|

---

### ⚠️ **常见问题解决**
- **直通后黑屏**：  
  添加 `video=efifb:off` 到GRUB参数，释放帧缓冲。
- **SPICE无声音**：  
  虚拟机添加AC97声卡，并安装SPICE Guest Tools。
- **显示器未被识别**：  
  检查是否安装虚拟机增强工具（如VMware Tools/VirtIO驱动）。

通过上述方法，可灵活分配物理或虚拟显示器至指定虚拟机。具体选择需结合硬件支持及应用场景，优先推荐 **PCI直通**（高性能需求）或 **SPICE多屏**（远程协作需求）。