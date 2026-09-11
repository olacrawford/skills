# Java / Spring 专项陷阱清单

每条：识别特征 → 判定要点。证据不足时记入「未确认」，不当 Bug 报。

## 事务失效（优先级最高，最常踩）

| 模式 | 识别特征 | 判定 |
|---|---|---|
| 自调用失效 | 同类内 `this.xxx()` 或直接方法名调用带 `@Transactional` 的方法 | AOP 代理被绕过，事务不生效 → 多步写无原子性，P1 |
| 非 public 方法 | `@Transactional` 标在 protected/包级/private 方法上 | 事务静默不生效，P1 |
| 吞异常不回滚 | 事务方法内 try-catch 后不重新抛出 | 默认只对 RuntimeException/Error 回滚，异常被吃 → 脏提交，P1 |
| rollbackFor 缺失 | 抛受检异常（自定义 Exception extends Exception）且未配 rollbackFor | 不回滚，P1 |
| 事务内发 MQ/调 RPC | `@Transactional` 方法体内发消息/远程调用 | 事务回滚但消息已发出（消费方处理了不存在的数据），或拉长事务；P1 |
| 事务内起线程 | `@Transactional` 里 `new Thread`/线程池提交写操作 | 新线程不在事务内 + 读不到未提交数据，P1 |
| 事务范围过大 | 事务方法内夹大循环、文件 IO、慢 RPC | 长事务占连接，连接池耗尽 → 全局故障，P1 |
| @Async + @Transactional | 同方法或同类组合使用 | 异步线程独立事务，外层回滚不影响内层，P2 |

## 并发与线程安全

- **check-then-act**：先 select 判断再 update/insert，中间无锁无条件更新 → 并发重复/超卖。
- **synchronized 锁错对象**：锁 String 字面量（常量池共享，跨请求互相影响）、锁每次新建的对象、单例里锁实例方法（锁 this 可被外部干扰）。
- **volatile 误当锁**：`count++` 复合操作即使 volatile 也非原子。
- **ThreadLocal 泄漏/串数据**：线程池场景 ThreadLocal 不 remove → 下一个请求读到上一个用户的数据（用户上下文错乱是 **P0**）；父线程 ThreadLocal 不会自动传到线程池任务。
- **线程池配置**：无界队列（`Executors.newFixedThreadPool`/`newSingleThreadExecutor`）→ OOM；拒绝策略为 Abort 但没处理 RejectedExecutionException；核心业务池与边缘任务共用。
- **共享可变状态**：单例 Service 的可变成员变量；共享 `SimpleDateFormat`、非线程安全 Map 的并发写。
- **ConcurrentHashMap 复合操作**：`get` 后 `put` 两步仍需 `putIfAbsent`/`computeIfAbsent`。

## Spring 框架机制

- **AOP/@Async 自调用失效**：同类内调用 `@Async` 方法 → 同步执行（与事务失效同根源）。
- **循环依赖**：构造器注入成环（启动失败或被自动放宽掩盖设计问题）。
- **@Scheduled 隐患**：默认单线程调度器，一个任务阻塞会推迟所有定时任务；任务执行时间 > 触发间隔的行为；集群部署时多实例重复执行（有无分布式锁/ShedLock）。
- **参数校验缺失**：Controller 漏 `@Validated`/`@Valid`；直接信任前端传入的 userId、金额、分页大小；`@RequestParam` 无范围约束。
- **全局异常处理吞错**：`@ControllerAdvice` 把异常兜底成 200 + 错误码，但部分分支漏兜 → 500 裸奔；或吞掉所有异常返回成功码。
- **Bean 作用域误解**：singleton 里注入有状态 prototype；`@RefreshScope` 缺失导致配置热更失效。
- **配置错误**：profile 引用不存在的 key（启动即失败，看启动日志）；连接池 maxActive < 并发需求；超时配置上下游不对齐。

## 输出提醒

找到疑似点后必须回读调用链确认：这个方法真的会被外部调用到吗？这条路径真的可达吗？可达性存疑 → 未确认。
