# 其他语言速查（Rust / PHP / .NET / C/C++ / Ruby 等）

按需查阅对应小节；模式与其他语言一致：manifest → 入口 → 框架层级 → 数据层 → 配置。

## Rust

- Manifest：`Cargo.toml`（workspace `[workspace].members` = 多 crate monorepo）。
- 入口：`src/main.rs`（二进制）、`src/lib.rs`（库）；多个 `src/bin/*.rs` = 多二进制。
- 框架：`axum`（router + handler，`Router::new()` 装配点）、`actix-web`（`App::new()` + `.service()`）、`rocket`。
- 数据：`sqlx`（`query!` 宏内嵌 SQL）、`diesel`（`schema.rs` 生成物）、`sea-orm`。
- 异步运行时 tokio；`#[tokio::main]` 是入口标记。

## PHP

- Manifest：`composer.json`（`require`、`scripts`、`autoload` psr-4 → 命名空间到目录映射）。
- Laravel：`routes/web.php` + `routes/api.php`（路由真相，从这里出发追 controller）；`app/Http/Controllers`、`app/Models`（Eloquent 模型 = 表结构）、`app/Services`、`database/migrations`；`artisan` 命令 = CLI 入口；`app/Console/Kernel.php` 的 schedule = 定时任务。
- ThinkPHP：`route/` 目录、`app/controller/`。

## C# / .NET

- Manifest：`*.sln`（解决方案 → 多项目）、`*.csproj`（`PackageReference`）。
- 入口：`Program.cs`——旧模板 `CreateHostBuilder` + `Startup.cs`（ConfigureServices = DI 装配树）；新模板 minimal hosting，`builder.Services` 注册链就是依赖图。
- 层级：`Controllers/`、`Services/`、`Repositories/`；EF Core：`DbContext` 子类 = 全部表结构（性价比最高的单文件）。
- 配置：`appsettings.json`（+ `appsettings.{Env}.json`）。

## C / C++

- Manifest：`CMakeLists.txt`（`add_executable`/`add_library` = 目标清单与依赖链接）、Makefile、`meson.build`。
- 入口：Grep `int main(`。
- 没有统一框架惯例：靠目录命名（`src/`、`include/`、`lib/`）+ 头文件 include 关系画依赖图；构建产物目录 `build/` 跳过。

## Ruby

- Manifest：`Gemfile`。
- Rails：`config/routes.rb`（路由真相）→ `app/controllers` → `app/models`（含关联 `has_many/belongs_to` = 表间关系）；`db/schema.rb` = 当前完整表结构；`app/jobs`、`config/sidekiq.yml` = 后台任务。

## 通用兜底（任何未列出的语言）

1. 找 manifest → 确定语言与依赖。
2. Grep `main|__main__|func main|public static void main` 找入口。
3. 看 Dockerfile/compose/Makefile 的启动命令反查主进程。
4. 按目录名语义（api/controller/service/dao/model）对号入座，用 import/include 关系验证层级。
5. 无法判定的写进待确认清单，不要硬下结论。
