# 开发约定

## 命名规范

### Dart/Flutter 代码

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件名 | snake_case | `quiz_engine.dart` |
| 类名 | PascalCase | `QuizEngine` |
| 变量/方法 | camelCase | `currentScore` |
| 常量 | camelCase | `maxRetries` |
| 枚举值 | camelCase | `QuestionType.choice` |
| 私有成员 | _前缀 | `_isLoading` |
| Provider | camelCase + Provider | `quizEngineProvider` |

### 资源文件

| 类型 | 规范 | 示例 |
|------|------|------|
| 内容 JSON | snake_case | `grade1_math.json` |
| 图片 | snake_case | `solar_system.png` |
| 音频 | snake_case | `story_001.mp3` |
| 动画 | snake_case | `reward_star.json` |

### 内容 ID

```
{module}_{type_prefix}_{3位序号}

module:  intellect | tech | logic | general | moral
prefix:  q (题目) | s (故事) | e (实验) | c (卡片) | g (游戏)
序号:    001-999

示例: intellect_q_001, tech_e_015, logic_g_003
```

## 目录约定

```
新增功能模块:  lib/features/{module_id}/
新增内容数据:  assets/content/{module_id}/
新增图片资源:  assets/images/{module_id}/
新增音频资源:  assets/audio/{module_id}/
新增动画资源:  assets/animations/{module_id}/
测试文件:      test/features/{module_id}/
```

## 模块结构约定

每个 feature 模块内部结构：

```
features/{module}/
├── {module}_screen.dart       # 模块主页面
├── models/                    # 模块私有数据模型
├── providers/                 # 模块 Riverpod providers
├── widgets/                   # 模块私有 UI 组件
└── sub_modules/               # 子模块（如有）
    ├── {sub}/
    │   ├── {sub}_screen.dart
    │   ├── providers/
    │   └── widgets/
```

## Git 约定

### 分支命名

```
feature/{module}-{功能}     例: feature/tech-virtual-lab
content/{module}-{描述}     例: content/logic-pattern-questions
fix/{模块}-{问题}           例: fix/engine-score-calculation
chore/{描述}               例: chore/update-dependencies
```

### Commit Message

```
<type>: <描述>

type: feat | fix | content | refactor | test | docs | chore | perf
```

示例：
- `feat: add virtual lab circuit simulator`
- `content: add grade3 math questions (50 items)`
- `fix: scoring error in matching questions`

## 内容添加约定

### 批量添加内容的标准流程

1. **准备 JSON 数据** — 遵循 `CONTENT_SCHEMA.md` 格式
2. **放置到正确路径** — `assets/content/{module}/`
3. **验证数据完整性** — ID 唯一、字段完整、引用资源存在
4. **更新内容索引** — `evolution/content_registry/{module}.md`
5. **更新变更记录** — `evolution/CHANGELOG.md`

### 内容质量要求

| 项目 | 要求 |
|------|------|
| 准确性 | 知识点必须准确无误 |
| 年龄适配 | 语言难度匹配目标年级 |
| 解释清晰 | explanation 字段必须对该年龄段友好 |
| 图片引用 | 所有 image 路径对应的文件必须存在 |
| 无歧义 | 选项不能有多个合理答案（除非设计如此） |
| 无偏见 | 内容不含性别、地域等偏见 |

## 自适应难度参数

```
连续答对 N 题升级:  N = 3
连续答错 N 题降级:  N = 2
初始难度:          该年级的 difficulty=2
难度范围:          1-5
跨年级:            不允许跨 ±2 年级推荐内容
```
