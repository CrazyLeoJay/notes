# PROXMOX VE 8.4 安装

## 镜像资源下载

- [官网-](http://proxmox.com/)
- [官网--镜像下载](http://proxmox.com/en/downloads)

## 启动盘制作工具

### Rufus（Windows）：[官网下载](https://rufus.ie/)

- []


### balenaEtcher（跨平台）：[官网下载](https://www.balena.io/etcher)



### 启动安装

1. **启动到Proxmox安装界面**   **按 `E` 键编辑内核参数**  

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


### 驱动包

[virtio-win](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/)



### ⚙️ **硬件直通（PCI Passthrough）——物理显示器直连**

> 测试有效

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



### Moonlight 远程桌面流

[文档](/moonlight/README)

