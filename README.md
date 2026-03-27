# 少年研学 (Student Study)

面向 K-9（小学至初中）学生的跨平台教育学习应用，基于 Flutter 构建，支持 Android 和 Windows 平台。

## 项目概述

少年研学是一款综合性学习应用，涵盖智育、科技、逻辑、通识、德育、好词好句六大学习模块，通过交互式答题、百科卡片、虚拟实验等多种形式，帮助 1-9 年级学生拓展知识面、锻炼思维能力。

## 功能模块

| 模块 | 说明 | 内容示例 |
|------|------|----------|
| **智育学堂** | 语数英三科同步练习 | 数学（1-9年级分级题库）、语文、英语 |
| **科技探索** | 前沿科技与科学知识 | 编程入门、AI 简介、航天航空、虚拟实验室、科技时间线 |
| **逻辑训练** | 思维能力专项训练 | 图形规律、空间推理、演绎推理、策略博弈（数独等） |
| **通识百科** | 百科知识卡片浏览 | 动植物、地理、历史、名人、艺术、生活技能等 19 个分类 |
| **德育** | 品德与人文素养 | 成语故事、名人传记、寓言、经典语录、传统文化、价值观 |
| **好词好句** | 写作素材与文学鉴赏 | 古诗词、现代散文、名人名言、作文好词好句 |

## 技术栈

- **框架**: Flutter (Dart SDK ^3.11.4)
- **状态管理**: Riverpod (flutter_riverpod + riverpod_annotation)
- **路由**: GoRouter (StatefulShellRoute 底部导航状态持久化)
- **本地数据库**: Drift (SQLite)
- **数据序列化**: Freezed + json_serializable
- **UI 组件**: Material 3、Flutter SVG、Google Fonts、Lottie 动画
- **图表**: fl_chart
- **音频**: just_audio
- **本地存储**: SharedPreferences、path_provider

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app/
│   ├── app.dart                 # 根组件 (Material 3 + 中文区域)
│   ├── router.dart              # GoRouter 路由配置
│   ├── placeholder_screens.dart # 占位页面
│   └── theme/
│       ├── app_theme.dart       # 亮色/暗色主题
│       ├── colors.dart          # 颜色常量 (模块色、年级色、语义色)
│       └── text_styles.dart     # 文本样式
├── core/
│   ├── content/
│   │   ├── content_loader.dart  # JSON 内容加载与缓存服务
│   │   └── models/
│   │       ├── content_item.dart  # 内容项基类
│   │       ├── question.dart      # 题目模型 (选择/填空/判断/配对/排序)
│   │       ├── story.dart         # 故事模型
│   │       └── experiment.dart    # 实验模型
│   ├── engine/
│   │   ├── quiz_engine.dart     # 测验引擎 (StateNotifier)
│   │   ├── scoring.dart         # 评分算法
│   │   └── difficulty.dart      # 难度调节
│   ├── user/
│   │   ├── user_model.dart      # 用户资料模型 (1-9年级)
│   │   ├── user_provider.dart   # Riverpod 用户状态提供者
│   │   ├── user_repository.dart # 用户数据持久化
│   │   └── progress_tracker.dart # 学习进度追踪 (签到/连续天数/统计)
│   ├── database/                # Drift 数据库 (tables + DAOs)
│   ├── gamification/            # 游戏化系统 (预留)
│   └── widgets/                 # 通用 UI 组件 (预留)
└── features/
    ├── home/                    # 首页 (问候语 + 签到 + 模块网格 + 统计)
    ├── intellect/               # 智育模块 (语文/数学/英语分科)
    ├── tech/                    # 科技模块 (编程/AI/航天/虚拟实验/时间线)
    ├── logic/                   # 逻辑模块 (规律/空间/演绎/策略+数独)
    ├── general/                 # 通识模块 (百科卡片浏览)
    ├── moral/                   # 德育模块
    ├── words/                   # 好词好句模块
    ├── quiz/                    # 通用答题页面 + 组件
    ├── profile/                 # 个人中心 (资料/编辑/设置)
    └── parent/                  # 家长管理页面
```

## 内容资源

所有教学内容以 JSON 格式存储在 `assets/content/` 目录下，按模块和学科分类组织：

```
assets/content/
├── intellect/           # 语文 (11个)、英语 (10个)、数学 (32个) JSON 题库
├── tech/                # 编程、AI、航天、科学、虚拟实验、时间线
├── logic/               # 演绎、规律、空间、策略、24点
├── general/             # 19 个百科分类 (动植物/地理/历史/科学家等)
├── moral/               # 故事/传统/价值观/名言
└── words/               # 古诗词/散文/名言/作文素材
```

## 核心架构

### 内容加载
`ContentLoader` 从 JSON 资源文件加载内容，支持按年级、难度、学科筛选，内存级缓存避免重复解析。

### 测验引擎
`QuizEngine` (StateNotifier) 管理答题生命周期：开始测验 → 提交答案 → 评分 → 导航 → 完成，支持限时测验和时间加分。

### 题目类型
支持 5 种题目子类型：
- **选择题** (choice) - 单选
- **填空题** (fill_blank) - 支持多空和可接受答案
- **判断题** (true_false)
- **配对题** (matching) - 左右连线
- **排序题** (drag_order) - 拖拽排列

### 用户系统
本地多用户管理，每个用户有独立的年级设置和学习进度，支持每日签到和连续天数统计。

## 开发环境

### 前置要求
- Flutter SDK >= 3.11.4
- Dart SDK >= 3.11.4

### 安装与运行

```bash
# 安装依赖
flutter pub get

# 运行代码生成 (Freezed / json_serializable / Drift / Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run

# 运行测试
flutter test
```

### 支持的平台
- Android
- Windows

## 主题与设计

- 支持亮色/暗色主题，跟随系统设置自动切换
- Material 3 设计语言
- 每个学习模块有独立的主题色标识
- 支持 1-9 年级独立颜色标识
- 游戏化设计元素（经验值、连续签到、成就星）