# 内容数据规范

所有内容数据的 JSON Schema 定义。新增内容时必须遵循此规范。

## 通用字段

每条内容数据都包含以下通用字段：

```json
{
  "id": "string         // 全局唯一ID，格式: {module}_{type}_{序号}",
  "module": "string     // 所属模块ID: intellect|tech|logic|general|moral|words",
  "type": "string       // 内容类型: question|story|experiment|card|game|word_game",
  "grade_min": "number  // 最低适用年级 1-9",
  "grade_max": "number  // 最高适用年级 1-9",
  "difficulty": "number // 难度 1-5 (⭐ 到 ⭐⭐⭐⭐⭐)",
  "tags": ["string"],
  "created_at": "string // ISO 8601 日期",
  "updated_at": "string // ISO 8601 日期",
  "version": "number    // 数据版本号，从1开始"
}
```

---

## TYPE-1: 题目 (question)

### 选择题 (choice)

```json
{
  "id": "intellect_q_001",
  "module": "intellect",
  "type": "question",
  "subtype": "choice",
  "grade_min": 1,
  "grade_max": 3,
  "difficulty": 1,
  "tags": ["math", "addition"],
  "subject": "math",
  "stem": "3 + 5 = ?",
  "stem_image": null,
  "options": [
    {"label": "A", "text": "7", "image": null},
    {"label": "B", "text": "8", "image": null},
    {"label": "C", "text": "9", "image": null},
    {"label": "D", "text": "6", "image": null}
  ],
  "answer": "B",
  "explanation": "3加5等于8，可以用手指数一数。",
  "hint": "从3开始，再往后数5个数。",
  "time_limit_seconds": 30,
  "points": 10,
  "version": 1,
  "created_at": "2026-03-27",
  "updated_at": "2026-03-27"
}
```

### 填空题 (fill_blank)

```json
{
  "id": "intellect_q_101",
  "module": "intellect",
  "type": "question",
  "subtype": "fill_blank",
  "grade_min": 2,
  "grade_max": 4,
  "difficulty": 2,
  "tags": ["chinese", "idiom"],
  "subject": "chinese",
  "stem": "完成成语：守株待___",
  "blanks": [
    {
      "position": 0,
      "answer": "兔",
      "accept_variants": ["兔"]
    }
  ],
  "explanation": "守株待兔，出自《韩非子》，比喻不主动努力而存万一的侥幸心理。",
  "hint": "想想什么动物会撞到树桩上？",
  "time_limit_seconds": 20,
  "points": 10,
  "version": 1,
  "created_at": "2026-03-27",
  "updated_at": "2026-03-27"
}
```

### 判断题 (true_false)

```json
{
  "id": "general_q_001",
  "module": "general",
  "type": "question",
  "subtype": "true_false",
  "grade_min": 3,
  "grade_max": 6,
  "difficulty": 1,
  "tags": ["geography", "planet"],
  "stem": "地球是太阳系中最大的行星。",
  "answer": false,
  "explanation": "木星才是太阳系最大的行星，地球排第五。",
  "points": 5,
  "version": 1,
  "created_at": "2026-03-27",
  "updated_at": "2026-03-27"
}
```

### 连线题 (matching)

```json
{
  "id": "intellect_q_201",
  "module": "intellect",
  "type": "question",
  "subtype": "matching",
  "grade_min": 1,
  "grade_max": 3,
  "difficulty": 2,
  "tags": ["english", "vocabulary"],
  "stem": "将英文单词与对应的中文连线：",
  "left_items": [
    {"id": "L1", "text": "Apple", "image": null},
    {"id": "L2", "text": "Cat", "image": null},
    {"id": "L3", "text": "Dog", "image": null}
  ],
  "right_items": [
    {"id": "R1", "text": "狗", "image": null},
    {"id": "R2", "text": "苹果", "image": null},
    {"id": "R3", "text": "猫", "image": null}
  ],
  "correct_pairs": [
    {"left": "L1", "right": "R2"},
    {"left": "L2", "right": "R3"},
    {"left": "L3", "right": "R1"}
  ],
  "points": 15,
  "version": 1,
  "created_at": "2026-03-27",
  "updated_at": "2026-03-27"
}
```

### 拖拽排序题 (drag_order)

```json
{
  "id": "logic_q_001",
  "module": "logic",
  "type": "question",
  "subtype": "drag_order",
  "grade_min": 2,
  "grade_max": 5,
  "difficulty": 2,
  "tags": ["pattern", "sequence"],
  "stem": "将下列图形按规律排列：",
  "items": [
    {"id": "I1", "text": null, "image": "assets/images/logic/shape_circle.png"},
    {"id": "I2", "text": null, "image": "assets/images/logic/shape_triangle.png"},
    {"id": "I3", "text": null, "image": "assets/images/logic/shape_square.png"}
  ],
  "correct_order": ["I1", "I3", "I2"],
  "explanation": "规律是边数递增：圆(0) → 正方形(4) → 三角形(3)... 这里按照给定规律排列。",
  "points": 15,
  "version": 1,
  "created_at": "2026-03-27",
  "updated_at": "2026-03-27"
}
```

---

## TYPE-2: 故事 (story)

```json
{
  "id": "moral_s_001",
  "module": "moral",
  "type": "story",
  "grade_min": 1,
  "grade_max": 6,
  "difficulty": 1,
  "tags": ["idiom", "perseverance"],
  "title": "铁杵磨成针",
  "category": "idiom_story",
  "cover_image": "assets/images/moral/iron_pestle.png",
  "audio": "assets/audio/moral/iron_pestle.mp3",
  "read_time_minutes": 3,
  "sections": [
    {
      "order": 1,
      "text": "唐朝大诗人李白小时候不爱学习，经常逃学...",
      "image": "assets/images/moral/iron_pestle_01.png"
    },
    {
      "order": 2,
      "text": "一天，他看到一位老奶奶在磨一根铁棒...",
      "image": "assets/images/moral/iron_pestle_02.png"
    }
  ],
  "moral": "只要功夫深，铁杵磨成针。做任何事情都需要坚持和耐心。",
  "follow_up_questions": [
    {
      "stem": "李白从老奶奶身上学到了什么？",
      "options": ["要快速完成", "坚持就能成功", "不要做困难的事"],
      "answer": 1
    }
  ],
  "related_idiom": "铁杵磨成针",
  "version": 1,
  "created_at": "2026-03-27",
  "updated_at": "2026-03-27"
}
```

---

## TYPE-3: 虚拟实验 (experiment)

```json
{
  "id": "tech_e_001",
  "module": "tech",
  "type": "experiment",
  "grade_min": 3,
  "grade_max": 6,
  "difficulty": 2,
  "tags": ["circuit", "electricity"],
  "title": "点亮小灯泡",
  "category": "electronics",
  "cover_image": "assets/images/tech/circuit_cover.png",
  "description": "用电池、导线和灯泡搭建一个简单电路，让灯泡亮起来。",
  "learning_goals": [
    "了解电路的基本组成",
    "理解开路和闭路的区别",
    "学会串联电路的搭建"
  ],
  "components": [
    {"id": "battery", "name": "电池", "icon": "battery.png", "count": 1},
    {"id": "wire", "name": "导线", "icon": "wire.png", "count": 2},
    {"id": "bulb", "name": "灯泡", "icon": "bulb.png", "count": 1},
    {"id": "switch", "name": "开关", "icon": "switch.png", "count": 1}
  ],
  "steps": [
    {"order": 1, "instruction": "将电池放在桌面上", "validation": "battery_placed"},
    {"order": 2, "instruction": "用导线连接电池正极和灯泡", "validation": "wire_positive"},
    {"order": 3, "instruction": "用导线连接灯泡和电池负极", "validation": "wire_negative"},
    {"order": 4, "instruction": "观察灯泡是否亮起", "validation": "circuit_complete"}
  ],
  "success_condition": "circuit_complete",
  "fun_facts": [
    "爱迪生尝试了上千种材料才找到合适的灯丝！",
    "电流的速度接近光速，每秒30万公里。"
  ],
  "follow_up_questions": [
    {
      "stem": "如果断开一根导线，灯泡会怎样？",
      "options": ["更亮", "熄灭", "不变"],
      "answer": 1
    }
  ],
  "points": 20,
  "version": 1,
  "created_at": "2026-03-27",
  "updated_at": "2026-03-27"
}
```

---

## TYPE-4: 百科卡片 (card)

```json
{
  "id": "general_c_001",
  "module": "general",
  "type": "card",
  "grade_min": 1,
  "grade_max": 9,
  "difficulty": 1,
  "tags": ["astronomy", "solar_system"],
  "title": "太阳系八大行星",
  "category": "astronomy",
  "cover_image": "assets/images/general/solar_system.png",
  "summary": "太阳系有八大行星，从近到远依次是：水星、金星、地球、火星、木星、土星、天王星、海王星。",
  "detail_sections": [
    {"title": "水星", "text": "离太阳最近，最小的行星...", "image": "mercury.png"},
    {"title": "金星", "text": "最热的行星，温度可达465°C...", "image": "venus.png"}
  ],
  "fun_facts": [
    "木星上的大红斑是一个持续了几百年的风暴！",
    "土星的密度比水还低，如果有足够大的水池，土星会浮起来。"
  ],
  "related_cards": ["general_c_002", "general_c_003"],
  "version": 1,
  "created_at": "2026-03-27",
  "updated_at": "2026-03-27"
}
```

---

## TYPE-5: 策略游戏 (game)

```json
{
  "id": "logic_g_001",
  "module": "logic",
  "type": "game",
  "subtype": "sudoku",
  "grade_min": 3,
  "grade_max": 6,
  "difficulty": 2,
  "tags": ["strategy", "sudoku"],
  "title": "数独 4×4",
  "grid_size": 4,
  "initial_grid": [
    [1, 0, 0, 4],
    [0, 0, 1, 0],
    [0, 1, 0, 0],
    [4, 0, 0, 2]
  ],
  "solution": [
    [1, 2, 3, 4],
    [3, 4, 1, 2],
    [2, 1, 4, 3],
    [4, 3, 2, 1]
  ],
  "hints_allowed": 3,
  "time_limit_seconds": 300,
  "points": 25,
  "version": 1,
  "created_at": "2026-03-27",
  "updated_at": "2026-03-27"
}
```

---

## TYPE-6: 填词选择 (word_game)

```json
{
  "id": "words_w_001",
  "module": "words",
  "type": "word_game",
  "subtype": "fill_word",
  "grade_min": 3,
  "grade_max": 6,
  "difficulty": 2,
  "tags": ["poetry", "tang_dynasty"],
  "category": "poetry_classical",
  "source": "李白《静夜思》",
  "context": "床前明月光，疑是地上___。",
  "blank_position": 7,
  "answer": "霜",
  "options": ["霜", "雪", "露", "冰"],
  "explanation": "出自李白《静夜思》：'床前明月光，疑是地上霜。'此句将月光比作地上的白霜，表达诗人的思乡之情。",
  "hint": "月光洒在地上，看起来像什么白色的东西？",
  "full_text": "床前明月光，疑是地上霜。举头望明月，低头思故乡。",
  "author": "李白",
  "dynasty": "唐",
  "points": 10,
  "version": 1,
  "created_at": "2026-03-27",
  "updated_at": "2026-03-27"
}
```

### 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `category` | string | 是 | 子模块分类: poetry_classical, prose_modern, composition_phrases, famous_quotes, idiom_usage, reading_excerpts, ancient_wisdom |
| `source` | string | 是 | 出处（作者+作品名） |
| `context` | string | 是 | 带空格的原文，`___` 标记填空位置 |
| `blank_position` | number | 是 | 空格在原文中的字符位置 |
| `answer` | string | 是 | 正确答案（单字或词语） |
| `options` | [string] | 是 | 4个选项，包含正确答案 |
| `full_text` | string | 否 | 完整原文（答题后展示） |
| `author` | string | 否 | 作者 |
| `dynasty` | string | 否 | 朝代（古文类适用） |

---

## 内容 ID 编码规则

```
{module}_{type_prefix}_{sequential_number}

module:       intellect | tech | logic | general | moral | words
type_prefix:  q (question) | s (story) | e (experiment) | c (card) | g (game) | w (word_game)
number:       001-999, 按模块递增

示例:
  intellect_q_001  → 智育模块第1题
  tech_e_015       → 科技模块第15个实验
  logic_g_003      → 逻辑模块第3个游戏
  moral_s_042      → 德育模块第42个故事
  words_w_001      → 好词好句模块第1条填词
```

## 添加新内容检查清单

- [ ] 遵循对应 TYPE 的 JSON Schema
- [ ] ID 遵循编码规则且全局唯一
- [ ] grade_min ≤ grade_max
- [ ] difficulty 在 1-5 范围内
- [ ] 所有引用的图片/音频路径真实存在
- [ ] explanation/hint 对该年龄段友好
- [ ] 更新 `content_registry/{module}.md` 索引
- [ ] 更新 `CHANGELOG.md`
