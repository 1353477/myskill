---
phase: 3
stage: project_delivery
status: in_progress
project_name: '{{project_name}}'
tech_stack: '{{tech_stack}}'
date: '{{date}}'
---

# 阶段三：项目搭建与交付报告

## 项目初始化

### 目录结构

{{directory_structure_with_rationale}}

### 技术栈版本选择

| 组件 | 版本 | 选择理由 |
|------|------|----------|
| {{component}} | {{version}} | {{reason}} |

---

## 代码生成

### 模块清单

| 模块 | 职责 | 文件数 | 说明 |
|------|------|--------|------|
| {{module}} | {{responsibility}} | {{file_count}} | {{note}} |

### 代码组织约定

{{code_organization_conventions}}

### 数据库设计

{{database_design_thinking}}

#### 迁移脚本

{{migration_scripts_with_explanation}}

---

## 基础设施

### Docker 配置

{{docker_configuration_explanation}}

### 部署架构

{{deployment_architecture}}

---

## 交付物清单

### 项目文件

{{generated_files_list}}

### 文档文件

{{documentation_files_list}}

---

## 验证结果

### 编译/启动验证

- [ ] 项目能成功编译
- [ ] 应用能正常启动
- [ ] 健康检查端点正常
- [ ] 数据库连接正常
- [ ] Docker 环境可运行

### 功能验证

- [ ] 基础 CRUD 接口可访问
- [ ] 全局异常处理生效
- [ ] 请求日志正常输出

---

## 已知 TODO 项

{{known_todo_items}}

## 演进建议

{{evolution_suggestions}}
