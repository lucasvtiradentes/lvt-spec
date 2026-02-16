# MetaGPT - Architecture

## High-Level Component Diagram

```
┌────────────────────────────────────────────────────────────────────────┐
│                              CLI / API                                 │
│                        (software_company.py)                           │
└──────────────────────────────┬─────────────────────────────────────────┘
                               |
                               v
┌───────────────────────────────────────────────────────────────────────┐
│                              Team                                     │
│                           (team.py)                                   │
│  - hire(roles)  - invest(budget)  - run(n_round, idea)                │
└──────────────────────────────┬────────────────────────────────────────┘
                               |
                               v
┌────────────────────────────────────────────────────────────────────────┐
│                     Environment / MGXEnv                               │
│                  (base_env.py / mgx_env.py)                            │
│  - add_roles()  - publish_message()  - run()  - is_idle                │
│                                                                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐                │
│  │TeamLeader│  │ProductMgr│  │ Architect│  │ Engineer2│  ...           │
│  │  (Mike)  │  │  (Alice) │  │  (Bob)   │  │  (Alex)  │                │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘                │
│       ^              ^              ^              ^                   │
│       |              |              |              |                   │
│       +---------- Messages (pub/sub) -------------+                    │
└──────────────────────────────┬─────────────────────────────────────────┘
                               |
                               v
┌────────────────────────────────────────────────────────────────────────┐
│                        Context / Config                                │
│  - Config (YAML)  - CostManager  - LLM instances                       │
└──────────────────────────────┬─────────────────────────────────────────┘
                               |
                               v
┌────────────────────────────────────────────────────────────────────────┐
│                        LLM Providers                                   │
│  OpenAI | Azure | Anthropic | Gemini | Ollama | Bedrock | ...          │
└────────────────────────────────────────────────────────────────────────┘
```

## Role Internal Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                          Role                                │
│  name, profile, goal, constraints                            │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │                    RoleContext (rc)                    │  │
│  │  env -------> Environment reference                    │  │
│  │  msg_buffer -> MessageQueue (incoming)                 │  │
│  │  memory -----> Memory (processed messages)             │  │
│  │  working_memory -> Memory (current task scratch)       │  │
│  │  state ------> int (current action index)              │  │
│  │  todo -------> Action (current action to execute)      │  │
│  │  watch ------> set[str] (subscribed Action types)      │  │
│  │  react_mode -> REACT | BY_ORDER | PLAN_AND_ACT         │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                    │
│  │ Action 1 │  │ Action 2 │  │ Action N │                    │
│  └──────────┘  └──────────┘  └──────────┘                    │
│                                                              │
│  run() ---> _observe() ---> react() ---> publish_message()   │
│                  |                                           │
│                  v                                           │
│             _think() <-----> _act()                          │
│                                |                             │
│                                v                             │
│                         Action.run() ---> LLM.aask()         │
└──────────────────────────────────────────────────────────────┘
```

## Folder Structure

```
metagpt/
├── __init__.py
├── software_company.py    - CLI entry point (Typer app), generate_repo()
├── team.py                - Team orchestrator: hire, invest, run
├── context.py             - Global Context: Config + CostManager + shared state
├── context_mixin.py       - ContextMixin: provides config/llm/context to Role and Action
├── config2.py             - Config class: loads and merges YAML configs
├── schema.py              - Message, Plan, Task, Document, and other data models
├── const.py               - Constants: paths, defaults, route addresses
├── llm.py                 - LLM factory function
├── logs.py                - Loguru configuration
├── subscription.py        - SubscriptionRunner for event-driven workflows
│
├── actions/               - all Action classes (atomic units of work)
│   ├── action.py          - base Action class
│   ├── action_node.py     - ActionNode: structured output extraction
│   ├── add_requirement.py - UserRequirement action
│   ├── write_prd.py       - WritePRD action
│   ├── design_api.py      - WriteDesign action
│   ├── write_code.py      - WriteCode action
│   ├── write_code_review.py - WriteCodeReview action
│   ├── write_test.py      - WriteTest action
│   ├── run_code.py        - RunCode action
│   ├── debug_error.py     - DebugError action
│   ├── summarize_code.py  - SummarizeCode action
│   ├── research.py        - CollectLinks, WebBrowseAndSummarize, ConductResearch
│   ├── search_and_summarize.py - SearchAndSummarize, SearchEnhancedQA
│   └── di/                - data interpreter actions
│       ├── write_plan.py  - WritePlan
│       ├── execute_nb_code.py - ExecuteNbCode
│       └── run_command.py - RunCommand
│
├── roles/                 - all Role classes (agents)
│   ├── role.py            - base Role class, RoleReactMode enum
│   ├── product_manager.py - ProductManager (Alice)
│   ├── architect.py       - Architect (Bob)
│   ├── project_manager.py - ProjectManager (Eve)
│   ├── engineer.py        - Engineer (legacy)
│   ├── qa_engineer.py     - QaEngineer (Edward)
│   ├── researcher.py      - Researcher
│   ├── tutorial_assistant.py - TutorialAssistant
│   ├── invoice_ocr_assistant.py - InvoiceOCRAssistant
│   └── di/                - data intelligence roles
│       ├── role_zero.py   - RoleZero: dynamic agent with tools
│       ├── team_leader.py - TeamLeader (Mike)
│       ├── data_interpreter.py - DataInterpreter
│       ├── data_analyst.py - DataAnalyst (David)
│       ├── engineer2.py   - Engineer2 (Alex)
│       └── swe_agent.py   - SWEAgent
│
├── environment/           - environments that host roles
│   ├── base_env.py        - base Environment class
│   ├── mgx/               - MGXEnv: TeamLeader-coordinated environment
│   ├── software/          - SoftwareEnv
│   ├── android/           - Android device environment
│   ├── minecraft/         - Minecraft environment
│   ├── stanford_town/     - Stanford Town simulation
│   ├── werewolf/          - Werewolf game environment
│   └── api/               - Read/Write API registries for environments
│
├── provider/              - LLM provider implementations
│   ├── base_llm.py        - BaseLLM abstract class
│   ├── llm_provider_registry.py - provider registry + factory
│   ├── openai_api.py      - OpenAI provider
│   ├── azure_openai_api.py - Azure OpenAI
│   ├── anthropic_api.py   - Anthropic Claude
│   ├── google_gemini_api.py - Google Gemini
│   ├── ollama_api.py      - Ollama (local models)
│   ├── bedrock_api.py     - AWS Bedrock
│   ├── dashscope_api.py   - Alibaba DashScope
│   ├── qianfan_api.py     - Baidu Qianfan
│   ├── spark_api.py       - iFlytek Spark
│   ├── zhipuai_api.py     - ZhipuAI
│   ├── ark_api.py         - Volcengine Ark
│   ├── human_provider.py  - Human-in-the-loop provider
│   └── postprocess/       - LLM output post-processing
│
├── configs/               - Pydantic config models per feature
│   ├── llm_config.py      - LLMConfig, LLMType enum
│   ├── browser_config.py  - BrowserConfig
│   ├── embedding_config.py - EmbeddingConfig
│   ├── search_config.py   - SearchConfig
│   ├── mermaid_config.py  - MermaidConfig
│   ├── redis_config.py    - RedisConfig
│   ├── s3_config.py       - S3Config
│   └── workspace_config.py - WorkspaceConfig
│
├── memory/                - memory implementations
│   ├── memory.py          - Memory: short-term in-memory storage
│   ├── longterm_memory.py - LongTermMemory: FAISS-backed persistent
│   ├── memory_storage.py  - MemoryStorage: persistence layer
│   ├── brain_memory.py    - BrainMemory
│   └── role_zero_memory.py - RoleZeroLongTermMemory
│
├── tools/                 - tool subsystem
│   ├── tool_registry.py   - ToolRegistry, @register_tool decorator
│   ├── tool_recommend.py  - BM25-based tool recommendation
│   ├── tool_data_type.py  - tool data models
│   └── libs/              - built-in tool implementations
│       ├── browser.py     - Browser tool (Playwright)
│       ├── editor.py      - Editor tool (file editing)
│       ├── terminal.py    - Terminal tool (shell commands)
│       ├── deployer.py    - Deployer tool
│       ├── cr.py          - CodeReview tool
│       ├── git.py         - Git operations tool
│       ├── gpt_v.py       - GPT Vision tool
│       └── web_scraping.py - Web scraping tool
│
├── strategy/              - planning strategies
│   ├── planner.py         - Planner: task decomposition, plan lifecycle
│   ├── tot.py             - Tree of Thought
│   ├── tot_schema.py      - ToT data schemas
│   └── experience_retriever.py - experience retrieval
│
├── rag/                   - RAG pipeline
│   ├── engines/           - RAG engines (SimpleEngine)
│   ├── retrievers/        - retriever implementations
│   ├── rankers/           - ranker implementations
│   ├── parsers/           - document parsers
│   └── factories/         - factory methods for RAG components
│
├── exp_pool/              - experience pool system
│   ├── manager.py         - ExperiencePoolManager
│   ├── context_builders.py - context building for experiences
│   ├── serializers.py     - experience serialization
│   └── scorers.py         - experience scoring
│
├── ext/                   - extensions
│   ├── aflow/             - AFlow: workflow generation
│   ├── sela/              - SELA
│   ├── spo/               - SPO: Self-Play Optimization
│   ├── cr/                - code review extension
│   ├── android_assistant/ - Android assistant
│   ├── stanford_town/     - Stanford Town extension
│   └── werewolf/          - Werewolf game extension
│
├── prompts/               - prompt templates by role/action
├── utils/                 - shared utilities
│   ├── common.py          - general utilities, NoMoneyException
│   ├── cost_manager.py    - CostManager: token/cost tracking
│   ├── git_repository.py  - GitRepository wrapper
│   ├── project_repo.py    - ProjectRepo: project file management
│   ├── yaml_model.py      - YamlModel base class
│   ├── token_counter.py   - token counting utilities
│   ├── serialize.py       - serialization helpers
│   ├── exceptions.py      - @handle_exception decorator
│   └── singleton.py       - Singleton metaclass
│
├── document_store/        - vector store integrations
│   ├── faiss_store.py     - FAISS
│   ├── chromadb_store.py  - ChromaDB
│   ├── milvus_store.py    - Milvus
│   ├── qdrant_store.py    - Qdrant
│   └── lancedb_store.py   - LanceDB
│
├── learn/                 - learned skill integrations
├── management/            - management utilities
└── skills/                - Semantic Kernel skill templates
```

## Entry Points

### CLI Entry

```
metagpt "Create a 2048 game"
    |
    v
software_company.py:app() ---> Typer CLI
    |
    v
generate_repo(idea, investment, n_round, ...)
    |
    v
Config.default() ---> Context(config) ---> Team(context)
    |
    v
team.hire([TeamLeader, ProductManager, Architect, Engineer2, DataAnalyst])
    |
    v
team.invest(3.0)
    |
    v
asyncio.run(team.run(n_round=5, idea="Create a 2048 game"))
```

### Programmatic Entry

```python
from metagpt.team import Team
from metagpt.roles import ProductManager, Architect, Engineer2

company = Team()
company.hire([ProductManager(), Architect(), Engineer2()])
company.invest(3.0)
await company.run(n_round=5, idea="Create a snake game")
```

## Data Flow - Software Development Lifecycle

```
User Input: "Create a 2048 game"
     |
     v
┌───────────────────────────────────────────────────┐
│ Team.run(idea)                                    │
│   |                                               │
│   v                                               │
│ publish_message(Message(cause_by=UserRequirement))│
└────────────────────┬──────────────────────────────┘
                     |
                     v
┌──────────────────────────────────────────────────┐
│ MGXEnv.run() - Round Loop                        │
│                                                  │
│  ┌───────────────────────────────────────────┐   │
│  │ TeamLeader (Mike)                         │   │
│  │   _observe() <-- user requirement         │   │
│  │   _think()   --> decide delegation        │   │
│  │   _act()     --> send to ProductManager   │   │
│  └──────────────────┬────────────────────────┘   │
│                     |                            │
│                     v                            │
│  ┌───────────────────────────────────────────┐   │
│  │ ProductManager (Alice)                    │   │
│  │   _observe() <-- TeamLeader message       │   │
│  │   _act()     --> WritePRD                 │   │
│  │   publish()  --> PRD document             │   │
│  └──────────────────┬────────────────────────┘   │
│                     |                            │
│                     v                            │
│  ┌───────────────────────────────────────────┐   │
│  │ TeamLeader re-routes PRD to Architect     │   │
│  └──────────────────┬────────────────────────┘   │
│                     |                            │
│                     v                            │
│  ┌───────────────────────────────────────────┐   │
│  │ Architect (Bob)                           │   │
│  │   _observe() <-- PRD message              │   │
│  │   _act()     --> WriteDesign              │   │
│  │   publish()  --> system design + API spec │   │
│  └──────────────────┬────────────────────────┘   │
│                     |                            │
│                     v                            │
│  ┌───────────────────────────────────────────┐   │
│  │ TeamLeader re-routes to Engineer2         │   │
│  └──────────────────┬────────────────────────┘   │
│                     |                            │
│                     v                            │
│  ┌───────────────────────────────────────────┐   │
│  │ Engineer2 (Alex)                          │   │
│  │   _observe() <-- design message           │   │
│  │   _act()     --> WriteCode (via Editor)   │   │
│  │   publish()  --> code files               │   │
│  └───────────────────────────────────────────┘   │
│                                                  │
│  Rounds continue until all roles idle or budget  │
│  exceeded or n_round exhausted                   │
└──────────────────────┬───────────────────────────┘
                       |
                       v
               env.archive() ---> git archive of project
               return project path
```

## Message Routing in MGXEnv

```
┌──────────┐   publish_message()   ┌──────────────┐
│  Role A  │ --------------------> │    MGXEnv    │
└──────────┘                       └──────┬───────┘
                                          |
                                   is_from_tl?
                                     /       \
                                   NO         YES
                                   /            \
                                  v              v
                    ┌─────────────────┐  ┌─────────────────┐
                    │ Route to        │  │ Route directly  │
                    │ TeamLeader      │  │ to send_to      │
                    │ (always sees    │  │ target roles    │
                    │  all messages)  │  └─────────────────┘
                    └────────┬─────────────────────────────┘
                             |
                             v
                    ┌─────────────────┐
                    │ TeamLeader      │
                    │ decides who     │
                    │ should receive  │
                    │ the message     │
                    └────────┬────────┘
                   |
                   v
          ┌─────────────────┐
          │ Re-publish with │
          │ explicit send_to│
          └─────────────────┘
```

## Role Execution Lifecycle

```
role.run()
    |
    v
_observe()
    |  pop messages from msg_buffer
    |  filter by: cause_by in rc.watch OR self.name in send_to
    |  store in rc.memory
    |
    v
react() --- selects strategy based on rc.react_mode
    |
    |--- REACT mode:
    |       loop up to max_react_loop:
    |           _think() --> LLM selects action from available states
    |           _act()   --> execute selected action
    |           if no more todo: break
    |
    |--- BY_ORDER mode:
    |       for each action in order:
    |           state++ --> set todo to actions[state]
    |           _act()  --> execute action
    |
    |--- PLAN_AND_ACT mode:
    |       _plan_and_act()
    |           Planner.create_plan() --> LLM creates task list
    |           for each task:
    |               _act_on_task(task) --> execute
    |               Planner.review_task() --> check result
    |
    v
publish_message(response)
    |  wrap result in Message with cause_by and send_to
    |  env.publish_message()
    |
    v
return response
```

## Module Dependency Graph

```
software_company.py
    |
    v
team.py ---------> environment/base_env.py
    |                      |
    |                      v
    |              environment/mgx/mgx_env.py
    |
    +------------> context.py ---------> config2.py
    |                  |                     |
    |                  v                     v
    |           utils/cost_manager.py   configs/*.py
    |
    +------------> roles/role.py
                       |
                       +---------> actions/action.py
                       |               |
                       |               v
                       |         actions/action_node.py
                       |               |
                       |               v
                       |         provider/base_llm.py
                       |               |
                       |               v
                       |         provider/openai_api.py
                       |         provider/anthropic_api.py
                       |         provider/google_gemini_api.py
                       |         provider/ollama_api.py
                       |         provider/... (others)
                       |
                       +---------> memory/memory.py
                       |
                       +---------> schema.py (Message, Plan, Task)
                       |
                       +---------> context_mixin.py
                       |
                       +---------> strategy/planner.py
                       |
                       v
                 roles/di/role_zero.py
                       |
                       +---------> tools/tool_registry.py
                       +---------> tools/tool_recommend.py
                       +---------> tools/libs/*.py
                       +---------> memory/role_zero_memory.py
```

## Design Patterns

| Pattern              | Where Used                                                                          |
|----------------------|-------------------------------------------------------------------------------------|
| Observer (Pub/Sub)   | roles watch Action types; Environment distributes messages to matching subscribers  |
| Mediator             | Environment (and MGXEnv + TeamLeader) mediates all role communication               |
| Strategy             | RoleReactMode selects among REACT / BY_ORDER / PLAN_AND_ACT strategies              |
| Template Method      | Role.run() defines skeleton: _observe -> react -> publish; subclasses override steps|
| Factory              | LLMProviderRegistry.create_llm_instance() creates provider from config              |
| Registry             | ToolRegistry for tools, LLMProviderRegistry for providers, API registries for envs  |
| Chain of Resp.       | MGXEnv message routing: Role -> MGXEnv -> TeamLeader -> MGXEnv -> target Role       |
| Command              | RoleZero parses LLM output into command dicts dispatched to tool_execution_map      |
| Decorator            | @handle_exception, @retry, @register_tool, @serialize_decorator, @exp_cache         |
| Mixin                | ContextMixin provides config/llm/context to Role and Action via multiple inheritance|
| Serialization        | SerializationMixin provides serialize()/deserialize() for JSON persistence          |
| Singleton            | Singleton metaclass in utils/singleton.py                                           |
