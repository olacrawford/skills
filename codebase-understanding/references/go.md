# Go 参考

## Manifest 与指纹

- `go.mod`：module 名（常含公司/仓库域名）、Go 版本、require 依赖。
- `go.work` / `go.work.sum`：多模块 workspace（monorepo）。
- `vendor/` 目录存在说明依赖已本地化。

## 入口定位

- Grep `func main`（限定 `package main`）→ 惯例在 `cmd/<appname>/main.go`。**多个 main = 多个二进制**（server、job、migration、cli 各自独立），逐个确认角色。
- Makefile 的 `run`/`build` 目标、Dockerfile ENTRYPOINT 反查哪个 main 是主服务。
- CLI 项目（spf13/cobra、urfave/cli）：入口是根 command，各子命令是功能入口。

## 层级定位

常见目录惯例（不同项目命名不同，按语义对号）：

| 层 | 常见目录/文件 |
|---|---|
| 路由/Handler | `cmd/*/main.go` 里 `gin.New()` 注册、`router.go`、`internal/handler`、`api/` |
| 业务 | `internal/service`、`usecase`、`biz` |
| 数据 | `internal/repo|dao|store|data`、`model/`、`entity/` |
| 配置 | `configs/*.yaml` + spf13/viper 加载 |

框架识别：

- HTTP：`gin-gonic/gin`、`labstack/echo`、`gofiber/fiber`、`go-chi/chi`、`cloudwego/hertz`
- 微服务框架：`go-kratos/kratos`（api/proto + internal 结构）、`zeromicro/go-zero`（.api 文件 + goctl 生成）、`go-micro`
- gRPC：`google.golang.org/grpc`；`.pb.go` 是**生成代码**，别逐行读——读 `*.proto` 才是契约
- DI：`google/wire`（`wire_gen.go` 是生成的装配代码，看它比看 provider 定义更快）、`uber/fx`

## 数据与中间件

| 依赖 | 说明 |
|---|---|
| `go-gorm/gorm`（`gorm.Open`、`AutoMigrate`） | ORM，model 定义即表结构 |
| `jmoiron/sqlx`、`sqlc`、`ent` | SQL/代码生成 ORM（ent/ 目录多为生成物） |
| `redis/go-redis` | Redis |
| `segmentio/kafka-go`、`IBM/sarama` | Kafka 消费者/生产者 = 隐藏入口 |
| `rabbitmq/amqp091-go`、`nats-io` | 其他 MQ |
| `golang-migrate/migrate`、`pressly/goose` | 迁移文件目录是表结构演变史 |

## 读法要点

1. 依赖注入多在 main 里手工装配（或 wire 生成），**读 main 就能看到整棵对象装配树**——这是 Go 项目最快的全局理解入口。
2. `context.Context` 层层透传，携带超时/取消/trace，调用链分析时注意 ctx 的传递。
3. 错误处理惯例 `fmt.Errorf("...: %w", err)` 包装链；关注错误在哪一层被真正处理。
4. goroutine/channel/`go func` 处标注并发流（异步任务、worker pool），这是时序分析重点。
5. `_gen.go`、`*.pb.go`、`wire_gen.go`、`mock_*` 一律标记为生成代码，只注明用途，不精读。
