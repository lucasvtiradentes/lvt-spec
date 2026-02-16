# Architecture

## High-Level Component Diagram

```
┌──────────────────────────────────────────────────────────────────────────┐
│                              User Interface                              │
│                                                                          │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────────────────┐  │
│  │  CLI (run.py)  │  │  SDK (sdk.py)  │  │  Web UI (Vue 3 + Vite)     │  │
│  └───────┬────────┘  └───────┬────────┘  └────────────┬───────────────┘  │
└──────────┼───────────────────┼────────────────────────┼──────────────────┘
           │                   │                        │
           v                   v                        v
┌──────────────────────────────────────────────────────────────────────────┐
│                          Server Layer (FastAPI)                          │
│                                                                          │
│  ┌──────────────┐  ┌───────────────┐  ┌───────────────────────────────┐  │
│  │ REST Routes  │  │ WebSocket /ws │  │ Services (session, artifact)  │  │
│  └──────┬───────┘  └──────┬────────┘  └──────────────┬────────────────┘  │
└─────────┼─────────────────┼──────────────────────────┼───────────────────┘
          │                 │                          │
          v                 v                          v
┌─────────────────────────────────────────────────────────────────────────┐
│                        Orchestration Layer                              │
│                                                                         │
│  ┌────────────────┐  ┌──────────────────┐  ┌───────────────────────┐    │
│  │ GraphExecutor  │  │ GraphManager     │  │ TopologyBuilder       │    │
│  │ (strategy      │  │ (builds graph    │  │ (cycle detection,     │    │
│  │ dispatch)      │  │ from config)     │  │ toposort, layers)     │    │
│  └───────┬────────┘  └──────────────────┘  └───────────────────────┘    │
│          │                                                              │
│  ┌───────┴──────────────────────────────────────────────────────┐       │
│  │                    Execution Strategies                      │       │
│  │  ┌────────────┐  ┌─────────────────┐  ┌───────────────────┐  │       │
│  │  │ DAG        │  │ Cycle           │  │ MajorityVote      │  │       │
│  │  │ Executor   │  │ Executor        │  │ Strategy          │  │       │
│  │  └────────────┘  └─────────────────┘  └───────────────────┘  │       │
│  └──────────────────────────────────────────────────────────────┘       │
└──────────────────────────────────────────┬──────────────────────────────┘
                                           │
                                           v
┌────────────────────────────────────────────────────────────────────────┐
│                          Runtime Layer                                 │
│                                                                        │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │                       Node Executors                           │    │
│  │  ┌───────┐ ┌────────┐ ┌───────┐ ┌──────────┐ ┌───────┐ ┌──────┐│    │
│  │  │ Agent │ │ Python │ │ Human │ │ Subgraph │ │ Liter │ │ Loop ││    │
│  │  └───┬───┘ └────────┘ └───────┘ └──────────┘ └───────┘ └──────┘│    │
│  └──────┼─────────────────────────────────────────────────────────┘    │
│         │                                                              │
│  ┌──────┴─────────────────────────────────────────────────────────┐    │
│  │                    Agent Subsystems                            │    │
│  │  ┌───────────┐ ┌───────────┐ ┌────────────┐ ┌────────────────┐ │    │
│  │  │ Providers │ │  Memory   │ │  Thinking  │ │ Tool Manager   │ │    │
│  │  │ (OpenAI,  │ │  (Simple, │ │  (Reflect, │ │ (Function,     │ │    │
│  │  │ Gemini)   │ │   File,   │ │  CoT)      │ │  MCP local,    │ │    │
│  │  │           │ │   Board)  │ │            │ │  MCP remote)   │ │    │
│  │  └───────────┘ └───────────┘ └────────────┘ └────────────────┘ │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                        │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │                    Edge Processing                             │    │
│  │  ┌─────────────────┐         ┌──────────────────────┐          │    │
│  │  │ Condition Mgrs  │         │ Payload Processors   │          │    │
│  │  │ (keyword, func) │         │ (regex, function)    │          │    │
│  │  └─────────────────┘         └──────────────────────┘          │    │
│  └────────────────────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────────────┘
                                           │
                                           v
┌────────────────────────────────────────────────────────────────────────┐
│                          Data Layer (entity/)                          │
│                                                                        │
│  ┌───────────────┐ ┌────────────┐ ┌────────────────┐ ┌───────────────┐ │
│  │ DesignConfig  │ │ Node       │ │ EdgeConfig     │ │ Message       │ │
│  │ GraphDef      │ │ EdgeLink   │ │ Condition      │ │ MessageBlock  │ │
│  │ GraphConfig   │ │ AgentCfg   │ │ Processor      │ │ AttachmentRef │ │
│  └───────────────┘ └────────────┘ └────────────────┘ └───────────────┘ │
└────────────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
                    ┌─────────────────┐
                    │  User provides  │
                    │  task prompt +  │
                    │  attachments    │
                    └────────┬────────┘
                             │
                             v
                    ┌──────────────────┐
                    │  load_config()   │
                    │  parse YAML      │
                    │  resolve ${VAR}  │
                    │  validate schema │
                    └────────┬─────────┘
                             │
                             v
                    ┌─────────────────┐
                    │  GraphManager   │
                    │  build_graph()  │
                    │  - nodes        │
                    │  - edges        │
                    │  - topology     │
                    │  - cycles (SCC) │
                    └────────┬────────┘
                             │
                             v
                    ┌─────────────────┐
                    │  Inject input   │
                    │  into start     │
                    │  nodes          │
                    └────────┬────────┘
                             │
                             v
            ┌────────────────┴─────────────────┐
            │          GraphExecutor           │
            │  select execution strategy       │
            └────┬──────────┬──────────────┬───┘
                 │          │              │
                 v          v              v
          ┌──────────┐ ┌──────────┐  ┌────────────┐
          │   DAG    │ │  Cycle   │  │  Majority  │
          │ Executor │ │ Executor │  │   Vote     │
          └────┬─────┘ └────┬─────┘  └────────────┘
               │            │
               v            v
    ┌──────────────────────────────────┐
    │  For each layer / cycle round:   │
    │                                  │
    │  1. Check node triggered?        │
    │  2. Execute node (parallel)      │
    │     - Agent: LLM call + tools    │
    │     - Python: subprocess         │
    │     - Human: wait for input      │
    │     - Subgraph: nested graph     │
    │  3. Process outgoing edges       │
    │     - Evaluate conditions        │
    │     - Transform payloads         │
    │     - Deliver to target.input    │
    │  4. Handle dynamic expansion     │
    │     (Map / Tree fan-out)         │
    │  5. Trim context window          │
    └──────────────┬───────────────────┘
                   │
                   v
    ┌──────────────────────────────────┐
    │  Collect output from end nodes   │
    │  Archive logs + token usage      │
    │  Return final message            │
    └──────────────────────────────────┘
```

## Request Lifecycle (Server Mode)

```
  Frontend (Vue 3)                    Backend (FastAPI + Uvicorn)
  ---------------                     ---------------------------

  connect to /ws ─────────────────---> WebSocketManager.connect()
                 <────────────────---- {type: "connection", session_id}

  {type: "run_workflow",
   yaml_path, task_prompt} ────────-> MessageHandler.handle_message()
                                          │
                                          v
                                      WorkflowRunService.start_workflow()
                                          │
                                          v
                                      WebSocketGraphExecutor
                                      (background thread)
                                          │
  <── {type: "node_start", node_id} ──────┤
  <── {type: "model_call", ...}     ──────┤
  <── {type: "tool_call", ...}      ──────┤
  <── {type: "artifact", ...}       ──────┤
                                          │
  (if human node reached)                 │
  <── {type: "human_input_required"} ─────┤
                                          │
  {type: "human_response",                │
   text: "..."} ──────────────────────--> │
                                          │
  <── {type: "node_end", node_id} ────────┤
  <── {type: "workflow_complete"} ────────┘
```

## Folder Structure

```
chatdev/
├── run.py                           - CLI entry point
├── server_main.py                   - Server entry point (FastAPI + uvicorn)
├── pyproject.toml                   - Python project metadata, dependencies
├── requirements.txt                 - Pip fallback dependencies
├── Makefile                         - Build/run shortcuts
├── .env.example                     - Environment variable template
├── uv.lock                          - uv lockfile
│
├── entity/                          - DATA LAYER: config dataclasses, messages
│   ├── config_loader.py             - loads YAML, resolves env vars
│   ├── enums.py                     - LogLevel, EventType, etc.
│   ├── graph_config.py              - GraphConfig wraps GraphDefinition
│   ├── messages.py                  - Message, MessageBlock, AttachmentRef
│   ├── tool_spec.py                 - ToolSpec for tool definitions
│   └── configs/
│       ├── base.py                  - BaseConfig ABC, ConfigFieldSpec
│       ├── graph.py                 - DesignConfig, GraphDefinition
│       ├── edge/                    - EdgeConfig, conditions, processors, dynamic
│       └── node/                    - Node, AgentConfig, HumanConfig, etc.
│
├── schema_registry/                 - Maps type names to config classes
│   ├── __init__.py                  - Public API: register/get/iter
│   └── registry.py                  - Dict-backed registries
│
├── runtime/                         - RUNTIME: executors, providers, memory
│   ├── sdk.py                       - run_workflow() Python API
│   ├── bootstrap/schema.py          - ensure_schema_registry_populated()
│   ├── node/
│   │   ├── registry.py              - node type registration
│   │   ├── builtin_nodes.py         - registers 7 node types
│   │   ├── splitter.py              - Splitter ABC for dynamic expansion
│   │   ├── executor/
│   │   │   ├── base.py              - ExecutionContext, NodeExecutor ABC
│   │   │   ├── factory.py           - NodeExecutorFactory
│   │   │   ├── agent_executor.py    - LLM call + tool loop + memory + thinking
│   │   │   ├── human_executor.py    - pauses for human input
│   │   │   ├── subgraph_executor.py - nested graph execution
│   │   │   ├── python_executor.py   - subprocess Python execution
│   │   │   ├── passthrough_executor.py
│   │   │   ├── literal_executor.py
│   │   │   └── loop_counter_executor.py
│   │   └── agent/
│   │       ├── memory/              - MemoryBase, SimpleMemory, FileMemory, BlackboardMemory
│   │       ├── providers/           - ModelProvider ABC, OpenAIProvider, GeminiProvider
│   │       ├── thinking/            - ThinkingManager, SelfReflection
│   │       └── tool/                - ToolManager (function, MCP local, MCP remote)
│   └── edge/
│       ├── conditions/              - EdgeConditionManager, keyword, function
│       └── processors/              - EdgePayloadProcessor, regex, function
│
├── workflow/                        - ORCHESTRATION: graph execution
│   ├── graph.py                     - GraphExecutor (main engine)
│   ├── graph_context.py             - GraphContext (mutable runtime state)
│   ├── graph_manager.py             - builds graph structure from config
│   ├── topology_builder.py          - cycle detection, toposort, layers
│   ├── cycle_manager.py             - Tarjan's SCC, CycleInfo
│   ├── subgraph_loader.py           - loads subgraph YAML with caching
│   ├── hooks/                       - workspace artifact detection
│   ├── runtime/
│   │   ├── runtime_builder.py       - assembles RuntimeContext
│   │   ├── execution_strategy.py    - DAG, Cycle, MajorityVote strategies
│   │   └── result_archiver.py       - exports logs and token usage
│   └── executor/
│       ├── dag_executor.py          - layer-by-layer parallel execution
│       ├── cycle_executor.py        - loop handling with nested detection
│       ├── parallel_executor.py     - ThreadPoolExecutor parallelism
│       ├── dynamic_edge_executor.py - Map and Tree dynamic expansion
│       └── resource_manager.py      - semaphore-based resource coordination
│
├── server/                          - WEB SERVER (FastAPI)
│   ├── app.py                       - FastAPI app creation
│   ├── bootstrap.py                 - CORS, middleware, routes, state init
│   ├── state.py                     - global WebSocketManager singleton
│   ├── routes/                      - REST + WS endpoints
│   │   ├── websocket.py             - /ws endpoint
│   │   ├── execute.py               - workflow execution
│   │   ├── workflows.py             - YAML CRUD
│   │   ├── sessions.py              - session management
│   │   ├── artifacts.py             - artifact download
│   │   ├── batch.py                 - batch execution
│   │   └── uploads.py               - file upload
│   └── services/
│       ├── websocket_manager.py     - connection lifecycle, message routing
│       ├── websocket_executor.py    - GraphExecutor subclass emitting WS events
│       ├── session_store.py         - in-memory session tracking
│       ├── workflow_run_service.py   - creates/runs workflow instances
│       └── prompt_channel.py        - WS-based human-in-the-loop
│
├── functions/                       - USER-DEFINED FUNCTIONS
│   ├── edge/conditions.py           - edge condition functions
│   ├── edge_processor/transformers.py
│   └── function_calling/            - tool implementations (weather, search, files, etc.)
│
├── utils/                           - SHARED UTILITIES
│   ├── exceptions.py                - custom exception hierarchy
│   ├── registry.py                  - generic Registry class
│   ├── logger.py                    - WorkflowLogger
│   ├── log_manager.py               - structured event recording
│   ├── vars_resolver.py             - ${VAR} placeholder resolution
│   ├── env_loader.py                - .env file loading
│   ├── function_manager.py          - loads Python functions from dirs
│   ├── human_prompt.py              - PromptService ABC
│   └── token_tracker.py             - per-node token usage
│
├── check/                           - VALIDATION
│   ├── check.py                     - load + validate YAML into DesignConfig
│   ├── check_yaml.py                - schema-level validation
│   └── check_workflow.py            - structural/logic validation
│
├── tools/                           - DEVELOPER TOOLING
│   ├── export_design_template.py    - generates yaml_template from schema
│   ├── sync_vuegraphs.py            - syncs vue graphs to YAML
│   └── validate_all_yamls.py        - batch validates all YAMLs
│
├── mcp_example/mcp_server.py        - example MCP server
├── yaml_template/design.yaml        - auto-generated full schema template
├── yaml_instance/                   - workflow YAML definitions
│   ├── ChatDev_v1.yaml              - classic ChatDev multi-agent
│   ├── GameDev_v1.yaml              - game development
│   ├── deep_research_v1.yaml        - deep research pipeline
│   ├── demo_*.yaml                  - feature demos
│   ├── data_visualization_*.yaml    - data viz workflows
│   ├── blender_*.yaml               - 3D generation
│   └── subgraphs/                   - reusable subgraph YAMLs
│
└── frontend/                        - VUE.JS WEB UI
    ├── package.json                 - Vue 3 + Vite + Vue Flow
    ├── vite.config.js
    └── src/
        ├── main.js                  - Vue app entry
        ├── App.vue                  - root component
        ├── router/index.js          - Vue Router config
        ├── pages/                   - views (Home, Launch, Workflow, Batch, Tutorial)
        ├── components/              - nodes, edges, sidebar, forms
        └── utils/                   - API calls, YAML parsing, config store
```

## Design Patterns

### Registry Pattern (core architectural pattern)

Every extensible component uses a two-phase registration system:

1. schema_registry (entity layer) - maps type name to config class (for YAML parsing and UI schema generation)
2. runtime registry - maps type name to implementation class (for execution)

Applied to: node types, edge condition types, edge processor types, memory store types, thinking types, model providers.

```
┌──────────────────────────────┐   ┌───────────────────────────────────┐
│  schema_registry             │   │  runtime registry                 │
│                              │   │                                   │
│  "agent"  ---> AgentConfig   │   │  "agent"  ---> AgentNodeExecutor  │
│  "human"  ---> HumanConfig   │   │  "human"  ---> HumanNodeExecutor  │
│  "python" ---> PythonConfig  │   │  "python" ---> PythonNodeExecutor │
│  ...                         │   │  ...                              │
└──────────────────────────────┘   └───────────────────────────────────┘
              ^                                  ^
              │                                  │
              └─────────── bootstrap ────────────┘
                  (imports all builtin_* modules once)
```

### Strategy Pattern

```
GraphExecutor
  |
  |----> DagExecutionStrategy ----> DAGExecutor (layer-by-layer parallel)
  |
  |----> CycleExecutionStrategy --> CycleExecutor (loop handling)
  |
  |----> MajorityVoteStrategy ----> parallel vote + pick majority
```

### Factory Pattern

- NodeExecutorFactory.create_executors()                  - creates executor per node type from registry
- MemoryFactory.create_memory()                           - creates memory store from config
- ThinkingManagerFactory.get_thinking_manager()           - creates thinking manager
- build_edge_condition_manager() / build_edge_processor() - factory functions

### Message Passing Model

```
┌────────────┐   output    ┌────────┐   condition    ┌────────┐   input    ┌────────────┐
│   Node A   │──────────-->│  Edge  │──── check ───->│  Edge  │──────────->│   Node B   │
│            │  Message[]  │        │  (keyword/fn)  │        │  Message[] │            │
│   input[]  │             │        │                │        │            │   input[]  │
│   output[] │             │        │   transform    │        │            │   output[] │
└────────────┘             │        │──── payload ──>│        │            └────────────┘
                           └────────┘   (regex/fn)   └────────┘
```

## Module Dependency Graph

```
run.py / server_main.py
  |
  v
check/ (validation)
  |
  +----> workflow/ (orchestration)
  |           |
  +----> entity/ (data models) ---+
  |           |                   |
  +----> schema_registry/ --------+
                                  |
                                  v
                            runtime/ (executors, providers)
                                  |
                                  v
                            utils/ (shared utilities)
```

## Cycle Execution (Tarjan SCC)

```
  Step 1: Detect cycles           Step 2: Build super-node DAG
  ──────────────────────          ───────────────────────────

  ┌───┐     ┌───┐                ┌─────────────────────┐
  │ A │────>│ B │──┐             │   Super-Node SCC1   │
  └───┘     └───┘  │             │  ┌───┐    ┌───┐     │
    ^       │      │             │  │ B │--->│ C │     │
    │       v      v             │  └───┘    └───┘     │
    │       ┌───┐  │             │  ^          │       │
    │       │ C │──┘             │  │          │       │
    │       └───┘                │  ┌───┐      │       │
    │       │                    │  │ D │<─────┘       │
    └───────┘                    └──────┬──────────────┘
                                        │
  Nodes B,C,D form an SCC       ┌───┐   │
  A is outside the cycle        │ A │───┘
                                └───┘ 

  Step 3: Execute cycle repeatedly until exit condition
```
