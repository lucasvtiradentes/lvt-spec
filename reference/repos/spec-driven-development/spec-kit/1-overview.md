# Spec Kit

## Info

| Field           | Value                              |
|-----------------|------------------------------------|
| repo_link       | https://github.com/github/spec-kit |
| created_at      | 2025-08-21                         |
| number_of_stars | 68390                              |
| analysed_at     | 2026-02-08                         |

## What It Is

Spec Kit is an open-source toolkit by GitHub that implements Spec-Driven Development (SDD) -- a methodology where specifications are the primary artifact and code is generated from them. Instead of specs serving code, code serves specs.

It has two main components:

1. Specify CLI - a Python CLI tool that bootstraps new projects with the SDD workflow
2. Slash Command Templates - markdown-based command definitions that integrate with 17+ AI coding agents (Claude Code, Gemini CLI, Copilot, Cursor, Codex, etc.)

## Purpose

Replace unstructured "vibe coding" with AI agents by providing a disciplined, multi-step process that produces higher-quality, more predictable results through specifications that constrain and guide LLM behavior at each stage.

## Core Concepts

1. Constitution (`memory/constitution.md`)   - immutable project-level governing principles; all generated specs/plans must comply
2. Feature Specification (`specs/NNN/spec.md`) - structured doc focusing on WHAT and WHY; user scenarios, acceptance criteria, functional requirements
3. Implementation Plan (`specs/NNN/plan.md`)   - bridges spec to implementation with tech stack, architecture decisions, research artifacts
4. Task Breakdown (`specs/NNN/tasks.md`)       - strict checklist with dependency ordering, parallel markers, user story labels
5. Checklists (`specs/NNN/checklists/`)        - "unit tests for requirements" validating spec quality before implementation

## Key Features

CLI Tool (specify):
- `specify init <name>`  - scaffolds a new SDD project from GitHub release templates
- `specify check`        - verifies installed tools (git, AI agents, VS Code)
- `specify version`      - displays CLI and template version info
- supports 17+ AI agents with interactive arrow-key selection UI
- supports both Bash and PowerShell script variants
- GitHub API rate-limit handling with token authentication

Slash Commands (AI Agent Integration):
- `/speckit.constitution` - create/update project governing principles
- `/speckit.specify`      - generate feature specification from natural language
- `/speckit.clarify`      - interactive clarification of ambiguous areas (up to 5 questions)
- `/speckit.plan`         - generate technical implementation plan with research artifacts
- `/speckit.tasks`        - generate dependency-ordered task lists by user story
- `/speckit.implement`    - execute the full task list phase-by-phase
- `/speckit.analyze`      - cross-artifact consistency/quality analysis (read-only)
- `/speckit.checklist`    - generate quality checklists for requirements

Shell Scripts:
- `create-new-feature.sh/ps1`    - creates feature branches with auto-numbering
- `setup-plan.sh/ps1`            - sets up plan artifacts in feature directory
- `check-prerequisites.sh/ps1`   - validates prerequisites before commands run
- `update-agent-context.sh/ps1`  - updates agent-specific context files
- `common.sh/ps1`                - shared utility functions

## Possible Usages

- Greenfield (0-to-1) development with AI-guided spec-plan-task-implement cycle
- Brownfield/legacy modernization with iterative feature addition
- Creative exploration: multiple parallel implementations from the same spec
- Enterprise constrained development with constitutional governance
- Team collaboration via versioned feature branches and PR-based review
- Technology evaluation using the same spec with different tech stacks
- Rapid prototyping from feature description to working code
- Quality assurance via pre-implementation requirement checklists

## Target Audience

- Developers using AI coding agents who want structured workflows
- Product managers/tech leads defining requirements in natural language
- Solo developers wanting SDLC discipline without team overhead
- Enterprise teams needing auditable, governed development processes

## Documentation Files

| File                                                | Description                                       |
|-----------------------------------------------------|---------------------------------------------------|
| [2-technical.md](./2-technical.md)                  | Tech stack, dependencies, installation, config    |
| [3-architecture.md](./3-architecture.md)            | Folder structure, design patterns, data flow      |
| [4-code-patterns.md](./4-code-patterns.md)          | Coding style, testing, CI/CD, conventions         |
| [5-usage-and-examples.md](./5-usage-and-examples.md)| How to use, examples, common workflows            |
