# Spec Kit - Architecture

## Folder Structure

```
spec-kit/
├── pyproject.toml                            - Python package definition (v0.0.22)
├── src/
│   └── specify_cli/
│       └── __init__.py                       - entire CLI, single-file monolith (~1370 lines)
├── templates/
│   ├── commands/                             - slash command definitions (9 commands)
│   │   ├── constitution.md                   - /speckit.constitution
│   │   ├── specify.md                        - /speckit.specify
│   │   ├── clarify.md                        - /speckit.clarify
│   │   ├── plan.md                           - /speckit.plan
│   │   ├── tasks.md                          - /speckit.tasks
│   │   ├── checklist.md                      - /speckit.checklist
│   │   ├── analyze.md                        - /speckit.analyze
│   │   ├── implement.md                      - /speckit.implement
│   │   └── taskstoissues.md                  - /speckit.taskstoissues
│   ├── spec-template.md                      - feature spec scaffold
│   ├── plan-template.md                      - implementation plan scaffold
│   ├── tasks-template.md                     - task list scaffold
│   ├── checklist-template.md                 - checklist scaffold
│   ├── agent-file-template.md                - agent context file scaffold
│   └── vscode-settings.json                  - VS Code settings for Copilot
├── scripts/
│   ├── bash/
│   │   ├── common.sh                         - shared functions
│   │   ├── create-new-feature.sh             - branch creation + spec init
│   │   ├── setup-plan.sh                     - plan template copy + path resolution
│   │   ├── check-prerequisites.sh            - validate feature dir + list docs
│   │   └── update-agent-context.sh           - parse plan.md -> update agent configs
│   └── powershell/
│       ├── common.ps1                        - shared functions (PowerShell)
│       ├── create-new-feature.ps1            - branch creation (PowerShell)
│       ├── setup-plan.ps1                    - plan setup (PowerShell)
│       ├── check-prerequisites.ps1           - prerequisites (PowerShell)
│       └── update-agent-context.ps1          - agent context (PowerShell)
├── memory/
│   └── constitution.md                       - project constitution template
├── .github/
│   ├── workflows/
│   │   ├── release.yml                       - auto-release on main push
│   │   ├── lint.yml                          - markdown linting
│   │   ├── docs.yml                          - documentation deploy
│   │   └── scripts/                          - release automation scripts
│   │       ├── get-next-version.sh
│   │       ├── check-release-exists.sh
│   │       ├── create-release-packages.sh    - builds per-agent ZIP packages
│   │       ├── create-release-packages.ps1
│   │       ├── generate-release-notes.sh
│   │       ├── create-github-release.sh
│   │       └── update-version.sh
│   └── CODEOWNERS                            - global owner: @localden
├── docs/                                     - GitHub Pages documentation (DocFX)
├── .devcontainer/                            - Codespaces/devcontainer config
├── media/                                    - logos, screenshots, GIFs
├── AGENTS.md                                 - contributor guide for adding agents
├── README.md                                 - user-facing docs
├── spec-driven.md                            - SDD methodology paper
├── CHANGELOG.md                              - version history
└── .markdownlint-cli2.jsonc                  - markdown linting config
```

## Entry Points

| Entry Point           | File                            | Mechanism                                |
|-----------------------|---------------------------------|------------------------------------------|
| CLI `specify` command | src/specify_cli/__init__.py     | pyproject.toml [project.scripts] mapping |
| `main()` function     | __init__.py (line ~1364)        | calls `app()` (Typer instance)           |
| `init` subcommand     | __init__.py (line ~946)         | @app.command() - primary user entry      |
| `check` subcommand    | __init__.py (line ~1244)        | @app.command() - tool availability       |
| `version` subcommand  | __init__.py (line ~1286)        | @app.command() - version/system info     |
| Release pipeline      | .github/workflows/release.yml   | CI trigger on push to main               |

The CLI bootstraps projects. The real "runtime" is the templates and scripts consumed by AI agents as slash commands.

## High-Level Component Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                        SPEC-KIT ECOSYSTEM                            │
│                                                                      │
│  ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐  │
│  │  Specify CLI     │   │  Template Engine │   │ Release System   │  │
│  │  (Python/Typer)  │   │ (Shell scripts + │   │ (GH Actions +    │  │
│  │                  │   │  MD templates)   │   │  build scripts)  │  │
│  │  - init          │   │                  │   │                  │  │
│  │  - check         │<->│  - commands/*.md │<->│  - Per-agent     │  │
│  │  - version       │   │  - *-template.md │   │    ZIP packages  │  │
│  │                  │   │  - scripts/bash/ │   │  - Version mgmt  │  │
│  └────────┬─────────┘   └────────┬─────────┘   └────────┬─────────┘  │
│           │                      │                      │            │
│           │ downloads            │ installed into       │ produces   │
│           v                      v                      │            │
│  ┌────────┴──────────────────────┴───────┐              │            │
│  │          USER'S PROJECT               │<─────────────┘            │
│  │                                       │                           │
│  │  .specify/ (templates, scripts, mem)  │                           │
│  │  .<agent>/commands/ (slash commands)  │                           │
│  │  specs/###-feature/ (artifacts)       │                           │
│  └───────────────────┬───────────────────┘                           │
│                      │ consumed by                                   │
│                      v                                               │
│  ┌───────────────────┴───────────────────┐                           │
│  │          AI CODING AGENTS             │                           │
│  │  Claude, Gemini, Copilot, Cursor,     │                           │
│  │  Qwen, opencode, Codex, Windsurf,     │                           │
│  │  Kilo Code, Auggie, Roo, CodeBuddy,   │                           │
│  │  Amp, SHAI, Amazon Q, IBM Bob, Qoder  │                           │
│  └───────────────────────────────────────┘                           │
└──────────────────────────────────────────────────────────────────────┘
```

## Two-Phase Architecture

The system operates in two distinct phases:

```
PHASE 1: BOOTSTRAPPING (CLI)          PHASE 2: DEVELOPMENT (AI Agent)
┌──────────────────────────┐          ┌───────────────────────────────────┐
│                          │          │                                   │
│  User runs               │          │  User launches AI agent           │
│  `specify init my-app`   │          │  (e.g., `claude`)                 │
│         │                │          │         │                         │
│         v                │          │         v                         │
│  ┌──────────────┐        │          │  /speckit.constitution            │
│  │ Interactive  │        │          │          │                        │
│  │ prompts      │        │          │          v                        │
│  └──────┬───────┘        │          │  /speckit.specify                 │
│         v                │          │         │                         │
│  ┌──────────────┐        │          │         v                         │   
│  │ GitHub API   │        │          │        /speckit.clarify (optional)│   
│  │ fetch release│        │          │          │                        │   
│  └──────┬───────┘        │          │          v                        │   
│         v                │          │  /speckit.plan                    │
│  ┌──────────────┐        │          │          │                        │
│  │ Extract ZIP  │        │          │          v                        │
│  │ to project   │        │          │  /speckit.tasks                   │
│  └──────┬───────┘        │          │         │                         │
│         v                │          │         v                         │
│  ┌──────────────┐        │          │  /speckit.analyze (optional)      │
│  │ Git init     │        │          │          │                        │
│  └──────────────┘        │          │          v                        │
│                          │          │  /speckit.implement               │
│  PROJECT BOOTSTRAPPED    │          │         │                         │
│                          │          │         v                         │
│                          │          │  WORKING CODE                     │
└──────────────────────────┘          └───────────────────────────────────┘
```

## Data Flow Through Slash Commands

```
/speckit.constitution
    reads:  memory/constitution.md (template)
    writes: memory/constitution.md (filled)
         │
         v
/speckit.specify  <---- user description
    runs:   create-new-feature.sh (creates branch + spec dir)
    reads:  templates/spec-template.md
    writes: specs/###-feature/spec.md
    writes: specs/###-feature/checklists/requirements.md
         │
         v
/speckit.clarify (optional)
    runs:   check-prerequisites.sh --paths-only
    reads:  specs/###-feature/spec.md
    writes: specs/###-feature/spec.md (with clarifications)
         │
         v
/speckit.plan  <---- tech stack description
    runs:   setup-plan.sh (copies plan template)
    runs:   update-agent-context.sh (updates CLAUDE.md/AGENTS.md etc.)
    reads:  specs/###-feature/spec.md, memory/constitution.md
    writes: specs/###-feature/plan.md
    writes: specs/###-feature/research.md
    writes: specs/###-feature/data-model.md
    writes: specs/###-feature/contracts/*
    writes: specs/###-feature/quickstart.md
         │
         v
/speckit.tasks
    runs:   check-prerequisites.sh
    reads:  plan.md, spec.md, data-model.md, contracts/, research.md
    writes: specs/###-feature/tasks.md
         │
         v
/speckit.analyze (optional, read-only)
    runs:   check-prerequisites.sh --require-tasks --include-tasks
    reads:  spec.md, plan.md, tasks.md, constitution.md
    writes: nothing (outputs report to console)
         │
         v
/speckit.checklist (optional)
    runs:   check-prerequisites.sh
    reads:  spec.md, plan.md, tasks.md
    writes: specs/###-feature/checklists/<domain>.md
         │
         v
/speckit.implement
    runs:   check-prerequisites.sh --require-tasks --include-tasks
    reads:  tasks.md, plan.md, data-model.md, contracts/, research.md, quickstart.md
    reads:  specs/###-feature/checklists/*.md (validates completion)
    writes: actual source code (per task execution)
```

## CLI Internal Architecture

```
src/specify_cli/__init__.py
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  Constants                                               │
│  ┌────────────────────────────────────────────────────┐  │
│  │ AGENT_CONFIG  - registry of 17 AI agents           │  │
│  │ BANNER        - ASCII art header                   │  │
│  │ APP_VERSION   - CLI version string                 │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  Classes                                                 │
│  ┌────────────────────────────────────────────────────┐  │   
│  │ StepTracker   - UI progress tree (Rich Tree)       │  │   
│  │ BannerGroup   - custom Typer group for help display│  │   
│  └────────────────────────────────────────────────────┘  │   
│                                                          │
│  Utility Functions                                       │
│  ┌────────────────────────────────────────────────────┐  │
│  │ run_command()                  - subprocess runner │  │
│  │ check_tool()                   - PATH checker      │  │
│  │ merge_json_files()             - deep JSON merge   │  │
│  │ select_with_arrows()           - interactive UI    │  │
│  │ download_template_from_github()- GitHub API fetch  │  │
│  │ download_and_extract_template()- ZIP extract       │  │
│  │ ensure_executable_scripts()    - chmod +x          │  │
│  │ init_git_repo()                - git init wrapper  │  │
│  │ _github_token()                - token resolution  │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  Commands (Typer)                                        │
│  ┌────────────────────────────────────────────────────┐  │
│  │ init()    - primary: scaffold project from release │  │
│  │ check()   - verify installed tools                 │  │
│  │ version() - display version and system info        │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  Entry Point                                             │
│  ┌────────────────────────────────────────────────────┐  │
│  │ main() ---> app() (Typer)                          │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

## Script Dependency Graph

```
common.sh (shared functions: get_repo_root, get_current_branch, etc.)
     ^
     │
     ├──── create-new-feature.sh    (used by /speckit.specify)
     │
     ├──── setup-plan.sh            (used by /speckit.plan)
     │
     ├──── check-prerequisites.sh   (used by /speckit.tasks, .analyze, .implement, .checklist, .clarify)
     │
     └──── update-agent-context.sh  (used by /speckit.plan)
```

## Design Patterns

1. Template Method Pattern - command templates define a fixed algorithm structure with placeholders (`{SCRIPT}`, `{ARGS}`, `__AGENT__`) substituted at release-build time per agent

2. Strategy Pattern (Multi-Agent) - `AGENT_CONFIG` dictionary acts as a strategy registry; same templates produce different outputs per agent through different file extensions, argument formats, and directory structures

3. Pipeline / Sequential Workflow - slash commands form a strict pipeline: constitution --> specify --> clarify --> plan --> tasks --> analyze --> implement. Each stage validates prerequisites from prior stages

4. Observer-like Pattern (StepTracker) - accepts a refresh callback (`attach_refresh(cb)`) and auto-triggers it on every state change; used with Rich's `Live` display for real-time progress

5. Builder Pattern (Release Packages) - `create-release-packages.sh` constructs each package by composing base structure + agent-specific commands + script variant

6. Convention over Configuration - feature branches follow `###-feature-name` naming; spec directories mirror branch names under `specs/`; scripts auto-detect current feature from git branch or `SPECIFY_FEATURE` env var

## Document Dependency Chain

```
constitution.md  (governance root, validated at plan time)
       │
       v
   spec.md       (must exist before plan)
       │
       v
   plan.md       (must exist before tasks)
       │
       v
   tasks.md      (must exist before implement)
```

## Agent-Specific Package Structure

The release system transforms agent-neutral templates into 34 agent-specific packages (17 agents x 2 script types):

```
Template Source                    Agent Package (e.g., Claude)
┌──────────────────────┐          ┌──────────────────────────────┐
│ templates/commands/  │          │   .claude/commands/          │
│   specify.md         │ -------> │   speckit.specify.md         │
│   plan.md            │          │   speckit.plan.md            │
│   tasks.md           │ -------> │   speckit.tasks.md           │
│   implement.md       │          │   speckit.implement.md       │
│   ...                │          │   ...                        │
├──────────────────────┤          ├──────────────────────────────┤
│   templates/         │          │   .specify/templates/        │
│   spec-template.md   │ -------> │   spec-template.md           │
│   plan-template.md   │          │   plan-template.md           │
├──────────────────────┤          ├──────────────────────────────┤
│   scripts/bash/      │          │   .specify/scripts/bash/     │
│   common.sh          │ -------> │   common.sh                  │
│   create-new-feature │          │   create-new-feature.sh      │
├──────────────────────┤          ├──────────────────────────────┤
│   memory/            │          │   .specify/memory/           │
│   constitution.md    │ -------> │   constitution.md            │
└──────────────────────┘          └──────────────────────────────┘
```
