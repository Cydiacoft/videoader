# Videoader 项目工作日志

## 日期：2026-03-11

## 今日完成的工作

### 1. 下载选项功能扩展

- 在 AppSettings 中添加下载格式选项（视频/音频/封面）
- 在 AppSettings 中添加画质选择（最佳/1080p/720p/480p/360p）
- 在 AppSettings 中添加 Cookie 文件路径配置
- 修改 startDownload 方法，根据格式和画质构建不同的 yt-dlp 参数
- 添加 Cookie 支持，使用 --cookies 参数

#### 下载格式参数说明

- **视频**: 使用 `-f bestvideo[height<=x]+bestaudio/best[height<=x]` 指定画质
- **音频**: 使用 `-x --audio-format mp3 --audio-quality 0` 提取 MP3
- **封面**: 使用 `--skip-download --write-thumbnail` 跳过下载仅获取封面

### 2. UI 更新

- 下载页面：添加 AppBar 按钮展开下载选项面板
- 下载页面：添加格式选择下拉框（视频/音频/封面）
- 下载页面：添加画质选择下拉框（最佳/1080p/720p/480p/360p）
- 下载页面：显示当前 Cookie 状态
- 设置页面：添加 Cookie 配置区域
- PathConfigCard：添加 onClear 回调支持清除功能
- 设置页面：添加 Cookie 文件选择功能

### 3. Cookie 获取方式增强

- 添加 webview_flutter 依赖
- 创建在线登录页面（CookieLoginPage）
- 使用内置 WebView 登录网站
- 支持平台：YouTube、Bilibili、Twitter/X、TikTok
- 登录后自动导出 Cookie 到 cookies.txt
- 添加手动粘贴 Cookie 功能

### 4. Windows 端构建

- 解决 Flutter 与 Visual Studio 2026 (版本 18) 不兼容问题
- 问题原因：Flutter 默认使用 "Visual Studio 16 2019" 生成器
- 解决方法：手动运行 CMake 指定正确的生成器 "Visual Studio 18 2026"
- 修改 windows/CMakeLists.txt 设置平台工具集 v142
- 构建成功：生成 `videoder_demo.exe` (89KB + flutter_windows.dll 19MB)

### 5. URL 解析功能

- 简化 URL 提取逻辑，使用正则表达式从文本中提取链接
- 支持批量下载模式，每行自动提取 URL
- 支持从文件导入，每行自动提取 URL
- 支持各种短链接：v.douyin.com、b23.tv、youtu.be 等
- yt-dlp 会自动处理重定向

### 6. 版本检测与更新

- 添加 checkVersions 方法检测 yt-dlp 和 ffmpeg 版本
- 解析版本号中的日期，计算版本过期天数
- 超过 90 天显示过期警告
- 添加 updateYtDlp 方法支持一键更新 yt-dlp
- 设置页面显示版本信息和更新按钮

### 7. 下载工具按钮

- 设置页面添加"下载 yt-dlp"和"下载 ffmpeg"按钮
- 点击后打开官方 GitHub 下载页面
- 弹出提示说明版权信息（规避开源协议问题）

### 8. GitHub 开源

- 初始化 Git 仓库
- 创建 README.md 完整中英文介绍文档
- 添加 MIT 许可证
- 推送到 https://github.com/Cydiacoft/videoader

## 修复的问题

1. **ffmpeg 路径问题**
   - 问题：`--ffmpeg-location` 需要文件夹路径，而非文件路径
   - 修复：自动提取 ffmpeg 所在文件夹路径

2. **URL 解析问题**
   - 问题：只能解析特定平台的 URL
   - 修复：通用 URL 提取，支持任意文本中的链接

3. **批量下载问题**
   - 问题：批量模式不支持从文本提取 URL
   - 修复：每行使用通用提取逻辑

4. **文件导入问题**
   - 问题：文件导入不支持从文本提取 URL
   - 修复：每行使用通用提取逻辑

## 构建命令

```bash
# 清理并配置 CMake
cmake -S windows -B build/windows/x64 -G "Visual Studio 18 2026" -A x64

# 构建 Release
msbuild build/windows/x64/videoder_demo.sln -p:Configuration=Release -p:Platform=x64
```

## 项目文件结构

```
lib/
├── main.dart                    # 应用入口，主题切换
├── pages/
│   ├── download_page.dart       # 下载页面：URL输入、批量下载、下载选项
│   ├── settings_page.dart       # 设置页面：工具配置、Cookie、版本检测
│   └── cookie_login_page.dart   # 在线登录获取Cookie
├── providers/
│   └── app_provider.dart        # 核心逻辑：下载、版本检测、更新
├── widgets/
│   ├── path_config_card.dart   # 路径配置卡片
│   └── log_viewer.dart        # 日志查看器
└── models/
    └── download_task.dart      # 下载任务模型
```

## 待解决的问题

1. ~~Windows 端构建~~ ✅ 已完成
2. ~~URL 解析功能~~ ✅ 已完成
3. ~~版本检测与更新~~ ✅ 已完成
4. ~~GitHub 开源~~ ✅ 已完成

## 发布信息

- 最新版本：`build/publish-v10/`
- GitHub：https://github.com/Cydiacoft/videoader
