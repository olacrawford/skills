# Python 参考

## Manifest 与指纹

- `pyproject.toml`：看构建后端（poetry/uv/setuptools/hatch）、`[project.dependencies]`、`[project.scripts]`（CLI 入口命令）。
- 其余可能形态：`requirements*.txt`（常分 base/dev/prod）、`setup.py`、`Pipfile`、`environment.yml`（conda）。
- 依赖清单可能过期：**import 语句与 requirements 冲突时，以代码 import 为准**，并把差异记入待确认。

## 入口定位

| 类型 | 位置 |
|---|---|
| FastAPI | Grep `FastAPI(` 找 app 定义；路由经 `APIRouter` include；启动命令惯例 `uvicorn <pkg>.main:app` |
| Django | `manage.py`；`settings.py` 的 `ROOT_URLCONF` → 全局 `urls.py` → 各 app 的 `views.py`；`INSTALLED_APPS` 列出全部业务 app |
| Flask | Grep `Flask(__name__)`；blueprint 注册 |
| CLI | `[project.scripts]`、click/typer/argparse |
| 包运行 | `__main__.py` → `python -m pkg` |
| 任务 | celery app + `tasks.py` + `beat_schedule`（定时/异步 = 隐藏入口） |

## 层级定位

| 层 | 常见位置 |
|---|---|
| API | `api/`、`routers/`、`views.py`、`endpoints/` |
| 业务 | `services/`、`core/`、`domain/` |
| 数据 | `models.py|models/`（SQLAlchemy/Django ORM）、`crud/`、`repositories/` |
| 迁移 | `alembic/`、Django `migrations/`——看迁移文件能还原完整表结构 |
| schema | `schemas/`（pydantic）——请求/响应契约 |

- SQLAlchemy：`create_engine` + `session` 管理在哪（常有 `db.py`/`database.py`）；`relationship` 字段是表间关系线索。

## AI / LLM 迹象（详见 ai-llm.md）

`openai`、`anthropic`、`langchain|langgraph`、`llama_index`、`chromadb|milvus|qdrant|pgvector|weaviate|pinecone`、`transformers`、`mcp`（FastMCP `@mcp.tool`）、`autogen|crewai|pydantic-ai`。命中任一 → 追加读 `references/ai-llm.md`。

## 读法要点

1. `tests/` 目录是捷径：测试用例直接展示函数预期行为与调用方式，理解业务语义快于读实现。
2. `.env.example` / `config.py`（pydantic-settings）列出全部外部依赖。
3. Jupyter notebook（`.ipynb`）多为原型实验，不算运行时入口，但能反映数据处理意图。
4. `if __name__ == "__main__":` 块常带本地运行逻辑，可作入口补充。
5. 注意异步标记：FastAPI `async def` + `await`，异步链路里的阻塞调用是常见问题点（只记录）。
