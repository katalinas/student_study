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

| 平台 | 状态 |
|------|------|
| Windows | 支持 |
| Android | 支持 |
| iOS | 计划中 (V2.0) |
| Web | 计划中 (V2.0) |

## 快速开始

### 环境要求

- Flutter 3.41.6+
- Dart 3.11.4+
- Android SDK（构建 Android）
- Visual Studio 2022 + C++ 桌面开发（构建 Windows）

### 安装运行

```bash
# 克隆项目
git clone https://github.com/katalinas/student_study.git
cd student_study

# 安装依赖
flutter pub get

# 运行（Windows）
flutter run -d windows

# 运行（Android）
flutter run -d android

# 静态分析
flutter analyze
```

### 构建发布

```bash
# 构建 Android APK
flutter build apk --release

# 构建 Windows
flutter build windows --release
```

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

## CI/CD 自动发布

推送 `v*` 标签自动触发 GitHub Actions 构建：

```bash
git tag v1.0.1
git push origin v1.0.1
```

自动产出：
- Android APK — `student-study-*-android.apk`
- Windows 安装包 — `student-study-*-windows.zip`

发布产物自动附加到 GitHub Release 页面。

| CI 组件 | 版本 |
|---------|------|
| Node.js | 24 |
| Java | 21 (Temurin) |
| Flutter | 3.41.6 |

## 内容扩展指南

项目设计了完整的演进体系，方便持续添加内容：

1. 查看 `evolution/CONTENT_SCHEMA.md` 了解数据格式
2. 参考 `evolution/templates/` 中的模板
3. 在 `assets/content/{module}/` 添加 JSON 文件
4. 更新 `evolution/content_registry/` 索引

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
