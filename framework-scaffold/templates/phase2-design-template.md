---
phase: 2
stage: architecture_design
status: in_progress
project_name: '{{project_name}}'
tech_stack: '{{tech_stack}}'
date: '{{date}}'
---

# 阶段二：架构设计与评价报告

## 市场调研

### 参考系统

{{referenced_systems_with_analysis}}

### 行业实践

{{industry_practices}}

### 调研结论

{{research_conclusions}}

---

## 架构设计

### 设计思路

{{architecture_design_thinking_为什么这么设计}}

### 架构风格

{{architecture_style_and_reason}}

### 架构图

```mermaid
{{mermaid_architecture_diagram}}
```

### 分层设计

| 层 | 职责 | 关键包/目录 |
|----|------|-------------|
| {{layer}} | {{responsibility}} | {{packages}} |

### 模块划分

{{module_division_with_business_alignment}}

---

## 技术选型

### 主框架

| 项目 | 选择 | 理由 |
|------|------|------|
| {{area}} | {{choice}} | {{reason}} |

### 备选方案对比

| 技术 | 优点 | 缺点 | 结论 |
|------|------|------|------|
| {{alternative}} | {{pros}} | {{cons}} | {{decision}} |

---

## 关键设计决策

| 决策 | 业务动因 | 技术理由 | 备选及拒绝原因 |
|------|----------|----------|----------------|
| {{decision}} | {{business_motivation}} | {{technical_rationale}} | {{alternatives}} |

---

## 方案评价

### 维度评分

| 维度 | 评分 | 说明 |
|------|------|------|
| 业务匹配度 | {{score}} | {{comment}} |
| 可扩展性 | {{score}} | {{comment}} |
| 性能 | {{score}} | {{comment}} |
| 可维护性 | {{score}} | {{comment}} |
| 开发效率 | {{score}} | {{comment}} |
| 技术风险 | {{score}} | {{comment}} |

### 已知局限性

{{known_limitations}}

### 关键权衡

{{trade_offs}}

### 用户调整意见

{{user_adjustments_if_any}}

---

## 演进路径建议

{{evolution_roadmap}}
