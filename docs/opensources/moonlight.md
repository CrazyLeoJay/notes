# moonlight 

## Moonlight服务端 [Sunshine](https://github.com/LizardByte/Sunshine)

配置：

```yaml
# C:\Program Files\Sunshine\config\sunshine.conf
"ip": "192.168.10.2",  # 绑定内部网络
"min_log_level": 2,     # 减少日志开销
"encoder": "nvenc",     # 强制使用NVENC编码器
"adapter_name": "Ethernet" # 指定虚拟网卡

```

## Moonlight 客户端


### Linux

```bash
# 安装 Moonlight 并优化配置
sudo apt install moonlight-qt
mkdir -p ~/.config/moonlight
nano ~/.config/moonlight/streaming.conf

```

```ini
[192.168.10.2]
width = 1920
height = 1080
fps = 144             # 与显示器刷新率同步
bitrate = 150         # 内网可拉满（单位Mbps）
codec = h265          # HEVC节省带宽
swap_eyes = false
audio_device = alsa_output.pci-0000_00_1b.0.analog-stereo
```

## 在虚拟及proxmoxVE中的优化

### 网络加速：

在 Proxmox 中启用 Jumbo Frames：

```bash
ip link set vmbr1 mtu 9000
```

Windows/Ubuntu 虚拟机网卡同样设置 MTU=9000

### Moonlight 延迟优化：

关键参数：

```yaml
# Sunshine 高级设置 (sunshine.conf)
"ping_timeout": 10000
"channels": 4        # 并行编码通道
"hevc_mode": 1       # 强制HEVC
```

Ubuntu 客户端启动命令（减少渲染延迟）：

```bash
moonlight stream -app "Desktop" -localaudio -nounsupported -nosops 192.168.10.2
```

### 解决音频回环问题：

在 Ubuntu 安装 PulseAudio 虚拟声卡：

```bash
sudo apt install pulseaudio-module-jack
pactl load-module module-null-sink sink_name=Moonlight
```

在 Moonlight 音频设置中选择 Moonlight 为输出设备


## 🌟 Sunshine (Moonlight 服务端) 专属优化

针对 40 系 NVENC 编码器配置

```yaml
# C:\ProgramData\Sunshine\apps\desktop.json
{
  "name": "RTX4080_GameMode",
  "output": "desktop",
  "encoder": {
    "type": "nvenc",  // 强制使用硬件编码
    "codec": "hevc",  // 40系支持AV1但不建议（HEVC更稳定）
    "rate_control": "cbr",
    "bitrate": 150,    // 内网可拉满
    "preset": "p7",   // 40系专属性能档
    "tuning": "ull"   // Ultra Low Latency模式
  },
  "hdr": true         // 开启HDR流传输
}
```

启动参数降延迟

```powershell
# Sunshine 高级启动参数（管理员运行）
Start-Process sunshine.exe -ArgumentList "--app-args `"-limit_ram_to_24gb -prefer_fast_upload`""
```
> 📌 注：-prefer_fast_upload 启用 RTX 40 系的直接显存上传技术，减少 3ms 延迟

## 🛠️ Ubuntu Moonlight 客户端硬解配置


```bash
# 启用 VAAPI 硬解 + 低延迟渲染
sudo nano ~/.config/moonlight/streaming.conf
```

```ini
[192.168.10.2]
...
video_codec = hevc
video_device = /dev/dri/renderD128  # 指向核显/亮机卡
frame_pacing = 2                    # 帧同步模式（0=禁用, 2=激进）
vsync = 0                           # 关闭垂直同步
fullscreen = true
```

> ✅ 测试命令：moonlight test 192.168.10.2 检查 DECODE LATENCY 应 <2ms




