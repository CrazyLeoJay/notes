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




### Moonlight 远程桌面流

[文档](/moonlight/README)

