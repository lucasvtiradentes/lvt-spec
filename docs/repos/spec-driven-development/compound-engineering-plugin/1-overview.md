# Compound Engineering Plugin

## Info

| Field            | Value                                                          |
|------------------|----------------------------------------------------------------|
| repo_link        | https://github.com/EveryInc/compound-engineering-plugin        |
| created_at       | 2025-10-09                                                     |
| number_of_stars  | 7557                                                           |
| analysed_at      | 2026-02-08                                                     |

## What It Is

A dual-purpose repository by Every, Inc. (author: Kieran Klaassen) that combines:

1. A Claude Code plugin marketplace - hosts and distributes plugins for Anthropic's Claude Code CLI tool, following the plugin marketplace specification with a `marketplace.json` catalog and individual plugin directories under `plugins/`.

2. A Bun/TypeScript CLI tool (npm: `@every-env/compound-plugin`, v0.2.0) that converts Claude Code plugins into formats compatible with OpenCode and OpenAI Codex. It parses Claude Code's plugin structure (agents, commands, skills, hooks, MCP servers) and transpiles them into equivalent structures for target platforms.

## Core Philosophy

The name comes from "compound engineering" - the idea that each unit of engineering work should make subsequent work easier, not harder. This inverts typical software entropy where codebases grow more complex over time. Instead, the system captures learnings, documents solutions, and codifies patterns so they compound and accelerate future development cycles.

The central workflow follows: Plan ---> Work ---> Review ---> Compound ---> Repeat.

## Features

CLI Tool:
- `install`  - fetch a plugin (from local path, GitHub, or marketplace), parse, convert, and write to target config directory
- `convert`  - convert a local Claude Code plugin directory into OpenCode or Codex format
- `sync`     - sync personal Claude Code configuration (~/.claude/) to OpenCode or Codex, including skills (as symlinks) and MCP servers
- `list`     - list available plugins in the local plugins/ directory
- Multi-target output via `--also` flag
- Permission mapping modes: "none", "broad", or "from-commands"
- Temperature inference from agent names (review agents get 0.1, planning get 0.2, creative get 0.6)
- Model normalization (short names to provider-prefixed names)
- Hook event mapping between platforms

Compound Engineering Plugin (v2.30.0):
- 29 specialized AI agents across 5 categories (review, research, design, workflow, docs)
- 25 slash commands including a full engineering workflow (plan, work, review, compound)
- 16 skills covering architecture patterns, code style guides, knowledge management, multi-agent orchestration, image generation, browser automation
- 1 MCP server integration (Context7 for framework documentation lookup)

Coding Tutor Plugin (v1.2.1):
- Personalized coding tutorial system with spaced repetition quizzes
- 3 commands (`/teach-me`, `/quiz-me`, `/sync-tutorials`) and 1 skill

## Core Concepts

Compound Engineering Workflow:
- `/workflows:plan`      - creates structured implementation plans using parallel research agents
- `/workflows:work`      - executes plans with git branches/worktrees, task tracking, incremental commits
- `/workflows:review`    - multi-agent code review (13+ reviewers in parallel: security, performance, architecture, etc.)
- `/workflows:compound`  - documents solved problems into searchable knowledge base at docs/solutions/
- `/lfg`                 - fully autonomous end-to-end pipeline: plan ---> deepen-plan ---> work ---> review ---> resolve todos ---> test ---> PR
- `/slfg`                - same as /lfg but with swarm mode for parallel execution

Agents:
- Markdown files with YAML frontmatter (name, description, model) and system prompt body
- Organized by category: review, research, design, workflow, docs

Skills:
- Directory-based units containing SKILL.md with frontmatter and optional reference files, scripts, templates
- Provide domain-specific knowledge that agents can load on demand

Commands:
- Markdown files defining slash commands with optional frontmatter (argument-hint, allowed-tools, model)

Multi-Agent Orchestration:
- The orchestrating-swarms skill documents three patterns: Parallel Specialists, Pipeline (sequential with auto-unblocking), and Swarm (self-organizing workers claiming from shared pool)
- Agents communicate via JSON inbox files

Plugin Format Conversion:
- Agents become OpenCode agent files or Codex skills
- Commands become OpenCode command configs or Codex prompts + skills
- Skills are symlinked/copied to target skill directory
- Hooks transpiled to OpenCode plugin event handlers
- MCP servers converted between transport formats
- Claude-specific syntax transformed to target equivalents

## Possible Usages

For Software Teams Using Claude Code:
- Install compound-engineering plugin for a complete AI-assisted engineering workflow
- Use /workflows:plan for thorough feature planning with automated research
- Use /workflows:review for multi-agent code reviews catching security, performance, and architecture issues
- Use /workflows:compound to build searchable knowledge base of solved problems
- Use /lfg for fully autonomous end-to-end feature development

For Teams Using Multiple AI Coding Tools:
- Convert Claude Code plugins to work with OpenCode or Codex
- Sync personal Claude Code skills and MCP servers to other platforms
- Maintain a single plugin source that works across platforms

For Plugin Developers:
- Use the marketplace structure as a template for creating Claude Code plugin marketplaces
- Use the coding-tutor plugin as a reference for building educational plugins

For Code Review:
- Deploy specialized review agents for language-specific reviews (Rails, Python, TypeScript)
- Run security audits, performance checks, architectural validation, data migration verification

For Knowledge Management:
- Build searchable library of solved problems in docs/solutions/
- Cross-reference related issues and solutions
- Surface relevant past solutions during planning

## Documentation Files

| File                                                | Description                                         |
|-----------------------------------------------------|-----------------------------------------------------|
| [2-technical.md](./2-technical.md)                  | tech stack, dependencies, installation, config      |
| [3-architecture.md](./3-architecture.md)            | folder structure, data flow, component diagrams     |
| [4-code-patterns.md](./4-code-patterns.md)          | coding style, testing, CI/CD, conventions           |
| [5-usage-and-examples.md](./5-usage-and-examples.md)| how to use, examples, CLI commands, workflows       |
