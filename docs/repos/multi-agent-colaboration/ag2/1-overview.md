# AG2

## Info

| Field           | Value                        |
|-----------------|------------------------------|
| repo_link       | https://github.com/ag2ai/ag2 |
| created_at      | 2024-11-11                   |
| number_of_stars | 4113                         |
| analysed_at     | 2026-02-09                   |

## What It Is

AG2 (formerly AutoGen) is an open-source Python framework for building AI agents and facilitating multi-agent conversations. It brands itself as an "Open-Source AgentOS for AI Agents." The framework simplifies orchestration, optimization, and automation of LLM workflows through customizable and conversable agents.

AG2 was forked from Microsoft's AutoGen (v0.2.35) by the original founders (Chi Wang and Qingyun Wu) to continue development under open community governance. The PyPI packages `ag2` and `autogen` are aliases for the same package. Licensed under Apache 2.0.

## Key Features

- Multi-agent conversations with configurable orchestration patterns
- 15+ LLM provider support (OpenAI, Anthropic, Gemini, Bedrock, Cohere, Mistral, Groq, Cerebras, Together, Ollama, DeepSeek, and more)
- Tool use with caller/executor separation pattern
- Human-in-the-loop with three modes (ALWAYS, TERMINATE, NEVER)
- 5 orchestration patterns: two-agent chat, sequential chat, group chat, nested chat, swarm
- Group chat speaker selection: AutoPattern, DefaultPattern, RoundRobinPattern, RandomPattern, ManualPattern
- Code execution via local shell, Docker, Jupyter, Remyx Cloud, YepCode Cloud
- Structured outputs via Pydantic models
- RAG support via DocAgent, Neo4j GraphRAG, FalkorDB GraphRAG
- RealtimeAgent for voice interactions (WebSocket, WebRTC, Twilio)
- A2A (Agent-to-Agent) protocol for distributed agent communication
- AG-UI protocol for streaming agent events to frontend UIs
- MCP (Model Context Protocol) integration
- Interoperability with CrewAI, LangChain, PydanticAI tools
- Pre-built agents: CaptainAgent, DocAgent, ReasoningAgent, WebSurferAgent, DeepResearchAgent
- Pre-built tools: Google Search, YouTube Search, Wikipedia, Browser Use, Crawl4AI
- Caching (disk, Redis, CosmosDB, in-memory)
- Context variables for shared state across agents
- Hook system for dynamic behavior modification

## Core Concepts

- ConversableAgent  - the fundamental building block; every agent extends this class
- LLMConfig         - declarative configuration for LLM providers with fallback support
- Tools             - extend agent capabilities via function calling with caller/executor separation
- Group Chat        - multi-agent coordination with configurable speaker selection
- Handoffs          - explicit control transfer between agents in group/swarm patterns
- Context Variables - shared mutable state passed between agents
- Code Execution    - sandboxed environments for running agent-generated code
- Events/Messages   - structured typed notifications flowing through IOStream

## Possible Usages

- Financial compliance (transaction monitoring, suspicious activity detection, human approval)
- Customer support (tiered routing, escalation, human handoff)
- Research and deep research (autonomous information gathering and synthesis)
- Content creation pipelines (research, drafting, editing, polishing)
- E-commerce order processing (validation, inventory, payment, fulfillment)
- Healthcare triage and diagnosis systems
- Education (lesson planning with teacher/planner/reviewer agent teams)
- Real-time voice interactions (customer support, virtual assistance)
- Web browsing and data collection
- Distributed agent systems via A2A protocol
- Interactive web UIs via AG-UI protocol
- Code generation and execution with varying human involvement
- Math problem solving and decision making

## History

- Mar 2023   - AutoGen created within Microsoft's FLAML library
- Aug 2023   - AutoGen paper published on arXiv
- Oct 2023   - AutoGen spins off from FLAML as standalone repo under Microsoft
- Nov 2023   - Top trending GitHub repo; mentioned by Satya Nadella
- May 2024   - Best paper award at ICLR 2024 LLM Agents Workshop
- Nov 2024   - Fork to AG2 under open governance (AG2AI organization)
- Current    - Active development with A2A, AG-UI, pattern cookbook, reference agents

## Documentation Files

| File                   | Description                                                |
|------------------------|------------------------------------------------------------|
| 1-overview.md          | Project overview, features, core concepts, use cases       |
| 2-technical.md         | Tech stack, dependencies, installation, configuration      |
| 3-architecture.md      | Folder structure, design patterns, data flow, diagrams     |
| 4-code-patterns.md     | Coding style, testing, CI/CD, conventions                  |
| 5-usage-and-examples.md| How to use, code examples, common workflows                |
