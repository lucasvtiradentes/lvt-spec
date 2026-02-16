# CrewAI - Architecture

## High-Level Component Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                           User Code                                  │
│  crew.kickoff() / flow.kickoff() / agent.kickoff() / crewai CLI      │
└────────┬─────────────────────┬────────────────────────┬──────────────┘
         │                     │                        │
         v                     v                        v
┌────────────────┐   ┌────────────────┐   ┌──────────────────────────┐
│     Crew       │   │     Flow       │   │        CLI               │
│  crew.py       │   │  flow/flow.py  │   │  cli/cli.py (Click)      │
│  (2062 lines)  │   │  @start        │   │  create/run/train/test   │
│                │   │  @listen       │   │  deploy/flow/tool        │
│  sequential    │   │  @router       │   └──────────────────────────┘
│  hierarchical  │   │  state mgmt    │
└───────┬────────┘   └───────┬────────┘
        │                    │
        │   Flow embeds Crews as steps
        │<-------------------┘
        │
        v
┌───────────────────────────────────────────────────────────────┐
│                        Agent Layer                            │
│  agent/core.py (2217 lines)                                   │
│  - role, goal, backstory                                      │
│  - execute_task() / kickoff()                                 │
│  - knowledge retrieval, memory integration                    │
│  - reasoning, guardrails, MCP tools                           │
└───────┬───────────────────────────────────────────────────────┘
        │
        v
┌───────────────────────────────────────────────────────────────┐
│                   Executor Layer                              │
│  agents/crew_agent_executor.py (1556 lines)                   │
│  - ReAct loop (text-based tool calling)                       │
│  - Native function calling loop (OpenAI-style)                │
│  - Human feedback, memory creation                            │
│  - Context length management                                  │
└───────┬──────────────────┬────────────────────────────────────┘
        │                  │
        v                  v
┌───────────────┐   ┌──────────────────────────────────────────┐
│  LLM Layer    │   │            Tool System                   │
│  llm.py       │   │  tools/base_tool.py                      │
│  llms/        │   │  70+ built-in (crewai-tools)             │
│  providers/   │   │  @tool decorator                         │
│  - openai     │   │  MCP tools (mcp/)                        │
│  - anthropic  │   │  Agent delegation tools                  │
│  - gemini     │   │  LangChain adapter                       │
│  - azure      │   └──────────────────────────────────────────┘
│  - bedrock    │
│  - litellm    │
└───────────────┘
        │
        v
┌───────────────────────────────────────────────────────────────┐
│                  Shared Infrastructure                        │
├──────────────┬──────────────┬──────────────┬──────────────────┤
│  Memory      │  Knowledge   │  Events      │  Utilities       │
│  short_term  │  ChromaDB    │  event_bus   │  i18n            │
│  long_term   │  Qdrant      │  40+ events  │  prompts         │
│  entity      │  RAG sources │  listeners   │  converter       │
│  external    │  embeddings  │  tracing     │  streaming       │
└──────────────┴──────────────┴──────────────┴──────────────────┘
```

## Folder Structure

```
lib/crewai/src/crewai/
├── __init__.py                 - public API: Agent, Crew, Task, Flow, LLM, Process, Knowledge
├── crew.py                     - Crew class (2062 lines), orchestrates agents+tasks
├── task.py                     - Task class (1279 lines), unit of work
├── process.py                  - Process enum: sequential, hierarchical
├── llm.py                      - LLM class, multi-provider router (2000+ lines)
├── lite_agent.py               - LiteAgent (deprecated, replaced by Agent.kickoff)
├── context.py                  - ContextVars for task_id tracking
│
├── agent/
│   ├── core.py                 - Agent class (2217 lines), main agent implementation
│   ├── utils.py                - reasoning, knowledge retrieval, tool prep helpers
│   └── internal/meta.py        - AgentMeta metaclass
│
├── agents/
│   ├── crew_agent_executor.py  - execution engine (1556 lines), ReAct + native loops
│   ├── parser.py               - ReAct output parser (AgentAction/AgentFinish)
│   ├── tools_handler.py        - tool cache integration
│   ├── constants.py            - regex patterns, error templates
│   ├── agent_builder/
│   │   ├── base_agent.py       - BaseAgent ABC (472 lines)
│   │   └── base_agent_executor_mixin.py - memory creation mixin
│   ├── agent_adapters/
│   │   ├── langgraph/          - LangGraph adapter
│   │   └── openai_agents/      - OpenAI Agents SDK adapter
│   └── cache/
│       └── cache_handler.py    - in-memory dict cache for tool results
│
├── tasks/
│   ├── task_output.py          - TaskOutput model
│   ├── conditional_task.py     - ConditionalTask with condition callable
│   ├── output_format.py        - OutputFormat enum: RAW, JSON, PYDANTIC
│   └── llm_guardrail.py        - LLM-based string guardrail
│
├── crews/
│   ├── crew_output.py          - CrewOutput model (raw, pydantic, json_dict, token_usage)
│   └── utils.py                - prepare_kickoff, setup_agents, prepare_task_execution
│
├── llms/
│   ├── base_llm.py             - BaseLLM ABC
│   ├── constants.py            - model name lists per provider
│   ├── providers/
│   │   ├── openai/             - OpenAI native SDK
│   │   ├── anthropic/          - Anthropic native SDK
│   │   ├── gemini/             - Google Gemini native SDK
│   │   ├── azure/              - Azure OpenAI native SDK
│   │   ├── bedrock/            - AWS Bedrock native SDK
│   │   └── utils/              - shared provider utilities
│   └── hooks/                  - LLM-level hooks
│
├── flow/
│   ├── flow.py                 - Flow class, @start, @listen, @router, or_, and_
│   ├── flow_wrappers.py        - FlowMethod, StartMethod, ListenMethod, RouterMethod
│   ├── flow_context.py         - ContextVars for flow_id tracking
│   ├── constants.py            - AND_CONDITION, OR_CONDITION
│   ├── persistence/            - FlowPersistence ABC, SQLite implementation
│   ├── visualization/          - flow graph visualization (interactive HTML)
│   └── async_feedback/         - human feedback types
│
├── events/
│   ├── event_bus.py            - CrewAIEventsBus singleton (676 lines)
│   ├── base_events.py          - BaseEvent model
│   ├── event_listener.py       - EventListener (console output for 40+ events)
│   ├── event_context.py        - event scope tracking with ContextVars
│   ├── handler_graph.py        - topological sort for handler dependencies
│   ├── depends.py              - Depends class for handler dependency declaration
│   ├── types/
│   │   ├── crew_events.py      - CrewKickoff/Train/Test started/completed/failed
│   │   ├── task_events.py      - TaskStarted/Completed/Failed
│   │   ├── agent_events.py     - AgentExecution started/completed/error
│   │   ├── llm_events.py       - LLMCall started/completed/failed, StreamChunk
│   │   ├── tool_usage_events.py- ToolUsage started/finished/error
│   │   ├── flow_events.py      - Flow created/started/finished/paused
│   │   ├── memory_events.py    - MemoryRetrieval started/completed/failed
│   │   ├── knowledge_events.py - KnowledgeQuery started/completed/failed
│   │   ├── mcp_events.py       - MCPConnection/ToolExecution events
│   │   ├── a2a_events.py       - A2A conversation/delegation events
│   │   ├── reasoning_events.py - AgentReasoning started/completed/failed
│   │   └── guardrail_events.py - Guardrail started/completed/failed/retrying
│   └── listeners/tracing/      - TraceCollectionListener for platform upload
│
├── tools/
│   ├── base_tool.py            - BaseTool ABC, Tool class, @tool decorator
│   ├── structured_tool.py      - runtime tool wrapper with schema
│   ├── mcp_tool_wrapper.py     - MCP HTTPS server tool wrapper
│   ├── mcp_native_tool.py      - native MCP client tool wrapper
│   └── agent_tools/
│       ├── agent_tools.py      - delegation tools (DelegateWork, AskQuestion)
│       └── read_file_tool.py   - file input reader
│
├── memory/
│   ├── short_term/             - ChromaDB RAG-based, per-execution
│   ├── long_term/              - SQLite-based, cross-session
│   ├── entity/                 - ChromaDB RAG-based entity tracking
│   ├── external/               - user-provided implementation
│   ├── contextual/             - aggregator composing all memory types
│   └── storage/                - storage backends
│
├── knowledge/
│   ├── knowledge.py            - Knowledge class with query/add_sources
│   ├── knowledge_config.py     - results_limit, score_threshold
│   ├── source/                 - string, text, PDF, CSV, JSON, Excel, URL sources
│   └── storage/                - KnowledgeStorage wrapping RAG
│
├── rag/
│   ├── chromadb/               - ChromaDB adapter
│   ├── qdrant/                 - Qdrant adapter
│   ├── embeddings/providers/   - 15+ embedding providers
│   └── storage/                - RAG storage abstraction
│
├── mcp/
│   ├── client.py               - MCPClient async client
│   ├── config.py               - MCPServerStdio, MCPServerHTTP, MCPServerSSE
│   ├── filters.py              - tool filtering
│   └── transports/             - stdio, http, sse transports
│
├── a2a/                        - Agent-to-Agent protocol (Google A2A)
│   ├── config.py               - A2AConfig, client/server configs
│   ├── wrapper.py              - A2A task delegation
│   ├── auth/                   - authentication
│   └── extensions/             - capability registry
│
├── hooks/
│   ├── llm_hooks.py            - before/after LLM call hooks
│   └── tool_hooks.py           - before/after tool call hooks
│
├── security/
│   ├── fingerprint.py          - UUID-based identity
│   └── security_config.py      - SecurityConfig model
│
├── project/
│   ├── annotations.py          - @agent, @task, @crew, @tool, @llm decorators
│   └── crew_base.py            - @CrewBase: YAML loading, auto-wiring
│
├── cli/
│   ├── cli.py                  - main CLI entry (698 lines, Click)
│   ├── create_crew.py          - crewai create crew
│   ├── create_flow.py          - crewai create flow
│   ├── run_crew.py             - crewai run
│   ├── train_crew.py           - crewai train
│   ├── evaluate_crew.py        - crewai test
│   ├── crew_chat.py            - crewai chat
│   ├── kickoff_flow.py         - crewai flow kickoff
│   ├── plot_flow.py            - crewai flow plot
│   ├── deploy/                 - deployment commands
│   ├── templates/              - project scaffolding templates
│   └── authentication/         - login/signup
│
├── utilities/
│   ├── i18n.py                 - prompt strings from JSON translations
│   ├── prompts.py              - system/user prompt builder
│   ├── converter.py            - raw output ---> Pydantic/JSON converter
│   ├── agent_utils.py          - LLM response handling, tool parsing
│   ├── guardrail.py            - guardrail execution with events
│   ├── planning_handler.py     - CrewPlanner for pre-execution planning
│   ├── rpm_controller.py       - rate limiting
│   ├── streaming.py            - streaming infrastructure
│   └── training_handler.py     - training data save/load
│
├── telemetry/                  - Scarf pixel + OpenTelemetry
├── translations/               - i18n JSON files
├── types/
│   ├── usage_metrics.py        - token usage tracking
│   └── streaming.py            - streaming output models
└── experimental/               - experimental executor and evaluation
```

## Execution Lifecycle: Crew.kickoff()

```
crew.kickoff(inputs={"topic": "AI"})
         │
         v
┌─────────────────────────────────┐
│  1. prepare_kickoff()           │
│  - Emit CrewKickoffStartedEvent │
│  - Run before_kickoff_callbacks │
│  - Interpolate {topic} in all   │
│  task descriptions/agents       │
│  - Setup agents (create         │
│  executors, assign knowledge)   │
│  - Run planning if enabled      │
└────────┬────────────────────────┘
         │
         v
┌────────────────────────────────┐
│  2. Process Selection          │
│  sequential: _execute_tasks()  │
│  hierarchical: create manager  │
│  then _execute_tasks()         │
└────────┬───────────────────────┘
         │
         v (for each task)
┌────────────────────────────────────────────────────────────┐
│  3. Task Execution Loop                                    │
│                                                            │
│  For each task in order:                                   │
│    a. Check conditional (skip if condition=False)          │
│    b. Wait for pending async tasks if needed               │
│    c. Build context from prior task outputs                │
│    d. Prepare tools (delegation, MCP, code, platform)      │
│    e. Execute: task.execute_sync(agent, context, tools)    │
│       OR task.execute_async() for async tasks              │
│    f. Apply guardrails (retry if validation fails)         │
│    g. Store TaskOutput                                     │
└────────┬───────────────────────────────────────────────────┘
         │
         v
┌────────────────────────────────────────────────────────────┐
│  4. Individual Task Execution                              │
│                                                            │
│  task._execute_core(agent, context, tools):                │
│    a. Emit TaskStartedEvent                                │
│    b. agent.execute_task(task, context, tools)             │
│       - handle_reasoning() if reasoning=True               │
│       - inject date if inject_date=True                    │
│       - build task prompt + schema instructions            │
│       - retrieve memory (STM + LTM + Entity + External)    │
│       - retrieve knowledge (agent + crew level)            │
│       - prepare tools                                      │
│       - apply training data                                │
│       - invoke executor                                    │
│    c. Apply guardrails (retry loop on failure)             │
│    d. Export to Pydantic/JSON if configured                │
│    e. Execute callbacks                                    │
│    f. Write to output_file if set                          │
│    g. Emit TaskCompletedEvent                              │
└────────┬───────────────────────────────────────────────────┘
         │
         v
┌────────────────────────────────────────────────────────────┐
│    5. Executor Loop (2 modes)                              │
│                                                            │
│    Native Function Calling (when LLM supports it):         │
│    - Convert tools to OpenAI schema                        │
│    - LLM returns structured tool_calls                     │
│    - Execute ONE tool at a time (with reflection)          │
│    - Loop until LLM returns text (final answer)            │
│                                                            │
│    ReAct Text Pattern (fallback):                          │
│    - Tools described in prompt text                        │
│    - LLM outputs: Thought/Action/Action Input              │
│    - Or: Thought/Final Answer                              │
│    - Parser extracts AgentAction or AgentFinish            │
│    - Tool results added as observations                    │
│    - Loop until Final Answer                               │
└────────┬───────────────────────────────────────────────────┘
         │
         v
┌────────────────────────────────────────────────────────────┐
│  6. Create CrewOutput                                      │
│  - Aggregate all TaskOutputs                               │
│  - Calculate token usage metrics                           │
│  - Flush event bus                                         │
│  - Run after_kickoff_callbacks                             │
│  - Emit CrewKickoffCompletedEvent                          │
│  - Return CrewOutput(raw, pydantic, json_dict,             │
│  tasks_output, token_usage)                                │
└────────────────────────────────────────────────────────────┘
```

## Flow Execution Model

```
flow.kickoff()
       │
       v
┌──────────────────────┐
│  Find @start methods │
│  Execute all entry   │
│  points in parallel  │
└──────┬───────────────┘
       │
       v
┌──────────────────────────────────────────────────────────┐
│  Listener Graph (DAG)                                    │
│                                                          │
│  @start()            @listen(begin)      @listen(proc)   │
│  begin() ──────────> process() ────────> finalize()      │
│                          │                               │
│                          v                               │
│                      @router(process)                    │
│                      route() ──┬──────> "high" listener  │
│                                └──────> "low" listener   │
│                                                          │
│  Conditions:                                             │
│  or_(m1, m2)  - trigger when ANY completes               │
│  and_(m1, m2) - trigger when ALL complete                │
└──────────────────────────────────────────────────────────┘
       │
       v
┌──────────────────────┐
│  State available as  │
│  self.state (dict or │
│  Pydantic model)     │
│  Persisted via       │
│  SQLite if @persist  │
└──────────────────────┘
```

## LLM Provider Dispatch

```
LLM.call(messages, tools)
       │
       v
┌──────────────────────────────┐
│  Detect provider from model  │
│  string prefix               │
└──────┬───────────────────────┘
       │
       ├── gpt-/o1-/o3-/o4- ────────> _call_openai()
       ├── claude- ──────────────────> _call_anthropic()
       ├── gemini/ ──────────────────> _call_gemini()
       ├── azure/ ───────────────────> _call_azure()
       ├── bedrock//anthropic./meta. > _call_bedrock()
       └── (anything else) ─────────> _call_litellm()
               │
               v
       ┌────────────────────────┐
       │  Emit events:          │
       │  LLMCallStartedEvent   │
       │  LLMStreamChunkEvent   │
       │  LLMCallCompletedEvent │
       │  LLMCallFailedEvent    │
       └────────────────────────┘
```

## Memory Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                    ContextualMemory                           │
│  build_context_for_task(task, context)                        │
│  - Queries all memory types                                   │
│  - Combines results into context string                       │
└───────┬──────────┬──────────┬──────────┬──────────────────────┘
        │          │          │          │
        v          v          v          v
┌────────────┐ ┌────────────┐ ┌───────────┐ ┌───────────────┐
│ Short-Term │ │ Long-Term  │ │ Entity    │ │   External    │
│ Memory     │ │ Memory     │ │ Memory    │ │   Memory      │
│            │ │            │ │           │ │               │
│ ChromaDB   │ │ SQLite3    │ │ ChromaDB  │ │ User-provided │
│ RAG search │ │ Task-based │ │ Entity    │ │ Storage impl  │
│ Per-exec   │ │ Cross-sess │ │ tracking  │ │               │
└────────────┘ └────────────┘ └───────────┘ └───────────────┘
```

## Knowledge Architecture

```
┌─────────────────────────────────────────────────┐
│                  Knowledge                      │
│  query(queries, results_limit, score_threshold) │
└────────┬────────────────────────────────────────┘
         │
         v
┌────────────────────────────────────────────────┐
│            KnowledgeStorage                    │
│  Wraps RAG storage (ChromaDB or Qdrant)        │
└────────┬───────────────────────────────────────┘
         │
         v
┌─────────────────────────────────────────────────┐
│           Knowledge Sources                     │
│                                                 │
│  StringKnowledgeSource   - raw strings          │
│  TextFileKnowledgeSource - .txt files           │
│  PDFKnowledgeSource      - PDF documents        │
│  CSVKnowledgeSource      - CSV files            │
│  ExcelKnowledgeSource    - .xlsx spreadsheets   │
│  JSONKnowledgeSource     - JSON documents       │
│  CrewDoclingSource       - web URLs             │
│  BaseKnowledgeSource     - custom (extend)      │
└─────────────────────────────────────────────────┘
         │
         v
┌────────────────────────────────────────────────┐
│           Embedding Providers (15+)            │
│  OpenAI, Ollama, Google, Azure, Vertex,        │
│  Cohere, VoyageAI, AWS Bedrock, HuggingFace,   │
│  IBM Watson, Jina, Mem0, ...                   │
└────────────────────────────────────────────────┘
```

## Event System Architecture

```
┌───────────────────────────────────────────────────────────────┐
│              CrewAIEventsBus (Singleton)                      │
│                                                               │
│  emit(source, event) ────> dispatch to handlers               │
│                                                               │
│  ┌─────────────────────┐  ┌──────────────────────────────┐    │
│  │  Sync Handlers      │  │  Async Handlers              │    │
│  │  ThreadPoolExecutor │  │  Dedicated asyncio loop      │    │
│  │  10 workers         │  │  Background daemon thread    │    │
│  └─────────────────────┘  └──────────────────────────────┘    │
│                                                               │
│  Handler Dependencies: build_execution_plan()                 │
│  - Topological sort of handlers via Depends                   │
│  - Same-level handlers run concurrently                       │
│  - Stream chunks always run synchronously                     │
│                                                               │
│  Registration: @crewai_event_bus.on(EventType)                │
│  Cleanup: flush(timeout=30), shutdown() with atexit           │
└───────────────────────────────────────────────────────────────┘
```

## Module Dependency Graph

```
                   ┌──────────┐
                   │ __init__ │
                   └────┬─────┘
        ┌───────────────┼───────────────┬───────────────┐
        v               v               v               v
   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌─────────┐
   │   Crew   │    │  Agent   │    │   Task   │    │   Flow  │
   │ crew.py  │    │ agent/   │    │ task.py  │    │ flow/   │
   └────┬─────┘    └────┬─────┘    └─────┬────┘    └────┬────┘
        │               │                │              │
   ┌────┴────┐     ┌────┴─────┐     ┌────┴──────┐       │
   │ crews/  │     │ agents/  │     │ tasks/    │       │
   │ utils   │     │ executor │     │ cond_task │       │
   │ output  │     │ parser   │     │ output    │       │
   └────┬────┘     │ base_agt │     │ guardrail │       │
        │          └────┬─────┘     └────┬──────┘       │
        │               │                │              │
   ┌────┴───────────────┴────────────────┴──────────────┴────┐
   │                 Shared Infrastructure                   │
   ├─────────────────────────────────────────────────────────┤
   │  events/    - event bus, 40+ event types, listeners     │
   │  llm.py     - LLM router (OpenAI/Anthropic/Gemini/...)  │
   │  llms/      - BaseLLM ABC, native providers             │
   │  tools/     - BaseTool, agent tools, MCP tools          │
   │  memory/    - STM, LTM, Entity, External, Contextual    │
   │  knowledge/ - knowledge sources, vector storage         │
   │  rag/       - embeddings, ChromaDB, Qdrant              │
   │  mcp/       - MCP client, transports (stdio/http/sse)   │
   │  security/  - fingerprinting                            │
   │  hooks/     - LLM hooks, tool hooks                     │
   │  utilities/ - i18n, prompts, converter, streaming, ...  │
   │  a2a/       - Agent-to-Agent protocol                   │
   │  project/   - declarative annotations, CrewBase         │
   │  cli/       - Click CLI commands                        │
   └─────────────────────────────────────────────────────────┘
```

## Design Patterns

| Pattern                  | Where Used                                                                                      |
|--------------------------|-------------------------------------------------------------------------------------------------|
| Strategy                 | Process selection (sequential/hierarchical), LLM provider dispatch, executor mode (ReAct/native)|
| Observer/Pub-Sub         | CrewAIEventsBus with 40+ event types and handler registration                                   |
| Template Method          | BaseAgent.execute_task() abstract, Agent concrete implementation                                |
| Chain of Responsibility  | Guardrails: sequential validation chain with independent retries                                |
| Factory                  | create_llm(), Crew._create_manager_agent(), project scaffolding                                 |
| Singleton                | CrewAIEventsBus: thread-safe double-checked locking                                             |
| Decorator (structural)   | @start, @listen, @router, @agent, @task, @crew, @tool                                           |
| Composite                | ContextualMemory composes 4 memory types                                                        |
| Adapter                  | LangGraph adapter, OpenAI Agents adapter, LangChain tool adapter, MCP tool wrappers             |
| Command                  | Task encapsulates execution parameters, supports replay                                         |
| Mixin                    | FlowTrackable on Crew/Agent, CrewAgentExecutorMixin                                             |
| Proxy                    | CrewStreamingOutput proxies chunks, MCPToolWrapper proxies calls                                |
| State                    | Flow state management driven by decorator graph                                                 |
| Builder                  | Prompts class builds prompts, ContextualMemory builds context                                   |

## Key Abstractions

BaseAgent (ABC):
- execute_task(task, context, tools) ---> str
- create_agent_executor(tools) ---> None
- get_delegation_tools(agents) ---> list[BaseTool]
- get_mcp_tools(mcps) ---> list[BaseTool]

BaseLLM (ABC):
- call(messages, tools, callbacks) ---> str | BaseModel | list
- supports_function_calling() ---> bool
- supports_stop_words() ---> bool
- get_context_window_size() ---> int

BaseTool (ABC):
- _run(**kwargs) ---> Any
- Fields: name, description, args_schema, result_as_answer

BaseEvent:
- event_id, timestamp, type, parent_event_id, emission_sequence

FlowPersistence (ABC):
- save_state(flow_id, method, state) ---> None
- load_state(flow_id) ---> state
