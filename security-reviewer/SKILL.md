---
name: security-reviewer
description: 从攻击者视角对项目做系统性安全审查的通用工作流：先建立攻击面（所有用户可控输入的位置），沿"输入→代码路径→验证→资源影响"逐条追踪，覆盖认证与授权（JWT/密码存储/IDOR 越权）、SQL 注入/XSS/CSRF/SSRF、文件上传/路径穿越、命令执行、敏感信息泄露、微服务信任边界（Header 伪造）、Redis/MQ、AI（Prompt Injection/Tool 权限/Agent 越权/数据泄露）、RAG 租户隔离、MCP 安全，按 P0-P3+INFO 定级，每个漏洞必须给出可复现的攻击路径，只审不改。只要用户要求"安全审查/看看有没有安全漏洞/检查越权/渗透视角检查/上线前安全把关/AI 应用安全/RAG 越权"，就应使用本 Skill。适用于 Java/Spring、Go、Python、Node/TS、Web 后端、微服务、API 服务、AI/Agent/RAG/MCP。核心纪律：防误报（说不清攻击路径的不定级），不夸大风险；只报告不修改，修复交 bug-fixer/code-writer。工程质量评审用 code-reviewer，功能性 Bug 用 bug-finder。
---

# Security Reviewer（安全审查 · 通用）

从**攻击者视角**分析项目安全风险。不是检查"有没有使用某个安全框架"，而是沿一条链找真实、可利用的问题：

```
攻击者可以控制什么输入
→ 输入经过哪些代码
→ 是否进行了正确验证
→ 最终能影响什么资源
→ 攻击者可能获得什么权限或造成什么影响
```

默认只审查、不修改任何代码；发现漏洞先报告，修复交 bug-fixer / code-writer。

## 铁律（贯穿全程）

1. **攻击者视角。** 逐个入口沿上面的链条分析；不以"用了 Spring Security / 参数校验框架"为安全依据，以"输入到影响的完整路径上都有控制"为依据。
2. **防误报是底线。** 报告一个问题前必须尽量证明五件事：存在攻击入口、用户能控制输入、输入能到达危险位置、缺少必要安全控制、可产生实际影响。说不清攻击路径的不定级，进「需要进一步验证」；不夸大风险等级。
3. **只审不改。** 不修改业务代码，不删除漏洞证据，不自动关闭安全检查，不为了通过测试降低安全要求。
4. **攻击路径必须具体。** 每个漏洞写清：谁能打、从哪个入口、带什么输入、经过哪些代码、最终影响什么。写不出路径 = 证据不足。
5. **好的防护也要说。** 项目已有的安全措施明确列出（报告第 7 节），避免修复时重复建设。
6. **不顺手修。** 发现功能性 Bug 交 bug-fixer；本 Skill 只对安全负责。

## 工作流

### Step 1 建立攻击面

- 用 **codebase-understanding**（焦点模式，或复用已有项目地图）理解架构与数据流。
- 枚举所有"用户可以控制输入"的位置：HTTP API、Gateway、Controller/Handler、WebSocket、文件上传/下载、URL 请求、第三方 API 回调、数据库、Redis、MQ、管理接口、内部服务接口、AI Tool、MCP Tool。
- 产出攻击面清单（进报告第 2 节），每个入口标注：谁能访问（公网 / 登录用户 / 管理员 / 仅内部）、输入什么。

### Step 2 认证与授权（最高优先级）

**Authentication**：登录/注册流程、JWT（签名、过期、篡改、泄露）、Session、Token/Refresh Token、密码存储（是否哈希、什么算法）、密码校验、暴力破解防护（限流/锁定）。

**Authorization** 重点查越权（IDOR）：

- 用户 A 能否访问用户 B 的数据。
- 是否只验证"已登录"，没有验证资源归属。
- 管理员接口是否有保护；内部接口能否被外部访问；Gateway 鉴权是否完整覆盖。

**尤其检查 `/order/{id}`、`/user/{id}`、`/file/{id}` 这类按 ID 取资源的接口：不能只验证"用户已登录"，必须验证"这个资源是不是这个用户的"。**

### Step 3 Web 常见漏洞

- **SQL 注入**：SQL 拼接、动态 SQL（`${}` / 字符串拼接）、参数处理、ORM/Mapper 使用方式。
- **XSS**：用户输入进入 HTML、富文本、前端输出转义。
- **CSRF**：根据项目认证方式判断（Cookie Session 有风险，Header Token 基本免疫）。
- **SSRF**：用户是否可控制 URL/Host/IP/Webhook/图片地址/文件地址。**服务器会主动请求用户提供的 URL 时重点查**（内网探测、云元数据）。
- **文件上传**：类型/大小/文件名/MIME/扩展名校验、存储位置、能否上传可执行文件、路径穿越。
- **路径穿越**：`../`、`..\`，用户输入是否可控制文件路径。

### Step 4 命令执行与敏感信息

**命令执行**：Runtime、ProcessBuilder、shell、exec、系统命令、动态脚本。**用户输入能够进入命令 → 必须重点报告（P0 候选）。**

**敏感信息**：API Key、Secret、JWT Secret、数据库密码、Redis 密码、MQ 密码、云服务密钥、私钥、Token —— 检查 Git 仓库、配置文件、日志、Exception 信息、API 返回值中是否泄露。

### Step 5 微服务 / Redis / MQ 安全

**微服务**：Gateway → Service 之间是否缺少鉴权、能否绕过 Gateway 直接访问内部服务、下游是否信任 Header（X-User-Id / X-User-Role 能否伪造）、内部 API 是否公开。**特别检查：Gateway 把用户信息放入 Header 时，下游服务是否可以被攻击者直接调用并伪造 Header。**

**Redis**：是否暴露公网、有无密码、Key 中是否含敏感数据、Token 是否存 Redis、用户数据是否直接缓存、Redis Lua/Command 是否受用户输入影响。

**MQ**：消息来源、消息参数、消费者是否信任消息内容、消息能否被伪造、敏感信息是否进入消息、重复消息是否可能导致业务攻击。

### Step 6 AI / Agent / RAG / MCP 安全（项目涉及才做）

**AI / Agent**：

- Prompt Injection：用户输入能否覆盖系统 Prompt、修改 Agent 行为、获取隐藏 Prompt、诱导调用危险 Tool。
- Tool Security：Tool 参数校验、Tool 权限、能否访问任意资源 / 执行系统命令 / 读文件 / 访问网络 / 操作数据库。
- Agent Permission：**Agent 是否具有超出用户权限的能力**——普通用户 → Agent → 数据库，如果 Agent 可以执行任意 SQL，必须重点审查。
- 数据泄露：System Prompt、用户数据、RAG 文档、内部知识、API Key、Tool 返回结果是否可能被模型输出泄露。

**RAG**：文档权限、用户权限、租户隔离、向量库访问权限、检索结果过滤、文档中的 Prompt Injection、敏感文档、跨用户数据泄露。**特别检查：用户 A 是否可能通过检索获得用户 B 的私有文档。**

**MCP**：Tool/Resource 权限、Tool 参数校验、Server 权限、凭证管理、文件系统访问、网络访问、命令执行、任意 Tool 调用、Tool 输出中的敏感信息。

### Step 7 定级

| 级别 | 定义 |
|---|---|
| P0 | 严重漏洞：远程代码执行、大规模数据泄露、完全权限接管 |
| P1 | 高危：用户数据泄露、越权、敏感接口访问、严重业务攻击 |
| P2 | 中危：存在一定攻击条件或影响范围有限 |
| P3 | 低危：安全加固建议 |
| INFO | 不属于漏洞，但值得关注 |

## 漏洞卡格式

```
【等级】P0 / P1 / P2 / P3 / INFO
【漏洞类型】SQL Injection / IDOR / SSRF / XSS / Authentication / Authorization / Prompt Injection / Secret Leakage …
【位置】文件路径 + 类/方法 + API
【攻击前提】攻击者需要具备什么条件（公网可访问？需要登录？需要知道某 ID？）
【攻击路径】攻击者输入 → 代码处理 → 漏洞点 → 最终影响（一步步写清）
【影响】攻击者最终能够做什么
【修复建议】应该如何修复
【验证方式】如何验证漏洞已经修复
```

## 最终报告

```
# Security Review Report

## 1. 安全概况
整体安全情况（2~4 句）：最严重的风险方向、整体防护水平。

## 2. 攻击面
枚举：API、管理接口、文件、外部请求、AI Tool、MCP Tool、数据库、Redis、MQ，标注谁能访问。

## 3. P0 / P1
高危漏洞，每条一张漏洞卡，按影响排序。

## 4. P2 / P3
其他问题。

## 5. INFO
安全加固建议。

## 6. 最危险的 5 个问题
为什么危险 / 攻击前提 / 影响 / 修复优先级。

## 7. 已有安全措施
项目目前已做到的防护，明确列出。

## 8. 未确认问题
需要进一步验证的风险 + 缺什么证据。
```

## 与其他 Skill 配合

完整链路：**codebase-understanding（读）→ security-reviewer（安全审查）→ bug-fixer / code-writer（修复）→ test-writer（安全测试）→ security-reviewer（重新审查）→ code-reviewer（整体 review）**。形成：理解 → 安全审查 → 修复 → 测试 → 重新审查。

- **codebase-understanding（读）**：Step 1 的上下文来源，提供入口清单与数据流；已有项目地图直接复用坐标。
- **bug-finder（查）**：分工——bug-finder 找功能性 Bug（顺带撞见的明显安全问题会报告）；系统性、攻击者视角的安全审查走本 Skill。
- **code-reviewer（审）**：分工——reviewer 在代码评审中只报"有明确攻击路径"的单点安全问题；系统性安全审查走本 Skill。
- **architecture-reviewer（架）**：越权、信任边界问题的根因在架构层（鉴权只做了 Gateway 一层、服务可被直连）时，交它评估安全架构分层。
- **bug-fixer / code-writer（修）**：确认的漏洞按漏洞卡交它们修复；修完由本 Skill 重新审查验证。
- **test-writer（测）**：按攻击路径编写安全测试（复现用例），修复后回归，防止漏洞复发。
