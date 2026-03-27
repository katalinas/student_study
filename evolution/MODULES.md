# 模块注册表

所有模块的元信息。新增模块时必须在此注册。

## 模块列表

### MOD-001: 智育学堂 (intellect)

| 属性 | 值 |
|------|------|
| ID | `intellect` |
| 路径 | `features/intellect/` |
| 权重 | ★★★ 30% |
| 状态 | `alpha` |
| 年级范围 | 1-9 |
| 子模块 | math, chinese, english |
| 依赖 | core/engine, core/content |
| 内容索引 | `content_registry/intellect.md` |
| 数据路径 | `assets/content/intellect/` |
| 题目类型 | 选择题、填空题、判断题、连线题 |
| 预计条目 | 2000+ |

---

### MOD-002: 科技探索 (tech)

| 属性 | 值 |
|------|------|
| ID | `tech` |
| 路径 | `features/tech/` |
| 权重 | ★★☆ 25% |
| 状态 | `alpha` |
| 年级范围 | 1-9 |
| 子模块 | programming, ai_intro, virtual_lab, aerospace, tech_timeline |
| 依赖 | core/engine, core/content |
| 内容索引 | `content_registry/tech.md` |
| 数据路径 | `assets/content/tech/` |
| 题目类型 | 选择题、拖拽操作、模拟实验、代码编辑 |
| 预计条目 | 800+ |

---

### MOD-003: 逻辑训练 (logic)

| 属性 | 值 |
|------|------|
| ID | `logic` |
| 路径 | `features/logic/` |
| 权重 | ★★☆ 20% |
| 状态 | `alpha` |
| 年级范围 | 1-9 |
| 子模块 | pattern, deduction, strategy, spatial |
| 依赖 | core/engine, core/content |
| 内容索引 | `content_registry/logic.md` |
| 数据路径 | `assets/content/logic/` |
| 题目类型 | 图形拖拽、数字填空、策略游戏、空间操作 |
| 预计条目 | 800+ |
| 闯关 | 80关（4岛 × 20关） |

---

### MOD-004: 通识百科 (general)

| 属性 | 值 |
|------|------|
| ID | `general` |
| 路径 | `features/general/` |
| 权重 | ★☆☆ 15% |
| 状态 | `alpha` |
| 年级范围 | 1-9 |
| 子模块 | geography, history, art, life_skills |
| 依赖 | core/content |
| 内容索引 | `content_registry/general.md` |
| 数据路径 | `assets/content/general/` |
| 题目类型 | 卡片浏览、选择题、图文匹配 |
| 预计条目 | 500+ |

---

### MOD-005: 德育融入 (moral)

| 属性 | 值 |
|------|------|
| ID | `moral` |
| 路径 | `features/moral/` |
| 权重 | ★☆☆ 10% |
| 状态 | `alpha` |
| 年级范围 | 1-9 |
| 子模块 | daily_quote, story_reader, tradition, values |
| 依赖 | core/content |
| 内容索引 | `content_registry/moral.md` |
| 数据路径 | `assets/content/moral/` |
| 题目类型 | 阅读 + 简单问答 |
| 预计条目 | 350+ |
| 集成方式 | 融入签到流程，非独立Tab |

---

### MOD-006: 好词好句 (words)

| 属性 | 值 |
|------|------|
| ID | `words` |
| 路径 | `features/words/` |
| 权重 | ★★☆ (新增特色模块) |
| 状态 | `alpha` |
| 年级范围 | 3-9 |
| 子模块 | poetry_classical, prose_modern, composition_phrases, famous_quotes, idiom_usage, reading_excerpts, ancient_wisdom |
| 依赖 | core/content |
| 内容索引 | `content_registry/words.md` |
| 数据路径 | `assets/content/words/` |
| 题目类型 | 填词选择 (fill_word) |
| 预计条目 | 500+ |

---

## 模块状态定义

| 状态 | 含义 |
|------|------|
| `planned` | 已设计，未开始开发 |
| `in_progress` | 开发中 |
| `alpha` | 基础功能可用，内容不完整 |
| `beta` | 功能完整，内容基本完整 |
| `stable` | 发布就绪 |
| `evolving` | 已发布，持续扩充内容 |

## 新增模块检查清单

- [ ] 在本文件注册模块元信息
- [ ] 创建 `features/{module_id}/` 目录
- [ ] 创建 `assets/content/{module_id}/` 数据目录
- [ ] 创建 `content_registry/{module_id}.md` 索引
- [ ] 在 `ARCHITECTURE.md` 更新依赖图
- [ ] 在 `app/router.dart` 注册路由
- [ ] 在首页添加入口
- [ ] 在 `CONTENT_SCHEMA.md` 添加特有数据格式（如有）
- [ ] 更新 `ROADMAP.md`
- [ ] 更新 `CHANGELOG.md`
