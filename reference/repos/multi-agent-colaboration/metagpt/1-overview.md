# MetaGPT

## Info

| Field           | Value                                        |
|-----------------|----------------------------------------------|
| repo_link       | https://github.com/FoundationAgents/MetaGPT  |
| created_at      | 2023-06-30                                   |
| number_of_stars | 64043                                        |
| analysed_at     | 2026-02-09                                   |

## What It Is

MetaGPT is an open-source multi-agent framework (v1.0.0, MIT licensed) that simulates an entire software company by assigning distinct professional roles to LLM-powered agents. Its core philosophy is "Code = SOP(Team)" -- it materializes Standard Operating Procedures and applies them to teams composed of LLMs. Given a single natural-language requirement (e.g., "Create a 2048 game"), MetaGPT orchestrates a complete software development lifecycle through collaborating agents (Product Manager, Architect, Project Manager, Engineer, QA Engineer, Data Analyst, Team Leader) that communicate via a structured message-passing environment, ultimately producing a working code repository with all associated documents (PRDs, system designs, task breakdowns, tests).

Developed by DeepWisdom (authored by Alexander Wu), backed by peer-reviewed research (published at ICLR 2024, with AFlow receiving an oral at ICLR 2025). The commercial product is called MGX (MetaGPT X).

## Key Features

1. Software Company Simulation   - simulates a full company with defined roles and SOPs, takes a one-line requirement and outputs user stories, competitive analysis, requirements, data structures, APIs, docs, and working code
2. Multi-Agent Orchestration      - roles communicate via publish/subscribe message system through an Environment; TeamLeader manages delegation; supports concurrent role execution via asyncio
3. Multiple React Modes           - REACT (LLM-driven think-act loop), BY_ORDER (sequential), PLAN_AND_ACT (plan first, then execute)
4. Built-in Professional Roles    - ProductManager, Architect, ProjectManager, Engineer/Engineer2, QaEngineer, DataAnalyst, DataInterpreter, Researcher, TeamLeader, TutorialAssistant, InvoiceOCRAssistant, Sales, CustomerService
5. Data Interpreter               - dedicated role for data analysis/ML, writes and executes code in Jupyter notebooks, supports tool recommendation
6. Researcher                     - automated web research agent with three-phase pipeline: collect links, browse and summarize, produce report
7. Advanced Reasoning             - Tree of Thought (BFS, DFS, MCTS solvers), Planner with task decomposition and topological sorting, human-in-the-loop review
8. Memory System                  - short-term (in-memory), long-term (persistent with FAISS similarity search), working memory, RoleZero memory, brain memory
9. RAG Pipeline                   - full RAG with engines, retrievers, rankers, parsers; supports FAISS, Elasticsearch, Chroma; BM25 retrieval; cohere/colbert/flag-embedding reranking
10. Tool System                   - tool registry with decorator-based registration, BM25-based tool recommendation; built-in: Browser, Editor, Terminal, Deployer, CodeReview, Git, search engines, TTS
11. Multi-LLM Provider Support   - OpenAI, Azure, Anthropic Claude, Google Gemini, Ollama, ZhipuAI, Baidu Qianfan, Alibaba DashScope, iFlytek Spark, AWS Bedrock, Ark, OpenRouter, Human Provider
12. Serialization and Recovery    - full state serialization/deserialization of teams, roles, and context; project recovery; git-based archiving
13. Experience Pool               - caching and retrieval of past experiences with scorers and judges
14. Subscription System           - SubscriptionRunner for long-running trigger-based agent workflows
15. Budget Management             - built-in CostManager tracks API usage costs with configurable budget

## Core Concepts

- Role       - the fundamental agent building block; has name, profile, goal, constraints, and a set of Actions; observes messages, thinks, and acts
- RoleZero   - advanced dynamic base role with broader toolset (Editor, Browser, Terminal), tool recommendation, experience retrieval
- Action     - atomic unit of work; has a name, LLM, and run() method; can use ActionNodes for structured output
- ActionNode - structured output schema definition; generates Pydantic model classes from schemas for LLM output extraction
- Environment - shared space where roles live and communicate; hosts roles, maintains address mapping, runs roles concurrently
- MGXEnv     - default environment with TeamLeader as message router; supports direct chat and public/private modes
- Message    - communication primitive carrying content, routing metadata (sent_from, send_to, cause_by), and role field
- Team       - top-level orchestrator; has an Environment, hires Roles, manages budget, runs project through rounds
- Context    - global config and state container holding Config, CostManager, and shared state
- Memory     - stores messages with action-based indexing; LongTermMemory adds persistent storage with similarity-based dedup
- Plan/Task  - plan is a sequence of tasks toward a goal; tasks have dependencies and are topologically sorted

## Possible Usages

- Software Development       - generate entire projects from a one-line requirement, incremental development, automated code review/testing/debugging
- Data Science and Analysis   - automated EDA with DataInterpreter, ML pipelines, interactive data analysis in notebook style
- Research                    - automated web research with Researcher role, competitive analysis, market research
- Content Generation          - tutorial writing, novel writing, teaching plan generation
- Business Operations         - invoice OCR processing, customer service automation, sales conversations
- Game Environments           - Werewolf game simulation, Minecraft agent interaction, Stanford Town social simulation
- Mobile Automation           - Android assistant for mobile app interaction
- Document Processing         - RAG-powered question answering over documents
- Custom Agent Workflows      - build custom multi-agent systems, subscription-based pipelines, human-in-the-loop workflows

## How It Differs From Other Frameworks

- SOP-driven design             - explicitly models Standard Operating Procedures rather than generic agent loops, reducing hallucination
- Multi-role specialization     - assigns specialized roles with domain-specific prompts/actions/constraints instead of interchangeable agents
- Structured artifact production - produces intermediate artifacts (PRDs, system designs, task lists) before generating code
- Message-based pub/sub         - roles communicate through a structured Environment with explicit routing, not free-form chains
- Built-in software engineering - deep git integration, project repo structures, code review, testing lifecycle
- Human-in-the-loop             - supports human review at plan, task, and code levels; HumanProvider allows human to act as LLM
- Budget and cost management    - built-in CostManager with configurable budget; stops execution when exceeded
- Academic rigor                - backed by ICLR publications, implements ReAct, Tree of Thought, Plan-and-Act
- Dynamic orchestration (MGX)   - TeamLeader dynamically delegates tasks to specialized roles

## Target Audience

- AI/ML engineers building multi-agent systems
- Software developers wanting to automate parts of the SDLC
- Data scientists seeking automated analysis pipelines
- Researchers studying multi-agent collaboration
- Startups and teams wanting to prototype software ideas rapidly
- Hobbyists experimenting with LLM-powered code generation

## Documentation Files

| File                     | Description                                                    |
|--------------------------|----------------------------------------------------------------|
| 1-overview.md            | project purpose, features, core concepts, usages               |
| 2-technical.md           | tech stack, dependencies, installation, configuration          |
| 3-architecture.md        | folder structure, entry points, design patterns, data flow     |
| 4-code-patterns.md       | coding style, testing, CI/CD, conventions, error handling      |
| 5-usage-and-examples.md  | how to use, CLI, Python API, examples, common workflows        |
