# Quality Dimensions Detail

5 个核心维度的详细说明、检查清单和跨语言代码对比。

## 1. Correctness（正确性）

逻辑完全符合需求规约，在所有预期输入下产生正确结果。

### Checklist

- [ ] 正常输入路径产生正确输出
- [ ] 空输入 / null / undefined 处理正确
- [ ] 极值处理正确（空集合、零、最大值、负数）
- [ ] 返回值语义清晰，无歧义（返回 null 是什么意思？返回空集合呢？）
- [ ] 并发/竞态场景下行为正确（如适用）

### Good vs Bad

**Python — 用户查询**

```python
# ❌ Bad: 没处理找不到用户的情况，调用方拿到 None 后容易 NPE
def get_user_email(user_id):
    user = db.query(User).filter_by(id=user_id).first()
    return user.email

# ✅ Good: 明确处理边界，返回值语义清晰
def get_user_email(user_id: int) -> str | None:
    """Return user email, or None if user not found."""
    user = db.query(User).filter_by(id=user_id).first()
    if user is None:
        return None
    return user.email
```

**Java — 集合计算**

```java
// ❌ Bad: 空集合时返回 0，调用方无法区分"总和为0"和"没有数据"
public int calculateTotal(List<Order> orders) {
    int total = 0;
    for (Order o : orders) total += o.getAmount();
    return total;
}

// ✅ Good: 用 Optional 明确表达"可能没有结果"
public Optional<BigDecimal> calculateTotal(List<Order> orders) {
    if (orders.isEmpty()) return Optional.empty();
    return Optional.of(orders.stream()
        .map(Order::getAmount)
        .reduce(BigDecimal.ZERO, BigDecimal::add));
}
```

**JS/TS — 数组操作**

```typescript
// ❌ Bad: 数组为空时返回 undefined，隐式传播
function getFirstActiveUser(users: User[]) {
  return users.find(u => u.isActive).name; // 如果找不到，.name 会抛错
}

// ✅ Good: 防御空值，返回类型明确
function getFirstActiveUserName(users: User[]): string | null {
  const user = users.find(u => u.isActive);
  return user?.name ?? null;
}
```

## 2. Readability（可读性）

代码首先是给人看的。降低认知成本，让读者快速理解意图。

### Checklist

- [ ] 变量/函数/类命名揭示意图，无需猜
- [ ] 函数长度适中（一屏可见），单一职责
- [ ] 逻辑线性展开，避免深层嵌套（guard clause 优先）
- [ ] 注释以解释 why 为主；复杂逻辑中可在关键步骤处加简短注释
- [ ] 没有晦涩的"聪明"写法（除非性能关键路径且有注释说明）
- [ ] 代码读起来像自然语言描述

### Good vs Bad

**Python — 条件逻辑**

```python
# ❌ Bad: 嵌套深，逻辑不线性
def process_order(order):
    if order is not None:
        if order.items:
            if order.customer.is_active:
                return calculate_total(order)
    return None

# ✅ Good: guard clause，线性阅读
def process_order(order: Order) -> Decimal | None:
    if order is None or not order.items:
        return None
    if not order.customer.is_active:
        return None
    return calculate_total(order)
```

**Java — 命名与结构**

```java
// ❌ Bad: 缩写、职责不清、注释复述代码
// Process the data
public Map<String, Object> proc(List<Map<String, Object>> d) {
    Map<String, Object> r = new HashMap<>();
    for (Map<String, Object> i : d) {
        if ((int) i.get("a") > 18) {
            r.put((String) i.get("n"), i.get("s"));
        }
    }
    return r;
}

// ✅ Good: 命名表意，结构清晰
public Map<String, Double> indexScoresByAdultName(List<Person> people) {
    return people.stream()
        .filter(person -> person.getAge() > 18)
        .collect(Collectors.toMap(
            Person::getName,
            Person::getScore
        ));
}
```

**JS/TS — 业务逻辑可读性**

```typescript
// ❌ Bad: 魔法数字，嵌套三元，意图不明
const x = u.t > 2 ? u.s === 'a' ? 1 : 2 : 3;

// ✅ Good: 命名常量，逻辑展开
const MIN_PURCHASES_FOR_VIP = 2;

function getDiscountTier(user: User): DiscountTier {
  if (user.totalPurchases <= MIN_PURCHASES_FOR_VIP) {
    return DiscountTier.Standard;
  }
  return user.status === Status.Active
    ? DiscountTier.Premium
    : DiscountTier.Regular;
}
```

## 3. Robustness（健壮性）

面对异常、错误输入或环境变化时平稳处理，不崩溃不丢数据。

### Checklist

- [ ] 外部输入（API/用户/文件/DB）全部校验
- [ ] 异常处理分层：能处理的处理，不能处理的传播
- [ ] 不吞异常（空 catch / catch-all without re-raise）
- [ ] 资源总是正确释放（连接、文件句柄、锁）
- [ ] 防御空指针 / 空值 / 越界访问
- [ ] 错误信息包含上下文（操作、输入、期望）

### Good vs Bad

**Python — 文件处理**

```python
# ❌ Bad: 异常被吞，资源可能不释放
def read_config(path):
    try:
        f = open(path)
        return json.loads(f.read())
    except:
        return {}

# ✅ Good: 资源正确释放，异常信息有上下文，异常向上传播
def read_config(path: str) -> dict:
    try:
        with open(path) as f:
            return json.loads(f.read())
    except FileNotFoundError:
        raise ConfigError(f"Config file not found: {path}")
    except json.JSONDecodeError as e:
        raise ConfigError(f"Invalid JSON in config file {path}: {e}")
```

**Java — 外部 API 调用**

```java
// ❌ Bad: 裸 catch，异常信息丢失
public User fetchUser(String id) {
    try {
        return restTemplate.getForObject("/users/" + id, User.class);
    } catch (Exception e) {
        return null;  // 调用方无法区分"用户不存在"和"服务挂了"
    }
}

// ✅ Good: 区分异常类型，保留上下文
public User fetchUser(String id) throws UserNotFoundException, UserServiceException {
    try {
        ResponseEntity<User> response = restTemplate.getForEntity(
            "/users/" + id, User.class);
        if (response.getStatusCode().is2xxSuccessful()) {
            return response.getBody();
        }
        throw new UserServiceException("Unexpected status: " + response.getStatusCode());
    } catch (HttpClientErrorException.NotFound e) {
        throw new UserNotFoundException("User not found: " + id, e);
    } catch (RestClientException e) {
        throw new UserServiceException("Failed to fetch user " + id, e);
    }
}
```

**JS/TS — 异步错误处理**

```typescript
// ❌ Bad: Promise 无 catch，错误静默丢失
async function saveReport(data: ReportData) {
  const response = await fetch("/api/reports", {
    method: "POST",
    body: JSON.stringify(data),
  });
  return response.json(); // 网络错误或非 2xx 会怎样？
}

// ✅ Good: 完整错误处理链
async function saveReport(data: ReportData): Promise<Report> {
  const response = await fetch("/api/reports", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  if (!response.ok) {
    throw new ReportSaveError(
      `Failed to save report (status ${response.status}): ${await response.text()}`
    );
  }
  return response.json() as Promise<Report>;
}
```

## 4. Low Coupling（低耦合）

代码易于修改和替换，修改一处不影响其他地方。

### Checklist

- [ ] 函数/类单一职责（一个理由改变，不是多个）
- [ ] 依赖通过参数/构造函数/接口注入，不内部创建
- [ ] 模块间通过接口/事件/回调通信，不直接访问内部状态
- [ ] 修改一个功能的实现不需要改动调用方
- [ ] 没有隐藏的全局可变状态依赖

### Good vs Bad

**Python — 依赖注入**

```python
# ❌ Bad: 函数内部创建依赖，测试时无法替换，换个存储要改函数
def get_user(user_id):
    db = PostgresClient("localhost:5432")  # 硬编码依赖
    cache = RedisClient("localhost:6379")
    cached = cache.get(f"user:{user_id}")
    if cached:
        return json.loads(cached)
    user = db.query("SELECT * FROM users WHERE id = %s", [user_id])
    cache.set(f"user:{user_id}", json.dumps(user))
    return user

# ✅ Good: 依赖注入，可测试，可替换
class UserService:
    def __init__(self, db: UserDataSource, cache: Cache):
        self._db = db
        self._cache = cache

    def get_user(self, user_id: int) -> User | None:
        cached = self._cache.get(f"user:{user_id}")
        if cached:
            return User.from_dict(json.loads(cached))
        user = self._db.find_by_id(user_id)
        if user:
            self._cache.set(f"user:{user_id}", json.dumps(user.to_dict()))
        return user
```

**Java — 接口隔离**

```java
// ❌ Bad: 具体类直接依赖具体类
public class OrderService {
    private MySqlOrderRepository repo = new MySqlOrderRepository();  // 硬编码
    private SendGridEmailSender emailSender = new SendGridEmailSender();  // 硬编码

    public void placeOrder(Order order) {
        repo.save(order);
        emailSender.sendConfirmation(order);
    }
}

// ✅ Good: 面向接口，依赖注入
public class OrderService {
    private final OrderRepository repo;
    private final EmailSender emailSender;

    public OrderService(OrderRepository repo, EmailSender emailSender) {
        this.repo = repo;
        this.emailSender = emailSender;
    }

    public void placeOrder(Order order) {
        repo.save(order);
        emailSender.sendConfirmation(order);
    }
}
```

**JS/TS — 模块解耦**

```typescript
// ❌ Bad: 组件直接依赖全局状态和具体实现
function UserDashboard() {
  const response = fetch("/api/users/me"); // 直接调 API
  const theme = window.localStorage.getItem("theme"); // 直接读 localStorage
  // 渲染...
}

// ✅ Good: 通过参数/接口注入，可测试可替换
function UserDashboard({
  userLoader,
  themeProvider,
}: UserDashboardProps) {
  const user = userLoader.getCurrentUser();
  const theme = themeProvider.getTheme();
  // 渲染...
}
```

## 5. Appropriate Extensibility（适度扩展）

在核心逻辑中面向接口编程，方便未来扩展，但不提前为假设的需求设计。

### Checklist

- [ ] 核心流程面向接口/抽象，不写死具体实现
- [ ] if-else 状态爆炸时用策略模式/查找表替代
- [ ] 新增同类功能不需要修改核心逻辑（开闭原则）
- [ ] **反向检查：** 只有 1 个实现时，抽象层可能是过度设计
- [ ] **反向检查：** 没有真实需求驱动，不要建"灵活"的配置系统

### Good vs Bad

**Python — 策略模式**

```python
# ❌ Bad: 每新增一种折扣就要改这个函数
def apply_discount(order, discount_type):
    if discount_type == "percentage":
        return order.total * (1 - order.discount_value / 100)
    elif discount_type == "fixed":
        return order.total - order.discount_value
    elif discount_type == "buy_one_get_one":
        # 复杂计算...
        pass
    # 每次新增都要加 elif...

# ✅ Good: 策略模式，新增折扣类型只需新增类
class DiscountStrategy(Protocol):
    def apply(self, total: Decimal) -> Decimal: ...

class PercentageDiscount:
    def __init__(self, percent: Decimal): self.percent = percent
    def apply(self, total: Decimal) -> Decimal:
        return total * (1 - self.percent / 100)

class FixedDiscount:
    def __init__(self, amount: Decimal): self.amount = amount
    def apply(self, total: Decimal) -> Decimal:
        return total - self.amount

def apply_discount(order: Order, strategy: DiscountStrategy) -> Decimal:
    return strategy.apply(order.total)
```

**Java — 扩展点设计**

```java
// ❌ Bad: 过度设计 — 只有一种通知方式（邮件），却建了完整的通知框架
public interface NotificationChannel { void send(Message msg); }
public class EmailChannel implements NotificationChannel { ... }
public class SmsChannel implements NotificationChannel { ... }  // 从未使用
public class PushChannel implements NotificationChannel { ... } // 从未使用
public class NotificationRouter {  // 从未需要路由
    private Map<String, NotificationChannel> channels;
    public void route(String type, Message msg) { ... }
}

// ✅ Good: 只有一个实现时，直接写，等第二个实现出现时再抽象
public class EmailNotifier {
    private final MailClient mailClient;

    public void send(String to, String subject, String body) {
        mailClient.send(to, subject, body);
    }
}
// 当需要第二种通知方式时，再提取 Notifier 接口
```

**JS/TS — 适度配置化**

```typescript
// ❌ Bad: 过度配置化 — 只有 2 个固定场景，却建了完整的规则引擎
interface ValidationRule { validate(value: unknown): boolean; }
class ValidationEngine {
  constructor(private rules: Map<string, ValidationRule[]>) {}
  validate(field: string, value: unknown): boolean { ... }
}
// 实际只有 email 和 phone 两种校验

// ✅ Good: 简单直接，等真的有 5+ 种校验时再建引擎
function validateEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validatePhone(phone: string): boolean {
  return /^\+?\d{10,15}$/.test(phone);
}
```
