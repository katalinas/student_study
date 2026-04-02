# 本地构建运行指南

## 环境准备

### 1. 安装 Flutter SDK

```bash
# 下载 Flutter 3.41.6+
# https://docs.flutter.dev/get-started/install

# 验证安装
flutter doctor -v
```

确保 `flutter doctor` 无红色错误。常见问题：
- **Android toolchain**: 安装 Android Studio 或 `sdkmanager` 配置 SDK
- **Chrome**: Web 开发需要 Chrome 浏览器（通常已安装）
- **Visual Studio**: Windows 桌面构建需要 VS 2022 + "使用 C++ 的桌面开发"工作负载

### 2. 克隆项目

```bash
git clone https://github.com/katalinas/student_study.git
cd student_study
```

### 3. 初始化

```bash
# 方式一：使用 Makefile（需要 GNU Make）
make setup

# 方式二：手动
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## 运行方式

### Web 版（推荐，零额外依赖）

```bash
make run
# 或
flutter run -d chrome
```

自动打开 Chrome，支持 Hot Reload（按 `r`）和 Hot Restart（按 `R`）。

### Windows 桌面版

需要以下任一条件：
- Windows 开发者模式已启用（设置 → 开发者选项）
- 以管理员权限运行终端

```bash
make run-win
# 或
flutter run -d windows
```

### Android

需要连接 Android 设备或启动模拟器：

```bash
# 列出可用设备
flutter devices

# 运行
make run-android
# 或
flutter run -d android
```

## 构建发布版

```bash
# Web（输出到 build/web/）
make build-web

# Android APK（输出到 build/app/outputs/flutter-apk/app-release.apk）
make build-apk

# Windows（输出到 build/windows/x64/runner/Release/）
make build-win

# 全部构建
make build
```

## 代码质量

```bash
# 静态分析（必须零错误）
make analyze

# 运行测试
make test

# 分析 + 测试
make check
```

## Makefile 命令一览

| 命令 | 说明 |
|------|------|
| `make help` | 显示所有可用命令 |
| `make setup` | 首次初始化（依赖 + 代码生成） |
| `make run` | 运行 Web 版 (Chrome) |
| `make run-web` | 运行 Web 版 |
| `make run-win` | 运行 Windows 版 |
| `make run-android` | 运行 Android 版 |
| `make build` | 构建 Web + APK release |
| `make build-web` | 构建 Web release |
| `make build-win` | 构建 Windows release |
| `make build-apk` | 构建 APK release |
| `make check` | 静态分析 + 测试 |
| `make analyze` | Dart 静态分析 |
| `make test` | 单元测试 |
| `make clean` | 清理构建缓存 |
| `make reinstall` | 清理 + 重装依赖 |
| `make codegen` | 运行代码生成 |
| `make codegen-watch` | 代码生成监听模式 |
| `make doctor` | 检查 Flutter 环境 |

## 常见问题

### Q: `flutter run -d windows` 报 symlink 错误
**A:** 需要启用开发者模式或以管理员身份运行。推荐先用 `make run`（Web 版）不需要任何额外配置。

### Q: `flutter run -d windows` 报 Visual Studio toolchain 错误
**A:** 安装 Visual Studio 2022 Community，勾选 "使用 C++ 的桌面开发" 工作负载。或使用 Web 版开发。

### Q: 代码生成后出现类型错误
**A:** 运行 `make codegen` 重新生成。如果仍有问题，`make reinstall` 清理重来。

### Q: Hot Reload 不生效
**A:** 按大写 `R`（Hot Restart）而非小写 `r`（Hot Reload）。状态类的修改需要 Restart。
