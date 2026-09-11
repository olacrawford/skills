# Node / TypeScript 参考

## Manifest 与指纹

- `package.json` 是信息密度最高的文件：
  - `scripts`：`dev`/`start`/`build` 就是**启动方式的真相**；
  - `main`/`bin`：库/CLI 入口；
  - `dependencies` vs `devDependencies`：区分运行时与构建期技术；
  - `workspaces` + `pnpm-workspace.yaml` / `turbo.json` / `nx.json`：monorepo 证据。
- `tsconfig.json` 的 `paths` 别名（如 `@/ → src/`）——读 import 时需要用它还原真实路径。

## 入口定位

| 类型 | 位置 |
|---|---|
| 通用 | `src/index.ts`、`src/main.ts`、`server.ts`、`app.ts`（与 scripts 命令交叉验证） |
| NestJS | `src/main.ts`（bootstrap）；`*.module.ts` 的 `@Module({controllers, providers})` 组成模块树 |
| Express/Koa/Hono | Grep `express()|new Koa|new Hono`；`app.use(...)` 挂载顺序即请求管线顺序 |
| Next.js | `app/`（App Router，`page.tsx` + `route.ts` API）或 `pages/` + `pages/api/`——目录即路由 |
| Nuxt | `pages/`、`server/api/` |

## 层级定位

| 层 | 常见位置 |
|---|---|
| API | NestJS `*.controller.ts`；Express `routes/`、router 文件 |
| 业务 | NestJS `*.service.ts`；`services/` |
| 数据 | `prisma/schema.prisma`、`*.entity.ts`（TypeORM）、`drizzle/`、`mongoose` schema、`migrations/` |
| 校验 | zod / class-validator / DTO —— 请求结构证据 |

## 数据与中间件

| 依赖 | 说明 |
|---|---|
| `prisma` | **先读 `prisma/schema.prisma`**——一张文件看全数据模型，性价比最高 |
| `ioredis`/`redis` | Redis |
| `bullmq`/`bull` | 队列 + worker = 异步任务链（隐藏入口：`new Worker(...)`） |
| `kafkajs`、`amqplib` | MQ |
| `nestjs` 的 `@Cron`/`@Interval` | 定时任务 |

## 读法要点

1. NestJS：模块树（`imports` 关系）= 依赖图；`@Injectable` + 构造器注入，顺着 provider 找实现。
2. Express：**中间件注册顺序决定行为**（auth → bodyparser → 路由 → 错误处理），乱序是常见问题（只记录）。
3. 前后端同仓：先分 `apps/`、`packages/` 或 `client/`、`server/`，确认用户问的是哪一侧。
4. 库项目（有 `main`/`exports`）：入口从 `exports` 字段开始，README 的 usage 示例是快速语义来源。
