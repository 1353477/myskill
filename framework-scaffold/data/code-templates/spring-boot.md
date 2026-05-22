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
│   │   │   ├── common/
│   │   │   │   ├── exception/
│   │   │   │   │   └── GlobalExceptionHandler.java
│   │   │   │   ├── response/
│   │   │   │   │   └── ApiResponse.java
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
│   │       ├── application.yml
│   │       ├── application-dev.yml
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
import {package}.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/{resource_path}")
@RequiredArgsConstructor
public class {EntityName}Controller {

    private final {EntityName}Service service;

    @GetMapping
    public ResponseEntity<ApiResponse<List<{EntityName}>>> list() {
        return ResponseEntity.ok(ApiResponse.success(service.findAll()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<{EntityName}>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(service.findById(id)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<{EntityName}>> create(@RequestBody {EntityName} entity) {
        return ResponseEntity.ok(ApiResponse.success(service.create(entity)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<{EntityName}>> update(
            @PathVariable Long id, @RequestBody {EntityName} entity) {
        return ResponseEntity.ok(ApiResponse.success(service.update(id, entity)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
```

## 全局异常处理器

```java
package {package}.common.exception;

import {package}.common.response.ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleException(Exception e) {
        log.error("未处理的异常: ", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("服务器内部错误"));
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ApiResponse<Void>> handleRuntimeException(RuntimeException e) {
        log.error("运行时异常: ", e);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
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
public class ApiResponse<T> {
    private int code;
    private String message;
    private T data;

    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(200, "success", data);
    }

    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(500, message, null);
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

```yaml
# application.yml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/{db_name}
    username: ${DB_USERNAME:postgres}
    password: ${DB_PASSWORD:postgres}
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    open-in-view: false

logging:
  level:
    {package}: INFO

management:
  endpoints:
    web:
      exposure:
        include: health,info
```

## Dockerfile 模板

```dockerfile
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN ./mvnw dependency:go-offline -B
COPY src ./src
RUN ./mvnw package -DskipTests -B

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```
