# 通用开发 Skill 库(十件套)

> 版本 v1.0 · 2026-09-12 · 本目录为**唯一源**,通过 `sync-to-project.sh` 分发到各项目的 `.agents/skills/`。修改任何 Skill 只改这里,再同步分发。

十个 Skill 覆盖开发完整生命周期:**读 → 写 → 查 → 修 → 测 → 审**,外加四个专项(重构 / 性能 / 安全 / 架构)。

## 1. Skill 一览

| Skill | 环节 | 一句话职责 | 权限 |
|---|---|---|---|
| codebase-understanding | 读 | 理解任意代码库,产出「项目地图」 | 只读 |
| code-writer | 写 | 新功能 / 常规改动,按项目风格实现并验证 | 可改 |
| bug-finder | 查 | 沿调用链找运行时 Bug,输出报告卡 | 只读 |
| bug-fixer | 修 | 定位根因 → 最小修改 → 实际验证 | 可改 |
| test-writer | 测 | 设计场景、编写测试、实际执行并归因失败 | 可改(仅测试代码) |
| code-reviewer | 审 | 代码级工程质量评审(12 维度,P0-P3+GOOD) | 只读 |
| refactor | 重构 | 行为不变的纯结构优化,先建行为基线 | 可改 |
| performance | 能 | 先测量再优化的性能分析与调优 | 可改 |
| security-reviewer | 安 | 攻击者视角安全审查,每个漏洞给攻击路径 | 只读 |
| architecture-reviewer | 架 | 系统级架构审查(边界/一致性/可靠性/扩展性) | 只读 |

只读的 5 个只产出报告;可改的 5 个必须实际编译/测试验证,禁止"理论上正确"冒充"已验证"。

## 2. 触发速查:你说什么 → 用哪个 Skill

| 你说的话 | 该用 |
|---|---|
| "这个项目怎么跑起来的 / 帮我读懂这个仓库 / 入口在哪" | codebase-understanding |
| "实现 X / 加个接口 / 写个服务 / 接入第三方" | code-writer |
| "找找 bug / 排查问题 / 有没有隐患 / 这段逻辑会不会出错" | bug-finder |
| "修这个报错 / (粘贴 Stack Trace、日志) / 为什么一直报错" | bug-fixer |
| "写测试 / 补个单测 / 覆盖一下这段逻辑" | test-writer |
| "review 一下 / 能不能合 / 上线前把把关 / 写得怎么样" | code-reviewer |
| "重构 / 拆这个类 / 消除重复代码 / 太难改了" | refactor |
| "接口慢 / 压测 / 性能优化 / 为什么这么卡 / Token 成本高" | performance |
| "有没有安全漏洞 / 检查越权 / 渗透视角 / AI 应用安全" | security-reviewer |
| "架构审查 / 模块怎么拆 / 要不要微服务 / 还能扩展吗" | architecture-reviewer |

## 3. 易混淆的分工边界(速记)

- **找 Bug(只报告)= bug-finder;修 Bug(要改代码)= bug-fixer。**
- 新功能/常规改动 = code-writer;行为不变的纯结构优化 = refactor;服务/模块级拆分 = architecture-reviewer。
- 代码级设计问题 = code-reviewer;系统级(边界/一致性/可靠性/扩展性)= architecture-reviewer。
- 评审中发现的单点性能/安全问题 = code-reviewer 报告;系统性测量/审查 = performance / security-reviewer。
- 跑通相关既有测试(最小验证)= code-writer;体系化测试设计(场景矩阵/并发/集成)= test-writer。
- 全维度评审、上线前把关 = code-reviewer(代码)/ security-reviewer(安全)/ architecture-reviewer(架构)各管一层。

## 4. 按场景的标准链路

```
主链路(任何改动):
读(codebase-understanding) → 写(code-writer) → 测(test-writer) → 审(code-reviewer)

修 Bug:
bug-finder(查) → bug-fixer(定位根因→修改→验证) → test-writer(回归) → code-reviewer

重构:
code-reviewer(发现结构问题) → refactor(基线→小步执行) → test-writer(回归) → code-reviewer

性能优化:
codebase-understanding → performance(测量→瓶颈→优化) → code-writer(实施) → test-writer(功能回归) → performance(前后对比)

安全审查:
codebase-understanding → security-reviewer(漏洞卡) → bug-fixer/code-writer(修复) → test-writer(安全测试) → security-reviewer(复审)

架构演进:
codebase-understanding → architecture-reviewer(架构审查) → refactor/code-writer(分步实施) → test-writer → bug-finder(回归) → bug-fixer → architecture-reviewer(复审)

上线前把关:
code-reviewer(质量) + security-reviewer(安全) + performance(性能) → 收口 architecture-reviewer
```

## 5. 标准使用 Prompt(复制即用,<>处替换)

### codebase-understanding
```
使用 codebase-understanding skill 理解以下项目。
- 项目路径:<路径>
- 深度:<快速 / 深度(要接手改造) / 只看模块:xxx>
要求:按 Phase 流程分析,输出完整「项目地图」(含关键调用链与外部依赖);
结论分 确认/推测/未知,带文件坐标;发现的问题只记录,交 bug-finder 或 security-reviewer 深查。
```

### code-writer
```
使用 code-writer skill 实现以下需求。
【需求】<一句话:输入 → 处理 → 输出>
【边界】<验收标准;明确不包含什么>
要求:先读相关代码与相似实现再动手;按规模分级决定是否先给方案等确认;
遵循项目已有风格与分层,复用优先;完成后实际编译/测试并按固定格式汇报,失败如实写。
```

### bug-finder
```
使用 bug-finder skill 检查以下代码的潜在 Bug。
- 范围:<整个项目 / 某模块 / 某段代码>
- 关注点:<并发 / 数据一致性 / 边界,没有就默认核心业务链路>
要求:只读不改;沿调用链分析,每个问题必须给触发条件与执行过程;
说不清触发条件的放「未确认」,不为凑数硬找;按 Bug 检测报告格式输出。
```

### bug-fixer
```
使用 bug-fixer skill 修复以下 Bug。

【输入】(三选一)
A. Bug Finder 报告卡:<粘贴>
B. 报错信息:- Stack Trace / 日志:<粘贴> - 触发条件 / 复现步骤:<怎么触发的>
C. 现象描述:<什么操作后出现什么异常>
相关模块(如果知道):<路径或接口名,不知道就留空>

【要求】
先定位根因再改代码;给出【根因】【修复方案】【修改范围】【风险】简报后动手;
修复后实际编译、测试,并用原触发条件复现验证;
最后按"Bug 修复报告"格式输出,明确区分"实际验证通过"和"理论上正确"。
简单问题不用等我确认,直接修。
```

### code-reviewer
```
使用 code-reviewer skill 审查以下代码。

【评审对象】(三选一)
A. 改动/PR:<粘贴 diff、文件列表或分支名>
B. 模块:<模块路径>
C. 全项目:<项目路径>(上线前把关)

【背景】(可选,给了更准)
- 这段代码的业务目的:
- 已有 Bug Finder 报告:<粘贴,避免重复报告>

【要求】
先理解上下文再评审,不孤立看单个方法;
按 P0-P3+GOOD 定级,每个问题说清"为什么是问题、不修的后果";
命名/空格等风格问题不用报,不凑数;
最后按 Code Review Report 格式输出,并明确:是否建议合入/上线、
最优先修改的 5 个问题、下一步改什么测什么、各交给哪个 Skill。
```

### test-writer
```
使用 test-writer skill 为以下目标编写测试。

【测试目标】
- 模块/类/接口:<路径,如 service/OrderService>
- 业务目的:<这段代码是干什么的>
- 重点:<只测 X / 核心链路全覆盖 / 为某次改动补测试>

【已有信息】(可选,给了更准)
- Bug Finder / Code Review 报告:<粘贴,其"测试缺口"部分重点覆盖>

【要求】
先理解项目与已有测试体系,沿用项目已有框架、目录和写法;
按 正常/异常/边界/重复/并发(+数据一致性) 设计场景,只 Mock 外部依赖,核心逻辑真实执行;
写完必须实际执行(mvn test / go test / pytest / npm test 按项目为准);
失败先归因:测试代码错就修测试,发现生产代码 Bug 输出【发现 Bug】交 bug-fixer,
不许改断言变绿,更不许改生产代码适配测试;
最后按 Test Report 格式输出,没实际跑过的明确标"未执行"。
```

### refactor
```
使用 refactor skill 重构以下代码。

【重构对象】
- 范围:<文件/类/方法/模块路径>
- 痛点:<改起来费劲在哪 / 重复 / 职责混乱 / 难测试,不确定可留空让它自己判断>

【约束】
- 业务行为必须保持不变(输入相同→输出相同,异常行为也一致)
- 是否允许动 API/数据库/配置:<默认不允许>
- 重构预算:<小范围即可 / 类级别 / 模块级别>

【要求】
先理解调用方、依赖方和外部依赖,上下文不足先说;
如果收益不高,直接告诉我"当前不建议重构",不要硬改;
值得改就先建行为基线(跑通现有测试,没测试先记录关键行为),
给出【当前问题】【重构目标】【重构方案】【修改范围】【风险】【验证方案】;
小步执行,每步编译+测试;最后按 Refactor Report 格式输出,
行为有任何变化必须明确指出,没实际跑过的验证标注"未执行"。
```

### performance
```
使用 performance skill 分析并优化以下性能问题。

【分析对象】
- 范围:<整个系统 / 某接口 / 某条链路,如 POST /api/orders>
- 现象:<哪里慢、多慢、什么时候开始的;没量过就说不知道>
- 已有数据:<监控/APM/日志耗时/压测报告,有就贴>

【约束】
- 是否允许压测:<可以 / 不可以(线上环境)>
- 是否允许加缓存/异步/引入新组件:<默认不允许,除非有数据证明必要>

【要求】
先测量再优化:先建立性能基线,缺什么指标明确列出来,不伪造数据;
按 CPU/内存/GC/数据库/Redis/MQ/并发/微服务/AI 各域排查,只查项目实际用到的;
每个优化建议给【问题】【证据】【原因】【方案】【预期收益】【验证】,
没实测依据的标"理论性能风险,尚未实际验证";
按 收益×严重程度÷修改成本 排序,收益低直接说"不建议优化";
实施时小步修改、不改业务行为,优化后实际压测并输出前后对比表;
没实际执行的验证明确标"未执行"。
```

### security-reviewer
```
使用 security-reviewer skill 对以下项目做安全审查。

【审查对象】
- 项目路径:<项目根目录>
- 范围:<全部 / 重点某模块或某类接口>
- 项目形态:<Web 后端 / 微服务 / API 服务 / AI Agent / RAG / MCP,涉及哪个写哪个>

【背景】(可选)
- 已知的安全措施:<已用的鉴权框架、网关、WAF 等>
- 之前的安全审查报告:<有就贴,避免重复报告>

【要求】
先建立攻击面(枚举所有用户可控输入的位置,标注谁能访问);
按攻击链逐入口分析:认证授权(IDOR)、SQL注入/XSS/CSRF/SSRF、
文件上传/路径穿越、命令执行、敏感信息泄露、微服务信任边界、
Redis/MQ,涉及 AI/RAG/MCP 的加查 Prompt Injection/Tool 权限/租户隔离;
每个漏洞输出漏洞卡,攻击路径一步步写清,说不清路径的进"需要进一步验证",
不夸大等级,已有安全措施也要列出;
只审不改,最后按 Security Review Report 格式输出。
```

### architecture-reviewer
```
使用 architecture-reviewer skill 审查以下系统的架构。

【审查对象】
- 项目路径:<项目根目录>
- 系统形态:<单体 / 微服务 / AI 服务,不确定就让它自己判断>
- 业务背景:<系统是干什么的、服务谁、当前规模(用户量/QPS/数据量,大概即可)>

【关注点】(可选)
<模块边界 / 服务拆分 / 数据一致性 / 可靠性 / 扩展性 / 可观测性 / AI 架构,
有明确困惑就写,没有就全面审查>

【要求】
基于真实代码分析,不凭目录名猜架构;
先输出系统概览和当前架构图(多条关键链路),确认理解无误后再下结论;
问题按 P0-P3+GOOD+INFO 定级,每个问题说清"为什么是问题、什么场景暴露、不修的后果";
反对过度架构:当前业务用不上的微服务/分库分表/分布式事务不要建议;
扩展性分析说"哪类瓶颈会先出现",不编造 QPS 数字;
最后按 Architecture Review Report 格式输出,给出短期/中期/长期建议;
确认值得改的架构调整,指出交 refactor/code-writer 分步实施。
```

## 6. 部署与同步

1. **目标路径必须是 `.agents/skills/`(复数,带 s)**——少一个 s ZCode 不会发现。正确结构:

```
<项目根>/
└── .agents/
    └── skills/
        ├── codebase-understanding/   (含 references/)
        ├── code-writer/              (含 references/)
        ├── bug-finder/               (含 references/)
        ├── bug-fixer/SKILL.md
        ├── code-reviewer/SKILL.md
        ├── test-writer/SKILL.md
        ├── refactor/SKILL.md
        ├── performance/SKILL.md
        ├── security-reviewer/SKILL.md
        └── architecture-reviewer/SKILL.md
```

2. 同步命令(在本目录执行):

```bash
./sync-to-project.sh <项目路径> [更多项目路径...]
# 示例
./sync-to-project.sh ~/code/order-service ~/code/user-center
```

脚本只覆盖本库的 10 个 Skill 目录(目录内 --delete 对齐源),**不会动项目 `.agents/skills/` 里的其他 Skill**;并会检测误建的 `.agents/skill`(单数)目录并提示。

3. 同步后**新开会话**生效(会话启动时加载 Skill 元数据)。

## 7. 维护约定

- **唯一源原则**:改 SKILL.md 只改本目录,然后 `./sync-to-project.sh` 分发;不直接改项目里的副本。
- **新增/修改 Skill 时**:同步更新相关 Skill 的「与其他 Skill 配合」引用和本 README(一览表、链路、Prompt)。
- **修改纪律**:沿用各 Skill 的风格(全角标点、铁律 → 工作流 → 固定输出格式 → 配合),description 保留"触发短语 + 让位语句"结构。
- 改完在下方追加版本记录。

## 8. 版本记录

- **v1.0(2026-09-12)**:十件套建成;全库一致性修复(重构路由、bug-finder→security-reviewer 让位、bug-fixer 链路补回归、codebase-understanding 问题路由、architecture-reviewer 快速模式);新增本 README 与同步脚本。

## 9. 已知缺口与后续计划

- **incident-debugging(线上故障排查)**:唯一未覆盖的通用能力——拿线上日志/TraceId/堆栈/监控现场定位问题。计划在首次真实故障排查场景后创建,避免凭空设计。
- **专项 references**:test-writer 测试模式、performance profiler 命令、security-reviewer AI 检查手法——等实际使用暴露需求再补,遵循渐进披露。
- **description 瘦身**:十份 description 约 10KB 常驻上下文;若实际使用中 token 开销成为问题,把各 description 尾部"核心纪律"句挪进正文(预计省 40%),保留触发短语。
