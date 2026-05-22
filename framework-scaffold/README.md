# framework-scaffold

> 通过多轮对话理解你的业务需求，然后设计架构并实际搭建出可运行的项目骨架。

## 这个 Skill 能做什么

你说一句"我想做个订单管理系统，用 Spring Boot"，它会：

1. **先问你** — 不会直接动手，而是按业务→技术→团队→约束的优先级，问你 5-8 个关键问题
2. **设计架构** — 调研市场上的成熟方案，给出多个备选对比，诚实评价优劣
3. **搭建项目** — 生成完整的项目骨架代码、数据库迁移脚本、Docker 环境，可以直接启动

## 怎么用

在 Claude Code 里说以下任何一句就能触发：

- "搭建项目框架"
- "设计框架"
- "框架设计与搭建"
- "create project scaffold"

## 工作流程

整个流程分 3 个阶段、9 个步骤，每个阶段之间需要你确认才会继续：

```
阶段一：信息收集（步骤 1-2）
  "告诉我你想做什么项目"
        ↓ 提问、追问，直到理解需求
        ↓ 你确认需求理解
阶段二：架构设计（步骤 3-5）
  "让我调研一下市场上的方案"
        ↓ 市场调研 → 架构设计 → 方案评价
        ↓ 你确认设计方案
阶段三：项目搭建（步骤 6-9）
  "开始搭建项目"
        ↓ 项目初始化 → 代码生成 → Docker → 交付
        ↓ 交付可运行的项目
```

## 文件结构说明

```
framework-scaffold/
│
├── SKILL.md                    ← 入口文件，定义角色和整体规则
│                                  Claude 加载的第一个文件
│
├── customize.toml              ← 配置文件
│                                  可以改语言、加自定义步骤等
│
├── data/                       ← 数据文件（skill 查阅的参考材料）
│   ├── question-catalog.md       问题库：13 个基础问题 + 4 个领域分支
│   │                              （电商、SaaS、内容管理、IoT 各有专属问题）
│   ├── tech-stacks.csv           技术栈速查表
│   └── code-templates/           代码模板（按技术栈分文件）
│       ├── spring-boot.md        Spring Boot 各层代码模板
│       ├── nestjs.md             NestJS 各层代码模板
│       └── fastapi.md            FastAPI 各层代码模板
│
├── templates/                  ← 文档模板（生成设计报告用的骨架）
│   ├── phase1-report-template.md  需求收集报告模板
│   ├── phase2-design-template.md  架构设计报告模板
│   └── phase3-delivery-template.md 交付报告模板
│
└── steps/                      ← 步骤文件（核心！每步一个文件）
    ├── step-01-init.md           步骤 1：初始化 + 首轮提问
    ├── step-02-deep-dive.md      步骤 2：深入追问 + 需求确认
    ├── step-03-market-research.md 步骤 3：市场调研
    ├── step-04-architecture-design.md 步骤 4：架构设计
    ├── step-05-evaluation.md      步骤 5：方案评价 + 确认
    ├── step-06-project-init.md    步骤 6：项目初始化
    ├── step-07-code-generation.md 步骤 7：代码生成
    ├── step-08-docker-infra.md    步骤 8：Docker 环境
    └── step-09-delivery.md        步骤 9：交付验证
```

## 各文件的角色

### SKILL.md — 总指挥
告诉 Claude "你是谁、怎么做、分几步"。Claude 首先读取这个文件，了解整个工作流的规则，然后去读第一个步骤文件。

### steps/ — 执行指令
每一步的具体操作指南。Claude 同一时间只读一个步骤文件，做完当前步骤后才加载下一个。步骤之间有"门禁"——必须你确认才能继续。

### data/ — 参考资料
步骤文件执行时会查阅这些数据。比如步骤 1 会从 `question-catalog.md` 挑问题，步骤 7 会从 `code-templates/` 读模板来生成代码。

### templates/ — 文档骨架
每个阶段结束时，Claude 会用这些模板生成一份设计文档，记录思考过程和决策理由。文档写到你的项目的 `docs/design/` 目录下。

## 支持的技术栈

| 技术栈 | 状态 |
|--------|------|
| Java Spring Boot | ✅ 完整支持（含代码模板） |
| Python FastAPI | ✅ 完整支持（含代码模板） |
| TypeScript NestJS | ✅ 完整支持（含代码模板） |
| 其他技术栈 | ⚡ 可用，但无专属代码模板（需手动指定结构） |

要添加新技术栈：在 `data/code-templates/` 下新建一个 `{框架名}.md`，按现有模板的格式写好各层代码模板即可。

## 生成的项目里会有什么

```
你的项目/
├── 完整目录结构（按架构设计生成）
├── 构建文件（pom.xml / package.json / requirements.txt）
├── 配置文件（application.yml / .env 等）
├── 主启动入口
├── 每个模块的骨架代码：
│   ├── Entity/Model（数据库实体）
│   ├── Repository/DAO（数据访问层）
│   ├── Service（业务逻辑层，TODO 标注）
│   └── Controller/Router（API 层）
├── 全局异常处理器
├── 健康检查端点（/health）
├── 请求日志中间件
├── 数据库迁移脚本
├── Dockerfile + docker-compose.yml
├── README.md
└── docs/design/          ← 7 份设计文档
    ├── 01-requirements-gathering.md   需求收集报告
    ├── 02-market-research.md          市场调研报告
    ├── 03-architecture-design.md      架构设计文档
    ├── 04-project-init.md             项目初始化报告
    ├── 05-code-generation.md          代码生成报告
    ├── 06-infrastructure.md           基础设施报告
    └── 07-delivery-report.md          交付报告
```

## 特色功能

- **领域智能提问** — 自动识别你的项目领域（电商/SaaS/IoT 等），优先问该领域最关键的问题
- **新建 & 改造** — 既能从零搭建新项目，也能检测已有项目进入改造模式
- **断点续建** — 中途中断后重新触发，会检测已有进度从中断处继续
- **市场调研** — 设计前会搜索验证当前技术版本和最佳实践
- **诚实评价** — 从 6 个维度给方案打分，明确指出局限性
- **全流程留档** — 每个阶段的思考过程和决策理由都记录在设计文档里

## 自定义配置

编辑 `customize.toml`：

```toml
[workflow]
# 改语言
communication_language = "中文"
document_output_language = "中文"

# 加自定义步骤（在问候前/后执行）
activation_steps_prepend = []
activation_steps_append = []

# 加持久上下文（整个流程中携带）
persistent_facts = []
```
