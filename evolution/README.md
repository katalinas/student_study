# Evolution - 项目演进中心

本目录是项目长期演进的核心知识库，供 AI 助手和开发者快速理解项目全貌、添加内容和功能。

## 目录结构

```
evolution/
├── README.md                 # 本文件 - 演进中心入口
├── PRODUCT_VISION.md         # 产品愿景与长期目标
├── ARCHITECTURE.md           # 技术架构与扩展点
├── MODULES.md                # 模块注册表（所有模块的元信息）
├── CONTENT_SCHEMA.md         # 内容数据规范（题目/故事/实验的格式）
├── ROADMAP.md                # 版本路线图与里程碑
├── CHANGELOG.md              # 已完成的变更记录
├── CONVENTIONS.md            # 开发约定与命名规范
├── templates/                # 新增内容/模块的模板
│   ├── new_module.md         # 新模块提案模板
│   ├── new_topic.md          # 新知识主题模板
│   ├── question.json         # 题目数据模板
│   ├── story.json            # 故事数据模板
│   ├── experiment.json       # 实验数据模板
│   └── feature_request.md    # 功能需求模板
├── content_registry/         # 内容注册表（按模块索引所有内容）
│   ├── intellect.md          # 智育内容索引
│   ├── tech.md               # 科技内容索引
│   ├── logic.md              # 逻辑思维内容索引
│   ├── general.md            # 通识内容索引
│   └── moral.md              # 德育内容索引
└── decisions/                # 架构决策记录 (ADR)
    └── 001_flutter_cross_platform.md
```

## 如何使用

### AI 助手添加新内容
1. 读取 `MODULES.md` 了解目标模块结构
2. 读取 `CONTENT_SCHEMA.md` 了解数据格式
3. 参考 `templates/` 中的模板生成内容
4. 更新 `content_registry/` 中对应的索引
5. 更新 `CHANGELOG.md` 记录变更

### AI 助手添加新功能
1. 读取 `ARCHITECTURE.md` 了解技术架构和扩展点
2. 读取 `CONVENTIONS.md` 了解开发约定
3. 参考 `templates/feature_request.md` 明确需求
4. 参考 `templates/new_module.md` 如果是新模块
5. 更新 `ROADMAP.md` 和 `CHANGELOG.md`

### AI 助手添加新模块
1. 使用 `templates/new_module.md` 编写模块提案
2. 在 `MODULES.md` 注册模块元信息
3. 在 `content_registry/` 创建内容索引
4. 在 `CONTENT_SCHEMA.md` 添加模块特有的数据格式（如有）
5. 更新 `ARCHITECTURE.md` 的模块依赖图
