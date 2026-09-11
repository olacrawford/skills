# AI / LLM 项目参考（跨语言，检测到 LLM 迹象时追加阅读）

## 何时追加读本文件

Phase 1/6 出现以下任一证据：依赖里有 `openai`、`anthropic`、`google-genai`、`langchain*`、`llama-index`、`modelcontextprotocol`、`mcp`；env 里有 `OPENAI_API_KEY`、`ANTHROPIC_API_KEY` 等；存在 `prompts/`、`agents/`、`tools/`、`evals/` 目录或 `.prompt` 模板文件。

## 三类典型形态与标准调用链

**1. RAG（检索增强）**
```
离线链路: 加载 loader → 切分 chunker → 向量化 embedder → 向量库入库
在线链路: Query → embed → 向量检索 top-k → (rerank 重排) → 组装 prompt → LLM → 后处理/引用
```
识别点：`TextSplitter`、`Embeddings`、`Retriever`、`VectorStore`（langchain 抽象）；`chromadb|milvus|qdrant|pgvector|weaviate|pinecone`。

**2. Agent（工具调用循环）**
```
用户目标 → Planner/LLM → 选择工具(function calling) → 执行 tool → 结果回喂 LLM → 循环直至完成
                    ↑ memory（短期会话 + 长期存储）     ↓
```
识别点：tool 注册表、`while tool_calls` 主循环、`checkpointer`/`memory`、多 Agent 编排（autogen/crewai/langgraph）。**找到主循环所在文件是理解 Agent 项目的关键一步。**

**3. MCP 服务**
- Server：`FastMCP`（Python `@mcp.tool`）或 TypeScript `McpServer`；每个 tool 注册 = 一项能力。
- Transport：stdio（本地）/ SSE / streamable HTTP（远程）。
- Client 配置：`.mcp.json`、`claude_desktop_config.json`——里面列了该 Agent 接了哪些 MCP server。
- 入口不是 HTTP 路由，而是 **tool 定义清单**。

## 必须弄清并在地图中报告的内容

| 维度 | 要找的证据 |
|---|---|
| 模型与供应商 | 模型名字符串（gpt-4o/claude-*/qwen…）、SDK client 初始化处 |
| Prompt 管理 | 硬编码字符串 or `prompts/` 文件 or 模板变量拼接；是否版本化 |
| 记忆/状态 | 会话历史存哪（Redis/DB/内存）、长期记忆存储 |
| 向量与检索 | 向量库、embedding 模型、chunk 大小、检索 top-k |
| 工具清单 | 注册了哪些 tool、各自职责（MCP/Agent 项目核心） |
| 可靠性 | 重试/降级/超时、流式 vs 非流式、成本/token 控制 |
| 评测 | `evals/`、ragas、promptfoo、deepeval——有则说明工程化程度 |

## 读法要点

1. Prompt 常散落两处：代码字符串 + 独立模板文件，两处都要搜。
2. 流式路径（SSE/WebSocket）与非流式是两条不同调用链，分别确认。
3. LLM 输出的解析（JSON mode / 正则抽取 / pydantic 校验）是脆弱点，理解业务时要看解析失败后的分支。
4. 温度、max_tokens、system prompt 的设置位置能反映"哪个环节是业务核心"（如 system prompt 组装逻辑通常承载主要业务规则）。
