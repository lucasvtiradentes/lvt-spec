# AI Dev Workshop - Overview

## Info

| Field           | Value                                          |
|-----------------|------------------------------------------------|
| repo_link       | https://github.com/lfnovo/ai-dev-workshop      |
| created_at      | 2025-08-20                                     |
| number_of_stars | 22                                             |
| analysed_at     | 2026-02-08                                     |

## What It Is

AI Dev Workshop is a prompt engineering framework called "Product On Rails" created by Supernova Labs, a Brazilian AI consultancy. It provides a complete set of Claude Code and Claude Desktop configurations (agents, slash commands, and prompt templates) that orchestrate an end-to-end AI-assisted software development lifecycle.

This is NOT a code library or application. It is a collection of markdown-based agent definitions, slash commands, and workflow templates designed to be dropped into any repository to enable structured AI-driven product and engineering workflows using Anthropic's Claude.

## Purpose

Enable structured, repeatable AI-assisted development workflows with built-in quality gates, human approval checkpoints, and architectural consistency validation. The framework treats project specifications ("Meta Specs") as a constitutional document that all agents validate against.

## Core Concepts

1. Meta Specs           - Living documents serving as the project "DNA" or "Constitution." They contain business context, strategic intentions, success criteria, and executable instructions. All agents validate work against them.

2. Session-Based Dev    - Each feature branch gets a dedicated `.claude/sessions/<feature_slug>/` folder with intermediate artifacts (`context.md`, `architecture.md`, `plan.md`). Enables session resumption and context persistence.

3. Phased Implementation - Work is broken into ~2-hour phases tracked in `plan.md` with status markers. Enables incremental delivery, human checkpoints, and easy session recovery.

4. Agent Orchestration  - The main Claude Code agent delegates to specialized sub-agents (python-developer, react-developer, test-engineer, code-reviewer) to preserve context window.

5. Human-in-the-Loop    - Explicit approval gates at every phase transition, architecture decision, and PR creation. The AI proposes, the human approves.

## Key Features

- 11 specialized agent definitions (developers, reviewers, testers, researchers, gatekeepers)
- 19 slash commands across 4 categories (product, engineering, metaspecs, repodocs)
- Full engineering pipeline: `/start` --> `/plan` --> `/work` --> `/pre-pr` --> `/pr`
- Full product pipeline: `/collect` --> `/refine` --> `/spec` --> `/architecture` --> `/check`
- Multi-repo ecosystem documentation generation
- Architecture Decision Records (ADR) extraction
- Linear integration for project management
- Claude Desktop product manager agent prompt
- MCP server integration guidance (Context7, Perplexity, Code Expert, GitHub)

## Possible Usages

1. Bootstrap AI-assisted dev workflows - Drop the `.claude/` folder into any repo for structured AI workflows
2. Consistent product requirements     - Use product commands for validated, structured requirements
3. Automated pre-PR quality gates      - Run metaspec validation, code review, docs, and test planning at once
4. Multi-repo ecosystem documentation  - Generate per-repo docs, consolidate into summaries, build ecosystem architecture views
5. Feature development from scratch    - Full pipeline from requirements through delivered PR with traceability
6. Onboarding new developers           - Generated documentation gives rapid context about any project
7. Architecture decision tracking      - Automatically extract and maintain ADRs from existing codebases

## Target Audience

- Development teams adopting Claude Code / Claude Desktop
- AI consultancies and agencies delivering AI-powered products
- Product managers working with AI for requirements management
- Engineering teams in startups using AI agents as force multipliers
- Teams managing multi-repo / microservice architectures
- Portuguese-speaking development teams (prompts are in Brazilian Portuguese)

## Documentation Index

| File                    | Description                                                    |
|-------------------------|----------------------------------------------------------------|
| 1-overview.md           | Project purpose, features, core concepts, possible usages      |
| 2-technical.md          | Tech stack, dependencies, installation, configuration          |
| 3-architecture.md       | Folder structure, design patterns, data flow, ASCII diagrams   |
| 4-code-patterns.md      | Coding style, prompt patterns, testing, conventions            |
| 5-usage-and-examples.md | How to use, workflows, CLI commands, agent usage, MCP setup    |
