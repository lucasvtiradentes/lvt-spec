# por-marketplace

## Info

| Field           | Value                                        |
|-----------------|----------------------------------------------|
| repo_link       | https://github.com/lfnovo/por-marketplace    |
| created_at      | 2025-12-15                                   |
| number_of_stars | 6                                            |
| analysed_at     | 2026-02-08                                   |

## What It Is

por-marketplace is a Claude Code plugin marketplace that provides structured development workflows following the "Product on Rails" (POR) methodology. It is authored by Luis Novo and licensed under MIT.

The project is not a traditional codebase with runtime code. It is a collection of markdown-based command definitions that extend Claude Code (Anthropic's CLI agent) with opinionated, multi-step workflows for software development. The sole plugin currently available is `por-dev` (v1.1.0).

The core purpose is to enforce a methodical, plan-before-code approach: thorough requirements gathering, architecture design, task breakdown, and phased implementation -- all driven through slash commands inside Claude Code sessions.

## Key Features

The plugin provides two workflow tracks:

Complete Workflow (complex features):
- `/prime`     - Bootstraps agent context by reading project structure, README, and docs
- `/discover`  - Creates a feature specification from requirements (natural language, file, or PM card via MCP)
- `/design`    - Transforms spec into technical architecture with research and codebase analysis
- `/plan`      - Breaks architecture into phased, trackable implementation tasks
- `/implement` - Executes the plan step-by-step (supports `--ff` fast-forward and `--phases` phased modes)

Fast Track (simple tasks):
- `/fast:bug`     - Surgical bug-fix plan with root cause analysis and validation commands
- `/fast:feature` - Lightweight feature plan with phased implementation
- `/fast:chore`   - Maintenance task plan

Utility Commands:
- `/all-tools`               - Lists all available Claude Code tools in the current session
- `/generate-all-claude-mds` - Generates CLAUDE.md documentation files throughout the codebase

## Core Concepts

- Marketplace/Plugin system   - `.claude-plugin/marketplace.json` at root, `.claude-plugin/plugin.json` per plugin
- Slash commands              - each `.md` file in `commands/` defines a Claude Code slash command with YAML frontmatter
- Specs directory convention  - all planning artifacts stored in `specs/` within the target project
- Phased implementation       - tasks organized into phases with dependency tracking and `[P]` parallel markers
- Progressive refinement      - discover (WHAT) ---> design (HOW) ---> plan (TASKS) ---> implement (DO)
- `$ARGUMENTS` placeholder    - template variable replaced with user input at invocation time

## Possible Usages

| Scenario                  | Workflow                                                               |
|---------------------------|------------------------------------------------------------------------|
| Simple bug fix            | `/prime` ---> `/fast:bug` ---> `/implement`                            |
| Dependency upgrade        | `/prime` ---> `/fast:chore` ---> `/implement`                          |
| Small UI feature          | `/prime` ---> `/fast:feature` ---> `/implement`                        |
| New API endpoint          | `/prime` ---> `/discover` ---> `/design` ---> `/plan` ---> `/implement`|
| Codebase documentation    | `/generate-all-claude-mds`                                             |
| Audit available tools     | `/all-tools`                                                           |

## Target Audience

- Developers using Claude Code who want structured, repeatable workflows instead of ad-hoc prompting
- Teams following the POR methodology or similar plan-first development approaches
- Individual developers wanting to reduce rework by enforcing requirements analysis before implementation
- Teams wanting consistent documentation artifacts (specs, architecture docs, task plans) as a byproduct

## Documentation Files

| File                                                | Description                                        |
|-----------------------------------------------------|----------------------------------------------------|
| [1-overview.md](./1-overview.md)                    | Project purpose, features, core concepts, usages   |
| [2-technical.md](./2-technical.md)                  | Tech stack, dependencies, installation, config     |
| [3-architecture.md](./3-architecture.md)            | Folder structure, entry points, design patterns    |
| [4-code-patterns.md](./4-code-patterns.md)          | Coding style, testing, CI/CD, conventions          |
| [5-usage-and-examples.md](./5-usage-and-examples.md)| How to use, examples, common workflows             |
