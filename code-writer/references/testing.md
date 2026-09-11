# 测试策略（Step 6 用）

## 1. 先探测测试资产

- 目录：`src/test`、`test/`、`tests/`、`__tests__/`、`*Test.java`、`test_*.py`、`*.spec.ts`、`*_test.go`。
- manifest：`package.json` scripts 的 `test`、`pyproject.toml` 的 pytest 配置、`Makefile` 的 test 目标。
- CI：`.github/workflows/` 里实际执行的测试命令，就是项目的权威测试入口。

## 2. 优先运行相关测试

改动前先建立基线：**在改动之前跑一次相关测试**（或用 `git stash` 对比），确认哪些测试本来就挂——避免把既有失败算到自己头上。

定位与改动对应的测试：
| 技术栈 | 命令 |
|---|---|
| Maven | `mvn test -Dtest=XxxServiceTest` |
| Gradle | `./gradlew test --tests "com.x.XxxServiceTest"` |
| Go | `go test ./internal/service/... -run TestXxx` |
| Python | `pytest tests/test_xxx.py -k name` |
| Node | `npm test -- xxx.spec.ts` / `npx jest xxx` / `npx vitest run xxx` |
| Rust | `cargo test xxx` |

找不到对应测试 ≠ 没影响，按命名惯例再 Grep 一轮（类名/方法名/路由路径）。

## 3. 补充测试的规则

1. **先读 1~2 个同类测试再写**：模仿项目的测试框架（JUnit5/Testify/pytest/jest）、mock 方式（Mockito/gomock/unittest.mock/jest.mock）、构造夹具的方式。
2. **数据层策略跟随项目**：项目用 H2/testcontainers/内存库/mock repository，新测试用同一套；不擅自引入新测试基建。
3. **测什么**：核心路径 1 条 + 关键边界 1~2 个（空输入、失败分支、幂等）；不给覆盖率数字打工。
4. 测试命名与断言风格与既有测试一致。

## 4. 项目没有测试时

按顺序做可执行验证，并在汇报中如实分级：
1. 编译/构建通过（self-check 的 ⚡ 命令）。
2. 静态检查通过（若项目已配置）。
3. 启动冒烟：能启动则启动后调一次相关接口/命令验证（只读接口优先；写操作用测试环境数据，没有把握就跳过并注明）。
4. 列出**未验证清单**：哪些分支/集成点没有实际验证、为什么。

## 5. 测试失败的处理

- 我改坏的 → 修复代码（不是改断言）直到通过。
- 改动前就挂的 → 原样记录到汇报【风险】（`测试文件:用例名` + 失败摘要），不擅自大修无关测试。
- 需求本身改变了行为 → 更新断言，并在汇报【实现方式】中说明行为变更点。

禁止：注释/删除失败的测试来"变绿"；把 `skip` 加到失败的用例上。
