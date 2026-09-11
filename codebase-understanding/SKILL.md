---
name: codebase-understanding
description: 通用代码阅读与项目理解：快速搞清楚任意语言的代码仓库——语言/框架/构建工具、目录结构、入口、核心模块、模块依赖、架构模式、核心业务流程、关键调用链、数据库/Redis/MQ 等外部依赖，最终输出一份结构化「项目地图」。只要用户要求理解、阅读、分析、熟悉、接手、梳理、onboard 一个代码库，问"这个项目是怎么跑起来的 / 入口在哪 / 架构是什么 / 用了什么技术 / 某个功能是怎么实现的"，或者在修改陌生仓库之前需要先摸清现状，就应使用本 Skill——即使用户没有明确说"分析项目"。适用于 Java/Spring、Go、Python、Node/TS、AI/LLM（MCP/Agent/RAG）、Rust、PHP、.NET 等任意技术栈。
---

# 代码阅读 / 项目理解（通用）

把一个陌生仓库变成一份开发者可快速上手的「项目地图」。产出以理解为目的：说清楚**哪个模块负责什么、为什么这样设计、模块之间怎么协作、一次请求/一条消息是怎么流转的**，而不是罗列文件名。

## 铁律（整个分析过程持续生效）

1. **只读不改。** 这是理解任务：不修改任何业务代码，不运行会改变状态的命令（install / build / migrate / 启动服务）。只运行只读命令（ls / find / grep / tree / cat / git log）。发现的问题只记录，不顺手修。
2. **不全量输出代码。** 读代码是为了形成结论；输出结论 + 引用坐标（文件路径、类名、方法名），最多贴几行关键代码作为证据。永远不要把整个项目的文件内容倒出来。
3. **预算制阅读。** 按 Phase 顺序推进，每个 Phase 用少量高杠杆文件（manifest、入口、路由、配置）获取最多信息；先用 Grep 定位层级，再精读命中文件。中小项目全流程应控制在几十次工具调用内；大仓库优先采样核心路径，边缘目录只看结构不读内容。
4. **引用具体坐标。** 每个结论尽量带 `路径 + 类名/函数名`（如 `order/OrderService.createOrder()`），让用户可以跳转验证。
5. **不确定就明说。** 结论分三档：**确认**（有直接证据）、**推测**（有间接证据，写明推理依据）、**未知**（没查到，进待确认清单）。禁止把推测写成事实。
6. **给下一步路标。** 结尾指出"若要继续深入 X，应接着读哪些文件"。

## 工作流

按 Phase 1→7 执行。允许相邻 Phase 交错，但不要跳过 Phase 1——指纹识别决定后面所有动作该看什么。

### Phase 1 项目指纹（语言 / 框架 / 构建 / 模块形态）

目标：读 3~6 个文件就确定项目类型。

1. `ls` 项目根目录；读 README 前 ~100 行（通常直接写了项目用途和启动方式）。
2. 按下表读构建 manifest（存在哪个读哪个；多模块项目把所有 manifest 都列出来）：

| 文件 | 语言 / 构建 |
|---|---|
| pom.xml / build.gradle(.kts) / settings.gradle | Java/Kotlin · Maven/Gradle |
| go.mod / go.work | Go |
| pyproject.toml / requirements*.txt / setup.py / Pipfile / environment.yml | Python |
| package.json（+ lockfile）/ pnpm-workspace.yaml / turbo.json / nx.json | Node/TS |
| Cargo.toml | Rust |
| composer.json | PHP |
| *.csproj / *.sln | C#/.NET |
| CMakeLists.txt / Makefile | C/C++，或任意语言的辅助构建 |

3. 扫部署与运行证据：`Dockerfile`（ENTRYPOINT/CMD）、`docker-compose.yml`（service 与 command）、`k8s/`、`Makefile`、`.github/workflows/`。启动命令是入口的强线索。
4. 判定模块形态：单工程 or 多模块/monorepo（Maven `<modules>`、go.work、package.json `workspaces`、pnpm-workspace）。
5. **按主语言读对应参考文件，再进入 Phase 2：**
   - Java/Kotlin → `references/java-spring.md`
   - Go → `references/go.md`
   - Python → `references/python.md`
   - Node/TS → `references/node-typescript.md`
   - 其他语言（Rust/PHP/.NET/C++/Ruby…）→ `references/other-languages.md`
   - 检测到 LLM/AI 迹象（openai、langchain、mcp、vector db 等依赖或目录）→ 追加 `references/ai-llm.md`
   - 多语言项目：按"业务核心所在语言"选主参考，其余按需补充。

### Phase 2 目录结构与入口

1. 看两层目录树：`tree -L 2 -d` 或 `find <root> -maxdepth 2 -type d`，忽略 `node_modules vendor target dist build .git`。
2. 给目录树逐目录写一句话注释——这个产出直接进模板第 3 节。
3. 定位入口（具体模式见参考文件），并用部署文件反查交叉验证：
   - 搜 main 类 / `func main()` / ASGI/WSGI 目标 / package.json scripts；
   - Dockerfile 的 `ENTRYPOINT`/`CMD`、compose 的 `command`、Makefile 的 run 目标；
   - **读入口文件本身确认**，不要凭文件名猜。
4. 多模块/monorepo：列出全部子模块及各自角色，标出「启动模块」和「核心业务模块」，后续分析以核心模块为主线。

### Phase 3 架构与核心模块

1. 用目录命名 + import 方向判断架构模式：分层（controller/service/dao）、DDD（application/domain/infrastructure）、六边形/整洁架构、微服务、事件驱动、单体、插件化。写出判断依据。
2. 用 Grep 定位各层（语言专属模式在参考文件里），例如：
   - Web 层：`@RestController`、`@RequestMapping`、`gin.Context`、`APIRouter`、`@(Get|Post)Mapping`
   - 业务层：`@Service`、`service`/`usecase`/`biz` 目录
   - 数据层：`@Mapper`、`@Repository`、`JpaRepository`、`gorm`、`schema.prisma`、SQLAlchemy models
3. 产出**核心模块清单**：每个模块一行职责 + 关键文件。区分「业务核心」与「技术支撑」（鉴权、日志、配置、通用工具），不要平均用力。
4. 模块依赖关系：通过 import/包引用方向画一张文本依赖图，标出可疑的循环依赖或反向依赖。

### Phase 4 运行流程与关键调用链

1. 找到路由注册点（Controller 注解 / router 文件 / API 前缀），列出主要接口清单：方法 + 路径 + 处理函数。
2. **挑 1~3 条最核心的调用链完整走通**（选实现项目核心业务的接口 / MQ 消费者 / 定时任务），每跳记录 `类#方法`：
   `入口(路由/消息/定时) → 中间件/拦截器 → Controller/Handler → Service/UseCase → Repository/Mapper → DB/Redis/MQ/外部 HTTP`
3. 别漏掉改变运行时路径的东西——它们是"看不见的入口"：Filter/Interceptor/Middleware、AOP 切面、全局异常处理、事件监听、定时任务（@Scheduled / cron / celery beat）、MQ 消费者。
4. 外部依赖以配置为证：`application*.yml`、`.env.example`、`config/`、docker-compose 里的 MySQL/Redis/Kafka 连接与地址。

### Phase 5 核心业务解释

对每条核心流程，用业务语言回答三件事：

- **哪个模块负责什么**：职责边界在哪里。
- **它们怎么协作**：一次流转中谁调谁、数据经过哪些存储/中间件、状态怎么变。
- **为什么这样设计**：接口分离、事件解耦、状态机、策略模式、缓存……设计意图必须有代码证据；说不出证据就标"推测"。

### Phase 6 技术栈确认

- 只列**有证据**的技术，注明证据来源（manifest 依赖 / import 语句 / 配置文件），版本取 manifest 声明。
- 区分直接依赖与臆测；README 宣称但代码里找不到的，归入"待确认"，不进技术栈表。

### Phase 7 输出项目地图

用下方模板输出。

## 深度模式

- **快速版**（默认，用户只是想"先搞明白"）：Phase 1-4 + 精简模板，1 条主调用链。
- **深度版**（用户要接手/改造/评审，或明确要完整地图）：全 Phase，2~3 条调用链，模块清单完整。
- **指定焦点**（用户说"只关心订单模块 / AI 调用链"）：Phase 1-3 仍做全景，Phase 4-5 聚焦指定模块。

## 输出模板：项目地图

```
# 项目地图：<项目名>
> 分析范围 <路径> · 深度 <快速/深度> · 日期 <日期>

## 1. 项目概览
2~4 句话：这是什么项目、解决什么问题、以什么形态对外提供服务（HTTP/CLI/库/Agent…）。标注判断依据。

## 2. 技术栈
| 技术 | 版本 | 证据（manifest/配置/import） | 在项目中的角色 |

## 3. 项目目录结构（带注释）
只保留关键目录，每个一句话说明。

## 4. 核心模块
### <模块名>（`路径`）
职责 / 关键文件 / 与其他模块的关系

## 5. 模块依赖关系
文本依赖图 + 方向说明，标出异常（循环依赖、越层调用）。

## 6. 核心业务流程
### 流程 A：<业务名>
1. 触发 …（`XxxController#create`）
2. …
（每步带代码坐标；设计意图标注 确认/推测）

## 7. 关键调用链
入口 → 各层方法 → 存储/中间件，每跳一行坐标，例如：
POST /api/orders
→ OrderController.create()         web/OrderController.java
→ OrderService.create()            service/OrderService.java
→ OrderMapper.insert()             dao/OrderMapper.java
→ MySQL t_order + Redis stock:{sku}

## 8. 数据库 / Redis / MQ / 外部服务
| 类型 | 实例/地址线索 | 用途 | 证据 |

## 9. 启动方式
本地启动命令、前置依赖（DB/中间件）、关键环境变量。来源注明（README/Makefile/Dockerfile）。

## 10. 值得重点阅读的代码
按优先级排序：文件/类 + 为什么值得读（一条调用链主干上的、最能代表项目设计风格的）。

## 11. 待确认问题 & 发现的问题
- 待确认：没查到/推测的事项，需要用户补充。
- 发现的问题：只记录不修改（`路径:行号` + 描述）；需要深入排查的交 bug-finder，疑似安全问题的交 security-reviewer。
```

## 追问与续读

用户追问某个模块/某条流程时：不必重跑全流程，直接从上次项目地图的坐标出发（模板第 4/10 节列的文件），沿调用链精读后增量补充结论；若发现地图原有判断有误，明确指出修正。
