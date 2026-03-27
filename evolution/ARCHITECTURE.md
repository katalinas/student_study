# 技术架构

## 技术栈

| 层级 | 技术选型 | 说明 |
|------|---------|------|
| 前端框架 | Flutter 3.x | 跨平台 Windows + Android |
| 状态管理 | Riverpod | 响应式、可测试 |
| 本地数据库 | SQLite (drift) | 题库、用户数据、进度 |
| 内容存储 | JSON + Markdown | 题目数据 + 富文本内容 |
| 路由 | go_router | 声明式路由 |
| 多媒体 | just_audio + cached_network_image | 音频朗读 + 图片缓存 |
| 图表 | fl_chart | 学习报告可视化 |
| 动画 | Lottie + Flutter内置 | 交互动画 |

## 目录结构

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # MaterialApp 配置
│   ├── router.dart                 # 路由定义
│   └── theme/                      # 主题（色彩、字体、组件样式）
│       ├── app_theme.dart
│       ├── colors.dart
│       └── text_styles.dart
│
├── core/                           # 跨模块共享基础设施
│   ├── database/                   # SQLite 数据层
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   └── daos/
│   ├── content/                    # 内容加载引擎
│   │   ├── content_loader.dart     # JSON/Markdown 解析
│   │   ├── content_cache.dart      # 内容缓存
│   │   └── models/                 # 通用内容模型
│   │       ├── question.dart
│   │       ├── story.dart
│   │       └── experiment.dart
│   ├── engine/                     # 答题/闯关引擎
│   │   ├── quiz_engine.dart        # 答题流程控制
│   │   ├── scoring.dart            # 计分逻辑
│   │   ├── difficulty.dart         # 自适应难度
│   │   └── timer.dart              # 计时器
│   ├── gamification/               # 游戏化系统
│   │   ├── achievement.dart        # 成就/徽章
│   │   ├── daily_task.dart         # 每日任务
│   │   ├── growth_tree.dart        # 成长树
│   │   └── streak.dart             # 连续打卡
│   ├── user/                       # 用户管理
│   │   ├── user_model.dart
│   │   ├── user_repository.dart
│   │   └── progress_tracker.dart   # 学习进度
│   └── widgets/                    # 通用 UI 组件
│       ├── question_card.dart
│       ├── progress_bar.dart
│       ├── reward_animation.dart
│       └── age_gate.dart           # 年龄段内容过滤
│
├── features/                       # 功能模块（每个模块独立）
│   ├── intellect/                  # 智育学堂 ★★★
│   │   ├── math/
│   │   ├── chinese/
│   │   └── english/
│   ├── tech/                       # 科技探索 ★★☆
│   │   ├── programming/            # 编程练习场
│   │   ├── ai_intro/               # AI 科普
│   │   ├── virtual_lab/            # 虚拟实验室
│   │   ├── aerospace/              # 航天航空
│   │   └── tech_timeline/          # 科技时间线
│   ├── logic/                      # 逻辑训练 ★★☆
│   │   ├── pattern/                # 模式识别
│   │   ├── deduction/              # 演绎推理
│   │   ├── strategy/               # 策略游戏
│   │   └── spatial/                # 空间思维
│   ├── general/                    # 通识百科 ★☆☆
│   │   ├── geography/
│   │   ├── history/
│   │   ├── art/
│   │   └── life_skills/
│   ├── moral/                      # 德育融入 ★☆☆
│   │   ├── daily_quote.dart        # 每日签到名句
│   │   ├── story_reader.dart       # 品德故事
│   │   └── tradition.dart          # 传统文化
│   ├── home/                       # 首页
│   ├── profile/                    # 个人中心
│   └── parent/                     # 家长面板
│
└── assets/                         # 静态资源引用
    # 实际资源在项目根目录 assets/ 下
```

```
assets/
├── content/                        # 内容数据文件
│   ├── intellect/
│   │   ├── math/
│   │   │   ├── grade1.json
│   │   │   └── ...
│   │   ├── chinese/
│   │   └── english/
│   ├── tech/
│   │   ├── programming/
│   │   ├── experiments/
│   │   └── timeline.json
│   ├── logic/
│   │   ├── pattern.json
│   │   ├── deduction.json
│   │   ├── strategy.json
│   │   └── spatial.json
│   ├── general/
│   └── moral/
│       ├── stories/
│       └── quotes.json
├── images/
├── animations/                     # Lottie JSON
└── audio/
```

## 扩展点（Extension Points）

新增内容或功能时的接入位置：

### EP1: 新增题目类型
- 位置: `core/content/models/` 新增模型
- 位置: `core/engine/quiz_engine.dart` 注册题型处理器
- 位置: `core/widgets/` 新增题型 UI 组件
- 数据: `assets/content/{module}/` 添加 JSON 文件

### EP2: 新增功能模块
- 位置: `features/{new_module}/` 创建模块目录
- 位置: `app/router.dart` 注册路由
- 位置: `features/home/` 添加入口卡片
- 演进: `evolution/MODULES.md` 注册模块元信息
- 演进: `evolution/content_registry/` 创建内容索引

### EP3: 新增年级/难度
- 位置: `core/engine/difficulty.dart` 添加难度级别
- 数据: `assets/content/{module}/grade{n}.json` 添加对应年级数据
- 位置: `core/user/progress_tracker.dart` 扩展进度追踪

### EP4: 新增游戏化元素
- 位置: `core/gamification/` 新增游戏化组件
- 位置: `features/profile/` 展示新成就/奖励

### EP5: 新增平台支持
- 位置: `pubspec.yaml` 添加平台配置
- 位置: `lib/core/` 处理平台差异（如有）

## 模块依赖图

```
core/database ← core/content ← features/*
core/engine   ← features/intellect
              ← features/logic
              ← features/tech
core/gamification ← features/home
                  ← features/profile
core/user ← features/parent
          ← features/profile
          ← core/gamification
```

规则：features 之间不直接依赖，全部通过 core 共享。
