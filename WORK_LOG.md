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

## 2026-03-12 更新

### 1. Cookie 存储问题修复 ✅

 - 添加 path_provider 依赖，Cookie 存储到 app 私有目录
 - 新增 CookiePlatform 枚举：YouTube、Bilibili、Twitter/X、TikTok
 - AppSettings 改用 Map 存储各平台 Cookie（不再共用单一文件）
 - 下载时根据 URL 自动检测平台并使用对应 Cookie
 - 设置页面显示 4 个平台独立配置入口
 - 在线登录自动识别当前网站平台并保存到对应文件

### 2. 抖音下载问题（已知外部问题）

 抖音的下载问题属于 yt-dlp 官方已知问题：
 - yt-dlp 的 douyin extractor 经常失效
 - 需要使用最新 nightly 版本 yt-dlp
 - 需要非常"新鲜"的 Cookie（刚刚从浏览器提取）
 - 建议使用在线登录方式获取 Cookie

### 3. Twitter/X 下载问题

 - yt-dlp 支持 Twitter/X 视频下载
 - 仅支持包含视频的推文（图片推文无法下载）
 - 正确 URL 格式：`https://x.com/user/status/1234567890` 或 `https://twitter.com/user/status/1234567890`
 - 不支持嵌入推文的 iframe URL（如 platform.twitter.com）

### 4. UI 更新

 - 设置页面添加平台使用说明提示
 - Cookie 管理页面重构：每个平台独立卡片，显示 Cookie 列表
 - 新增"新增"按钮，弹出对话框填写：网站链接(必填)、备注(选填)、Cookie内容
 - 支持删除单个 Cookie

### 5. Cookie 存储结构更新

 - 新增 CookieEntry 类存储：url、remark、cookieContent、createdAt
 - 每个平台存储 CookieEntry 列表，支持多个 Cookie
 - 数据存储为 JSON 格式

### 6. Windows 版本编译 ✅

 - 使用 Visual Studio 2026 手动 CMake 编译成功
 - 输出位置: `build/publish-v11/videoder_demo.exe`
 - 创建编译说明文档: `BUILD_WINDOWS.md`

## 2026-03-14 更新

### 1. Cookie 存储逻辑重构（参考 Seal）

#### 变更原因
- 原方案：将 Cookie 内容以 JSON 格式存储在 SharedPreferences
- 问题：读取时需要额外解析，且格式与 yt-dlp 要求的 Netscape 格式不一致
- 新方案：直接存储为 Netscape 格式的 cookie 文件，与 yt-dlp --cookies 参数无缝配合

#### 变更内容
- **app_provider.dart**:
  - 移除 CookieEntry 类和相关 JSON 序列化逻辑
  - 移除 AppSettings 中的 cookies Map 和 getCookies/hasCookie 方法
  - 添加 `hasCookieFile(platform)` 方法检查 cookie 文件是否存在
  - 修改 `addCookie()` 方法，将 cookie 内容直接写入 Netscape 格式文件
  - 添加 `getCookiePath(platform)` 返回文件完整路径
  - 修改 `removeCookie(platform)` 和 `clearCookie(platform)` 删除文件

- **settings_page.dart**:
  - 移除 CookieEntry 列表展示，改为显示"已配置/暂无"状态
  - 使用 FutureBuilder + hasCookieFile 检查各平台状态
  - 简化删除逻辑，直接调用 clearCookie

- **download_page.dart**:
  - 使用 FutureBuilder + hasCookieFile 检查已配置的 cookie 平台

#### Seal 的 Cookie 存储逻辑（参考）
Seal 应用从 Android WebView 的 cookie 数据库读取 cookies，然后转换为 Netscape 格式保存到 `cookies.txt`：
- 从 `context.dataDir.resolve("app_webview/Default/Cookies")` 读取 SQLite 数据库
- 查询 cookies 表，提取：host_key、expires_utc、path、name、value、is_secure
- 转换为 Netscape 格式（# Netscape HTTP Cookie File）
- 保存到配置目录的 cookies.txt 文件
- yt-dlp 使用 `--cookies` 参数直接读取此文件

### 2. Windows 编译

#### 编译环境
- Visual Studio 2026 (Version 18.4.0)
- CMake: `D:\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe`

#### 编译步骤
```powershell
# 配置 CMake 项目（使用 Visual Studio 18 2026 生成器）
cd windows
cmake -G "Visual Studio 18 2026" -A x64 -S . -B build

# 构建 Release 版本
cmake --build . --config Release
```

#### 生成的 exe 文件
- 位置: `windows/build/runner/Release/videoder_demo.exe`
- 大小: 90,112 bytes

#### CMakeLists.txt 修改
- 将平台工具集从 v142 改为 v180（VS 2026）
```cmake
set(CMAKE_VS_PLATFORM_TOOLSET v180)
```

## 2026-03-24 更新

### 1. 自定义 Cookie 编辑功能

- **app_provider.dart**:
  - CustomCookie 类新增 `cookie` 字段存储 Cookie 内容
  - 添加 `updateCustomCookie()` 方法支持更新已保存的 Cookie
  - 修改 `fromJson` 和 `toJson` 序列化方法

- **settings_page.dart**:
  - 自定义网站列表添加编辑按钮
  - 新增 `_showEditCustomCookieDialog()` 方法
  - 更新成功后显示提示信息

### 2. 下载历史删除逻辑优化

- **app_provider.dart**:
  - DownloadNotifier 新增 `removeHistory(taskId)` 方法
  - 支持删除单条历史记录

- **download_page.dart**:
  - 每条历史记录添加删除按钮，点击弹出确认对话框
  - 清空按钮改为弹出选择框：
    - "清空已完成"：只删除 completed 和 failed 状态的任务
    - "清空全部"：删除所有历史记录

### 3. 日志显示框折叠功能

- **log_viewer.dart**:
  - 添加 `isExpanded` 和 `onToggle` 参数支持外部控制
  - 使用 `AnimatedCrossFade` 实现平滑折叠动画
  - 点击标题行可折叠/展开日志内容

- **download_page.dart**:
  - 添加 `_logExpanded` 状态变量
  - 日志区域高度随展开状态变化
  - 历史记录区域自动随日志折叠而上移

### 4. 设置页面重构（两级菜单结构）

- **settings_page.dart**:
  - 移除 Cookie 在线登录相关功能（专注 Windows 开发）
  - 移除对不存在方法 `cookiePath`/`setCookiePath` 的引用
  - 新增两个可展开的一级菜单：
    - **环境配置**：yt-dlp、ffmpeg、aria2 路径配置，检查更新
    - **Cookies 配置**：各平台 Cookie 管理 + 自定义网站
  - 添加 AppBar 返回按钮
  - 使用 `AnimatedCrossFade` 实现展开/折叠动画

### 5. Windows 编译

```bash
flutter build windows
```

- 输出: `build/windows/x64/runner/Release/videoder_demo.exe`
- 编译成功，无错误


