---
name: crafting-quality-code
description: Use when writing or refactoring functions, classes, or modules. Ensures code is elegant, readable, robust, appropriately extensible, and loosely coupled based on actual business needs.
---

# Crafting Quality Code

## Overview

模拟资深工程师写代码时的质量内审机制。每写一段代码，自动按质量维度审视并修正。

**Core principle:** 满足需求前提下尽量简单。不为假设的未来设计，但写下的每一行都经得起审视。

## When to Use

- 编写新函数、类、模块
- 重构已有代码
- 修复 bug 并需要确保修复质量
- 用户要求"高质量"/"生产级"/"源码级"代码

**Not for:** 项目架构设计、技术栈选型、目录结构规划（那是架构级 skill 的事）

## Core Quality Dimensions

5 个核心维度，按优先级排列。详细说明和代码示例见 `quality-dimensions.md`。

| # | 维度 | 一句话 | 适用场景 |
|---|------|--------|---------|
| 1 | **正确性** | 逻辑符合规约，边界处理完备 | 所有代码 |
| 2 | **可读性** | 命名表意，结构清晰，注释解释 why | 所有代码 |
| 3 | **健壮性** | 防御外部输入，异常分层，资源释放 | 处理外部数据/网络/文件 |
| 4 | **低耦合** | 单一职责，依赖可注入，修改局部化 | 类/模块级别 |
| 5 | **适度扩展** | 面向接口，避免写死，但不提前抽象 | 核心业务逻辑/公开 API |

## Quality-Pragmatism Balance

不是所有代码都值得 5 维度全上。根据代码角色选择侧重：

| 代码角色 | 判断信号 | 质量维度侧重 |
|---------|---------|------------|
| 核心业务逻辑 | revenue-critical | 全部 5 维度 |
| 公开 API / SDK | others depend on it | 可读性 + 健壮性 + 适度扩展 |
| 胶水代码 / 适配器 | connects systems | 正确性 + 可读性 + 低耦合 |
| 内部工具 / 脚本 | internal only | 正确性 + 可读性 |

**Iron rule:** 满足需求前提下尽量简单。过度设计比适度设计危害更大。

## Code Writing Workflow

```
1. 理解需求
   → 明确输入、输出、边界条件、异常场景
   → 确定代码角色（核心逻辑 / 工具 / API / 胶水代码）

2. 选择质量侧重
   → 根据代码角色从上方表格选择维度

3. 编写代码
   → 遵循 Universal Code Craftsmanship Rules（下方）
   → 应用所选质量维度

4. 自检
   → 使用 self-review-checklist.md 逐项检查
   → 发现问题 → 修正 → 对修正部分重检

5. 输出
   → 代码 + 简要设计说明（为什么这样写）
```

## Universal Code Craftsmanship Rules

跨语言通用的编码手艺规则。不管写 Python、Java、JS 还是 Go，这些原则一样适用。

### 命名：揭示意图

```
❌ Bad:  d, data, result, temp, flag, obj
✅ Good: daysSinceLastLogin, unverifiedUsers, retryCount
```

函数名是动词或动词短语：`fetchUserById`, `calculateTotalPrice`, `isValidEmail`
类名是名词：`UserRepository`, `PaymentProcessor`, `EmailValidator`
布尔变量/函数用 is/has/can/should 前缀：`isActive`, `hasPermission`, `canRetry`

### 函数：短小、单一职责

- 一个函数做一件事，一个层级
- 一屏能看完（~20 行是理想，超过 40 行要警惕）
- 参数不超过 3 个，多了就封装成对象/结构体
- 幂等优先：相同输入总返回相同结果，无副作用或副作用被隔离

### 错误处理：分层明确

- 不吞异常（空 catch / bare except / catch all without re-raise）
- 不裸抛（不 catch 后原样 throw，让异常自然传播）
- 在能处理错误的层级处理，不能处理就往上抛
- 错误信息包含上下文（什么操作失败、输入是什么、期望是什么）

### 依赖：可注入

- 不在函数内部 new 具体依赖（数据库、HTTP 客户端、文件系统）
- 通过参数、构造函数、配置传入
- 测试时可替换为 mock，生产时传入真实实现

### 注释：只解释 why

- 好注释解释决策原因（约束、权衡、历史背景），坏注释复述代码行为
- 需要注释时，先想能否通过更好的命名消除它
- 代码本身就是最好的文档
- 复杂代码块可在关键步骤处加简短注释，帮助读者快速理解流程

```
❌ Bad:  // increment counter by 1
        counter++;

❌ Bad:  // check if user is active
        if (user.status === 'active') {

✅ Good: // Retry up to 3 times because the downstream service has transient failures
✅ Good: // Using UTC here because the legacy API expects UTC timestamps
✅ Good: // 查找已有标签，不存在则新建
✅ Good: // 按需关联标签到目标对象
```

如果注释在逐行复述显而易见的代码行为，删掉它，改好命名。但复杂逻辑中标注关键步骤的简短注释是合理的。

### 数据：不信任外部输入

- 外部输入 = 用户输入、API 响应、文件内容、数据库读取、环境变量
- 校验放在系统边界（函数入口 / API 网关），内部代码信任已校验的数据
- 校验失败返回明确错误，不默默忽略或用默认值

### 抽象：3 处重复再提取

- 看到 2 处相似代码：留意，但不提取
- 看到 3 处相似代码：提取共享函数/类
- 不为"将来可能需要"提前建抽象层
- 三行相似代码 > 一个过早的抽象

### 资源：总是正确释放

```
Python:   with open(f) / contextlib.closing
Java:     try-with-resources
JS/TS:    try { ... } finally { resource.close() }
Go:       defer resource.Close()
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| 函数做两件事 | 拆成两个函数，名字分别描述各自的事 |
| 魔法数字/字符串 | 提取为命名常量 |
| 捕获异常后只打日志 | 要么处理它、要么往上抛、用 finally 清理 |
| 提前建了"灵活"的抽象层 | 删掉，等真正需要时再建 |
| 函数参数 5+ 个 | 封装为配置对象 / builder / options 结构体 |
| 注释复述代码 | 删注释，改命名 |
| 全局可变状态 | 限制作用域，通过参数传递 |
| 嵌套 3+ 层 if/for | 提前 return/guard clause，提取子函数 |

## Red Flags — STOP and Re-examine

- 写完一段代码自己都觉得"这块有点绕" → 可读性不够，重写
- 函数超过 40 行 → 职责可能不单一，拆分
- catch 块是空的或只有日志 → 吞异常，处理或传播
- 新建了抽象类/接口但只有一个实现 → 可能过度设计
- 逐行注释解释显而易见的代码行为 → 命名不够好（复杂逻辑中标注关键步骤除外）
- 修改 A 模块时担心影响 B 模块 → 耦合太高
- 函数内部 new 了外部依赖 → 依赖不可注入

**When in doubt:** 写能让 6 个月后的自己看懂的代码。不是写给编译器，是写给人。
