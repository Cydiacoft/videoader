# Videoader 项目工作日志

## 日期：2026-03-10

## 今日完成的工作

### 1. UI 交互改进

- 下载页面：添加剪贴板粘贴按钮
- 下载页面：批量下载改为 AppBar 图标直接切换
- 下载页面：URL 输入框添加实时字符计数提示
- 下载页面：下载历史从水平卡片改为垂直列表
- 下载页面：失败任务增加重新下载按钮
- 日志组件：改进空状态显示，增加说明文字
- 日志组件：添加日志计数显示
- 日志组件：优化日志颜色高亮（🚀、⚠️等emoji识别）
- 设置页面：添加配置提示卡片
- 设置页面：路径配置项添加验证状态图标
- 设置页面：下载目录增加"打开文件夹"按钮
- 主题切换：添加主题切换按钮（浅色/深色/跟随系统）

### 2. Android 端集成 youtubedl-android 库的尝试

#### 尝试方案 A：使用 pub.dev 上的 flutter_yt_dlp 包

- 结果：包依赖的 ffmpeg-kit 无法下载（仓库问题）

#### 尝试方案 B：直接集成 youtubedl-android Android 原生库

- 在 android/app/build.gradle.kts 添加依赖：
  
  ```kotlin
  implementation("io.github.junkfood02.youtubedl-android:library:0.18.1")
  implementation("io.github.junkfood02.youtubedl-android:ffmpeg:0.18.1")
  ```
- 编写 MainActivity.kt Method Channel 代码
- 遇到问题：Kotlin 找不到正确的包名（尝试了 org.jaummer, com.github.yausername 等）
- APK 能构建成功，但 Kotlin 代码编译失败

#### 当前状态

- 回退到手动选择文件的方式
- Android 端和 Desktop 端使用相同的逻辑：用户需要手动选择 yt-dlp 和 ffmpeg 可执行文件
- APK 构建成功

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

### 3. Windows 端构建

- 解决 Flutter 与 Visual Studio 2026 (版本 18) 不兼容问题
- 问题原因：Flutter 默认使用 "Visual Studio 16 2019" 生成器
- 解决方法：手动运行 CMake 指定正确的生成器 "Visual Studio 18 2026"
- 构建成功：生成 `videoder_demo.exe` (1.1MB)
- 构建输出目录：`build/windows/x64/runner/Debug/`

#### 构建命令

```bash
# 手动 CMake 配置（解决生成器版本问题）
cmake -S windows -B build/windows/x64 -G "Visual Studio 18 2026" -A x64

# 使用 MSBuild 构建
msbuild build/windows/x64/videoder_demo.sln -p:Configuration=Debug -p:Platform=x64
```

## 待解决的问题

### 1. Android 端内置 yt-dlp（优先级：高）

- 需要解决 JitPack 仓库下载问题
- 找到正确的 Kotlin 包名来调用 youtubedl-android 库
- 参考 Seal 项目的实现方式

### 2. 可能的其他库

- 考虑使用 ffmpeg_kit_flutter 代替
- 或使用 Termux API 方式

### 3. Windows 端优化（优先级：中）

- 在 Visual Studio 2026 环境下优化 Windows 端应用

### 4. Cookie 获取方式增强（优先级：中）

- 添加在线登录获取 Cookie 功能
- 使用 webview_flutter 嵌入浏览器
- 支持 YouTube、Bilibili、Twitter/X、TikTok 等平台
- 登录后自动导出 Cookie 到 cookies.txt

## 项目文件结构（关键改动）

```
lib/
├── main.dart                    # 添加主题切换
├── pages/
│   ├── download_page.dart       # UI改进：粘贴按钮、批量下载优化、下载选项
│   ├── settings_page.dart       # UI改进：简化配置流程、Cookie配置
│   └── cookie_login_page.dart   # 在线登录获取Cookie
├── providers/
│   └── app_provider.dart        # 核心下载逻辑：添加格式、画质、Cookie选项
├── widgets/
│   ├── path_config_card.dart   # 添加打开文件夹功能、清除功能
│   └── log_viewer.dart         # 改进空状态显示
└── models/
    └── download_task.dart

android/
├── app/
│   ├── build.gradle.kts        # 添加 NDK abiFilters
│   └── src/main/
│       └── AndroidManifest.xml  # 添加存储权限
└── build.gradle.kts            # 添加 JitPack 仓库
```

## 构建命令

```bash
# 构建 Debug APK
flutter build apk --debug

# 分析代码
flutter analyze
```

## 明天的工作

1. 继续尝试集成 youtubedl-android 库
2. 研究正确的 Kotlin 包名导入方式
3. 或考虑使用其他方案（如 ffmpeg_kit_flutter）
4. 在Visual Studio 2026的环境下为Windows端的应用进行优化
