# Spring Boot 代码模板

骨架代码各层的命名约定和模板。

## 目录结构

```
{project_name}/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/{package_path}/
│   │   │   ├── {ProjectName}Application.java
│   │   │   ├── config/
│   │   │   │   ├── SwaggerConfig.java
│   │   │   │   └── WebMvcConfig.java
│   │   │   ├── common/
│   │   │   │   ├── enums/
│   │   │   │   │   └── BusinessErrorEnum.java
│   │   │   │   ├── exception/
│   │   │   │   │   ├── BusinessException.java
│   │   │   │   │   └── GlobalExceptionHandler.java
│   │   │   │   ├── response/
│   │   │   │   │   └── R.java
│   │   │   │   └── interceptor/
│   │   │   │       └── RequestLoggingInterceptor.java
│   │   │   └── {module}/
│   │   │       ├── controller/
│   │   │       │   └── {Entity}Controller.java
│   │   │       ├── service/
│   │   │       │   ├── {Entity}Service.java
│   │   │       │   └── {Entity}ServiceImpl.java
│   │   │       ├── repository/
│   │   │       │   └── {Entity}Repository.java
│   │   │       └── entity/
│   │   │           └── {Entity}.java
│   │   └── resources/
│   │       ├── bootstrap.yml
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-sit.yml
│   │       ├── application-prod.yml
│   │       └── db/migration/
│   │           └── V1__init_schema.sql
│   └── test/
│       └── java/{package_path}/
├── Dockerfile
├── docker-compose.yml
├── docs/design/
├── README.md
└── .gitignore
```

## Entity 模板

```java
package {package}.{module}.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "{table_name}")
public class {EntityName} {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // TODO: 添加业务字段

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
```

## Repository 模板

```java
package {package}.{module}.repository;

import {package}.{module}.entity.{EntityName};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface {EntityName}Repository extends JpaRepository<{EntityName}, Long> {
}
```

### MyBatis-Plus Entity 模板（替代 JPA）

```java
package {package}.{module}.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("{table_name}")
public class {EntityName} {

    @TableId(type = IdType.ASSIGN_UUID)
    private String id;

    // TODO: 添加业务字段

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;
}
```

### MyBatis-Plus Repository 模板（替代 JPA）

```java
package {package}.{module}.repository;

import {package}.{module}.entity.{EntityName};
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface {EntityName}Repository extends BaseMapper<{EntityName}> {
}
```

### MyBatis-Plus 自动填充处理器

```java
package {package}.config;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;
import java.time.LocalDateTime;

@Component
public class MyBatisPlusMetaObjectHandler implements MetaObjectHandler {

    @Override
    public void insertFill(MetaObject metaObject) {
        this.strictInsertFill(metaObject, "createdAt", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, "updatedAt", LocalDateTime.class, LocalDateTime.now());
    }
}
```
```

## Service 接口模板

```java
package {package}.{module}.service;

import {package}.{module}.entity.{EntityName};
import java.util.List;

public interface {EntityName}Service {
    List<{EntityName}> findAll();
    {EntityName} findById(Long id);
    {EntityName} create({EntityName} entity);
    {EntityName} update(Long id, {EntityName} entity);
    void delete(Long id);
}
```

## Service 实现模板

```java
package {package}.{module}.service;

import {package}.{module}.entity.{EntityName};
import {package}.{module}.repository.{EntityName}Repository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class {EntityName}ServiceImpl implements {EntityName}Service {

    private final {EntityName}Repository repository;

    @Override
    @Transactional(readOnly = true)
    public List<{EntityName}> findAll() {
        // TODO: 实现具体逻辑
        return repository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public {EntityName} findById(Long id) {
        // TODO: 实现具体逻辑
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("{EntityName} not found: " + id));
    }

    @Override
    public {EntityName} create({EntityName} entity) {
        // TODO: 实现具体逻辑
        return repository.save(entity);
    }

    @Override
    public {EntityName} update(Long id, {EntityName} entity) {
        // TODO: 实现具体逻辑
        findById(id);
        entity.setId(id);
        return repository.save(entity);
    }

    @Override
    public void delete(Long id) {
        // TODO: 实现具体逻辑
        repository.deleteById(id);
    }
}
```

## Controller 模板

```java
package {package}.{module}.controller;

import {package}.{module}.entity.{EntityName};
import {package}.{module}.service.{EntityName}Service;
import {package}.common.response.R;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/{resource_path}")
@RequiredArgsConstructor
public class {EntityName}Controller {

    private final {EntityName}Service service;

    @GetMapping
    public R<List<{EntityName}>> list() {
        return R.ok(service.findAll());
    }

    @GetMapping("/{id}")
    public R<{EntityName}> getById(@PathVariable Long id) {
        return R.ok(service.findById(id));
    }

    @PostMapping
    public R<{EntityName}> create(@RequestBody {EntityName} entity) {
        return R.ok(service.create(entity));
    }

    @PutMapping("/{id}")
    public R<{EntityName}> update(@PathVariable Long id, @RequestBody {EntityName} entity) {
        return R.ok(service.update(id, entity));
    }

    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return R.ok();
    }
}
```

## 错误码体系

```java
package {package}.common.enums;

import lombok.Getter;
import lombok.AllArgsConstructor;

@Getter
@AllArgsConstructor
public enum BusinessErrorEnum {

    // 通用错误
    PARAM_ERROR(400, "参数错误"),
    NOT_FOUND(404, "资源不存在"),
    UNAUTHORIZED(401, "未授权"),
    FORBIDDEN(403, "无权限"),

    // 业务错误 — 按模块扩展
    // {MODULE}_XXX(XXXX, "描述"),

    // 系统 error
    INTERNAL_ERROR(500, "系统内部错误");

    private final int code;
    private final String message;
}
```

## 业务异常

```java
package {package}.common.exception;

import {package}.common.enums.BusinessErrorEnum;
import lombok.Getter;

@Getter
public class BusinessException extends RuntimeException {

    private final int code;

    public BusinessException(BusinessErrorEnum errorEnum) {
        super(errorEnum.getMessage());
        this.code = errorEnum.getCode();
    }

    public BusinessException(BusinessErrorEnum errorEnum, String detail) {
        super(errorEnum.getMessage() + ": " + detail);
        this.code = errorEnum.getCode();
    }

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }
}
```

## 全局异常处理器

```java
package {package}.common.exception;

import {package}.common.response.R;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<R<Void>> handleBusinessException(BusinessException e) {
        log.warn("业务异常: code={}, message={}", e.getCode(), e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(R.fail(e.getCode(), e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<R<Void>> handleValidationException(MethodArgumentNotValidException e) {
        String errors = e.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining("; "));
        log.warn("参数校验失败: {}", errors);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(R.fail(400, errors));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<R<Void>> handleException(Exception e) {
        log.error("未处理的异常: ", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(R.fail(500, "系统内部错误"));
    }
}
```

## 统一响应

```java
package {package}.common.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class R<T> {
    private int code;
    private String message;
    private T data;

    public static <T> R<T> ok(T data) {
        return new R<>(200, "success", data);
    }

    public static <T> R<T> ok() {
        return new R<>(200, "success", null);
    }

    public static <T> R<T> fail(int code, String message) {
        return new R<>(code, message, null);
    }

    public static <T> R<T> fail(String message) {
        return new R<>(500, message, null);
    }
}
```

## 请求日志拦截器

```java
package {package}.common.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Slf4j
@Component
public class RequestLoggingInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        request.setAttribute("startTime", System.currentTimeMillis());
        log.info("请求开始: {} {}", request.getMethod(), request.getRequestURI());
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response,
                                 Object handler, Exception ex) {
        long duration = System.currentTimeMillis() - (Long) request.getAttribute("startTime");
        log.info("请求完成: {} {} - 状态:{} 耗时:{}ms",
                request.getMethod(), request.getRequestURI(), response.getStatus(), duration);
    }
}
```

## SQL 迁移模板

```sql
CREATE TABLE {table_name} (
    id BIGSERIAL PRIMARY KEY,
    -- TODO: 添加业务字段
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

## 配置模板

### application.yml（主配置）

```yaml
server:
  port: 8080

spring:
  application:
    name: {project_name}
  profiles:
    active: dev

  # 虚拟线程（Spring Boot 3.2+）
  threads:
    virtual:
      enabled: true

  datasource:
    url: jdbc:postgresql://localhost:5432/${DB_NAME:{db_name}}
    username: ${DB_USERNAME:postgres}
    password: ${DB_PASSWORD:postgres}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5

  # JPA（使用 JPA 时）
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    open-in-view: false

  # Redis
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD:}
      lettuce:
        pool:
          max-active: 20
          max-idle: 10
          min-idle: 5

# Knife4j API 文档
knife4j:
  enable: true
  setting:
    language: zh_cn

logging:
  level:
    {package}: INFO

management:
  endpoints:
    web:
      exposure:
        include: health,info
```

### bootstrap.yml（Nacos 配置）

```yaml
spring:
  application:
    name: {project_name}
  cloud:
    nacos:
      server-addr: ${NACOS_ADDR:localhost:8848}
      discovery:
        namespace: ${NACOS_NAMESPACE:dev}
        group: DEFAULT_GROUP
      config:
        namespace: ${NACOS_NAMESPACE:dev}
        group: DEFAULT_GROUP
        file-extension: yml
        shared-configs:
          - data-id: common-redis.yml
            group: DEFAULT_GROUP
            refresh: true
          - data-id: common-datasource.yml
            group: DEFAULT_GROUP
            refresh: true
```

### application-dev.yml（开发环境）

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/{db_name}_dev
    username: postgres
    password: postgres

logging:
  level:
    {package}: DEBUG
    org.springframework.web: DEBUG
```

### application-sit.yml（测试环境）

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST}:{db_name}_sit
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}

logging:
  level:
    {package}: INFO
```

### application-prod.yml（生产环境）

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST}:{db_name}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 50
      minimum-idle: 10

logging:
  level:
    {package}: WARN
```

## Swagger/Knife4j 配置

```java
package {package}.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("{ProjectName} API")
                        .description("{ProjectName} 接口文档")
                        .version("v1"));
    }
}
```

## Dockerfile 模板

```dockerfile
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN ./mvnw dependency:go-offline -B
COPY src ./src
RUN ./mvnw package -DskipTests -B

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## SSE 控制器模板

```java
package {package}.{module}.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.concurrent.*;

@Slf4j
@RestController
@RequestMapping("/api/v1/sse")
@RequiredArgsConstructor
public class SseController {

    private final ExecutorService sseExecutor = Executors.newCachedThreadPool();

    @GetMapping(value = "/connect/{clientId}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter connect(@PathVariable String clientId) {
        // 超时设 0 表示无限，配合心跳保活
        SseEmitter emitter = new SseEmitter(0L);

        emitter.onCompletion(() -> log.info("SSE 连接完成: {}", clientId));
        emitter.onTimeout(() -> log.warn("SSE 连接超时: {}", clientId));
        emitter.onError(e -> log.error("SSE 连接异常: {}", clientId, e));

        return emitter;
    }

    public static void sendEvent(SseEmitter emitter, String eventName, Object data) {
        try {
            emitter.send(SseEmitter.event().name(eventName).data(data));
        } catch (IOException e) {
            emitter.completeWithError(e);
        }
    }
}
```

## 策略 + 工厂模式模板

```java
package {package}.{module}.strategy;

// 策略接口
public interface {EntityName}Strategy {
    /** 返回策略类型 ID，用于路由 */
    Integer getTypeId();
    /** 具体业务方法 */
    List<{EntityName}VO> getList(Long projectId);
}

// 策略工厂 — @PostConstruct 注册
@Component
public class {EntityName}StrategyFactory {

    @Resource
    private List<{EntityName}Strategy> strategies;

    private final Map<Integer, {EntityName}Strategy> strategyMap = new HashMap<>();

    @PostConstruct
    public void init() {
        for ({EntityName}Strategy strategy : strategies) {
            strategyMap.put(strategy.getTypeId(), strategy);
        }
    }

    public {EntityName}Strategy getStrategy(Integer typeId) {
        {EntityName}Strategy strategy = strategyMap.get(typeId);
        if (strategy == null) {
            throw new BusinessException(BusinessErrorEnum.PARAM_ERROR, "不支持的处理类型: " + typeId);
        }
        return strategy;
    }
}

// 策略实现示例
@Service
@RequiredArgsConstructor
public class QualificationStrategy implements {EntityName}Strategy {

    @Override
    public Integer getTypeId() { return 1; }

    @Override
    public List<{EntityName}VO> getList(Long projectId) {
        // 具体实现
    }
}
```

## 异步配置模板

```java
package {package}.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean(name = "asyncExecutor")
    public Executor asyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(10);
        executor.setMaxPoolSize(20);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
}
```

### 事务后异步执行模板

```java
// 事务提交后触发异步任务（避免在事务中执行耗时操作）
@Transactional(rollbackFor = Exception.class)
public void updateAndNotify(Long id, Object data) {
    // 先做数据库操作
    repository.save(entity);

    // 注册事务后回调 — 事务提交后才执行异步任务
    TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
        @Override
        public void afterCommit() {
            CompletableFuture.runAsync(() -> {
                notificationService.notify(id);
            }, asyncExecutor);
        }
    });
}
```

### CompletableFuture 带超时模板

```java
// 异步执行 + 超时控制
public <T> T executeWithTimeout(Supplier<T> task, long timeoutSeconds) {
    try {
        return CompletableFuture.supplyAsync(task, asyncExecutor)
                .get(timeoutSeconds, TimeUnit.SECONDS);
    } catch (TimeoutException e) {
        throw new BusinessException("操作超时，请稍后重试");
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        throw new BusinessException("操作被中断");
    } catch (ExecutionException e) {
        throw new BusinessException("操作失败: " + e.getCause().getMessage());
    }
}
```

## Redis Stream 消费者模板

```java
package {package}.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.stream.*;
import org.springframework.data.redis.stream.StreamMessageListenerContainer;
import org.springframework.data.redis.stream.Subscription;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class RedisStreamConfig {

    private final RedisConnectionFactory connectionFactory;
    private final {ConsumerName}Listener listener;

    private static final String STREAM_KEY = "stream:{entity_name}";
    private static final String GROUP_NAME = "{entity_name}_group";

    @Bean
    public Subscription {entityName}Subscription() {
        StreamMessageListenerContainer.StreamMessageListenerContainerOptions<String, MapRecord<String, String, String>> options =
                StreamMessageListenerContainer.StreamMessageListenerContainerOptions.builder()
                        .batchSize(10)
                        .build();

        StreamMessageListenerContainer<String, MapRecord<String, String, String>> container =
                StreamMessageListenerContainer.create(connectionFactory, options);

        Subscription subscription = container.receive(
                Consumer.from(GROUP_NAME, "{entity_name}_consumer"),
                StreamOffset.create(STREAM_KEY, ReadOffset.lastConsumed()),
                listener
        );

        container.start();
        log.info("Redis Stream 消费者已启动: stream={}", STREAM_KEY);
        return subscription;
    }
}
```

## Spring AI ChatClient 配置模板

```java
package {package}.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.ai.openai.OpenAiChatOptions;
import org.springframework.ai.openai.api.OpenAiApi;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Data
@Configuration
@ConfigurationProperties(prefix = "llm")
public class LlmConfig {

    private Map<String, ModelConfig> models = new ConcurrentHashMap<>();

    @Data
    public static class ModelConfig {
        private String baseUrl;
        private String apiKey;
        private String model;
        private Double temperature;
        private Integer maxTokens;
    }

    /**
     * 多模型路由 — 按场景名获取对应的 ChatClient
     */
    @Bean
    public Map<String, ChatClient> chatClientRegistry() {
        Map<String, ChatClient> registry = new ConcurrentHashMap<>();
        models.forEach((key, config) -> {
            OpenAiApi api = OpenAiApi.builder()
                    .baseUrl(config.getBaseUrl())
                    .apiKey(config.getApiKey())
                    .build();

            OpenAiChatOptions options = OpenAiChatOptions.builder()
                    .model(config.getModel())
                    .temperature(config.getTemperature())
                    .maxTokens(config.getMaxTokens())
                    .build();

            OpenAiChatModel chatModel = OpenAiChatModel.builder()
                    .openAiApi(api)
                    .defaultOptions(options)
                    .build();

            registry.put(key, ChatClient.builder(chatModel).build());
        });
        return registry;
    }
}
```

### LLM 多模型路由配置（application.yml）

```yaml
llm:
  models:
    default:
      base-url: ${LLM_BASE_URL:https://api.openai.com}
      api-key: ${LLM_API_KEY}
      model: ${LLM_MODEL:gpt-4o}
      temperature: 0.7
      max-tokens: 4096
    reasoning:
      base-url: ${LLM_REASONING_BASE_URL}
      api-key: ${LLM_REASONING_API_KEY}
      model: deepseek-r1
      temperature: 0.3
      max-tokens: 8192
    embedding:
      base-url: ${LLM_EMBEDDING_BASE_URL}
      api-key: ${LLM_EMBEDDING_API_KEY}
      model: text-embedding-v3
```

## 分布式锁模板（Redisson）

```java
package {package}.common.lock;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Slf4j
@Component
@RequiredArgsConstructor
public class DistributedLockExecutor {

    private final RedissonClient redissonClient;

    /**
     * 编程式分布式锁 — 带 waitTime 和 leaseTime
     */
    public <T> T executeWithLock(String lockKey, long waitSeconds, long leaseSeconds, Supplier<T> task) {
        RLock lock = redissonClient.getLock(lockKey);
        try {
            boolean acquired = lock.tryLock(waitSeconds, leaseSeconds, TimeUnit.SECONDS);
            if (!acquired) {
                throw new BusinessException(409, "操作频繁，请稍后重试");
            }
            return task.get();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new BusinessException("获取锁被中断");
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }

    public void executeWithLock(String lockKey, long waitSeconds, long leaseSeconds, Runnable task) {
        executeWithLock(lockKey, waitSeconds, leaseSeconds, () -> { task.run(); return null; });
    }
}
```

### 分布式锁配置（application.yml）

```yaml
spring:
  redis:
    redisson:
      config: |
        singleServerConfig:
          address: "redis://${REDIS_HOST:localhost}:${REDIS_PORT:6379}"
          password: ${REDIS_PASSWORD:}
          database: 0
          connectionPoolSize: 20
          connectionMinimumIdleSize: 5
```
