# 变更记录

格式: `[版本] - 日期 - 类型 - 描述`

## [未发布]

### 2026-03-27 — 新增好词好句模块 + 内容补充至3000+
- **feat**: 新增好词好句模块 (words)，325条填词内容
  - 古诗词名句填词 (poetry_classical): 65条
  - 现代散文佳句 (prose_modern): 65条
  - 作文好词好句 (composition_phrases): 60条
  - 名人名言 (famous_quotes): 25条
  - 成语运用 (idiom_usage): 55条
  - 名著经典选段 (reading_excerpts): 30条
  - 古文智慧 (ancient_wisdom): 25条
  - 模块UI界面 + 答题交互
- **content**: 德育三观教育 (values) 新增110条
  - 价值观/世界观/人生观/态度/榜样5个分类

### 2026-03-27 — 内容扩充第二批 (1196→2906条)
- **content**: 智育数学全年级扩充至1219题
- **content**: 语文/英语各4级别共约400题
- **content**: 科技编程题80个 + 科学100题 + 更多实验20个
- **content**: 逻辑推理/空间/模式各扩充 + 数独30局 + 24点30题
- **content**: 通识历史/国家/文化/体育等百科卡片
- **content**: 德育三观教育110条（价值观/世界观/人生观/态度/榜样）
- 总计: 从约407条扩充至 **2906条**

### 2026-03-27 — 内容大规模扩充
- **content**: 智育数学全年级覆盖（grade1-9），104题
- **content**: 智育语文4个级别，44题（拼音/成语/古诗词/文言文）
- **content**: 智育英语4个级别，46题（字母/词汇/语法/阅读）
- **content**: 科技AI科普8卡片 + 航天10卡片 + 力学实验3个 + 工业/信息时间线16卡片
- **content**: 逻辑演绎推理15题 + 空间思维10题 + 高级模式识别10题
- **content**: 通识历史10卡片 + 艺术8卡片 + 生活技能8卡片 + 中国地理10卡片
- **content**: 德育寓言5篇 + 名人传记5篇 + 传统节日8卡片 + 名句30条
- 总计: 从约90条扩充至 **407条**

### 2026-03-27 — 项目初始化与核心框架搭建

- **chore**: Flutter 3.41.6 项目初始化，Windows + Android 双平台配置
- **feat**: UI 设计系统
  - Material 3 主题，模块专属配色
  - 儿童友好字体排版
- **feat**: JSON 内容加载引擎
  - JSON 解析器 + 内存缓存
- **feat**: 答题引擎，支持5种题型
  - choice（选择）、fill_blank（填空）、true_false（判断）、matching（连线）、drag_order（拖拽排序）
  - 自适应难度系统（连续答对升级 / 答错降级）
  - 计分系统含时间奖励
- **feat**: 用户系统
  - 本地多用户，基于 SharedPreferences
- **feat**: 进度追踪
  - 每日统计 + 连续打卡天数
- **feat**: 首页与导航
  - 首页模块卡片、每日签到、统计栏
  - go_router 导航，StatefulShellRoute 5 Tab 布局
- **chore**: ops/ 运维目录
  - Makefile 本地命令
  - build/release/setup bash 脚本
  - 环境配置文件
- **ci**: GitHub Actions CI/CD
  - ci.yml — lint/test/build
  - release.yml — tag 触发发布，产出 APK + Windows 产物
- **content**: 示例内容，10个 JSON 文件覆盖全部5模块（约90条）
- **docs**: 创建 evolution 演进体系
  - PRODUCT_VISION.md — 产品愿景
  - ARCHITECTURE.md — 技术架构与扩展点
  - MODULES.md — 模块注册表
  - CONTENT_SCHEMA.md — 内容数据规范
  - ROADMAP.md — 版本路线图
  - CONVENTIONS.md — 开发约定
  - CHANGELOG.md — 变更记录
  - templates/ — 模板文件
  - content_registry/ — 内容索引
  - decisions/ — 架构决策记录

---

## 记录规范

每条变更记录包含:
- **日期**: YYYY-MM-DD
- **类型**: feat | fix | content | refactor | test | docs | chore | perf
- **描述**: 简要说明变更内容
- **影响模块**: 涉及的模块 ID（如有）
- **条目数**: 添加/修改的内容条目数（内容变更时）

示例:
```
### 2026-04-15 — 智育数学题库上线
- **content**: 添加1-3年级数学选择题 (intellect)
  - 新增条目: 150题
  - 覆盖: 加减法、乘除法、图形认知
  - 文件: assets/content/intellect/math/grade1.json, grade2.json, grade3.json
```
