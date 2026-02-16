# Architecture

## Folder Structure

```
por-marketplace/
├── .claude-plugin/
│   └── marketplace.json              - marketplace registry, declares available plugins
├── .gitignore                        - ignores .beta/, .claude, .DS_Store
├── LICENSE                           - MIT License (Luis Novo, 2025)
├── README.md                        - marketplace-level README with installation instructions
└── por-dev/                          - the sole plugin in this marketplace
    ├── .claude-plugin/
    │   └── plugin.json               - plugin manifest (name, version 1.1.0, author)
    ├── README.md                     - comprehensive plugin documentation
    └── commands/                     - all slash commands exposed by the plugin
        ├── prime.md                  - /prime: codebase context priming
        ├── discover.md              - /discover: feature spec extraction
        ├── design.md                - /design: technical architecture design
        ├── plan.md                  - /plan: implementation task breakdown
        ├── implement.md             - /implement: execute the plan
        ├── fast/                    - fast-track commands (shorter workflows)
        │   ├── bug.md               - /fast:bug: surgical bug fix planning
        │   ├── chore.md             - /fast:chore: maintenance task planning
        │   └── feature.md           - /fast:feature: small feature planning
        └── util/                    - utility commands
            ├── all-tools.md         - /all-tools: list available Claude Code tools
            └── generate-all-claude-mds.md - /generate-all-claude-mds: CLAUDE.md generator
```

## Entry Points

This is not a traditional software project with executable code. It is a Claude Code Plugin Marketplace -- a collection of markdown-based prompt templates that Claude Code interprets as slash commands.

| Entry Point          | File                                   | Purpose                                          |
|----------------------|----------------------------------------|--------------------------------------------------|
| Marketplace registry | `.claude-plugin/marketplace.json`      | Claude Code discovers available plugins          |
| Plugin manifest      | `por-dev/.claude-plugin/plugin.json`   | Claude Code registers the `por-dev` plugin       |
| Each `.md` command   | `commands/*.md` and `commands/**/*.md` | Each markdown file becomes a slash command       |

Command registration mechanism:
- Files directly in `commands/` become `/commandname` (e.g., `discover.md` ---> `/discover`)
- Files in subdirectories become `/dirname:filename` (e.g., `fast/bug.md` ---> `/fast:bug`)

## High-Level Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    por-marketplace                          │
│                                                             │
│  ┌───────────────────────┐    ┌──────────────────────────┐  │
│  │  marketplace.json     │    │  por-dev plugin          │  │
│  │  (registry)           │--->│                          │  │
│  └───────────────────────┘    │  ┌────────────────────┐  │  │
│                               │  │  plugin.json       │  │  │
│                               │  │  (manifest v1.1.0) │  │  │
│                               │  └────────────────────┘  │  │
│                               │                          │  │
│                               │  ┌────────────────────┐  │  │
│                               │  │  commands/         │  │  │
│                               │  │  (slash commands)  │  │  │
│                               │  └────────────────────┘  │  │
│                               └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Workflow Pipeline Diagram

```
                  prime
                    |
        +-----------+-----------+
        |                       |
        v                       v
    discover              fast:bug
        |                 fast:chore
        v                 fast:feature
      design                    |
        |                       |
        v                       |
       plan                     |
        |                       |
        +-----------+-----------+
                    |
                    v
                implement
```

## Data Flow Diagram

```
USER INPUT (natural language / file / card reference)
        |
        v
+------------+     reads: git ls-files, README, docs/
|   prime    |     output: agent mental model (no file written)
+-----+------+
      |
      v
+------------+     input: $ARGUMENTS (feature description)
|  discover  |     reads: codebase for context
+-----+------+     writes: specs/<slug>/spec.md
      |            side effect: creates git branch
      v
+------------+     reads: specs/<slug>/spec.md
|   design   |     researches: web, libraries, codebase patterns
+-----+------+     writes: specs/<slug>/architecture.md
      |            writes: specs/<slug>/contracts.md (optional)
      v
+------------+     reads: spec.md + architecture.md + contracts.md
|    plan    |     writes: specs/<slug>/plan.md
+-----+------+
      |
      v
+------------+     reads: plan.md (from any workflow)
| implement  |     executes: code changes per the plan
+------------+     updates: plan.md (marks tasks [x])
                   output: git diff --stat summary
```

For fast-track workflows:

```
+------------+     input: $ARGUMENTS (task description)
|   fast:*   |     reads: README.md, codebase
+-----+------+     writes: specs/<task-name>.md (single flat file)
      |
      v
+------------+
| implement  |     same as above
+------------+
```

## Module Dependency Graph

```
                  prime.md
                     |
        (codebase context required)
                     |
         +-----------+-----------+
         |                       |
         v                       v
    +-----------+         +-----------+
    | discover  |         | fast:bug  |
    | produces: |         | fast:chore|
    | spec.md   |         | fast:feat |
    +-----+-----+         | produces: |
          |               | <name>.md |
          v               +-----+-----+
    +-----------+               |
    | design    |               |
    | requires: |               |
    | spec.md   |               |
    | produces: |               |
    | arch.md   |               |
    | contr.md  |               |
    +-----+-----+               |
          |                     |
          v                     |
    +-----------+               |
    | plan      |               |
    | requires: |               |
    | spec.md   |               |
    | arch.md   |               |
    | produces: |               |
    | plan.md   |               |
    +-----+-----+               |
          |                     |
          +----------+----------+
                     |
                     v
              +-----------+
              | implement |
              | requires: |
              | plan.md   |
              | produces: |
              | code edits|
              +-----------+

Standalone (no dependencies):
  - util/all-tools.md
  - util/generate-all-claude-mds.md
```

## Artifact Schema

All persistence is file-based, using the target project's filesystem:

| Artifact            | Path                          | Created By  | Content                                          |
|---------------------|-------------------------------|-------------|--------------------------------------------------|
| Feature spec        | `specs/<slug>/spec.md`        | `/discover` | User stories, functional reqs, success criteria  |
| Architecture        | `specs/<slug>/architecture.md`| `/design`   | Tech decisions, component structure, data flow   |
| Contracts           | `specs/<slug>/contracts.md`   | `/design`   | API endpoints, data models, validation rules     |
| Implementation plan | `specs/<slug>/plan.md`        | `/plan`     | Phased task list with checkboxes, time estimates |
| Fast-track plan     | `specs/<task-name>.md`        | `/fast:*`   | Single-file plan (bug/chore/feature format)      |

State is tracked via:
- Git branch names (feature branches created by `/discover`)
- Checkbox state in plan.md (`[ ]` vs `[x]`)
- Emoji status markers in plan.md (pending/in-progress/completed)

## Design Patterns

1. Prompt-as-Code       - the entire codebase is markdown files that serve as structured prompts for an LLM
2. Pipeline/Chain       - commands execute in strict sequential pipeline, each output feeds the next
3. Strategy Pattern     - two workflow strategies (complete vs fast track) for different complexity levels
4. Template Method      - each command follows the same structural pattern: check prereqs, research, generate, summarize, chain
5. Convention over Config - command names derived from file paths, no explicit routing needed
