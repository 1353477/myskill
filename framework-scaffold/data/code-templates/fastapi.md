# FastAPI 代码模板

骨架代码各层的命名约定和模板。

## 目录结构

```
{project_name}/
├── pyproject.toml
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   ├── common/
│   │   ├── __init__.py
│   │   ├── exceptions.py
│   │   ├── middleware.py
│   │   └── response.py
│   └── {module}/
│       ├── __init__.py
│       ├── router.py
│       ├── service.py
│       ├── repository.py
│       ├── models.py
│       └── schemas.py
├── alembic/
│   ├── env.py
│   └── versions/
│       └── 001_init_schema.py
├── Dockerfile
├── docker-compose.yml
├── tests/
├── docs/design/
├── README.md
├── .env.example
└── .gitignore
```

## Model 模板

```python
from datetime import datetime, timezone
from sqlalchemy import Column, Integer, DateTime
from app.database import Base


class {EntityName}(Base):
    __tablename__ = "{table_name}"

    id = Column(Integer, primary_key=True, autoincrement=True)

    # TODO: 添加业务字段

    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)
```

## Schema 模板

```python
from datetime import datetime
from pydantic import BaseModel


class {EntityName}Base(BaseModel):
    # TODO: 添加业务字段
    pass


class {EntityName}Create({EntityName}Base):
    pass


class {EntityName}Update({EntityName}Base):
    pass


class {EntityName}Response({EntityName}Base):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
```

## Repository 模板

```python
from sqlalchemy.orm import Session
from app.{module}.models import {EntityName}


class {EntityName}Repository:
    def __init__(self, db: Session):
        self.db = db

    def find_all(self, skip: int = 0, limit: int = 100):
        return self.db.query({EntityName}).offset(skip).limit(limit).all()

    def find_by_id(self, item_id: int):
        return self.db.query({EntityName}).filter({EntityName}.id == item_id).first()

    def create(self, data: dict):
        item = {EntityName}(**data)
        self.db.add(item)
        self.db.commit()
        self.db.refresh(item)
        return item

    def update(self, item_id: int, data: dict):
        item = self.find_by_id(item_id)
        if not item:
            return None
        for key, value in data.items():
            setattr(item, key, value)
        self.db.commit()
        self.db.refresh(item)
        return item

    def delete(self, item_id: int):
        item = self.find_by_id(item_id)
        if item:
            self.db.delete(item)
            self.db.commit()
        return item
```

## Service 模板

```python
from fastapi import HTTPException
from sqlalchemy.orm import Session
from app.{module}.repository import {EntityName}Repository
from app.{module}.schemas import {EntityName}Create, {EntityName}Update


class {EntityName}Service:
    def __init__(self, db: Session):
        self.repository = {EntityName}Repository(db)

    def find_all(self, skip: int = 0, limit: int = 100):
        # TODO: 实现具体逻辑
        return self.repository.find_all(skip, limit)

    def find_by_id(self, item_id: int):
        item = self.repository.find_by_id(item_id)
        if not item:
            raise HTTPException(status_code=404, detail="{EntityName} not found")
        return item

    def create(self, data: {EntityName}Create):
        # TODO: 实现具体逻辑
        return self.repository.create(data.model_dump())

    def update(self, item_id: int, data: {EntityName}Update):
        # TODO: 实现具体逻辑
        self.find_by_id(item_id)
        return self.repository.update(item_id, data.model_dump(exclude_unset=True))

    def delete(self, item_id: int):
        # TODO: 实现具体逻辑
        return self.repository.delete(item_id)
```

## Router 模板

```python
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.{module}.service import {EntityName}Service
from app.{module}.schemas import {EntityName}Create, {EntityName}Update, {EntityName}Response
from app.common.response import ApiResponse

router = APIRouter(prefix="/api/{resource_path}", tags=["{module_name}"])


@router.get("", response_model=ApiResponse[list[{EntityName}Response]])
def list_items(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    service = {EntityName}Service(db)
    items = service.find_all(skip, limit)
    return ApiResponse.success(items)


@router.get("/{item_id}", response_model=ApiResponse[{EntityName}Response])
def get_item(item_id: int, db: Session = Depends(get_db)):
    service = {EntityName}Service(db)
    item = service.find_by_id(item_id)
    return ApiResponse.success(item)


@router.post("", response_model=ApiResponse[{EntityName}Response])
def create_item(data: {EntityName}Create, db: Session = Depends(get_db)):
    service = {EntityName}Service(db)
    item = service.create(data)
    return ApiResponse.success(item)


@router.put("/{item_id}", response_model=ApiResponse[{EntityName}Response])
def update_item(item_id: int, data: {EntityName}Update, db: Session = Depends(get_db)):
    service = {EntityName}Service(db)
    item = service.update(item_id, data)
    return ApiResponse.success(item)


@router.delete("/{item_id}", response_model=ApiResponse[None])
def delete_item(item_id: int, db: Session = Depends(get_db)):
    service = {EntityName}Service(db)
    service.delete(item_id)
    return ApiResponse.success(None)
```

## 异常处理

```python
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError


class AppException(Exception):
    def __init__(self, status_code: int, detail: str):
        self.status_code = status_code
        self.detail = detail


async def app_exception_handler(request: Request, exc: AppException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"code": exc.status_code, "message": exc.detail, "data": None},
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422,
        content={"code": 422, "message": "参数校验失败", "data": exc.errors()},
    )
```

## 统一响应

```python
from typing import TypeVar, Generic, Optional
from pydantic import BaseModel

T = TypeVar("T")


class ApiResponse(BaseModel, Generic[T]):
    code: int = 200
    message: str = "success"
    data: Optional[T] = None

    @staticmethod
    def success(data: T = None) -> "ApiResponse[T]":
        return ApiResponse(code=200, message="success", data=data)

    @staticmethod
    def error(message: str, code: int = 500) -> "ApiResponse[None]":
        return ApiResponse(code=code, message=message, data=None)
```

## main.py 模板

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from app.common.exceptions import AppException, app_exception_handler, validation_exception_handler
from app.common.middleware import logging_middleware


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("应用启动")
    yield
    print("应用关闭")


app = FastAPI(
    title="{project_name}",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.middleware("http")(logging_middleware)
app.add_exception_handler(AppException, app_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)


@app.get("/health")
def health_check():
    return {"status": "ok"}


# TODO: 注册模块路由
# from app.{module}.router import router as {module}_router
# app.include_router({module}_router)
```

## Alembic 迁移模板

```python
"""init schema

Revision ID: 001
"""
from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(
        '{table_name}',
        sa.Column('id', sa.Integer, primary_key=True, autoincrement=True),
        # TODO: 添加业务字段
        sa.Column('created_at', sa.DateTime, server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime, server_default=sa.func.now(), onupdate=sa.func.now(), nullable=False),
    )


def downgrade():
    op.drop_table('{table_name}')
```

## Dockerfile 模板

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```
