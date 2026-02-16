# Usage and Examples

## Quickstart

Prerequisites: macOS / Linux / WSL / Windows, Python 3.12+, Node.js 18+, `uv` package manager.

```bash
uv sync
cd frontend && npm install
cp .env.example .env
```

Edit `.env` with your LLM provider credentials, then:

```bash
make dev
```

Open `http://localhost:5173`.

## CLI Usage

Entry point: `run.py`

```bash
uv run python run.py --path yaml_instance/demo.yaml --name test_project
```

| Argument            | Default                                         | Description                    |
|---------------------|-------------------------------------------------|--------------------------------|
| --path              | yaml_instance/net_loop_test_included.yaml       | Path to workflow YAML          |
| --name              | test_project                                    | Project/session name           |
| --fn-module         | None                                            | Python module for edge helpers |
| --inspect-schema    | flag                                            | Output schema and exit         |
| --schema-breadcrumbs| None                                            | JSON array for scoped schema   |
| --attachment        | repeatable                                      | Attach files to initial message|

After launch, the CLI prompts for `task_prompt` via stdin. Outputs go to `WareHouse/`.

Schema inspection:

```bash
python run.py --inspect-schema --schema-breadcrumbs '[{"node":"DesignConfig","field":"graph"}]'
```

## Python SDK

```python
from runtime.sdk import run_workflow

result = run_workflow(
    yaml_file="yaml_instance/demo.yaml",
    task_prompt="Summarize the attached document.",
    attachments=["/path/to/document.pdf"],
    variables={"API_KEY": "sk-xxxx"},
)

if result.final_message:
    print(f"Output: {result.final_message.text_content()}")

print(result.meta_info.session_name)
print(result.meta_info.output_dir)
print(result.meta_info.token_usage)
```

| Parameter    | Type                | Description                         |
|--------------|---------------------|-------------------------------------|
| yaml_file    | str / Path          | Path (relative to yaml_instance/)   |
| task_prompt  | str                 | User prompt                         |
| attachments  | Sequence[str/Path]  | Optional file paths                 |
| session_name | str                 | Optional, auto-generated if omitted |
| fn_module    | str                 | Optional edge function module       |
| variables    | Dict[str, Any]      | Optional dict overriding .env vars  |
| log_level    | LogLevel / str      | Optional log level                  |

Returns `WorkflowRunResult` with `final_message` (Message) and `meta_info` (WorkflowMetaInfo).

## Server Mode

```bash
uv run python server_main.py --port 6400 --reload
```

| Argument    | Default | Description                       |
|-------------|---------|-----------------------------------|
| --host      | 0.0.0.0 | Server bind host                  |
| --port      | 8000    | Server port                       |
| --log-level | info    | debug/info/warning/error/critical |
| --reload    | flag    | Auto-reload on file changes       |

Key API endpoints:

| Endpoint                                    | Method | Description                      |
|---------------------------------------------|--------|----------------------------------|
| /ws                                         | WS     | Real-time workflow execution     |
| /api/workflow/execute                       | POST   | Execute a workflow               |
| /api/config/schema                          | POST   | Get config schema                |
| /api/config/schema/validate                 | POST   | Validate YAML config             |
| /api/uploads/{session_id}                   | GET    | List attachments                 |
| /api/uploads/{session_id}                   | POST   | Upload file                      |
| /api/sessions/{session_id}/artifact-events  | GET    | Real-time artifact events        |
| /api/sessions/{session_id}/artifacts/{id}   | GET    | Download artifact                |
| /api/sessions/{session_id}/download         | GET    | Download session as zip          |

## Frontend UI

| Page               | Purpose                              |
|--------------------|--------------------------------------|
| Home               | Quick navigation links               |
| Workflow List      | Browse/preview YAML workflows        |
| Launch             | Main execution interface             |
| Workflow Workbench | Visual drag-and-drop workflow editor |
| Batch Run          | Batch execution of workflows         |
| Tutorial           | Built-in guides                      |

Launch workflow:
1. Select a YAML file from the left panel
2. Upload attachments (optional)
3. Enter task prompt
4. Click "Launch"
5. Monitor node status (pending -> running -> success/failed)
6. View real-time logs, node output, generated artifacts
7. When a `human` node is reached, the UI pauses for input
8. Download session results after completion

## Example Workflows

### Feature Demos

| File                     | Description                                                             |
|--------------------------|-------------------------------------------------------------------------|
| demo_code.yaml           | Human writes code, Python node executes it                              |
| demo_function_call.yaml  | Weather assistant with function calling (get_city_num, get_weather)     |
| demo_mcp.yaml            | MCP remote tool: poet + critic with random number MCP server            |
| demo_human.yaml          | Article writer with thinking/reflection + human reviewer                |
| demo_sub_graph.yaml      | Article generation with inline subgraph for critique                    |
| demo_sub_graph_path.yaml | Same but loads subgraph from external file                              |
| demo_loop_counter.yaml   | Loop counter: releases output only on 3rd iteration                     |
| demo_dynamic.yaml        | Dynamic map/tree: Shanghai travel planning with parallel fan-out        |
| demo_dynamic_tree.yaml   | Tree mode: splits novel text into chunks for parallel summary           |
| demo_majority_voting.yaml| Three agents vote; majority answer wins                                 |
| demo_simple_memory.yaml  | Simple memory-backed writing agent                                      |
| demo_file_memory.yaml    | File memory: indexes .md files for RAG                                  |
| demo_edge_transform.yaml | Regex extract processor: extracts code blocks from markdown             |
| demo_context_reset.yaml  | Demonstrates clear_context and clear_kept_context behaviors             |
| net_example_en.yaml      | Full article pipeline: Writer + Poet -> Editor -> Human -> Revision loop|
| react.yaml               | ReAct agent: Task Normalizer -> ReAct subgraph -> QA Editor             |
| reflexion_product.yaml   | Marketing campaign brainstorming using Reflexion subgraph               |

### Production Workflows

| File                               | Description                                                                              |
|------------------------------------|------------------------------------------------------------------------------------------|
| data_visualization_basic.yaml      | Data viz: Analyst -> Cleaner -> Planner -> Programmer -> Expert (review loops)           |
| data_visualization_enhanced_v2.yaml| Enhanced data visualization variant                                                      |
| deep_research_v1.yaml              | Deep research: Analyst -> Planner -> Executor (parallel web search) -> Writer -> Reviewer|
| ChatDev_v1.yaml                    | Classic multi-agent software dev: CEO, Programmer, Reviewer, Tester, CPO                 |
| GameDev_v1.yaml                    | Pygame game factory: Designer -> Planner -> Developer -> QA -> Bug Fixer                 |
| blender_3d_builder_simple.yaml     | 3D generation via Blender MCP: PM -> Planner -> Architect -> Reviewer                    |
| teach_video.yaml                   | Teaching video: Composer -> Paginator -> Code Gen (Manim, parallel) -> Render -> Concat  |
| MACNet_v1.yaml                     | MACNet multi-agent collaboration network                                                 |

## Creating Custom Workflows

### YAML Top-Level Structure

```yaml
version: 0.4.0
vars:
  BASE_URL: https://api.openai.com/v1
  API_KEY: ${API_KEY}
graph:
  id: my_workflow
  description: What this workflow does
  log_level: INFO
  start:
    - Node_A
  end:
    - Node_Z
  nodes:
    - id: Node_A
      type: agent
      config: { ... }
  edges:
    - from: Node_A
      to: Node_B
  memory:
    - name: my_memory
      type: simple
      config: { ... }
```

### Node Types

| Type         | Config Keys                                                                        |
|--------------|------------------------------------------------------------------------------------|
| agent        | provider, name, role, base_url, api_key, params, tooling, thinking, memories, retry|
| python       | interpreter, args, env, timeout_seconds, encoding                                  |
| human        | description                                                                        |
| subgraph     | type (file/config), config (path or inline graph)                                  |
| passthrough  | only_last_message                                                                  |
| literal      | content, role (user/assistant)                                                     |
| loop_counter | max_iterations, reset_on_emit, message                                             |

### Edge Configuration

```yaml
edges:
  - from: Writer
    to: Reviewer
    trigger: true
    carry_data: true
    keep_message: false
    clear_context: false
    condition:
      type: keyword
      config:
        any: [APPROVE]
        none: [REJECT]
        case_sensitive: true
    process:
      type: regex_extract
      config:
        pattern: "Score\\s*:\\s*(?P<score>\\d+)"
        group: score
    dynamic:
      type: map
      split:
        type: message
      config:
        max_parallel: 5
```

### Validate Workflows

```bash
make validate-yamls
```

## MCP Integration

### Two Modes

| Mode         | Type         | Use Case                          |
|--------------|--------------|-----------------------------------|
| Remote HTTP  | mcp_remote   | Hosted HTTP(S) MCP servers        |
| Local stdio  | mcp_local    | Local executables via stdio       |

### MCP Remote Example

```yaml
tooling:
  type: mcp_remote
  config:
    server: http://127.0.0.1:8001/mcp
    headers:
      Authorization: Bearer ${MY_MCP_TOKEN}
    timeout: 15
```

### MCP Local Example (Blender)

```yaml
tooling:
  type: mcp_local
  config:
    command: uvx
    args:
      - blender-mcp
    startup_timeout: 8
    wait_for_log: "MCP ready"
```

### Sample MCP Server

```python
from fastmcp import FastMCP
import random

mcp = FastMCP("Company Simple MCP Server", debug=True)

@mcp.tool
def rand_num(a: int, b: int) -> int:
    return random.randint(a, b)

if __name__ == "__main__":
    mcp.run()
```

Launch:

```bash
uv run fastmcp run mcp_example/mcp_server.py --transport streamable-http --port 8010
```

## Configuration Examples

### OpenAI Agent

```yaml
config:
  provider: openai
  base_url: ${BASE_URL}
  api_key: ${API_KEY}
  name: gpt-4o
  role: You are a helpful assistant.
  params:
    temperature: 0.7
    max_tokens: 2000
```

### Gemini Agent

```yaml
config:
  provider: gemini
  base_url: https://generativelanguage.googleapis.com
  api_key: ${GEMINI_API_KEY}
  name: gemini-2.0-flash-001
  params:
    response_modalities: ["text", "image"]
```

### Function Tooling

```yaml
tooling:
  type: function
  config:
    tools:
      - name: describe_available_files
      - name: read_text_file_snippet
      - name: save_file
      - name: web_search
      - name: deep_research:All
    timeout: 20
```

### Memory (Simple / FAISS)

```yaml
memory:
  - name: convo_cache
    type: simple
    config:
      memory_path: WareHouse/shared/simple.json
      embedding:
        provider: openai
        model: text-embedding-3-small
        api_key: ${API_KEY}
        base_url: ${BASE_URL}
```

### Memory (File / RAG)

```yaml
memory:
  - name: project_docs
    type: file
    config:
      index_path: index/docs.json
      file_sources:
        - path: docs/
          file_types: [".md", ".mdx"]
          recursive: true
      embedding:
        provider: openai
        model: text-embedding-3-small
```

### Thinking (Reflection)

```yaml
thinking:
  type: reflection
  config:
    reflection_prompt: |
      Review your response:
      1. Is the logic sound?
      2. Are there factual errors?
      3. Is it clear?
      Provide an improved version.
```

### Retry Strategy

```yaml
retry:
  enabled: true
  max_attempts: 3
  min_wait_seconds: 2.0
  max_wait_seconds: 10.0
  retry_on_status_codes: [408, 429, 500, 502, 503, 504]
```

### Keyword Condition (Loop Exit)

```yaml
condition:
  type: keyword
  config:
    none: [ACCEPT]
    case_sensitive: false
```
