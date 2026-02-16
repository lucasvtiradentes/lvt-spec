# AI Dev Workshop - Architecture

## Folder Structure

```
ai-dev-workshop/
├── .gitignore                              - ignores .DS_Store and claude-logs
├── README.md                               - main documentation with full workflow explanation
├── MCPs.md                                 - MCP server reference guide
├── CLAUDE.md.example                       - template for per-project AI behavior config
│
├── claude-desktop/
│   └── product-agent.md                    - system prompt for Claude Desktop product agent
│
└── .claude/
    ├── agents/                             - sub-agent prompt definitions (11 agents)
    │   ├── python-developer.md             - Python coding specialist (sonnet)
    │   ├── react-developer.md              - React/shadcn/ui specialist (sonnet)
    │   ├── code-reviewer.md                - general code reviewer (opus)
    │   ├── test-engineer.md                - test writer (sonnet)
    │   ├── test-planner.md                 - full-codebase test coverage analyst
    │   ├── research-agent.md               - multi-source research specialist (sonnet)
    │   ├── metaspec-gate-keeper.md         - architectural consistency guardian (sonnet)
    │   ├── branch-code-reviewer.md         - branch-scoped code reviewer (opus)
    │   ├── branch-test-planner.md          - branch-scoped test coverage analyst
    │   ├── branch-documentation-writer.md  - branch-scoped documentation updater
    │   └── branch-metaspec-checker.md      - branch-scoped metaspec alignment checker
    │
    └── commands/                           - slash command definitions (4 categories)
        ├── engineer/                       - engineering workflow (8 commands)
        │   ├── start.md                    - initialize feature dev
        │   ├── plan.md                     - create phased implementation plan
        │   ├── work.md                     - execute current plan phase
        │   ├── pre-pr.md                   - run 4 quality-check agents
        │   ├── pr.md                       - create PR, handle review
        │   ├── bump.md                     - version bump in pyproject.toml
        │   ├── warm-up.md                  - load project context
        │   └── docs.md                     - invoke documentation agent
        │
        ├── product/                        - product management (6 commands)
        │   ├── warm-up.md                  - load metaspecs + README
        │   ├── collect.md                  - quick issue capture to Linear
        │   ├── refine.md                   - refine requirements (WHY/WHAT/HOW)
        │   ├── spec.md                     - full PRD specification
        │   ├── architecture.md             - feature architecture design
        │   └── check.md                    - validate against metaspecs
        │
        ├── metaspecs/                      - documentation generation (6 commands)
        │   ├── build-index.md              - build/rebuild project index
        │   ├── build-tech-docs.md          - generate technical docs
        │   ├── build-business-docs.md      - generate business docs
        │   ├── build-repo-summary.md       - summarize repo for metaspecs
        │   ├── extract-adr-from-repo-docs.md       - extract ADRs
        │   └── extract-ecosystem-architecture.md   - multi-repo architecture
        │
        └── repodocs/
            └── generate-docs.md            - generate ai_docs/ per repo
```

## Entry Points

| Type               | Mechanism                                             | Purpose                                    |
|--------------------|-------------------------------------------------------|--------------------------------------------|
| Engineering flow   | `/start`, `/plan`, `/work`, `/pre-pr`, `/pr`          | Full feature development lifecycle         |
| Product flow       | `/collect`, `/refine`, `/spec`, `/architecture`       | Requirements to PRD to architecture        |
| Documentation flow | `/repodocs/generate-docs`, `/metaspecs/build-*`       | Generate and maintain project docs         |
| Session warm-up    | `/warm-up` (engineer and product variants)            | Load project context into agent memory     |
| Claude Desktop     | `claude-desktop/product-agent.md`                     | System prompt for non-CLI product managers |
| CLAUDE.md          | `CLAUDE.md.example`                                   | Template for per-project AI behavior       |

## Design Patterns

### Orchestrator / Sub-Agent Pattern

The central Claude Code agent delegates specialized work to sub-agents. Each sub-agent has a dedicated prompt under `.claude/agents/` with metadata (name, model, tools, color). The orchestrator preserves context window by offloading heavy tasks.

```
┌─────────────────────────────────────────────────────┐
│          Main Orchestrator (Claude Code)            │
│                                                     │
│ Reads commands, manages workflow, delegates tasks   │
└───────┬──────────┬──────────┬──────────┬────────────┘
        |          |          |          |
        v          v          v          v
┌─────────────┐ ┌─────────────┐ ┌────────────┐ ┌────────────┐
│   python    │ │   react     │ │  test      │ │   code     │
│   developer │ │   developer │ │  engineer  │ │   reviewer │
│   (sonnet)  │ │   (sonnet)  │ │  (sonnet)  │ │   (opus)   │
└─────────────┘ └─────────────┘ └────────────┘ └────────────┘
```

### Pipeline / Chain Pattern

Both engineering and product workflows define explicit ordered pipelines where each step produces artifacts consumed by the next.

```
Engineering Pipeline:
┌───────┐    ┌──────┐    ┌──────┐    ┌────────┐    ┌────┐
│ start │--->│ plan │--->│ work │--->│ pre-pr │--->│ pr │
└───────┘    └──────┘    └──────┘    └────────┘    └────┘
    |            |           |            |            |
    v            v           v            v            v
context.md   plan.md    code+tests   qa reports   GitHub PR
arch.md

Product Pipeline:
┌─────────┐    ┌────────┐    ┌──────┐    ┌──────────────┐    ┌───────┐
│ collect │--->│ refine │--->│ spec │--->│ architecture │--->│ check │
└─────────┘    └────────┘    └──────┘    └──────────────┘    └───────┘
     |              |            |              |                  |
     v              v            v              v                  v
Linear issue   WHY/WHAT/HOW   Full PRD    Design doc       Alignment report
```

### Gate / Guardian Pattern

Metaspec gate-keeper and branch-metaspec-checker agents act as architectural guards. They verify implementations conform to the project "constitution" and can block PRs if violations are found.

### Scoped Variants Pattern

Several agents exist in two variants:
- Global:        analyzes entire codebase (`code-reviewer`, `test-planner`)
- Branch-scoped: analyzes only `git diff origin/main...HEAD` (`branch-code-reviewer`, `branch-test-planner`)

### Session State via Filesystem

Feature development state persists in `.claude/sessions/<feature_slug>/` with files serving as resumable checkpoints.

## High-Level Component Diagram

```
┌────────────────────────────────────────────────────────────────────┐
│                       USER INTERFACE LAYER                         │
│                                                                    │
│  ┌───────────────────┐             ┌────────────────────────────┐  │
│  │    Claude Code    │             │      Claude Desktop        │  │
│  │   (CLI / IDE)     │             │    (Web / App UI)          │  │
│  └────────┬──────────┘             └──────────┬─────────────────┘  │
└───────────|────────────────────────────────────|───────────────────┘
            |                                    |
            v                                    v
┌─────────────────────────────────────────────────────────────────────┐
│                    COMMAND LAYER (Orchestration)                    │
│                                                                     │
│  ┌──────────────┐ ┌──────────────┐ ┌─────────────┐ ┌─────────────┐  │
│  │  engineer/   │ │  product/    │ │  metaspecs/ │ │  repodocs/  │  │
│  │  8 commands  │ │  6 commands  │ │  6 commands │ │  1 command  │  │
│  └──────┬───────┘ └──────┬───────┘ └──────┬──────┘ └──────┬──────┘  │
└─────────|────────────────|───────────────|───────────────|──────────┘
          |                  |                 |             |
          v                  v                 v             v
┌────────────────────────────────────────────────────────────────────┐
│                      AGENT LAYER (Specialists)                     │
│                                                                    │
│  ┌─────────────────┐ ┌──────────────────┐ ┌───────────────────┐    │
│  │ Dev Agents      │ │ Review Agents    │ │ Analysis Agents   │    │
│  │                 │ │                  │ │                   │    │
│  │ python-dev      │ │ code-reviewer    │ │ test-planner      │    │
│  │ react-dev       │ │ branch-reviewer  │ │ branch-test-plan  │    │
│  │                 │ │ branch-metaspec  │ │ metaspec-keeper   │    │
│  │                 │ │ branch-docs      │ │ research-agent    │    │
│  │                 │ │                  │ │ test-engineer     │    │
│  └─────────────────┘ └──────────────────┘ └───────────────────┘    │
└────────────────────────────────────────────────────────────────────┘
          |                  |                 |
          v                  v                 v
┌────────────────────────────────────────────────────────────────────┐
│                     ARTIFACT LAYER (Outputs)                       │
│                                                                    │
│  ┌──────────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Session Files    │  │  ai_docs/    │  │ Meta Specs           │  │
│  │ context.md       │  │  stack.md    │  │ (External Docs)      │  │
│  │ architecture.md  │  │  patterns.md │  │ Business context     │  │
│  │ plan.md          │  │  features.md │  │ Strategic intent     │  │
│  │                  │  │  gotchas.md  │  │ Success criteria     │  │
│  └──────────────────┘  └──────────────┘  └──────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
          |                  |                 |
          v                  v                 v
┌─────────────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES LAYER                              │
│                                                                         │
│  ┌──────────┐ ┌──────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐ │
│  │  GitHub  │ │  Linear  │ │  Context7  │ │ Perplexity │ │ Code Exprt │ │
│  │ (gh CLI) │ │  (SaaS)  │ │   (MCP)    │ │   (MCP)    │ │   (MCP)    │ │
│  └──────────┘ └──────────┘ └────────────┘ └────────────┘ └────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

## Engineering Workflow Data Flow

```
User: /start <feature>
      |
      v
[1] Branch setup + session folder creation
      |
      v
[2] Read Linear card / requirements
      |
      v
[3] Q&A with user ---> context.md
      |
      v
[4] Architecture proposal ---> architecture.md
      |
      v
User: /plan
      |
      v
[5] Read context.md + architecture.md ---> plan.md (phased)
      |
      v
User: /work <session-folder>
      |
      v
[6] Read plan.md, find current phase
      |
      v
[7] Delegate to sub-agents:
      |
      +---> python-developer (coding)
      +---> react-developer (coding)
      +---> test-engineer (tests)
      +---> code-reviewer (review)
      |
      v
[8] User validates each phase ---> update plan.md
      |
      v
User: /pre-pr
      |
      v
[9] Run 4 branch agents in sequence:
      |
      +---> branch-metaspec-checker  (alignment)
      +---> branch-code-reviewer     (quality)
      +---> branch-documentation-writer (docs)
      +---> branch-test-planner      (coverage)
      |
      v
[10] Main agent processes feedback, applies fixes
      |
      v
User: /pr
      |
      v
[11] Run tests ---> commit ---> move Linear card ---> create PR (gh)
      |
      v
[12] Wait for automated review comments ---> address them ---> push
      |
      v
[13] Notify user: PR ready for manual merge
```

## Product Workflow Data Flow

```
User: /collect <idea>
      |
      v
[1] Clarify ---> save to Linear as issue
      |
      v
User: /refine <requirement>
      |
      v
[2] Q&A ---> WHY/WHAT/HOW document
      |
      v
User: /spec <requirement>
      |
      v
[3] Full PRD: personas, functional reqs, non-functional reqs, risks
      |
      v
User: /architecture <feature>
      |
      v
[4] Architecture: components, trade-offs, diagrams
      |
      v
User: /check <feature>
      |
      v
[5] Validate against metaspecs ---> alignment / misalignment report
```

## Documentation Workflow Data Flow

```
Single-Repo:
┌───────────────────────┐  ┌────────────────────┐  ┌──────────────┐
│ /build-tech-docs      │->│ Technical docs     │->│              │
└───────────────────────┘  └────────────────────┘  │              │
                                                   │ /build-index │
┌───────────────────────┐  ┌────────────────────┐  │              │
│ /build-business-docs  │->│ Business docs      │->│              │
└───────────────────────┘  └────────────────────┘  └──────────────┘

Multi-Repo:
┌──────────────────┐     ┌──────────┐     ┌─────────────────────┐
│ /generate-docs   │---->│ ai_docs/ │---->│ /build-repo-summary │
│ (per each repo)  │     │ per repo │     │ (per each repo)     │
└──────────────────┘     └──────────┘     └─────────┬───────────┘
                                                    |
                                                    v
                                          ┌─────────────────────────┐
                                          │ technical/<repo>.md     │
                                          │ (in metaspecs repo)     │
                                          └─────────┬───────────────┘
                                                    |
                                                    v
                              ┌──────────────────────────────────────┐
                              │ /extract-ecosystem-architecture      │
                              │                                      │
                              │ Produces:                            │
                              │  meta/architecture/ (system views)   │
                              │  meta/adr/ (decision records)        │
                              └──────────────────────────────────────┘
```

## Agent Dependency Map

```
Main Orchestrator (Claude Code)
|
|--- /start, /plan (direct execution, no sub-agents)
|
|--- /work
|       |--- python-developer (coding)
|       |--- react-developer (coding)
|       |--- code-reviewer (review after coding)
|       |--- test-engineer (write tests)
|
|--- /pre-pr
|       |--- branch-metaspec-checker (metaspec alignment)
|       |--- branch-code-reviewer (branch code quality)
|       |--- branch-documentation-writer (update docs)
|       |--- branch-test-planner (test coverage gaps)
|
|--- /check, /architecture
|       |--- metaspec-gate-keeper (validate against metaspecs)
|
|--- research-agent (invoked ad-hoc for library research)
|
|--- test-planner (invoked for full-codebase analysis)
```

## Artifact Dependency Chain

```
┌───────────────────┐
│ CLAUDE.md.example │
│ (behavior config) │
└────────┬──────────┘
         | configures
         v
┌──────────────────────┐   ┌─────────────────────┐
│   Meta Specs         │<--│ metaspec-keeper     │
│ (external docs)      │<--│ branch-checker      │
│                      │<--│ /check, /spec       │
└──────────────────────┘   └─────────────────────┘

┌──────────────────────────────────┐
│  .claude/sessions/<feature>/     │
│                                  │
│  context.md -----> /plan, /work  │
│  architecture.md -> /plan, /work │
│  plan.md --------> /work         │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│ ai_docs/ (per-repo)              │
│                                  │
│ consumed by /build-repo-summary  │
│ ----> technical/<repo>.md        │
│ ----> /extract-ecosystem-arch    │
└──────────────────────────────────┘
```
