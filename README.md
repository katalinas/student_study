# 德智通识教育软件 (Student Study)

面向小学初中（6-15岁）的跨平台教育软件，涵盖智育、科技、逻辑、通识、德育、好词好句六大模块。

## 功能模块

| 模块 | 内容 | 条目数 |
|------|------|--------|
| 智育学堂 | 数学/语文/英语，覆盖1-9年级 | 1200+ |
| 科技探索 | 编程/AI/虚拟实验/航天/科技时间线 | 420+ |
| 逻辑训练 | 模式识别/推理/数独/24点/空间思维 | 300+ |
| 通识百科 | 地理/历史/艺术/科学/动植物/体育 | 300+ |
| 德育融入 | 三观教育/品德故事/传统文化/名句 | 330+ |
| 好词好句 | 古诗词/散文/作文/名著填词游戏 | 300+ |

**总计 3000+ 教育内容条目**

## 核心特性

- 答题引擎 — 选择/填空/判断/连线/拖拽 5 种题型
- 自适应难度 — 连续答对自动升级，答错降级
- 成长树 — 学习进度游戏化可视化（种子→结果树 7 阶段）
- 每日任务 — 智能推荐，优先弱项模块
- 错题本 — 间隔复习（1/3/7/14/30天）
- 成就系统 — 15+ 徽章自动解锁
- 好词好句 — 填词选择训练语感和文学素养
- 家长面板 — PIN 保护，学习报告，时长管理
- 多用户 — 本地多用户切换，年级自适应

## 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Flutter | 3.41.6 | 跨平台 UI 框架 |
| Dart | 3.11.4 | 编程语言 |
| Riverpod | 3.3.1 | 状态管理 |
| go_router | 17.1.0 | 声明式路由导航 |
| drift | 2.31+ | SQLite 数据库（预留） |
| fl_chart | 1.2.0 | 学习报告图表 |
| google_fonts | 8.0.2 | 字体管理 |
| SharedPreferences | 2.5.3 | 本地数据持久化 |

## 平台支持

| 平台 | 状态 | 备注 |
|------|------|------|
| Web (Chrome) | 支持 | 无需额外依赖，推荐开发调试 |
| Windows | 支持 | 需要 Visual Studio C++ 工具链或开发者模式 |
| Android | 支持 | 需要 Android SDK |
| iOS | 计划中 (V2.0) | |

## 快速开始

### 环境要求

- Flutter 3.41.6+
- Dart 3.11.4+
- （可选）Android SDK — 构建 Android
- （可选）Visual Studio 2022 + C++ 桌面开发 — 构建 Windows
- （可选）GNU Make — 使用 Makefile 命令

### 使用 Makefile（推荐）

```bash
# 克隆项目
git clone https://github.com/katalinas/student_study.git
cd student_study

# 首次初始化（安装依赖 + 代码生成）
make setup

# 运行 Web 版（最简单，无需额外工具链）
make run

# 运行 Windows 桌面版
make run-win

# 静态分析 + 测试
make check

# 查看所有可用命令
make help
```

### 手动运行

```bash
# 安装依赖
flutter pub get

# 代码生成（freezed / drift / json_serializable）
dart run build_runner build --delete-conflicting-outputs

# 运行 Web 版（推荐，无需开发者模式或 VS C++ 工具链）
flutter run -d chrome

# 运行 Windows 桌面版（需要开发者模式或管理员权限）
flutter run -d windows

# 运行 Android
flutter run -d android

# 静态分析
flutter analyze
```

### 构建发布

```bash
# 构建 Web
flutter build web --release          # 输出: build/web/

# 构建 Android APK
flutter build apk --release          # 输出: build/app/outputs/flutter-apk/

# 构建 Windows
flutter build windows --release      # 输出: build/windows/x64/runner/Release/

# 或使用 Makefile
make build                           # 构建 Web + APK
make build-win                       # 构建 Windows
```

### VSCode 启动配置

打开 `student_study.code-workspace` 后，可在 VSCode 的 **Run and Debug** 面板中选择：

| 配置 | 说明 |
|------|------|
| 🌐 Run Web (Chrome debug) | Web 开发调试 |
| 🖥️ Run Windows (debug) | Windows 桌面调试 |
| 📱 Run Android (debug) | Android 调试 |
| 🔬 Debug Windows | 带断点的 Windows 调试 |
| 🌐 Debug Web (Chrome) | 带断点的 Chrome 调试 |
| 📦 Build Web (release) | 构建 Web 发布版 |
| 🧪 Run Tests | 运行单元测试 |
| 🔍 Dart Analyze | 静态分析 |
| 🧹 Clean & Reinstall | 清理缓存重装依赖 |

## 项目结构

```
student_study/
├── lib/                          # Dart 源码
│   ├── app/                      # 应用配置（主题/路由/入口）
│   ├── core/                     # 核心引擎
│   │   ├── content/              # 内容加载器 + 数据模型
│   │   ├── engine/               # 答题引擎 + 计分 + 自适应难度
│   │   ├── gamification/         # 成长树/成就/每日任务/错题本
│   │   └── user/                 # 用户管理 + 进度追踪
│   └── features/                 # 功能模块
│       ├── home/                 # 首页（签到/模块卡片/统计）
│       ├── intellect/            # 智育学堂
│       ├── tech/                 # 科技探索
│       ├── logic/                # 逻辑训练（含可玩数独）
│       ├── general/              # 通识百科
│       ├── words/                # 好词好句填词游戏
│       ├── quiz/                 # 通用答题界面
│       ├── profile/              # 个人中心/错题本/成就
│       └── parent/               # 家长面板
├── assets/content/               # 3000+ 教育内容 JSON
├── ops/                          # 运维脚本（构建/发布/环境）
├── evolution/                    # 项目演进知识库
└── .github/workflows/            # CI/CD 自动构建发布
```

## Git 工作流

### 分支策略

| 分支 | 用途 |
|------|------|
| `main` | 稳定发布分支，仅通过 PR 合并 |
| `develop` | 日常开发分支 |
| `feature/*` | 功能开发分支，从 develop 切出 |
| `fix/*` | 问题修复分支 |
| `content/*` | 内容更新分支 |

### 日常开发流程

```bash
# 1. 从 develop 创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/新功能名称

# 2. 开发并提交
git add .
git commit -m "feat: 功能描述"

# 3. 推送到远程
git push origin feature/新功能名称

# 4. 在 GitHub 上创建 Pull Request → develop

# 5. 合并后删除功能分支
git checkout develop
git pull origin develop
git branch -d feature/新功能名称
```

### 提交规范

```
<type>: <描述>

type 类型：
  feat     新功能
  fix      修复 bug
  content  内容更新（题目/故事/卡片）
  refactor 代码重构
  docs     文档更新
  test     测试
  chore    构建/依赖/配置
  perf     性能优化
```

示例：
```bash
git commit -m "feat: 新增化学实验模块"
git commit -m "content: 数学三年级新增30题"
git commit -m "fix: 修复数独计分错误"
```

## 发布流程

### 自动发布（推荐）

推送 `v*` 格式的 tag 自动触发 GitHub Actions 构建并发布：

```bash
# 1. 确保 develop 分支代码最新且通过测试
git checkout develop
git pull origin develop
flutter analyze    # 确保零错误
flutter test       # 确保测试通过

# 2. 创建版本 tag
git tag -a v1.0.3 -m "v1.0.3 - 版本描述"

# 3. 推送 tag 触发自动构建
git push origin v1.0.3
```

GitHub Actions 自动执行：
1. **Build Android** — 构建 APK (`student-study-*-android.apk`)
2. **Build Windows** — 构建 Windows (`student-study-*-windows.zip`)
3. **Create Release** — 创建 GitHub Release，附加构建产物

构建完成后在 [Releases 页面](https://github.com/katalinas/student_study/releases) 下载。

### 手动发布

如果自动构建失败，可以手动操作：

1. 本地构建：
   ```bash
   flutter build apk --release          # Android
   flutter build windows --release      # Windows（需开发者模式）
   ```
2. 在 GitHub → Releases → Create new release
3. 填写 Tag（如 `v1.0.4`）和 Release notes
4. 上传构建产物到 Assets

### 版本号规则

```
v主版本.次版本.修订号

主版本  重大功能更新或架构变更（V1→V2）
次版本  新功能或模块上线（V1.0→V1.1）
修订号  Bug修复或内容更新（V1.0.0→V1.0.1）
```

### CI/CD 环境

| 组件 | 版本 | 说明 |
|------|------|------|
| Node.js | 24 | GitHub Actions 运行时 |
| Java | 21 (Temurin) | Android 构建 |
| Flutter | 3.41.6 | 跨平台框架 |
| Dart | 3.11.4 | 编程语言 |

### CI 工作流文件

| 文件 | 触发条件 | 功能 |
|------|---------|------|
| `.github/workflows/ci.yml` | push 到 main/develop, PR | 代码分析 + 测试 + 构建验证 |
| `.github/workflows/release.yml` | push `v*` tag | 构建 APK + Windows + 创建 Release |

## 内容扩展指南

项目设计了完整的演进体系，方便持续添加内容：

### 添加新题目

```bash
# 1. 了解数据格式
cat evolution/CONTENT_SCHEMA.md

# 2. 复制模板
cp evolution/templates/question.json assets/content/{module}/new_questions.json

# 3. 编辑内容，遵循 JSON Schema
# 4. 更新内容索引
vim evolution/content_registry/{module}.md

# 5. 提交
git add assets/content/ evolution/content_registry/
git commit -m "content: {module}新增N题"
```

### 添加新模块

```bash
# 1. 使用模块提案模板
cat evolution/templates/new_module.md

# 2. 在 MODULES.md 注册
# 3. 创建代码目录 lib/features/{module}/
# 4. 创建数据目录 assets/content/{module}/
# 5. 在 router.dart 注册路由
# 6. 在 pubspec.yaml 添加 assets 路径
```

详见 [evolution/README.md](evolution/README.md)

## 版本规划

| 版本 | 内容 | 状态 |
|------|------|------|
| V1.0 | 6模块 + 3000+内容 + 游戏化系统 | 开发中 |
| V1.1 | 内容扩充至5000+ + 离线模式 | 计划中 |
| V2.0 | iOS/Web + AI辅导 + 云同步 | 计划中 |
| V3.0 | 教师后台 + 自适应学习路径 | 计划中 |

## 许可证

私有项目，保留所有权利。
