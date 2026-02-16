# ChatDev (DevAll)

## Info

| Field           | Value                                |
|-----------------|--------------------------------------|
| repo_link       | https://github.com/OpenBMB/ChatDev   |
| created_at      | 2023-08-28                           |
| number_of_stars | 30630                                |
| analysed_at     | 2026-02-09                           |

## What It Is

ChatDev 2.0 (branded "DevAll") is a zero-code multi-agent orchestration platform developed by OpenBMB/THUNLP at Tsinghua University. It enables users to build, configure, and execute customized multi-agent systems entirely through YAML configuration and a visual Web UI -- no programming required. Users define agents, workflows, tools, and tasks to orchestrate complex scenarios spanning data visualization, 3D generation, game development, deep research, and educational video creation.

DevAll is the evolution of ChatDev 1.0, which was a "virtual software company" where LLM-based agents (CEO, CTO, Programmer, Tester) collaborated through role-playing to automate the software development lifecycle. Version 2.0 generalizes that concept into a universal multi-agent platform that can tackle any domain through configurable workflow graphs.

## Purpose and Goals

- Democratize multi-agent system construction by eliminating the need to write code
- Provide a flexible orchestration engine supporting simple linear pipelines and complex cyclic/nested graphs
- Offer a modular, extensible architecture where new node types, LLM providers, tools, and memory backends can be plugged in
- Support human-in-the-loop workflows where humans can review, approve, or redirect agent outputs
- Ship production-ready workflow templates for common use cases

## Key Features

- Zero-code workflow authoring via YAML configuration and a visual Web UI (Vue 3 + Vite)
- Multiple node types: Agent (LLM), Python (script execution), Human (human-in-the-loop), Subgraph (nested workflows), Passthrough, Literal, Loop Counter
- Multi-provider LLM support: OpenAI, Gemini, and any OpenAI-compatible API with per-node configuration
- Advanced graph execution engine supporting DAGs (topological sort + parallel layers) and cyclic graphs (Tarjan SCC detection, super-node construction)
- Dynamic parallel execution with Map (fan-out) and Tree (fan-out + hierarchical reduce) modes
- Conditional edges with keyword matching, regex extraction, and custom function evaluators
- Edge payload processors for transforming or filtering messages between nodes
- Memory system with three store types: Simple (FAISS vector + semantic rerank), File (document chunking + vector index), Blackboard (append-only recency log)
- Tooling system supporting Python function calling and MCP (Model Context Protocol) integration (remote HTTP and local stdio)
- Thinking/reasoning module with chain-of-thought and self-reflection modes
- Real-time observability via WebSocket streaming of node states, stdout/stderr, and artifact events
- Session-based run isolation with downloadable artifacts stored under WareHouse/<session>/
- Python SDK for programmatic/batch workflow execution
- Built-in retry strategy with configurable backoff and status code filtering
- Variable system with ${VAR} placeholders, .env file support, and priority-based resolution

## Core Concepts

| Concept              | Description                                                                                                                   |
|----------------------|-------------------------------------------------------------------------------------------------------------------------------|
| Workflow / Graph     | Top-level execution unit defined in YAML with version, vars, and graph (nodes, edges, start/end)                              |
| Node                 | Building block of a workflow; has a type and config. Types: agent, python, human, subgraph, passthrough, literal, loop_counter|
| Edge                 | Directed connection defining data flow and execution order; supports conditions, triggers, processors, dynamic configs        |
| Provider             | LLM API backend (OpenAI, Gemini, etc.) configured per-node with base_url, api_key, model, params                              |
| Memory               | Persistence and retrieval system for agent nodes. Stores: Simple (FAISS), File (chunked docs), Blackboard (append-only)       |
| Tooling              | External function/service calling. Two modes: Function (Python with auto-generated JSON schema) and MCP                       |
| Thinking             | Reasoning enhancement module supporting chain-of-thought and self-reflection                                                  |
| Session              | Isolated execution instance with unique ID; artifacts stored under WareHouse/<session>/                                       |
| Dynamic Execution    | Edge-level parallel processing; Map (fan-out) and Tree (fan-out + reduce)                                                     |
| Cycle Execution      | Handles loops via Tarjan's SCC algorithm; abstracts cycles into super-nodes forming a DAG                                     |

## Possible Use Cases

- Data Visualization         - upload CSV/Excel and have agents generate charts with analysis
- 3D Generation              - agents generate Blender scripts to create 3D models (requires Blender + blender-mcp)
- Game Development           - multi-agent software development for games (design, code, test)
- Deep Research              - automated multi-step research with web searching and synthesis
- Educational Video          - agents produce teaching videos using Manim animation library
- Content Creation Pipelines - article writing with human review loops, translation, multi-stage editing
- Document Processing        - long document summarization using Tree mode, document Q&A with File memory
- API Orchestration          - agents calling external APIs through function tooling or MCP servers
- RAG                        - agent nodes combined with File or Simple memory stores for knowledge-grounded generation
- Batch Processing           - Map mode for parallel item processing (translation, dataset analysis)

## License

Apache License, Version 2.0. Copyright 2025 OpenBMB.

## Documentation Files

| File                    | Description                                               |
|-------------------------|-----------------------------------------------------------|
| 1-overview.md           | Project overview, purpose, features, core concepts        |
| 2-technical.md          | Tech stack, dependencies, installation, configuration     |
| 3-architecture.md       | Folder structure, entry points, design patterns, diagrams |
| 4-code-patterns.md      | Coding style, testing, CI/CD, conventions                 |
| 5-usage-and-examples.md | How to use, CLI/SDK/server, example workflows             |
