# 语言特定迁移速查表

执行迁移时参考本文件，快速识别对应语言的常见迁移模式和风险点。

---

## Java

### 版本升级常见 API 变更

| 源版本 | 目标版本 | 变更项 | 迁移方式 |
|:---:|:---:|--------|---------|
| 8 | 11 | `javax.xml.bind` → `jakarta.xml.bind` | 添加独立依赖 |
| 8 | 11 | `java.compiler` 工具移除 | 改用 `javax.tools.JavaCompiler` |
| 11 | 17 | `java.security.acl` 移除 | 使用标准安全 API |
| 11 | 17 | `Applet API` 标记废弃 | 移除相关代码 |
| 8+ | 17 | 强封装内部 API（`--illegal-access` 不再生效） | 改用公开 API |
| 8+ | 21 | `Thread.suspend/resume` 移除 | 使用 `Lock`/`Condition` |
| 8+ | 21 | `java.awt.Window#show/hide` 移除 | 使用 `setVisible()` |
| 17 | 21 | 临时变量（`var`）在 switch 模式匹配中增强 | 可简化条件逻辑 |

### javax → jakarta 命名空间迁移

这是 Spring Boot 2→3 和 Java EE→Jakarta EE 迁移中最常见的变更。几乎所有 `javax.*` 包都需要重命名为 `jakarta.*`。

| 源包名 | 目标包名 | 适用场景 | 迁移方式 |
|--------|---------|---------|---------|
| `javax.servlet` | `jakarta.servlet` | Web 应用、Spring MVC | 全局替换包名 |
| `javax.persistence` | `jakarta.persistence` | JPA/Hibernate | 全局替换包名 |
| `javax.validation` | `jakarta.validation` | Bean Validation | 全局替换包名 + 依赖升级 |
| `javax.annotation` | `jakarta.annotation` | `@Resource`、`@PostConstruct` 等 | 全局替换包名 |
| `javax.transaction` | `jakarta.transaction` | JTA 事务 | 全局替换包名 |
| `javax.mail` | `jakarta.mail` | 邮件发送 | 全局替换包名 + 依赖升级 |
| `javax.websocket` | `jakarta.websocket` | WebSocket | 全局替换包名 |
| `javax.persistence.Entity` | `jakarta.persistence.Entity` | JPA 实体 | 全局替换 + 检查 JPA Provider 版本 |

**推荐工具：** OpenRewrite 的 `UpgradeSpringBoot_3_0` recipe 可自动完成大部分包名替换。

**注意事项：**
- 不仅是 import 替换，Maven/Gradle 依赖的 groupId 也要从 `javax.*` 改为 `jakarta.*`
- `javax.annotation.Resource` → `jakarta.annotation.Resource`，但 `javax.annotation.Nonnull` 不在迁移范围内（它属于 `findbugs`/`jetbrains` 注解）
- 如果项目同时依赖 Java EE 和 Jakarta EE 的 jar，会产生类冲突，必须彻底替换

### Spring Boot 2 → 3 迁移

| 变更项 | 源（Spring Boot 2.x） | 目标（Spring Boot 3.x） | 注意事项 |
|--------|----------------------|------------------------|---------|
| 最低 Java 版本 | Java 8+ | Java 17+ | 必须先升级 JDK |
| 命名空间 | `javax.*` | `jakarta.*` | 见上方 javax→jakarta 表 |
| Spring Security | `authorizeRequests()` | `authorizeHttpRequests()` | 授权模型重写 |
| Spring Security | `WebSecurityConfigurerAdapter` | `SecurityFilterChain` Bean | 继承模式 → 函数式配置 |
| Actuator 端点 | `/actuator/health` | `/actuator/health` | 大部分不变，个别端点路径调整 |
| 配置属性 | `spring.redis.*` | `spring.data.redis.*` | 前缀变更 |
| 配置属性 | `spring.elasticsearch.rest.*` | `spring.elasticsearch.*` | 前缀简化 |
| 自动配置 | `@EnableRedisHttpSession` | 自动配置 | 部分注解不再需要 |
| 数据库连接池 | 默认 HikariCP | 默认 HikariCP | 不变 |
| GraalVM | 不支持 | 原生支持 | 需要适配反射/资源 |

**推荐迁移顺序：** Java 版本升级 → 依赖版本升级 → javax→jakarta → Spring Security 重构 → 配置属性调整 → 测试

### 框架迁移

| 源框架 | 目标框架 | 关键差异 | 注意事项 |
|--------|---------|---------|---------|
| Spring MVC | Spring Boot | 自动配置、嵌入式容器 | 排除冲突依赖 |
| MyBatis | JPA/Hibernate | SQL 映射 → 对象映射 | N+1 查询风险 |
| JSP | Thymeleaf | 服务端渲染模板 | EL 表达式差异 |
| XML 配置 | 注解配置 | `@Configuration` 替代 XML | 逐步迁移可行 |
| Spring Security OAuth2 | Spring Authorization Server | 架构完全不同 | 建议重写认证模块 |

### 构建工具

| 源 | 目标 | 注意事项 |
|----|------|---------|
| Maven | Gradle | 插件生态差异，`pom.xml` → `build.gradle` |
| Ant | Maven/Gradle | 需要重新组织目录结构 |

---

## Python

### 版本升级

| 源版本 | 目标版本 | 变更项 | 迁移方式 |
|:---:|:---:|--------|---------|
| 2.x | 3.x | `print` 语句 → `print()` 函数 | 加括号 |
| 2.x | 3.x | `unicode` 类型统一为 `str` | 移除 `unicode()` 调用 |
| 2.x | 3.x | 整数除法 `/` → `//` | 确认除法语义 |
| 2.x | 3.x | `range` 返回迭代器 | 移除 `xrange` |
| 3.6 | 3.10+ | `typing` 模块增强 | 可简化类型注解（`list[X]` 替代 `List[X]`） |
| 3.x | 3.12 | `distutils` 移除 | 改用 `setuptools` |
| 3.8 | 3.10+ | `from __future__ import annotations` 不再需要 | 检查哪些 future import 可移除 |

### 打包工具迁移

| 源 | 目标 | 关键差异 | 注意事项 |
|----|------|---------|---------|
| `setup.py` | `pyproject.toml`（PEP 621） | 声明式配置替代命令式脚本 | 使用 setuptools 或 hatchling 作为构建后端 |
| `requirements.txt` | `pyproject.toml` `[project.dependencies]` | 依赖集中管理 | 可保留 `requirements.txt` 用于 CI/Docker |
| `setup.cfg` | `pyproject.toml` | 配置合并 | 逐步迁移，两者可共存 |

### 框架迁移

| 源框架 | 目标框架 | 关键差异 | 注意事项 |
|--------|---------|---------|---------|
| Flask | FastAPI | 同步 → 异步、类型注解 | `async/await` 适配 |
| Django | FastAPI | ORM → SQLAlchemy、模板 → JSON API | 数据模型需重写 |
| Django | Flask | 全功能 → 微框架 | 需自行集成 ORM、Auth |
| requests | httpx | 同步 → 可异步 | 接口风格类似 |
| Flask-RESTful | FastAPI | 手动序列化 → Pydantic | 数据校验方式不同 |

### Django → FastAPI 详细

| 维度 | Django | FastAPI | 迁移要点 |
|------|--------|---------|---------|
| ORM | Django ORM（`models.Model`） | SQLAlchemy（`Base` 声明式） | 字段类型映射、关系定义方式不同 |
| 序列化 | Django REST Framework Serializer | Pydantic BaseModel | 验证逻辑类似，语法定义不同 |
| 路由 | `urls.py` 配置 | 装饰器 `@router.get()` | 路径参数语法不同 |
| 认证 | Django Auth + Middleware | FastAPI Depends + OAuth2 | 中间件模式 → 依赖注入 |
| Admin | 内置 Admin 后台 | 无内置 | 需自建或用 SQLAdmin |
| 迁移 | `makemigrations` + `migrate` | Alembic | 概念类似，命令不同 |
| 模板渲染 | Django Templates | 不适用 | API 模式不需要模板引擎 |

---

## JavaScript / TypeScript

### 版本 / 模块系统

| 源 | 目标 | 关键差异 | 注意事项 |
|----|------|---------|---------|
| CommonJS (`require`) | ESM (`import`) | 异步加载、顶层 `await` | `package.json` 加 `"type": "module"` |
| 回调 | Promise | `.then().catch()` 链式调用 | 处理错误传播 |
| Promise | async/await | 同步风格写异步 | 注意循环中的并发 |
| JS | TS | 类型系统 | 先加 `any` 逐步收紧 |

### 框架迁移

| 源框架 | 目标框架 | 关键差异 | 注意事项 |
|--------|---------|---------|---------|
| Express | NestJS | 中间件 → 装饰器、DI 容器 | 范式转换大，建议模块逐个迁移 |
| Express | Koa | 中间件模型不同（洋葱 vs 线性） | 错误处理方式变 |
| Vue 2 | Vue 3 | Options API → Composition API | `this` 指向变化，Vue 2 已 EOL |
| React Class | React Hooks | 生命周期 → `useEffect` | 闭包陷阱，依赖数组 |
| REST | GraphQL | 端点 → Schema/Resolver | 需要重新设计 API 层 |
| AngularJS (1.x) | Angular (2+) | 完全重写，TypeScript | 无渐进式迁移路径 |
| Next.js Pages Router | App Router | 文件路由变化、Server Components | Layout 系统不同，数据获取方式变化 |
| Webpack | Vite | 配置方式不同、构建速度大幅提升 | 插件生态差异，部分 loader 无对应 |

### Next.js Pages → App Router 详细

| 维度 | Pages Router | App Router | 迁移要点 |
|------|-------------|------------|---------|
| 路由定义 | `pages/` 目录 | `app/` 目录 | 文件名约定不同 |
| 数据获取 | `getServerSideProps` / `getStaticProps` | `fetch` + `cache` 选项 | 概念对应关系：`no-store` = SSR，`force-cache` = SSG |
| Layout | 单一 `_app.js` | 嵌套 `layout.tsx` | 支持多级布局 |
| API 路由 | `pages/api/` | `app/api/` + Route Handlers | 函数签名变化 |
| 中间件 | `middleware.ts` | `middleware.ts` | 基本兼容，API 略有变化 |

---

## Go

### 版本升级

| 源版本 | 目标版本 | 变更项 | 迁移方式 |
|:---:|:---:|--------|---------|
| 1.17 | 1.22 | `for` 循环变量作用域变更 | 检查循环变量引用 |
| 1.20 | 1.22 | `net/http` 路由模式增强 | 可简化路由代码 |
| 1.21+ | 1.22 | `slices`/`maps`/`cmp` 标准库 | 替换第三方工具库 |
| 1.21 | 1.22 | `log/slog` 结构化日志 | 替换 `log.Printf` 模式 |

### 框架迁移

| 源框架 | 目标框架 | 关键差异 | 注意事项 |
|--------|---------|---------|---------|
| net/http | Gin | 性能更好、路由分组 | 中间件机制不同 |
| net/http | Echo | 简洁 API | 错误处理方式变 |
| Gin | Fiber | 基于 fasthttp | 兼容 net/http 生态不完全 |

---

## 数据库迁移

### 常见数据类型映射

| MySQL | PostgreSQL | MongoDB → PostgreSQL | 注意事项 |
|-------|-----------|---------------------|---------|
| `INT` | `INTEGER` | 嵌套文档 → 关联表 | 自增策略不同 |
| `VARCHAR(N)` | `VARCHAR(N)` | 数组字段 → JSONB | 字符集差异 |
| `DATETIME` | `TIMESTAMP` | ISODate → TIMESTAMP | 时区处理 |
| `TEXT` | `TEXT` | 自由文本 → TEXT | 索引方式不同 |
| `BOOLEAN` | `BOOLEAN` | 真假值映射 | MySQL 用 TINYINT |
| `JSON` | `JSONB` | 原生文档 → JSONB | PostgreSQL JSONB 支持索引 |
| `AUTO_INCREMENT` | `SERIAL`/`GENERATED` | `_id` → SERIAL | 自增 vs UUID |
| `ENUM` | `VARCHAR` + CHECK | 无原生枚举 | PostgreSQL 有 ENUM 类型但不常用 |
| `TINYINT` | `SMALLINT` | — | PostgreSQL 无 TINYINT |

### 存储过程处理

| 源数据库 | 目标数据库 | 建议 |
|---------|-----------|------|
| MySQL | PostgreSQL | 语法差异大，建议改写为应用层逻辑 |
| Oracle | PostgreSQL | 使用 `ORA2PG` 工具辅助转换 |
| SQL Server | PostgreSQL | T-SQL → PL/pgSQL 语法转换 |

### ORM 迁移

| 源 ORM | 目标 ORM | 关键差异 | 注意事项 |
|--------|---------|---------|---------|
| MyBatis | JPA/Hibernate | SQL 映射 → 对象关系映射 | 需要重新定义实体关系，注意 N+1 |
| Django ORM | SQLAlchemy | 活跃记录 → 数据映射器 | 模型定义方式不同 |
| TypeORM | Prisma | 装饰器 → Schema 文件 | 迁移脚本不兼容，需重新生成 |
| Sequelize | Prisma | 模型定义 → Schema 文件 | 异步 API 差异 |
