# CrewAI

## Info

| Field           | Value                                  |
|-----------------|----------------------------------------|
| repo_link       | https://github.com/crewAIInc/crewAI    |
| created_at      | 2023-10-27                             |
| number_of_stars | 43841                                  |
| analysed_at     | 2026-02-09                             |

## What is CrewAI

CrewAI is an open-source Python framework for orchestrating autonomous AI agents into collaborative multi-agent systems. It provides two complementary paradigms: Crews (teams of role-playing agents) and Flows (event-driven workflows). The framework is standalone with zero dependency on LangChain, built from scratch for production use.

Version: 1.9.3
License: MIT
Author: Joao Moura (joao@crewai.com)
Python: >=3.10, <3.14

## Purpose

Complex tasks often benefit from multiple AI "specialists" working together, each with a distinct role, goal, and expertise, rather than relying on a single LLM prompt. CrewAI provides the orchestration, state management, execution control, tool integration, memory, and knowledge infrastructure to make this work in production.

## Core Concepts

1. Agent         - autonomous unit with role, goal, backstory that performs tasks and uses tools
2. Task          - unit of work with description, expected_output, assigned agent, guardrails
3. Crew          - a group of agents + tasks with a process strategy (sequential or hierarchical)
4. Flow          - event-driven workflow with @start, @listen, @router decorators and state management
5. Process       - execution strategy: sequential (tasks in order) or hierarchical (manager delegates)
6. Tool          - capability for agents: 70+ built-in tools, custom tools via @tool or BaseTool
7. Memory        - short-term (ChromaDB), long-term (SQLite), entity (ChromaDB), external (custom)
8. Knowledge     - RAG-based access to external data (string, PDF, CSV, JSON, text, Excel, URLs)
9. LLM           - multi-provider abstraction: OpenAI, Anthropic, Gemini, Azure, Bedrock, Ollama, litellm
10. Guardrail    - validation of task output via callable or LLM-based string description

## Two Paradigms

Crews ("The Intelligence"):
- Natural autonomous decision-making between agents
- Dynamic task delegation and collaboration
- Specialized roles with defined goals and expertise
- Agents communicate like human team members

Flows ("The Backbone"):
- Fine-grained control over execution paths
- Secure consistent state management between tasks
- Clean integration of AI agents with production Python code
- Conditional branching for complex business logic
- Support for Crews as steps within Flows

The recommended production pattern is: use a Flow to define overall structure, state, and logic, then embed Crews within Flow steps when autonomous agent collaboration is needed.

## Key Features

- Dual paradigm: Crews for autonomy + Flows for precision
- Role-playing agent design (role, goal, backstory) for natural collaboration
- 70+ built-in tools (search, scraping, file ops, databases, code execution, RAG)
- Multi-provider LLM support (OpenAI, Anthropic, Gemini, Azure, Bedrock, Ollama)
- Memory system: short-term, long-term, entity, external
- Knowledge system: RAG with ChromaDB/Qdrant for PDF, CSV, JSON, text, etc.
- Task guardrails: callable or LLM-based output validation with retry
- Conditional tasks and async task execution
- Structured output: Pydantic models or JSON schema enforcement
- Streaming output support
- MCP (Model Context Protocol) integration
- A2A (Agent-to-Agent Protocol) for remote agent delegation
- Event system with 40+ event types for observability
- CLI for project scaffolding, execution, training, testing, deployment
- Planning mode: automatic pre-execution task planning
- Reasoning mode: agent reflects and plans before executing
- Human-in-the-loop support for task review
- YAML-based declarative configuration with @CrewBase decorator
- 16+ observability integrations (Langfuse, Datadog, MLflow, etc.)
- Enterprise AMP suite with deployment, tracing, and platform tools

## Possible Use Cases

| Use Case                 | Architecture                                                    |
|--------------------------|-----------------------------------------------------------------|
| Simple Automation        | Single Flow with Python tasks                                   |
| Complex Research         | Flow managing state ---> Crew performing research               |
| Application Backend      | Flow handling API requests ---> Crew generating content ---> DB |
| Content Creation         | Crew with researcher + writer agents, sequential process        |
| Market/Stock Analysis    | Crew with analyst + data agents, hierarchical process           |
| Trip Planning            | Crew with planner + researcher agents                           |
| Email Auto-Responder     | Flow with infinite loop, Crew for email analysis                |
| Lead Scoring             | Flow with human-in-the-loop approval gates                      |
| Book Writing             | Multi-crew pipeline: outline crew ---> chapter crew ---> flow   |
| Code Development/QA      | Crew with developer + reviewer + QA agents                      |
| Document Processing      | Crew with RAG knowledge sources for summarization/extraction    |

## Target Audience

- Python developers building AI-powered applications
- Enterprises needing production-grade multi-agent automation
- Teams building complex workflows requiring multiple AI roles
- Organizations with compliance/security requirements

## Comparison with Alternatives

vs LangChain/LangGraph: CrewAI is fully independent, claims 5.76x faster execution, simpler APIs, no boilerplate. Can still use LangChain tools.

vs AutoGen: AutoGen lacks inherent process concepts. Orchestrating agents requires significant programming. CrewAI provides built-in process types and Flow orchestration.

vs ChatDev: ChatDev introduced process concepts but implementation is rigid and not production-ready. CrewAI offers deep customization.

## Documentation Files

| File                    | Description                                             |
|-------------------------|---------------------------------------------------------|
| 1-overview.md           | Project overview, features, core concepts, use cases    |
| 2-technical.md          | Tech stack, dependencies, installation, configuration   |
| 3-architecture.md       | Folder structure, design patterns, data flow diagrams   |
| 4-code-patterns.md      | Coding style, testing, CI/CD, conventions               |
| 5-usage-and-examples.md | Usage guide, code examples, CLI reference, workflows    |
