# My Skills

Claude Code 自定义 Skill 集合。

## 自研 Skill

| Skill | 说明 | 触发方式 |
|-------|------|---------|
| **code-review** | 专业代码审查，10 个维度，三步工作流（审查报告 → 修复建议 → 代码修改），支持断点续检 | "审查代码"、"code review" |
| **crafting-quality-code** | 编写高质量代码，5 个核心维度 + 代码角色自适应，含自检清单 | 编写/重构函数、类、模块时自动触发 |
| **framework-scaffold** | 框架设计与搭建，3 阶段 9 步骤，从需求收集到可运行项目骨架 | "搭建项目框架"、"设计框架"、"create project scaffold" |
| **project-migration** | 项目迁移，6 阶段 6 文档工作流（分析→设计→计划→执行→验证→总结），支持断点续迁 | "迁移项目"、"项目迁移"、"migrate project" |

### Skill 结构

```
skill/
├── code-review/                  # 代码审查
│   ├── SKILL.md                    入口文件
│   ├── customize.toml              配置（effort 级别、输出目录）
│   └── README.md                   使用文档
│
├── crafting-quality-code/        # 高质量代码
│   ├── SKILL.md                    入口文件（5 维度 + 角色自适应）
│   ├── quality-dimensions.md       详细维度说明（含跨语言代码对比）
│   └── self-review-checklist.md    自检清单
│
├── framework-scaffold/           # 框架搭建
│   ├── SKILL.md                    入口文件（微文件架构，按需加载）
│   ├── customize.toml              配置（语言、自定义步骤）
│   ├── README.md                   使用文档
│   ├── steps/                      9 个步骤文件（一次只加载一个）
│   ├── data/                       问题库 + 技术栈速查 + 代码模板
│   │   ├── question-catalog.md       13 基础问题 + 4 领域分支
│   │   ├── tech-stacks.csv           Spring Boot / FastAPI / NestJS
│   │   └── code-templates/           各技术栈完整代码模板
│   └── templates/                  3 个阶段文档模板
│
├── project-migration/            # 项目迁移
│   ├── SKILL.md                    入口文件（6 阶段工作流）
│   ├── customize.toml              配置（语言、输出目录）
│   ├── README.md                   使用文档
│   ├── data/
│   │   └── migration-patterns.md    Java/Python/JS/Go 迁移速查表
│   └── templates/                  6 个阶段文档模板
│
└── bmad/                         # BMAD 方法论 Skill 集
    └── ...                         产品、架构、开发、测试等完整工具链
```

## 安装

将 skill 目录复制到 Claude Code 的 skills 目录：

```bash
# 复制到 Claude Code skills 目录
cp -r skill/* ~/.claude/skills/
```

或通过符号链接：

```bash
ln -s /path/to/skill/code-review ~/.claude/skills/code-review
ln -s /path/to/skill/crafting-quality-code ~/.claude/skills/crafting-quality-code
ln -s /path/to/skill/framework-scaffold ~/.claude/skills/framework-scaffold
ln -s /path/to/skill/project-migration ~/.claude/skills/project-migration
```

## 支持的技术栈

### framework-scaffold

| 技术栈 | 状态 |
|--------|------|
| Java Spring Boot | ✅ 完整支持（含代码模板） |
| Python FastAPI | ✅ 完整支持（含代码模板） |
| TypeScript NestJS | ✅ 完整支持（含代码模板） |
| 其他技术栈 | ⚡ 可用，无专属代码模板 |

### project-migration

| 迁移类型 | 示例 |
|---------|------|
| 技术升级 | Java 8→17、Python 2→3 |
| 框架替换 | Express→NestJS、MyBatis→JPA |
| 架构重构 | 单体→微服务 |
| 数据库迁移 | MySQL→PostgreSQL |
| 基座分支 | 基础版本→行业版 |
