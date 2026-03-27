# 新知识主题: {主题名称}

## 基本信息

| 属性 | 值 |
|------|------|
| 所属模块 | `{module_id}` |
| 所属子模块 | `{sub_module}` |
| 年级范围 | {min}-{max} |
| 内容类型 | {question/story/experiment/card/game} |
| 预计条目 | {数量} |

## 主题描述

{用1-2句话描述这个知识主题}

## 知识点分解

| 知识点 | 年级 | 难度 | 条目数 |
|--------|------|------|--------|
| {知识点1} | {年级} | ⭐ | {数} |
| {知识点2} | {年级} | ⭐⭐ | {数} |

## 内容示例

{给出1-2个典型题目/内容的 JSON 示例，遵循 CONTENT_SCHEMA.md}

## 数据文件路径

```
assets/content/{module_id}/{sub_module}/{文件名}.json
```

## 完成检查清单

- [ ] JSON 数据遵循 CONTENT_SCHEMA.md
- [ ] ID 全局唯一且遵循编码规则
- [ ] 年龄适配性验证
- [ ] 引用资源文件存在
- [ ] 更新 `content_registry/{module_id}.md`
- [ ] 更新 `CHANGELOG.md`
