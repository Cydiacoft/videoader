# Videoader 构建指南

## 环境要求

- Visual Studio 2026 (v14.50+)
- Flutter SDK 3.41.4+
- Windows 10/11 x64

## 快速构建

使用构建脚本（推荐）：

```powershell
# 普通构建
.\build.ps1

# 清理后重新构建
.\build.ps1 -Clean
```

或手动构建：

```powershell
flutter clean
flutter pub get
flutter build windows --release
```

## 输出位置

```
build\windows\x64\runner\Release\
├── videoder_demo.exe          # 主程序 (88 KB)
├── flutter_windows.dll         # Flutter 引擎 (19.84 MB)
├── url_launcher_windows_plugin.dll  # URL Launcher 插件 (96 KB)
└── data/                      # 应用资源
    ├── app.so                # Dart AOT 编译代码 (5.47 MB)
    ├── flutter_assets/        # Flutter 资源
    └── icudtl.dat           # ICU 数据
```

## 发布包制作

1. 创建发布目录
2. 复制所有文件到发布目录
3. 确保 `data/` 目录完整

## 功能特性

- [x] Fluid Editorial 设计系统
- [x] Material 3 配色方案
- [x] Aria2 多线程下载支持
- [x] Cookie 配置管理
- [x] 批量下载
- [x] 下载选项（格式/画质）

## 版本信息

- 构建工具: Visual Studio 2026 (18.4)
- Flutter: 3.41.4
- Dart: 3.11.1
