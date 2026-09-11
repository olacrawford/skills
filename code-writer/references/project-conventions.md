# 项目风格识别与跟随（写代码前 5 分钟做）

目的：让新代码"像这个项目里的人写的"。方法：读目标层级 2~3 个现有文件，逐项归纳下表，然后照着写。

## 风格清单

| 维度 | 要归纳什么 |
|---|---|
| 分层与放置 | controller/service/dao 各自的实际路径；DTO/VO/Entity 的命名与所在包；新文件放项目惯例位置，不发明新目录 |
| 命名 | 类/方法/变量/常量的命名模式（驼峰、后缀习惯如 `XxxService`/`XxxImpl`/`XxxDTO`）；表字段风格 |
| 错误处理 | 项目统一异常体系：自定义异常类？错误码枚举？Go 的 error wrapping？Node 的 next(err)？新代码必须抛/传同一套，不自创 |
| 返回值 | 统一响应包装（`Result`/`R`/`ResponseEntity`/裸对象）；分页包装方式 |
| DI 与装配 | 构造器注入 / 字段 `@Autowired` / wire / fx / NestJS module / Python 依赖注入容器 |
| 配置 | 配置类模式（`@ConfigurationProperties`/viper/pydantic-settings）；key 命名；env 变量使用方式 |
| 日志 | 门面（slf4j/zap/logging）、格式、级别习惯、是否脱敏；新日志照抄格式 |
| 工具复用 | 先搜 `utils|common|helpers|pkg` 里已有的：日期、JSON、加密、分页、断言——有就不写 |
| 事务/一致性 | `@Transactional` 边界习惯、unitofwork、gorm Transaction 用法 |
| 注释 | 语言（中/英）、密度、Javadoc/docstring 习惯、是否有"作者/日期"头 |

## 跟随原则

1. **模仿最近的同类实现**：不确定时，抄同类文件的骨架（注解、方法结构、命名节奏），换掉业务内容。
2. 项目内部风格不一致时，**跟随目标文件所在模块的局部风格**，并在汇报里提一句不一致。
3. 项目有 lint/format 配置（.editorconfig、prettier、gofmt、ruff format、spotless）：改完后用项目自己的格式化命令处理改过的文件。

## 常见"AI 味"反模式（避免）

- 过度防御：给内部私有方法加层层空判断、到处 try-catch 吞异常。
- 风格漂移：项目用构造器注入，新代码却用字段注入；项目中文注释，新代码英文注释（或反之）。
- 过度设计：需求只要一个方法，却引入策略模式/接口层/泛型抽象。
- 重复造轮子：重写项目已有的分页、日期、JSON 工具。
- 注释噪音：给显而易见的代码加"// 调用 service 处理"式注释。
- 顺手重构：把无关的旧代码"改进"一遍，污染 diff。
