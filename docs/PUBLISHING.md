# 发布指南

## 发布流程概览

```
开发完成 → flutter analyze (零错误) → flutter test (通过) → git tag → push tag → GitHub Actions 自动构建 → Release 页面下载
```

---

## 一、准备工作

### 1.1 环境检查

```bash
# 确认 Flutter 版本
flutter --version
# 要求: Flutter 3.41.6+, Dart 3.11.4+

# 确认代码零错误
flutter analyze

# 运行测试
flutter test
```

### 1.2 确认代码已提交

```bash
git status
# 确保工作区干净（no uncommitted changes）

git log --oneline -5
# 确认最新提交是你要发布的内容
```

---

## 二、创建发布

### 方法 A：自动发布（推荐）

推送 `v*` 格式的 Git Tag，GitHub Actions 自动构建 Android APK 和 Windows 安装包。

```bash
# 步骤 1：创建带注释的 tag
git tag -a v1.0.3 -m "v1.0.3 - 版本更新说明"

# 步骤 2：推送 tag（触发自动构建）
git push origin v1.0.3
```

构建过程：
1. GitHub Actions 检测到 `v*` tag 推送
2. 并行启动 Android 构建（ubuntu）和 Windows 构建（windows-latest）
3. 构建完成后自动创建 GitHub Release
4. APK 和 Windows zip 自动附加到 Release 的 Assets

查看构建状态：https://github.com/katalinas/student_study/actions

下载发布产物：https://github.com/katalinas/student_study/releases

### 方法 B：手动发布

适用于自动构建失败或需要自定义发布内容时。

**本地构建：**

```bash
# Android APK
flutter build apk --release
# 产出: build/app/outputs/flutter-apk/app-release.apk

# Windows（需要开发者模式或管理员权限）
flutter build windows --release
# 产出: build/windows/x64/runner/Release/
```

**上传到 GitHub：**

1. 打开 https://github.com/katalinas/student_study/releases
2. 点击 **Create a new release**
3. Tag: 输入版本号（如 `v1.0.4`），选择 "Create new tag on publish"
4. Title: `v1.0.4 - 版本说明`（英文和数字，不要中文）
5. Description: 填写版本更新内容（可以用中文）
6. 在 **Attach binaries** 区域上传：
   - `app-release.apk`（重命名为 `student-study-1.0.4-android.apk`）
   - Windows 文件夹打包的 zip（重命名为 `student-study-1.0.4-windows.zip`）
7. 点击 **Publish release**

---

## 三、版本号规则

```
v主版本.次版本.修订号

示例: v1.0.3
      │ │ └── 修订号: Bug修复、内容更新
      │ └──── 次版本: 新功能、新模块上线
      └────── 主版本: 重大架构变更
```

| 场景 | 版本变更 | 示例 |
|------|---------|------|
| 修复 bug | 修订号 +1 | v1.0.2 → v1.0.3 |
| 新增内容（题目/故事） | 修订号 +1 | v1.0.3 → v1.0.4 |
| 新增功能模块 | 次版本 +1 | v1.0.x → v1.1.0 |
| 重大改版（V2） | 主版本 +1 | v1.x.x → v2.0.0 |

---

## 四、GitHub Actions 配置

### CI 持续集成 (`.github/workflows/ci.yml`)

| 触发条件 | 执行内容 |
|---------|---------|
| push 到 main/develop | 代码分析 → 测试 → 构建验证 |
| Pull Request 到 main | 代码分析 → 测试 → 构建验证 |

### Release 自动发布 (`.github/workflows/release.yml`)

| 触发条件 | 执行内容 |
|---------|---------|
| push `v*` tag | 构建 Android APK → 构建 Windows → 创建 Release |

### CI 环境版本

| 组件 | 版本 | 说明 |
|------|------|------|
| Flutter | 3.41.6 | 与本地开发版本一致 |
| Dart | 3.11.4 | 随 Flutter 版本 |
| Java | 21 (Temurin) | Android 构建工具链 |
| Node.js | 24 | GitHub Actions 运行时 |
| Runner (Android) | ubuntu-latest | Linux 构建 |
| Runner (Windows) | windows-latest | Windows 构建 |

---

## 五、发布产物说明

### Android APK

- 文件名: `student-study-{version}-android.apk`
- 安装方式: 传输到安卓手机 → 打开文件 → 允许安装未知来源 → 安装
- 最低 Android 版本: API 21 (Android 5.0)
- 架构: 通用 APK（包含 arm64-v8a, armeabi-v7a, x86_64）

### Windows

- 文件名: `student-study-{version}-windows.zip`
- 安装方式: 解压 → 运行 `student_study.exe`
- 最低 Windows 版本: Windows 10
- 无需安装，解压即用（绿色版）

---

## 六、常见问题

### Q: 自动构建失败怎么办？

1. 打开 https://github.com/katalinas/student_study/actions
2. 点击失败的 workflow run
3. 展开失败的 step 查看错误日志
4. 常见原因：
   - Flutter 版本不匹配 → 检查 workflow 中的 flutter-version
   - 依赖解析失败 → 本地 `flutter pub get` 后提交 `pubspec.lock`
   - 编译错误 → 本地 `flutter analyze` 确认零错误后再推 tag

### Q: Tag 名称要求？

- 必须以 `v` 开头，后跟版本号
- 只能包含英文、数字、`.`、`-`
- 正确: `v1.0.3`, `v2.0.0-beta`
- 错误: `v1.0.3-修复版`, `版本1.0`

### Q: 如何删除错误的 tag？

```bash
# 删除本地 tag
git tag -d v1.0.3

# 删除远程 tag（需要仓库权限允许）
git push origin :refs/tags/v1.0.3
```

注意：如果仓库设置了 tag 保护规则，远程 tag 无法删除。此时直接创建新版本号。

### Q: Windows 构建需要开发者模式？

Flutter Windows 构建需要创建符号链接。两种解决方式：
1. 开启 Windows 开发者模式：设置 → 系统 → 开发者选项 → 开启
2. 以管理员权限运行构建命令

GitHub Actions 上不存在此问题（CI 环境自带权限）。

### Q: 如何查看历史发布？

- 所有发布: https://github.com/katalinas/student_study/releases
- 所有 tag: https://github.com/katalinas/student_study/tags
- 构建历史: https://github.com/katalinas/student_study/actions

---

## 七、发布检查清单

发布前确认：

- [ ] `flutter analyze` — 零错误
- [ ] `flutter test` — 测试通过
- [ ] 所有代码已提交推送
- [ ] 版本号递增（不与已有 tag 重复）
- [ ] CHANGELOG 已更新（`evolution/CHANGELOG.md`）
- [ ] README 版本信息一致

发布后确认：

- [ ] GitHub Actions 构建成功（绿色 ✓）
- [ ] Release 页面有 APK 和 Windows zip
- [ ] 下载 APK 能正常安装运行
- [ ] 下载 Windows zip 解压后能正常运行
