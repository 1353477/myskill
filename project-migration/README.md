# project-migration

> 将现有项目从一个技术状态迁移到另一个技术状态。先分析，再设计，再计划，再执行，再验证，最后总结归档。

## 这个 Skill 能做什么

你说一句"把这个项目从 Java 8 迁移到 Java 17"，它会：

1. **先分析** — 全面理解项目现状、迁移目的、风险和可行性
2. **设计迁移方案** — 选策略、定技术栈、做架构设计
3. **制定迁移计划** — 分阶段、定里程碑、设回滚预案
4. **执行迁移** — 逐阶段执行，输出完整迁移后代码
5. **验证测试** — 功能/性能/兼容性/安全全面验证
6. **总结归档** — 沉淀经验教训，输出对照总表

## 怎么用

在 Claude Code 里说以下任何一句就能触发：

- "迁移项目"
- "项目迁移"
- "migrate project"
- "把这个项目从 X 迁移到 Y"

## 工作流程

整个流程分 6 个阶段，每个阶段之间需要你确认才会继续：

```
阶段一：迁移分析
  "分析一下这个项目"
        ↓ 分析现状、识别风险、评估可行性
        ↓ 你确认分析报告
阶段二：方案设计
  "开始方案设计"
        ↓ 选策略、定技术栈、设计架构
        ↓ 你确认方案
阶段三：迁移计划
  "制定迁移计划"
        ↓ 分阶段、定步骤、设验证标准
        ↓ 你确认计划
阶段四：执行迁移
  "开始执行阶段 1"
        ↓ 逐阶段执行，输出完整代码
        ↓ 每阶段验证通过后继续
阶段五：验证测试
  "验证"
        ↓ 功能/性能/兼容性/安全全面验证
        ↓ 你确认验证通过
阶段六：总结归档
  "生成总结"
        ↓ 总结经验教训，输出对照总表
```

## 文件结构说明

```
project-migration/
│
├── SKILL.md                    ← 入口文件，定义角色和整体规则
│
├── customize.toml              ← 配置文件（可改语言、文档目录等）
│
├── data/
│   └── migration-patterns.md     语言特定迁移速查表
│                                  （Java/Python/JS/Go 常见迁移模式）
│
└── templates/                  ← 文档模板（每个阶段的输出文档骨架）
    ├── migration-analysis.md     阶段一：迁移分析报告
    ├── migration-solution.md     阶段二：方案设计
    ├── migration-plan.md         阶段三：迁移计划
    ├── migration-phase-result.md 阶段四：阶段执行结果
    ├── migration-verification.md 阶段五：验证测试报告
    └── migration-summary.md      阶段六：总结归档
```

## 支持的迁移类型

| 迁移类型 | 示例 | 状态 |
|---------|------|:---:|
| 技术升级 | Java 8→17、Python 2→3 | ✅ |
| 框架替换 | Express→NestJS、MyBatis→JPA | ✅ |
| 架构重构 | 单体→微服务 | ✅ |
| 功能独立抽取 | 从单体拆出用户服务 | ✅ |
| 基座分支 | 基础版本→行业版A/B | ✅ |
| 云原生化 | 传统部署→K8s | ✅ |
| 数据库迁移 | MySQL→PostgreSQL | ✅ |
| 性能重构 | 单机→分布式 | ✅ |

## 生成的文档

所有文档写入**目标项目**的 `docs/migration/` 目录：

```
你的目标项目/
└── docs/migration/
    ├── migration-analysis.md        迁移分析报告
    ├── migration-solution.md        方案设计
    ├── migration-plan.md            迁移计划
    ├── migration-phase-1-result.md  阶段1执行结果
    ├── migration-phase-2-result.md  阶段2执行结果
    ├── ...                          更多阶段结果
    ├── migration-verification.md    验证报告
    └── migration-summary.md         总结报告
```

## 特色功能

- **目的识别** — 自动识别迁移目的（升级/替换/重构等），不同目的对应不同策略
- **预检查** — 开始前检查项目状态，避免在脏状态上迁移
- **断点续迁** — 会话中断后重新触发，自动检测已有进度从中断处继续
- **源/目标分离** — 源项目只读分析，所有产物写入目标项目
- **语言特定速查** — 内置 Java/Python/JS/Go 常见迁移模式和风险点
- **冲突检测** — 执行阶段检测文件是否被外部修改

## 自定义配置

编辑 `customize.toml`：

```toml
[workflow]
# 改语言
communication_language = "中文"
document_output_language = "中文"

# 加自定义步骤
activation_steps_prepend = []
activation_steps_append = []

# 加持久上下文
persistent_facts = []

[output]
# 改文档输出目录（相对于目标项目）
docs_dir = "docs/migration"
```
