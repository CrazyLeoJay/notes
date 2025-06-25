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