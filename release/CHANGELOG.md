# 更新日志

## v13 (2026-03-19)

### 新增
- **Cookie 列表折叠功能** - 设置页面 Cookie 配置区域可折叠/展开
- **自定义网站 Cookie 支持** - 新增自定义网站 Cookie 管理功能
  - 支持添加任意网站的 Cookie
  - 独立管理每个自定义网站的配置
  - 支持网站名称、域名、备注信息

### 优化
- 代码质量优化，通过静态分析检查（No issues found）
- 修复 BuildContext async gap 警告
- 提升应用性能和稳定性

### 构建
- Windows 构建脚本优化
- 项目文件清理（移除 .vs 缓存）

---

## v12 (2026-03-19)

### 新增
- **Fluid Editorial 设计系统** - 全新的视觉设计语言
  - Material 3 配色方案（蓝紫色调）
  - 28dp 大圆角规范
  - 渐变主按钮和柔和阴影
  - 无边框设计（使用背景色阶分隔）
- **Aria2 多线程下载支持**
  - 自动检测 Aria2 安装路径
  - 下载模式偏好设置（默认/ARIA2）
  - Aria2 配置选项（可选）
- 批量下载模式切换
- 下载选项面板显示当前下载模式

### 优化
- 代码结构和性能优化
- 日志数量限制（最多 500 条）
- 更新的 AppLogsNotifier 便捷方法
- 设置页面卡片布局重新设计

### 构建
- 更新 Flutter 版本到 3.41.4
- Visual Studio 2026 兼容

---

## v11 (2026-03-12)

### 新增
- 多平台 Cookie 独立管理（YouTube、Bilibili、Twitter/X、TikTok）
- 新增 Cookie 弹窗：填写网站链接、备注、Cookie 内容
- Cookie 存储在 app 私有目录，更安全

### 修复
- Cookie 只能存储一个平台的问题
- Cookie 存储路径在 Downloads 不方便的问题
- UI 优化：列表形式展示 Cookie，一目了然

### 已知问题
- 抖音-dlp nightly 版本 + 新鲜 Cookie：需要最新 yt
- Twitter/X：仅支持包含视频的推文

---

## v10 (2024-03-11)

### 新增
- 初始版本
- 支持 YouTube、Bilibili、Twitter/X、TikTok 下载
- Cookie 认证支持
- 内置浏览器在线登录
