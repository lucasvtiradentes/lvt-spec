# AG2 - Architecture

## Folder Structure

```
autogen/
├── __init__.py                     - main package entry, re-exports core classes
├── version.py                      - package version
├── code_utils.py                   - legacy code execution utilities
├── doc_utils.py                    - documentation/export utilities
├── exception_utils.py              - custom exceptions
├── function_utils.py               - function introspection
├── formatting_utils.py             - output formatting
├── graph_utils.py                  - graph validation for speaker transitions
├── import_utils.py                 - optional import handling
├── json_utils.py                   - JSON utilities
├── math_utils.py                   - math utilities
├── runtime_logging.py              - runtime logging facade
├── token_count_utils.py            - token counting
├── types.py                        - shared type definitions
├── retrieve_utils.py               - RAG retrieval utilities
├── browser_utils.py                - browser interaction
│
├── agentchat/                      - CORE: agent system and conversation orchestration
│   ├── agent.py                    - Agent + LLMAgent protocols (abstract interfaces)
│   ├── conversable_agent.py        - ConversableAgent (4659 lines, central class)
│   ├── assistant_agent.py          - AssistantAgent (LLM-focused preset)
│   ├── user_proxy_agent.py         - UserProxyAgent (human/code-execution preset)
│   ├── groupchat.py                - GroupChat dataclass + GroupChatManager agent
│   ├── chat.py                     - ChatResult, initiate_chats, multi-chat orchestration
│   ├── utils.py                    - usage summary, chat info consolidation
│   ├── group/                      - new multi-agent orchestration (swarm-style)
│   │   ├── context_variables.py    - ContextVariables shared state
│   │   ├── on_condition.py         - declarative handoff conditions
│   │   ├── handoffs.py             - agent transition rules
│   │   ├── guardrails.py           - input/output validation
│   │   ├── reply_result.py         - structured reply from group
│   │   ├── multi_agent_chat.py     - run_group_chat orchestrator
│   │   ├── patterns/               - pre-built conversation patterns
│   │   ├── targets/                - transition targets (AgentTarget, TerminateTarget, etc.)
│   │   └── safeguards/             - safeguard implementations
│   ├── contrib/                    - community-contributed agents
│   │   ├── swarm_agent.py          - swarm orchestration
│   │   ├── gpt_assistant_agent.py  - OpenAI Assistants API
│   │   ├── web_surfer.py           - web browsing agent
│   │   ├── captainagent/           - meta-agent (auto-builds teams)
│   │   ├── capabilities/           - transform messages, teachability
│   │   ├── graph_rag/              - graph-based RAG
│   │   ├── rag/                    - RAG agents
│   │   └── vectordb/               - vector database integrations
│   ├── remote/                     - remote agent execution
│   └── realtime/                   - real-time voice/streaming agents
│
├── oai/                            - LLM client layer (multi-provider)
│   ├── client.py                   - OpenAIWrapper unified client (1666 lines)
│   ├── openai_utils.py             - config list helpers
│   ├── openai_responses.py         - OpenAI Responses API
│   ├── anthropic.py                - Anthropic client
│   ├── bedrock.py                  - AWS Bedrock client
│   ├── cerebras.py                 - Cerebras client
│   ├── cohere.py                   - Cohere client
│   ├── gemini.py                   - Google Gemini client
│   ├── groq.py                     - Groq client
│   ├── mistral.py                  - Mistral client
│   ├── ollama.py                   - Ollama client
│   └── together.py                 - Together AI client
│
├── llm_config/                     - LLM configuration system
│   ├── config.py                   - LLMConfig class
│   ├── client.py                   - ModelClient protocol
│   ├── entry.py                    - LLMConfigEntry per provider
│   └── utils.py                    - config list from JSON, filtering
│
├── llm_clients/                    - next-gen LLM client system (v2)
│   ├── client_v2.py                - ModelClientV2 protocol
│   ├── openai_completions_client.py - OpenAI Chat Completions v2
│   └── models/                     - UnifiedResponse, content blocks
│
├── coding/                         - code execution system
│   ├── base.py                     - CodeBlock, CodeResult, CodeExecutor protocol
│   ├── factory.py                  - CodeExecutorFactory
│   ├── local_commandline_code_executor.py  - local shell executor
│   ├── docker_commandline_code_executor.py - Docker executor
│   ├── yepcode_code_executor.py    - YepCode cloud executor
│   ├── remyx_code_executor.py      - Remyx executor
│   ├── markdown_code_extractor.py  - extract code from markdown
│   └── jupyter/                    - Jupyter kernel execution
│
├── tools/                          - tool system (function calling)
│   ├── tool.py                     - Tool class wrapping callables
│   ├── toolkit.py                  - Toolkit collection of tools
│   ├── dependency_injection.py     - BaseContext, ChatContext, Depends
│   ├── function_utils.py           - JSON schema generation from functions
│   ├── contrib/                    - contributed tools
│   └── experimental/               - experimental tools
│
├── mcp/                            - Model Context Protocol integration
│   ├── mcp_client.py              - MCP client (SSE, stdio, streamable HTTP)
│   ├── helpers.py                  - MCP helper utilities
│   └── mcp_proxy/                  - MCP proxy server
│
├── events/                         - event system (structured IO/streaming)
│   ├── base_event.py              - BaseEvent, wrap_event decorator, registry
│   ├── agent_events.py            - 50+ agent lifecycle events
│   └── client_events.py           - LLM client events
│
├── messages/                       - message system (parallel to events)
│   ├── base_message.py            - BaseMessage, wrap_message decorator
│   ├── agent_messages.py          - agent message types
│   └── client_messages.py         - client message types
│
├── io/                             - input/output stream system
│   ├── base.py                    - IOStream, protocols
│   ├── console.py                 - IOConsole (terminal)
│   ├── websockets.py              - IOWebsockets
│   ├── thread_io_stream.py        - thread-safe IO
│   ├── run_response.py            - RunResponse streaming wrapper
│   └── step_controller.py         - StepController for run_iter
│
├── cache/                          - caching system
│   ├── abstract_cache_base.py     - AbstractCache interface
│   ├── cache.py                   - Cache unified facade
│   ├── disk_cache.py              - DiskCache
│   ├── in_memory_cache.py         - InMemoryCache
│   ├── redis_cache.py             - RedisCache
│   └── cosmos_db_cache.py         - CosmosDB cache
│
├── interop/                        - framework interoperability
│   ├── interoperability.py        - convert tools between frameworks
│   ├── crewai/                    - CrewAI tool conversion
│   ├── langchain/                 - LangChain tool/model conversion
│   ├── litellm/                   - LiteLLM config conversion
│   └── pydantic_ai/               - PydanticAI tool conversion
│
├── a2a/                            - Agent-to-Agent protocol
│   ├── server.py                  - expose agents as A2A servers
│   ├── client.py                  - consume remote A2A agents
│   └── agent_executor.py          - bridge A2A and AG2
│
├── ag_ui/                          - AG-UI protocol (agent UI streaming)
│   ├── adapter.py                 - AGUIStream adapter
│   └── asgi.py                    - ASGI server adapter
│
├── agents/                         - new-style agent definitions
│   ├── contrib/                   - contributed agents
│   └── experimental/              - experimental agents
│
├── environments/                   - code execution environments
│   ├── system_python_environment.py
│   ├── venv_python_environment.py
│   ├── docker_python_environment.py
│   └── working_directory.py
│
├── fast_depends/                   - dependency injection (forked from FastDepends)
│   ├── core/                      - core DI engine
│   ├── dependencies/              - dependency resolution
│   └── use.py                     - Depends, inject decorators
│
├── logger/                         - logging infrastructure
│   ├── file_logger.py             - file-based logger
│   ├── sqlite_logger.py           - SQLite-based logger
│   └── logger_factory.py          - logger factory
│
└── testing/                        - test utilities
    ├── test_agent.py              - test agent helpers
    └── messages.py                - test message helpers
```

## Entry Points

| Method                              | Description                                    |
|-------------------------------------|------------------------------------------------|
| agent.run(message)                  | single-agent run with streaming                |
| agent.initiate_chat(recipient, msg) | two-agent chat                                 |
| agent.initiate_chats([...])         | sequential multi-chat                          |
| run_group_chat(pattern, messages)   | new group chat API with patterns               |
| initiate_swarm_chat(agent, msgs)    | swarm-style orchestration                      |
| GroupChatManager                    | legacy group chat via manager agent            |

## Agent Hierarchy

```
┌──────────────────────────────────────────────────────────┐
│ Agent (Protocol)                                         │
│   name, description, send, receive, generate_reply       │
├──────────────────────────────────────────────────────────┤
│ LLMAgent (Protocol)                                      │
│   + system_message, update_system_message                │
├──────────────────────────────────────────────────────────┤
│ ConversableAgent (class, 4659 lines)                     │
│   THE implementation of all agent behavior               │
│                                                          │
│   ├── AssistantAgent                                     │
│   │   human_input_mode="NEVER", has LLM, no code exec    │
│   │                                                      │
│   ├── UserProxyAgent                                     │
│   │   human_input_mode="ALWAYS", no LLM, code exec on    │
│   │                                                      │
│   ├── GroupChatManager                                   │
│   │   orchestrates multi-agent group conversations       │
│   │                                                      │
│   └── contrib agents                                     │
│       SwarmAgent, GPTAssistantAgent, WebSurfer, etc.     │
└──────────────────────────────────────────────────────────┘
```

## Reply Function Chain (Chain of Responsibility)

ConversableAgent uses an ordered list of reply functions. Each returns `(final: bool, reply)`. When `final=True`, the chain stops.

```
generate_reply() called
        |
        v
┌───────────────────────────────────────────┐
│ 1. check_termination_and_human_reply      │
│    - checks is_termination_msg            │
│    - prompts human based on input_mode    │
├───────────────────────────────────────────┤
│ 2. generate_function_call_reply           │
│    - handles legacy function_call format  │
├───────────────────────────────────────────┤
│ 3. generate_tool_calls_reply              │
│    - executes tool calls from LLM         │
│    - runs safeguard hooks                 │
├───────────────────────────────────────────┤
│ 4. generate_code_execution_reply          │
│    - extracts code blocks from messages   │
│    - executes via CodeExecutor            │
├───────────────────────────────────────────┤
│ 5. generate_oai_reply                     │
│    - calls LLM via OpenAIWrapper          │
│    - runs safeguard hooks                 │
└───────────────────────────────────────────┘
```

## Two-Agent Chat Data Flow

```
User Code
    |
    |  agent_a.initiate_chat(agent_b, message="Hello")
    v
┌─────────────────────┐
│ initiate_chat()     │
│   prepare_chat()    │
│   generate_init_msg │
│   self.send()       │
└────────┬────────────┘
         |
         v
┌─────────────────────┐     ┌─────────────────────┐
│ Agent A             │     │ Agent B             │
│                     │     │                     │
│ send(msg, B) -------+---->│ receive(msg, A)     │
│                     │     │   append to history │
│                     │     │   generate_reply()  │
│                     │     │     |               │
│                     │     │     v               │
│                     │     │   [reply chain]     │
│                     │     │     |               │
│                     │     │     v               │
│ receive(reply, B) <-+-----│ send(reply, A)      │
│   append to history │     │                     │
│   generate_reply()  │     │                     │
│     |               │     │                     │
│     v               │     │                     │
│   [reply chain]     │     │                     │
│     |               │     │                     │
│     v               │     │                     │
│ send(reply, B) -----+---->│ receive(...)        │
│                     │     │                     │
│  ... ping-pong until termination ...            │
└─────────────────────┘     └─────────────────────┘
         |
         v
┌─────────────────────┐
│ _summarize_chat()   │
│ return ChatResult   │
│   chat_history      │
│   summary           │
│   cost              │
└─────────────────────┘
```

## Group Chat Data Flow

```
User Code
    |
    |  user_proxy.initiate_chat(manager, message="Solve this")
    v
┌─────────────────────────────────────────────────────┐
│ GroupChatManager.run_chat()                         │
│                                                     │
│   for each round:                                   │
│     |                                               │
│     ├── groupchat.append(message, speaker)          │
│     |                                               │
│     ├── broadcast to all agents (silent)            │
│     |                                               │
│     ├── check termination                           │
│     |                                               │
│     ├── groupchat.select_speaker()                  │
│     |     |                                         │
│     |     ├── "auto"        ---> LLM picks speaker  │
│     |     ├── "round_robin" ---> next in list       │
│     |     ├── "random"      ---> random.choice      │
│     |     ├── "manual"      ---> human picks        │
│     |     └── callable      ---> custom function    │
│     |                                               │
│     ├── selected_speaker.generate_reply()           │
│     |     |                                         │
│     |     v                                         │
│     |   [full reply chain]                          │
│     |                                               │
│     └── message = reply (next iteration)            │
│                                                     │
│   return ChatResult                                 │
└─────────────────────────────────────────────────────┘
```

## LLM Client Architecture

```
┌────────────────────────┐
│ ConversableAgent       │
│                        │
│ generate_oai_reply()   │
│        |               │
│        v               │
│ ┌──────────────────┐   │
│ │ OpenAIWrapper    │   │
│ │ (oai/client.py)  │   │
│ │                  │   │
│ │ config_list:     │   │
│ │  ├── config[0]   │   │
│ │  ├── config[1]   │   │
│ │  └── config[N]   │   │
│ │                  │   │
│ │ create():        │   │
│ │  try config[0]   │   │
│ │  fallback [1]    │   │
│ │  fallback [N]    │   │
│ └────────┬─────────┘   │
│          |             │
└──────────┼─────────────┘
           |
           v
    ┌──────┴──────────────────────────────────┐
    |                                          |
    v                                          v
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│ OpenAI   │  │ Anthropic│  │ Gemini   │  │ Ollama   │
│ client   │  │ client   │  │ client   │  │ client   │
└──────────┘  └──────────┘  └──────────┘  └──────────┘
    ... and Bedrock, Cerebras, Cohere, Groq,
    Mistral, Together, OpenAI Responses ...
```

## Tool Calling Flow

```
┌──────────────────┐          ┌───────────────────┐
│ AssistantAgent   │          │ ExecutorAgent     │
│ (caller)         │          │ (executor)        │
│                  │          │                   │
│ LLM decides:     │          │ _function_map:    │
│ "call tool X"    │          │   tool_x -> fn()  │
│                  │          │   tool_y -> fn()  │
└────────┬─────────┘          └───────┬───────────┘
         |                            |
         | 1. LLM returns             |
         |    tool_calls              |
         |                            |
         | 2. send(tool_calls_msg)    |
         +--------------------------->|
         |                            |
         |                  3. generate_tool_calls_reply()
         |                     for each tool_call:
         |                       safeguard_tool_inputs()
         |                       lookup in _function_map
         |                       execute_function()
         |                       safeguard_tool_outputs()
         |                            |
         | 4. send(tool_results_msg)  |
         |<---------------------------+
         |                            |
         | 5. LLM processes results   |
         |    continues conversation  |
         |                            |
```

## Module Dependency Graph

```
                    autogen (__init__.py)
                          |
          +---------------+---------------+
          |               |               |
     agentchat/         oai/          llm_config/
          |               |               |
  +-------+-------+      |          config.py
  |       |       |      |          client.py (protocol)
  |  agent.py     |      |          entry.py
  |  (Protocol)   |      |
  |       |       |   client.py (OpenAIWrapper)
  |  conversable_ |      |
  |  agent.py ----+----->+-- anthropic.py
  |    |    |     |      +-- gemini.py
  |    |    |     |      +-- mistral.py
  |    |    |     |      +-- (10+ providers)
  |    |    |     |
  |  assistant_  user_proxy_
  |  agent.py    agent.py
  |    |
  |  groupchat.py
  |    |
  |  group/ (orchestration)
  |    |
  |  contrib/ (specialized agents)
  |
  +-------+-------+-------+-------+
  |       |       |       |       |
coding/ tools/  events/  io/    cache/
  |       |       |       |       |
  |       |       |       |    disk_cache
  |       |       |       |    redis_cache
  |       |       |       |    in_memory
  |       |       |       |    cosmos_db
  |       |       |       |
  +-------+-------+-------+-------+
  |       |       |       |       |
 mcp/  interop/  a2a/  ag_ui/ fast_depends/
```

Key dependency directions:
- agentchat depends on: oai, llm_config, coding, tools, events, io, cache, fast_depends
- oai/client.py depends on: cache, llm_config, events, io
- tools depends on: fast_depends (agentchat only via TYPE_CHECKING)
- mcp depends on: tools (creates Toolkit from MCP server)
- a2a depends on: agentchat (wraps agents as A2A servers/clients)
- ag_ui depends on: agentchat (streams agent events via AG-UI protocol)
- interop depends on: tools (converts external framework tools)
- events and messages are independent (Pydantic models only)
- io depends on: events (OutputStream.send accepts BaseEvent)
- cache is independent

## Event/Message System

```
┌──────────────────────────────────┐
│ BaseEvent (Pydantic ABC)         │
│   uuid: UUID                     │
│   print(f) method                │
└──────────┬───────────────────────┘
           |
    @wrap_event decorator
           |
           v
┌──────────────────────────────────────────────────────────┐
│ Wrapped Event                                            │
│   type: Literal["event_name"]  (discriminator field)     │
│   content: EventClass                                    │
└──────────────────────────────────────────────────────────┘

Events flow through IOStream:
┌───────────────┐     ┌───────────────┐     ┌──────────────────┐
│ Agent action  │---->│ IOStream      │---->│ Consumer         │
│ iostream.send │     │ (pluggable)   │     │ - IOConsole      │
│  (Event)      │     │               │     │ - IOWebsockets   │
│               │     │               │     │ - AGUIStream     │
│               │     │               │     │ - ThreadIOStream │
└───────────────┘     └───────────────┘     └──────────────────┘
```

## Streaming Architecture (run/RunResponse)

```
agent.run(message)
    |
    v
┌──────────────────────────────────────┐
│ Creates ThreadIOStream               │
│ Spawns background thread:            │
│   initiate_chat() with ThreadIO      │
│                                      │
│ Returns RunResponse immediately      │
└──────────┬───────────────────────────┘
           |
           v
┌──────────────────────────────────────┐
│ RunResponse                          │
│   .events / __iter__  - iterate      │
│   .result             - wait + get   │
│   .is_complete        - check done   │
│                                      │
│ Powers:                              │
│   - AG-UI (SSE streaming to frontend)│
│   - A2A (expose as A2A server)       │
│   - WebSocket UIs                    │
└──────────────────────────────────────┘
```

## Code Execution Architecture

```
┌───────────────────────────────────────────────────┐
│ ConversableAgent (code_execution_config enabled)  │
│                                                   │
│ generate_code_execution_reply()                   │
│   |                                               │
│   v                                               │
│ CodeExtractor.extract_code_blocks(message)        │
│   (MarkdownCodeExtractor: parses ``` blocks)      │
│   |                                               │
│   v                                               │
│ CodeExecutor.execute_code_blocks(blocks)          │
│   |                                               │
│   v                                               │
│ CodeResult(exit_code, output)                     │
└───────────────────────────────────────────────────┘

CodeExecutor implementations:
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ LocalCommandLine │  │ DockerCommandLine│  │ Jupyter          │
│   subprocess.run │  │   Docker API     │  │   kernel gateway │
│   temp files     │  │   bind mounts    │  │   rich output    │
└──────────────────┘  └──────────────────┘  └──────────────────┘
┌──────────────────┐  ┌────────────────────────────────────────┐
│ YepCode          │  │ Remyx                                  │
│   cloud API      │  │   remote Docker                        │
└──────────────────┘  └────────────────────────────────────────┘
```
