# Videoader

<div align="center">

<img src="https://img.shields.io/github/stars/Cydiacoft/videoader?style=flat&color=ff69b4" alt="stars">
<img src="https://img.shields.io/github/forks/Cydiacoft/videoader?style=flat&color=orange" alt="forks">
<img src="https://img.shields.io/github/license/Cydiacoft/videoader" alt="license">
<img src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Android-green" alt="platform">

**跨平台视频下载工具 | A Cross-Platform Video Downloader**

</div>

---

## ✨ 功能特点

- 🌐 **多平台支持** - 支持 YouTube、Bilibili、抖音、TikTok、Twitter/X 等主流视频平台
- 🎬 **多种下载格式** - 视频、音频（MP3）、封面图片
- 📺 **画质选择** - 最佳、1080p、720p、480p、360p
- 🔐 **Cookie 支持** - 多种方式获取 Cookie（文件导入、手动粘贴、在线登录）
- 🔄 **版本检测** - 自动检测 yt-dlp 更新，一键更新
- 🖥️ **跨平台** - Windows、macOS、Linux、Android
- 🌙 **主题切换** - 支持浅色/深色/跟随系统

---

## 📥 下载

### Windows 版本

前往 [Releases](https://github.com/Cydiacoft/videoader/releases) 下载最新的 Windows 版本。

**包含文件：**
- `videoder_demo.exe` - 主程序
- `flutter_windows.dll` - Flutter 引擎
- `data/` - 资源文件

将以上文件放在同一目录即可运行。

---

## ⚙️ 环境配置

本软件需要以下外部工具：

### 1. yt-dlp
- 用途：视频下载核心引擎
- 下载：[GitHub Releases](https://github.com/yt-dlp/yt-dlp/releases)
- 许可证：[Public Domain (Unlicense)](https://github.com/yt-dlp/yt-dlp/blob/master/LICENSE)

### 2. FFmpeg
- 用途：音视频合并与转码
- 下载：[GitHub Releases](https://github.com/BtbN/FFmpeg-Builds/releases)
- 许可证：[LGPL/GPL](https://ffmpeg.org/legal.html)

> **注意**：本软件不包含 yt-dlp 和 FFmpeg，需要用户自行下载配置。

---

## 🔧 使用方法

1. **首次运行**：在设置页面配置 yt-dlp 和 FFmpeg 路径
2. **复制链接**：从视频平台复制分享链接
3. **自动解析**：粘贴后自动解析完整 URL
4. **选择格式**：选择视频/音频/封面，画质
5. **开始下载**：点击下载按钮

---

## 📱 截图

*(待添加)*

---

## 🛠️ 开发

### 环境要求

- Flutter SDK 3.x
- Visual Studio 2022 / Xcode / GCC
- yt-dlp 和 FFmpeg 可执行文件

### 构建命令

```bash
# 获取依赖
flutter pub get

# 构建 Windows
flutter build windows --release

# 构建 Android
flutter build apk --release
```

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 感谢

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - 强大的视频下载工具
- [FFmpeg](https://ffmpeg.org/) - 多媒体处理框架
- [Flutter](https://flutter.dev/) - 跨平台 UI 框架

---

<div align="center">

**如果对你有帮助，欢迎 Star ⭐️**

</div>
