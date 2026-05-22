# 步骤 8：Docker 与基础设施

## 强制执行规则（必须先完整阅读）

- 📖 关键：必须完整阅读本步骤文件后再执行任何操作
- 🐳 Docker 文件必须能产出可用的环境
- ✅ docker-compose up 必须让应用和数据库正常通信
- ✅ 所有输出使用中文

## 续建检查

在开始前检查已有状态：
- 读取 `{design-docs}/06-infrastructure.md`，检查 frontmatter 中的 `stepsCompleted`
- 如果 `stepsCompleted` 已包含 8，直接加载 `./step-09-delivery.md`
- 检查项目根目录下 `Dockerfile` 和 `docker-compose.yml` 是否已存在
- 如果已存在，询问用户是覆盖还是保留现有配置

## 执行协议

- 🐳 生成针对技术栈优化的 Dockerfile
- 🔗 生成包含应用 + 数据库的 docker-compose.yml
- 📝 创建基础设施文档
- 📖 加载下一步前更新 frontmatter：`stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]`

## 上下文边界

- 步骤 7 已生成所有模块代码
- 步骤 6 已初始化项目和构建文件
- 架构设计指定了数据库和部署需求
- 只关注 Docker + 基础基础设施

## 你的任务

生成 Docker 和基础设施文件，创建一个可工作的开发环境，其中应用和数据库可以通信。

## 基础设施序列

### 1. 生成 Dockerfile

为对应技术栈生成多阶段构建的 Dockerfile，写入项目根目录 `{project-root}/Dockerfile`：

- 使用合适的基础镜像（alpine/slim 变体减小体积）
- 构建阶段安装依赖并编译
- 运行阶段只包含运行时必需的文件
- 暴露正确的端口
- 设置合理的健康检查

### 2. 生成 docker-compose.yml

写入 `{project-root}/docker-compose.yml`，包含：
- 应用服务
- 数据库服务（PostgreSQL/MySQL 等）
- 数据库持久化卷
- 服务间通信网络
- 环境变量
- 健康检查
- 正确的服务依赖顺序

### 3. 生成 .env.example

完整的环境变量模板：
- 数据库连接
- 应用配置
- 安全默认值（占位符）
- 每个变量的注释说明

### 4. 生成基础设施文档

写入 `{design-docs}/06-infrastructure.md`：

```markdown
---
phase: 3
stage: infrastructure
---

# Docker 与基础设施报告

## Docker 配置

### Dockerfile 说明

{为什么选择这个基础镜像和构建方式}

### docker-compose 说明

{服务编排和网络通信}

## 部署架构

{应用和数据库如何通信}

## 环境配置

| 变量 | 说明 | 默认值 | 生产建议 |
|------|------|--------|----------|
| {{变量}} | {{说明}} | {{默认值}} | {{生产环境建议}} |

## 思考过程

### 为什么这样配置 Docker

{Docker 设计决策}

### 网络和数据持久化策略

{网络和卷的策略}
```

### 5. 向用户展示进度

"Docker 环境配置完成。已生成：

🐳 **Dockerfile**：多阶段构建，优化镜像大小
🔗 **docker-compose.yml**：应用 + 数据库，带健康检查和数据持久化
📋 **.env.example**：环境变量模板

下一步我将生成 README、验证清单，并完成交付。

[C] 继续，完成交付
[A] 我想调整 Docker 配置"

## 成功标准

✅ Dockerfile 能为目标技术栈成功构建
✅ docker-compose.yml 包含应用 + 数据库及健康检查
✅ 应用和数据库通过 Docker 网络可以通信
✅ 数据库数据通过卷持久化
✅ 环境变量正确配置
✅ 基础设施文档包含理由说明

## 失败模式

❌ Dockerfile 无法构建
❌ docker-compose 服务之间无法通信
❌ 缺少数据库健康检查
❌ compose 文件中硬编码了密钥
❌ 未记录 Docker 设计决策

## 下一步

用户确认基础设施后，加载 `./step-09-delivery.md` 生成 README、验证清单并完成交付。

记住：用户确认 Docker 配置前，禁止进入步骤 09！
