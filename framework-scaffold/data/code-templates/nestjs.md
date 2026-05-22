# NestJS 代码模板

骨架代码各层的命名约定和模板。

## 目录结构

```
{project_name}/
├── package.json
├── tsconfig.json
├── nest-cli.json
├── src/
│   ├── main.ts
│   ├── app.module.ts
│   ├── common/
│   │   ├── filters/
│   │   │   └── all-exceptions.filter.ts
│   │   ├── interceptors/
│   │   │   └── logging.interceptor.ts
│   │   ├── decorators/
│   │   └── dto/
│   │       └── api-response.dto.ts
│   ├── config/
│   │   └── config.module.ts
│   └── {module}/
│       ├── {module}.module.ts
│       ├── {module}.controller.ts
│       ├── {module}.service.ts
│       ├── {module}.repository.ts
│       └── entities/
│           └── {entity}.entity.ts
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── Dockerfile
├── docker-compose.yml
├── test/
├── docs/design/
├── README.md
├── .env.example
└── .gitignore
```

## Entity 模板 (Prisma)

```prisma
model {EntityName} {
  id        Int      @id @default(autoincrement())
  // TODO: 添加业务字段
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("{table_name}")
}
```

## Entity 模板 (TypeORM)

```typescript
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('{table_name}')
export class {EntityName} {
  @PrimaryGeneratedColumn()
  id: number;

  // TODO: 添加业务字段

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
```

## Repository 模板

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class {EntityName}Repository {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.{entityName}.findMany();
  }

  async findById(id: number) {
    return this.prisma.{entityName}.findUnique({ where: { id } });
  }

  async create(data: any) {
    // TODO: 实现具体逻辑
    return this.prisma.{entityName}.create({ data });
  }

  async update(id: number, data: any) {
    // TODO: 实现具体逻辑
    return this.prisma.{entityName}.update({ where: { id }, data });
  }

  async delete(id: number) {
    return this.prisma.{entityName}.delete({ where: { id } });
  }
}
```

## Service 模板

```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { {EntityName}Repository } from './{module}.repository';

@Injectable()
export class {EntityName}Service {
  constructor(private readonly repository: {EntityName}Repository) {}

  async findAll() {
    // TODO: 实现具体逻辑
    return this.repository.findAll();
  }

  async findById(id: number) {
    const item = await this.repository.findById(id);
    if (!item) throw new NotFoundException(`{EntityName} not found: ${id}`);
    return item;
  }

  async create(data: any) {
    // TODO: 实现具体逻辑
    return this.repository.create(data);
  }

  async update(id: number, data: any) {
    await this.findById(id);
    // TODO: 实现具体逻辑
    return this.repository.update(id, data);
  }

  async remove(id: number) {
    await this.findById(id);
    return this.repository.delete(id);
  }
}
```

## Controller 模板

```typescript
import { Controller, Get, Post, Put, Delete, Param, Body } from '@nestjs/common';
import { {EntityName}Service } from './{module}.service';

@Controller('api/{resource_path}')
export class {EntityName}Controller {
  constructor(private readonly service: {EntityName}Service) {}

  @Get()
  findAll() {
    return this.service.findAll();
  }

  @Get(':id')
  findById(@Param('id') id: string) {
    return this.service.findById(+id);
  }

  @Post()
  create(@Body() data: any) {
    // TODO: 实现具体逻辑
    return this.service.create(data);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() data: any) {
    // TODO: 实现具体逻辑
    return this.service.update(+id, data);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.service.remove(+id);
  }
}
```

## 全局异常过滤器

```typescript
import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus } from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const message = exception instanceof HttpException
      ? exception.message
      : '服务器内部错误';

    response.status(status).json({
      code: status,
      message,
      data: null,
    });
  }
}
```

## 日志拦截器

```typescript
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, url } = request;
    const now = Date.now();

    return next.handle().pipe(
      tap(() => {
        console.log(`${method} ${url} - ${Date.now() - now}ms`);
      }),
    );
  }
}
```

## main.ts 模板

```typescript
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.enableCors();
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.useGlobalFilters(new AllExceptionsFilter());
  app.useGlobalInterceptors(new LoggingInterceptor());

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`应用已启动: http://localhost:${port}`);
}
bootstrap();
```

## Dockerfile 模板

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./
EXPOSE 3000
CMD ["node", "dist/main.js"]
```
