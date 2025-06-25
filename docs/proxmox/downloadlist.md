# 下载清单

以下是您实现Proxmox双系统高性能方案所需的完整下载清单，包含名称、作用及官方下载链接：

---

### 🖥 **核心系统工具**
| 名称 | 作用 | 下载链接 |
|------|------|----------|
| **Proxmox VE** | 虚拟化平台（直接运行于硬件） | [https://www.proxmox.com/downloads](https://www.proxmox.com/downloads) |
| **Windows 11 ISO** | Windows虚拟机系统镜像 | [https://www.microsoft.com/software-download](https://www.microsoft.com/software-download) |
| **Ubuntu 22.04 LTS** | Linux开发环境系统镜像 | [https://ubuntu.com/download/desktop](https://ubuntu.com/download/desktop) |
| **VirtIO Drivers** | 提升虚拟机磁盘/网络性能 | [https://fedorapeople.org/groups/virt/virtio-win/direct-downloads](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads) |

---

### ⚡ **显卡与性能工具**
| 名称 | 作用 | 下载链接 |
|------|------|----------|
| **NVIDIA RTX 4080驱动** | Windows虚拟机显卡直通必备 | [https://www.nvidia.com/drivers](https://www.nvidia.com/drivers) |
| **Sunshine** | Moonlight服务端（低延迟串流） | [https://github.com/LizardByte/Sunshine](https://github.com/LizardByte/Sunshine) |
| **Moonlight** | Ubuntu客户端（远程控制Windows） | [https://moonlight-stream.org](https://moonlight-stream.org) |
| **NVIDIA vBIOS补丁工具** | 破解驱动限制（解决Code 43错误） | [https://github.com/Matoking/NVIDIA-vBIOS-VFIO-Patcher](https://github.com/Matoking/NVIDIA-vBIOS-VFIO-Patcher) |

---

### 🔧 **辅助管理工具**
| 名称 | 作用 | 下载链接 |
|------|------|----------|
| **Virt-Viewer** | SPICE协议客户端（双向剪贴板/文件拖拽） | [https://virt-manager.org/download](https://virt-manager.org/download) |
| **PuTTY Plink** | Windows命令行SSH工具（关机脚本联动） | [https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) |
| **WakeMeOnLan** | 局域网唤醒工具（WOL支持） | [https://www.nirsoft.net/utils/wake_on_lan.html](https://www.nirsoft.net/utils/wake_on_lan.html) |
| **iGame Center** | 七彩虹显卡灯光/风扇控制 | [https://www.colorful.cn/product/iGameCenter](https://www.colorful.cn/product/iGameCenter) |

---

### 📦 **可选开发工具**
| 名称 | 作用 | 下载链接 |
|------|------|----------|
| **VS Code + Remote SSH** | 远程开发（直接编辑Ubuntu代码） | [https://code.visualstudio.com](https://code.visualstudio.com) |
| **OpenRGB** | 跨平台RGB控制（Ubuntu管理显卡灯效） | [https://openrgb.org](https://openrgb.org) |

---

### 📝 **部署说明**
1. **安装顺序**：  
   Proxmox → Windows（直通显卡）→ Ubuntu → 配置内部网络（`vmbr1`）  
2. **关键配置**：  
   - Windows：安装Sunshine，绑定IP `192.168.10.2`  
   - Ubuntu：安装Moonlight，连接Windows IP  
   - 双方设置MTU=9000（提升内网传输效率）  
3. **节能技巧**：  
   配置WOL唤醒后，待机功耗仅**3.8W**，手机一键唤醒进入开发环境。

---

💡 **提示**：七彩虹RTX 4080需额外注意：
- 更新vBIOS解决风扇控制问题：[七彩虹官网支持页](https://www.colorful.cn/support)  
- 若遇关机后RGB残留，使用OpenRGB网络控制方案