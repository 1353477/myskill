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

### Java 17 → 21 现代语言特性迁移

| 特性 | 迁移价值 | 迁移方式 |
|------|---------|---------|
| 虚拟线程（正式可用） | I/O 密集场景性能大幅提升 | `Executors.newVirtualThreadPerTaskExecutor()` 替代线程池，配合 `Semaphore` 控制并发 |
| Record 类 | 减少 DTO 样板代码，自带 equals/hashCode/toString | 替代 Lombok `@Value` 或手动不可变 DTO |
| Sealed Classes | 有限继承、穷举检查、类型安全 | 替代枚举+接口组合模式 |
| Switch 模式匹配（正式可用） | 简化类型判断和条件分支 | 替代 if-else instanceof 链 |
| 顺序集合 `SequencedCollection` | 统一有序集合 API | 替代 `List.get(0)`/`List.get(list.size()-1)` 等不一致写法 |

**虚拟线程迁移注意：**
- 不要池化虚拟线程，它们本身很轻量（每个仅占用几 KB 栈内存）
- 用 `Semaphore` 控制对外部服务的并发调用，而非固定大小线程池
- `synchronized` 块会钉住载体线程，优先改用 `ReentrantLock`
- 确保第三方库不使用 `synchronized` 锁定共享资源（如 HikariCP 需升级到 5.1.0+）

**Record 迁移示例：**

```java
// 迁移前：Lombok @Data
@Data
public class UserDTO {
    private Long id;
    private String name;
    private String email;
}

// 迁移后：Record（不可变，自带 equals/hashCode/toString）
public record UserDTO(Long id, String name, String email) {}
```

**Switch 模式匹配迁移示例：**

```java
// 迁移前：if-else instanceof 链
if (obj instanceof String s) {
    return s.length();
} else if (obj instanceof Integer i) {
    return i;
}

// 迁移后：switch 模式匹配
return switch (obj) {
    case String s -> s.length();
    case Integer i -> i;
    default -> 0;
};
```

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

### Spring Boot 3.x 小版本升级

| 源版本 | 目标版本 | 变更项 | 迁移方式 |
|:---:|:---:|--------|----------|
| 3.2 | 3.3+ | Rest Client 支持改进 | 可从 `RestTemplate` 迁移到 `RestClient` |
| 3.2 | 3.3+ | `spring.application.name` 最低要求 | 确保 `application.yml` 中有 `spring.application.name` |
| 3.3 | 3.4+ | CDS 支持 | 可配置 `spring.main.cds.enabled=true` 提升启动速度 |
| 3.3 | 3.5+ | Spring AI 正式集成 | 可使用 `spring-ai-starter` 集成 LLM |
| 3.4 | 3.5+ | 虚拟线程默认启用 | `spring.threads.virtual.enabled=true`，移除手动配置 |
| 3.x | 3.x | Spring Cloud 版本必须匹配 | Spring Boot 3.4.x → Spring Cloud 2024.0.x |

**注意事项：**
- Spring Boot 3.x 小版本通常向后兼容，但仍需检查 `Deprecation` 列表
- Spring Cloud 版本必须与 Spring Boot 版本严格匹配，否则会有兼容性问题
- Spring Cloud Alibaba 版本也需与 Spring Cloud 版本对应

### 框架迁移

| 源框架 | 目标框架 | 关键差异 | 注意事项 |
|--------|---------|---------|---------|
| Spring MVC | Spring Boot | 自动配置、嵌入式容器 | 排除冲突依赖 |
| MyBatis | JPA/Hibernate | SQL 映射 → 对象映射 | N+1 查询风险 |
| JSP | Thymeleaf | 服务端渲染模板 | EL 表达式差异 |
| XML 配置 | 注解配置 | `@Configuration` 替代 XML | 逐步迁移可行 |
| Spring Security OAuth2 | Spring Authorization Server | 架构完全不同 | 建议重写认证模块 |

### MyBatis → MyBatis-Plus 迁移

| 变更项 | MyBatis | MyBatis-Plus | 迁移方式 |
|--------|---------|-------------|----------|
| 实体定义 | 普通 POJO | `@TableName` + `@TableId` 注解 | 添加注解，兼容现有 POJO |
| CRUD | 手写 XML SQL | 继承 `BaseMapper<T>` 自动生成 | 简单 CRUD 直接继承，复杂查询保留 XML |
| 条件构造 | XML `<if>`/`<where>` | `QueryWrapper`/`LambdaQueryWrapper` | 优先用 Lambda 版本避免字段名硬编码 |
| 分页 | 手写 PageHelper 或自定义 | `IPage` + `MybatisPlusInterceptor` | 配置分页插件即可 |
| ID 生成 | 手动或数据库自增 | `@TableId(type = IdType.ASSIGN_UUID)` | 支持 UUID、雪花算法等多种策略 |
| 逻辑删除 | 手写 SQL 条件 | `@TableLogic` 注解 | 自动追加 `deleted = 0` 条件 |
| 自动填充 | 手动赋值 | `@TableField(fill = FieldFill.INSERT)` | 实现 `MetaObjectHandler` |

**迁移建议：**
- 兼容性：MyBatis-Plus 完全兼容原生 MyBatis XML 映射，可渐进式迁移
- 优先级：先让 `Mapper` 继承 `BaseMapper<T>` 获得基础 CRUD，再逐步用 `Wrapper` 替换简单 XML
- 保留复杂 SQL：多表关联、复杂统计等仍用 XML，不必强行迁移
- 注意事项：`BaseMapper` 的 `selectList` 等方法不要与自定义 XML 方法重名

### 构建工具

| 源 | 目标 | 注意事项 |
|----|------|---------|
| Maven | Gradle | 插件生态差异，`pom.xml` → `build.gradle` |
| Ant | Maven/Gradle | 需要重新组织目录结构 |

### 微服务基础设施迁移

| 组件 | 迁移场景 | 关键配置 | 注意事项 |
|------|---------|---------|--------|
| Spring Cloud Nacos | 服务注册/配置中心 | `spring.cloud.nacos.discovery.server-addr` | 替代 Eureka/Consul 时注意命名空间映射 |
| Spring Cloud OpenFeign | 服务间调用 | `@FeignClient(name="service-name")` | 替代 RestTemplate，注意超时和重试配置 |
| Redis (Lettuce) | 缓存/会话 | `spring.data.redis.*` | Lettuce 替代 Jedis 需注意连接池配置差异 |
| MinIO | 对象存储 | S3 兼容协议 | 替代本地文件存储时需考虑迁移方案 |
| gRPC | 跨语言服务通信 | Protobuf 定义 | 替代 REST 时注意序列化和流式处理差异 |
| Knife4j | API 文档 | `knife4j.enable=true` | 替代传统 Swagger UI，注解兼容 |

**Nacos 迁移注意事项：**
- 配置格式：`bootstrap.yml` 需配置 Nacos 地址和命名空间
- 多环境：通过 `namespace` 隔离 dev/sit/prod
- 配置优先级：Nacos 远程配置 > 本地配置
- 服务注册：确保 `spring.application.name` 全局唯一

**Feign 迁移注意事项：**
- 超时配置：`spring.cloud.openfeign.client.config.default.connectTimeout`
- 开启 Sentinel 熔断：`@FeignClient(fallbackFactory = XxxFallback.class)`
- 日志级别：`Logger.Level.FULL` 仅在 debug 时使用
- 拆分 Feign 模块到独立 jar，避免循环依赖

### Spring AI 迁移

| 变更项 | 旧版 | 新版 | 迁移方式 |
|--------|------|------|---------|
| 核心 API | `ChatModel.call()` | `ChatClient.prompt().call()` | ChatClient 是新的高层 API，ChatModel 仍可用 |
| 流式输出 | `ChatModel.stream()` 手动处理 | `ChatClient.prompt().stream()` | 返回 `Flux<ChatResponse>` |
| 模型配置 | 手动创建 `OpenAiChatModel` | `spring.ai.openai.chat.options.*` 自动配置 | Spring Boot Starter 自动注入 |
| 向量存储 | 手动创建 `EmbeddingModel` | `spring.ai.vectorstore.*` 自动配置 | 支持 Milvus/PgVector/Chroma |
| Prompt 模板 | 字符串拼接 | `PromptTemplate` + `#{variable}` | 声明式模板管理 |
| 工具调用 | 无 | `@Tool` 注解自动注册 | Spring AI 1.0+ 支持 |

**Spring AI 版本兼容：**
- Spring AI 1.0.x → Spring Boot 3.3.x
- Spring AI 1.1.x → Spring Boot 3.4.x/3.5.x
- Spring AI Alibaba 版本需与 Spring AI 版本匹配

**迁移建议：**
- 先升级 Spring Boot，再引入 Spring AI Starter
- ChatModel 是低层 API，ChatClient 是推荐的高层 API
- 自定义 LLM Provider 需实现 `ChatModel` 接口

### SSE 流式推送迁移

| 方案 | 适用场景 | 优点 | 缺点 |
|------|---------|------|------|
| Servlet `response.getWriter()` | 传统 Spring MVC | 简单直接 | 手动管理连接，无心跳 |
| Spring `SseEmitter` | Spring MVC | 框架管理生命周期 | 单机适用，集群需 Redis 广播 |
| WebFlux `Flux<ServerSentEvent>` | 响应式栈 | 背压支持、天然异步 | 需 WebFlux 依赖 |
| WebSocket | 双向通信 | 全双工 | 协议更重，LLM 场景通常不需要双向 |

**SseEmitter 迁移要点：**
- 连接超时：`new SseEmitter(timeout)` 设置合理超时（建议 0 = 无限，配合心跳）
- 心跳保活：定时发送空事件防止连接被代理/防火墙关闭
- 异常处理：`onCompletion`/`onTimeout`/`onError` 回调中清理资源
- 集群场景：SSE 连接绑定 JVM，多实例需 Redis Pub/Sub 广播事件

### Redis Stream 消息队列迁移

| 源方案 | 目标方案 | 适用场景 | 迁移要点 |
|--------|---------|---------|---------|
| RabbitMQ | Redis Stream | 轻量级异步任务 | 语义差异（ACK 机制不同） |
| Kafka | Redis Stream | 中小规模事件流 | Redis Stream 不支持分区，吞吐量有限 |
| 手动队列 | Redis Stream | 任务分发 | 使用 Consumer Group 实现消费者组 |

**Redis Stream 关键概念映射：**
- `XADD` = 发送消息
- `XREADGROUP` = 消费消息（Consumer Group）
- `XACK` = 确认消息
- `XPENDING` = 查看待处理消息
- `StreamMessageListenerContainer`（Spring Data Redis）= 消费者容器

**迁移注意：**
- Redis Stream 消息不会自动删除，需配置 `MAXLEN` 或 `XTRIM`
- Consumer Group 需提前创建（`XGROUP CREATE`），否则启动报错
- 消息确认（ACK）失败会导致重复消费，消费逻辑需幂等

### 向量数据库迁移

| 源方案 | 目标方案 | 迁移要点 |
|--------|---------|---------|
| 无向量库 → Milvus | 首次引入 | 设计 Collection Schema（字段、索引类型、维度） |
| Elasticsearch 向量检索 → Milvus | 替换向量引擎 | dense 向量 + sparse 向量（BM25）的 hybrid search 配置 |
| Pinecone → Milvus | 自托管 | 数据导出/导入，索引类型映射（IVF_FLAT/HNSW） |
| Chroma → Milvus | 生产就绪 | Schema 设计差异，Chroma 自动建索引而 Milvus 需显式创建 |

**Milvus 索引类型选择：**
- `FLAT`：小数据量（<10万），精确搜索
- `IVF_FLAT`：中等数据量，速度和精度平衡
- `HNSW`：大数据量，高召回率，内存占用较高
- `HYBRID`（dense + sparse）：混合检索，适合 RAG 场景

**迁移步骤：**
1. 设计 Collection Schema（主键、向量字段、标量字段）
2. 创建索引（向量索引 + 标量索引）
3. 批量导入数据（`insert` + `flush`）
4. 验证检索质量（召回率、延迟）

### 分布式锁迁移

| 源方案 | 目标方案 | 迁移要点 |
|--------|---------|---------|
| 数据库行锁/悲观锁 | Redisson 分布式锁 | 性能大幅提升，注意锁超时和续期 |
| `synchronized` | Redisson `RLock` | 单机 → 分布式，注意锁粒度 |
| 手写 Redis `SET NX` | Redisson 封装 | Redisson 提供看门狗自动续期，避免死锁 |
| ZooKeeper 锁 | Redisson | 性能更好，但可靠性略低（CP vs AP） |

**Redisson 迁移注意：**
- 看门狗：默认 30s 续期，业务执行超过 30s 需确认续期逻辑
- 锁粒度：锁的 key 要精确到业务 ID（如 `lock:order:123`），不要锁整个业务
- 超时设置：`leaseTime` 要大于业务最长执行时间
- 可重入：Redisson 默认支持可重入，注意嵌套调用场景
- Redis 集群：主从切换可能导致锁丢失，生产环境建议 `RedLock` 或 Redisson 的集群模式

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
| MyBatis | MyBatis-Plus | 增强版 MyBatis，CRUD 零 SQL | 兼容原生 MyBatis，XML 映射可直接复用 |
| MyBatis | JPA/Hibernate | SQL 映射 → 对象关系映射 | 需要重新定义实体关系，注意 N+1 |
| Django ORM | SQLAlchemy | 活跃记录 → 数据映射器 | 模型定义方式不同 |
| TypeORM | Prisma | 装饰器 → Schema 文件 | 迁移脚本不兼容，需重新生成 |
| Sequelize | Prisma | 模型定义 → Schema 文件 | 异步 API 差异 |
