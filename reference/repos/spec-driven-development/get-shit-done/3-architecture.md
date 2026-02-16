# Architecture

## High-Level Architecture

GSD is a prompt engineering framework, not a web application. Markdown files ARE the prompts. The system has three layers:

```
┌─────────────────────────────────────────────────────────────────┐
│  Layer 1: COMMANDS (commands/gsd/*.md)                          │
│  Thin entry points. Define slash command metadata.              │
│  Reference a workflow via @.                                    │
├─────────────────────────────────────────────────────────────────┤
│  Layer 2: WORKFLOWS (get-shit-done/workflows/*.md)              │
│  Process definitions. Multi-step orchestration logic.           │
│  Call gsd-tools.js for data ops. Spawn agents via Task().       │
├─────────────────────────────────────────────────────────────────┤
│  Layer 3: AGENTS (agents/gsd-*.md)                              │
│  Autonomous subagent prompts. Each gets fresh 200K context.     │
│  Self-contained role + instructions + success criteria.         │
├─────────────────────────────────────────────────────────────────┤
│  Runtime: gsd-tools.js                                          │
│  Single JS CLI utility. State mgmt, config, git, verification.  │
│  The only imperative code -- everything else is declarative MD. │
└─────────────────────────────────────────────────────────────────┘
```

## Folder Structure

```
get-shit-done/
├── package.json                              - npm package definition, bin entry, scripts
├── package-lock.json                         - lockfile
├── LICENSE                                   - MIT
├── README.md                                 - user-facing docs
├── CHANGELOG.md                              - version history
├── .gitignore                                - ignores node_modules, hooks/dist, .claude/
├── .github/
│   ├── FUNDING.yml                           - GitHub sponsorship config
│   └── pull_request_template.md              - PR template
├── assets/                                   - branding assets (logos, SVGs, PNGs)
│
├── bin/
│   └── install.js                            - MAIN ENTRY POINT (1740 lines)
│                                               interactive/CLI installer for all runtimes
│
├── scripts/
│   └── build-hooks.js                        - prepublishOnly: copies hooks to hooks/dist/
│
├── hooks/
│   ├── gsd-statusline.js                     - Claude Code statusline: model, task, context %
│   ├── gsd-check-update.js                   - SessionStart hook: npm version check
│   └── dist/                                 - (gitignored) built hooks for npm publish
│
├── commands/
│   └── gsd/
│       ├── help.md                           - /gsd:help
│       ├── new-project.md                    - /gsd:new-project
│       ├── map-codebase.md                   - /gsd:map-codebase
│       ├── discuss-phase.md                  - /gsd:discuss-phase
│       ├── research-phase.md                 - /gsd:research-phase
│       ├── list-phase-assumptions.md         - /gsd:list-phase-assumptions
│       ├── plan-phase.md                     - /gsd:plan-phase
│       ├── execute-phase.md                  - /gsd:execute-phase
│       ├── quick.md                          - /gsd:quick
│       ├── progress.md                       - /gsd:progress
│       ├── resume-work.md                    - /gsd:resume-work
│       ├── pause-work.md                     - /gsd:pause-work
│       ├── add-phase.md                      - /gsd:add-phase
│       ├── insert-phase.md                   - /gsd:insert-phase
│       ├── remove-phase.md                   - /gsd:remove-phase
│       ├── add-todo.md                       - /gsd:add-todo
│       ├── check-todos.md                    - /gsd:check-todos
│       ├── verify-work.md                    - /gsd:verify-work
│       ├── audit-milestone.md                - /gsd:audit-milestone
│       ├── plan-milestone-gaps.md            - /gsd:plan-milestone-gaps
│       ├── complete-milestone.md             - /gsd:complete-milestone
│       ├── new-milestone.md                  - /gsd:new-milestone
│       ├── settings.md                       - /gsd:settings
│       ├── set-profile.md                    - /gsd:set-profile
│       ├── debug.md                          - /gsd:debug
│       ├── update.md                         - /gsd:update
│       ├── reapply-patches.md                - /gsd:reapply-patches
│       └── join-discord.md                   - /gsd:join-discord
│
├── agents/
│   ├── gsd-planner.md                        - creates PLAN.md files with task breakdown
│   ├── gsd-executor.md                       - executes plans, atomic commits, SUMMARY.md
│   ├── gsd-roadmapper.md                     - creates ROADMAP.md from requirements
│   ├── gsd-verifier.md                       - goal-backward phase verification
│   ├── gsd-phase-researcher.md               - per-phase ecosystem research
│   ├── gsd-project-researcher.md             - project-level research
│   ├── gsd-research-synthesizer.md           - combines 4 research outputs
│   ├── gsd-plan-checker.md                   - validates plans against goals
│   ├── gsd-debugger.md                       - systematic debugging agent
│   ├── gsd-codebase-mapper.md                - brownfield codebase analysis
│   └── gsd-integration-checker.md            - cross-phase wiring verification
│
└── get-shit-done/
    ├── bin/
    │   ├── gsd-tools.js                      - CLI utility (4597 lines)
    │   └── gsd-tools.test.js                 - tests (2033 lines)
    │
    ├── templates/
    │   ├── config.json                       - default project config
    │   ├── project.md                        - PROJECT.md template
    │   ├── state.md                          - STATE.md template
    │   ├── roadmap.md                        - ROADMAP.md template
    │   ├── milestone.md                      - milestone template
    │   ├── milestone-archive.md              - milestone archive template
    │   ├── requirements.md                   - REQUIREMENTS.md template
    │   ├── summary.md                        - SUMMARY.md template
    │   ├── summary-standard.md               - standard summary variant
    │   ├── summary-minimal.md                - minimal summary variant
    │   ├── summary-complex.md                - complex summary variant
    │   ├── phase-prompt.md                   - phase prompt template
    │   ├── context.md                        - CONTEXT.md template
    │   ├── continue-here.md                  - session handoff template
    │   ├── discovery.md                      - DISCOVERY.md template
    │   ├── research.md                       - RESEARCH.md template
    │   ├── verification-report.md            - VERIFICATION.md template
    │   ├── UAT.md                            - UAT template
    │   ├── DEBUG.md                          - debug session template
    │   ├── user-setup.md                     - external service setup template
    │   ├── planner-subagent-prompt.md        - planner subagent prompt
    │   ├── debug-subagent-prompt.md          - debug subagent prompt
    │   ├── research-project/                 - research output templates
    │   │   ├── STACK.md
    │   │   ├── FEATURES.md
    │   │   ├── ARCHITECTURE.md
    │   │   ├── PITFALLS.md
    │   │   └── SUMMARY.md
    │   └── codebase/                         - codebase map templates
    │       ├── architecture.md
    │       ├── stack.md
    │       ├── structure.md
    │       ├── conventions.md
    │       ├── testing.md
    │       ├── integrations.md
    │       └── concerns.md
    │
    ├── references/
    │   ├── phase-argument-parsing.md         - how to parse phase arguments
    │   ├── decimal-phase-calculation.md      - decimal phase numbering rules
    │   ├── model-profiles.md                 - quality/balanced/budget model tables
    │   ├── model-profile-resolution.md       - how to resolve model per agent
    │   ├── git-integration.md                - git commit conventions
    │   ├── git-planning-commit.md            - planning doc commit patterns
    │   ├── continuation-format.md            - checkpoint continuation format
    │   ├── checkpoints.md                    - checkpoint handling reference
    │   ├── verification-patterns.md          - verification grep patterns
    │   ├── questioning.md                    - deep questioning techniques
    │   ├── planning-config.md                - config options reference
    │   ├── tdd.md                            - TDD execution reference
    │   └── ui-brand.md                       - UI/branding guidelines
    │
    └── workflows/
        ├── new-project.md                    - full project init workflow
        ├── map-codebase.md                   - codebase mapping workflow
        ├── discuss-phase.md                  - phase discussion workflow
        ├── research-phase.md                 - phase research workflow
        ├── plan-phase.md                     - phase planning orchestrator
        ├── execute-phase.md                  - phase execution orchestrator
        ├── execute-plan.md                   - single plan execution
        ├── verify-phase.md                   - phase verification
        ├── verify-work.md                    - UAT workflow
        ├── quick.md                          - quick task workflow
        ├── progress.md                       - progress + routing
        ├── resume-project.md                 - resume workflow
        ├── add-phase.md                      - add phase workflow
        ├── insert-phase.md                   - insert phase workflow
        ├── remove-phase.md                   - remove phase workflow
        ├── add-todo.md                       - add todo workflow
        ├── check-todos.md                    - check todos workflow
        ├── complete-milestone.md             - milestone completion
        ├── new-milestone.md                  - new milestone workflow
        ├── audit-milestone.md                - milestone audit
        ├── plan-milestone-gaps.md            - gap closure planning
        ├── list-phase-assumptions.md         - phase assumptions
        ├── pause-work.md                     - pause workflow
        ├── settings.md                       - settings workflow
        ├── set-profile.md                    - profile switch
        ├── diagnose-issues.md                - issue diagnosis
        ├── transition.md                     - phase transition
        ├── discovery-phase.md                - discovery workflow
        ├── help.md                           - help reference content
        └── update.md                         - update workflow
```

## Entry Points

| Entry Point                      | Trigger                                    | Purpose                                           |
|----------------------------------|--------------------------------------------|---------------------------------------------------|
| bin/install.js                   | npx get-shit-done-cc                       | Install/uninstall GSD into user's config dir      |
| commands/gsd/*.md                | /gsd:<command> in Claude Code              | Slash commands the AI reads to start workflows    |
| get-shit-done/bin/gsd-tools.js   | node gsd-tools.js <cmd> [args]             | CLI utility called by the AI during execution     |
| hooks/gsd-statusline.js          | Claude Code statusline config (stdin JSON) | Renders statusbar with model/task/context usage   |
| hooks/gsd-check-update.js        | Claude Code SessionStart hook              | Background npm version check                      |

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AI Runtime (Claude Code)                     │
│                                                                     │
│  ┌──────────────┐    ┌───────────────────┐    ┌───────────────────┐ │
│  │  /gsd:*      │--->│  workflows/*.md   │--->│  agents/gsd-*.md  │ │
│  │  (commands)  │    │  (orchestration)  │    │  (subagents)      │ │
│  └──────────────┘    └────────┬──────────┘    └───────┬───────────┘ │
│                               │                       │             │
│                               v                       v             │
│                      ┌────────────────────────────────────┐         │
│                      │       gsd-tools.js (CLI)           │         │
│                      │  state | config | git | verify     │         │
│                      └────────────────┬───────────────────┘         │
│                                       │                             │
│                                       v                             │
│                      ┌────────────────────────────────────┐         │
│                      │        .planning/ (filesystem)     │         │
│                      │  PROJECT.md | STATE.md | ROADMAP.md│         │
│                      │  phases/ | research/ | config.json │         │
│                      └────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────────────────┘
```

## Command ---> Workflow ---> Agent Chain

```
commands/gsd/execute-phase.md
        |
        | (references via @)
        v
workflows/execute-phase.md
        |
        | (spawns via Task())
        v
agents/gsd-executor.md
        |
        | (reads)
        v
workflows/execute-plan.md + templates/summary.md + references/checkpoints.md
```

## Installation Data Flow

```
npx get-shit-done-cc
        |
        v
bin/install.js
        |
        +---> Interactive prompts (runtime, location)
        |
        +---> Copy commands/gsd/*.md -----> ~/.claude/commands/gsd/
        |
        +---> Copy get-shit-done/ --------> ~/.claude/get-shit-done/
        |     (templates, workflows, references, bin)
        |
        +---> Copy agents/*.md -----------> ~/.claude/agents/
        |     (with runtime-specific frontmatter conversion)
        |
        +---> Copy hooks/dist/ -----------> ~/.claude/hooks/
        |
        +---> Configure settings.json
        |     (statusline, SessionStart hook)
        |
        +---> Write gsd-file-manifest.json (SHA256 hashes)
```

## Core Development Lifecycle

```
/gsd:new-project
        |
        +---> Deep questioning (user <---> AI conversation)
        +---> Write PROJECT.md
        +---> Spawn 4x gsd-project-researcher (parallel)
        |         ----> STACK.md, FEATURES.md, ARCHITECTURE.md, PITFALLS.md
        +---> Spawn gsd-research-synthesizer ----> research/SUMMARY.md
        +---> User scoping ----> REQUIREMENTS.md
        +---> Spawn gsd-roadmapper ----> ROADMAP.md + STATE.md
        +---> Git commit each artifact
        |
        v
/gsd:discuss-phase N (optional)
        |
        +---> Conversational vision capture ----> CONTEXT.md
        |
        v
/gsd:plan-phase N
        |
        +---> Spawn gsd-phase-researcher (optional) ----> RESEARCH.md
        +---> Spawn gsd-planner ----> XX-NN-PLAN.md files
        +---> Spawn gsd-plan-checker ----> revision loop (max 3)
        +---> Git commit plans
        |
        v
/gsd:execute-phase N
        |
        +---> Discover plans, analyze deps, group into waves
        +---> For each wave:
        |       +---> Spawn gsd-executor per plan (parallel within wave)
        |       |       +---> Execute tasks sequentially
        |       |       +---> Git commit per task
        |       |       +---> Create SUMMARY.md
        |       |       +---> Update STATE.md
        |       +---> Spot-check results
        |       +---> Handle checkpoints if any
        +---> Spawn gsd-verifier ----> VERIFICATION.md
        +---> If gaps: offer /gsd:plan-phase N --gaps
        +---> Update ROADMAP.md
        |
        v
(repeat for each phase)
        |
        v
/gsd:complete-milestone
```

## gsd-tools.js Data Flow

```
Workflow/Agent prompt
        |
        +---> Calls: node gsd-tools.js <command> [args]
        |
        +---> Reads from disk:
        |       .planning/config.json    (project config)
        |       .planning/STATE.md       (current position)
        |       .planning/ROADMAP.md     (phase structure)
        |       .planning/phases/XX-name/*.md (plans, summaries)
        |
        +---> Writes to disk:
        |       .planning/STATE.md       (updates)
        |       .planning/config.json    (config changes)
        |       .planning/phases/XX-name/ (scaffolding)
        |
        +---> Git operations:
        |       git add (specific files)
        |       git commit (formatted message)
        |
        +---> Returns: JSON to stdout (parsed by AI)
```

## Orchestrator-Subagent Pattern

```
┌─────────────────────────────────────────────────────────────┐
│  Orchestrator (main AI session, ~10-15% context)            │
│                                                             │
│  Coordinates, tracks progress, presents results to user     │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Executor │  │ Executor │  │ Executor │  │ Verifier │     │
│  │ Plan 1   │  │ Plan 2   │  │ Plan 3   │  │          │     │
│  │ (200K)   │  │ (200K)   │  │ (200K)   │  │ (200K)   │     │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘     │
│     Wave 1        Wave 1        Wave 2        Post-exec     │
└─────────────────────────────────────────────────────────────┘
```

## Agent Dependency Map

```
gsd-executor -----> gsd-tools.js state advance-plan
                    gsd-tools.js state record-metric
                    gsd-tools.js commit "..."

gsd-planner  -----> gsd-tools.js init plan-phase
                    gsd-tools.js history-digest
                    gsd-tools.js frontmatter validate

gsd-verifier -----> gsd-tools.js roadmap get-phase
                    gsd-tools.js verify artifacts
                    gsd-tools.js verify key-links

gsd-roadmapper ---> reads templates directly
```

## Prompt-Level Dependency Graph

```
commands/gsd/new-project.md
    +---> @workflows/new-project.md
              +---> @templates/project.md
              +---> @templates/research-project/*.md
              +---> @references/questioning.md
              +---> Spawns: gsd-project-researcher (x4)
              +---> Spawns: gsd-research-synthesizer
              +---> Spawns: gsd-roadmapper
                        +---> @templates/roadmap.md
                        +---> @templates/state.md

commands/gsd/plan-phase.md
    +---> @workflows/plan-phase.md
              +---> @references/ui-brand.md
              +---> Spawns: gsd-phase-researcher
              +---> Spawns: gsd-planner
              +---> Spawns: gsd-plan-checker

commands/gsd/execute-phase.md
    +---> @workflows/execute-phase.md
              +---> @references/ui-brand.md
              +---> Spawns: gsd-executor (per plan, per wave)
              +---> Spawns: gsd-verifier
```

## Template ---> Output Mapping

| Template                        | Output                                     |
|---------------------------------|--------------------------------------------|
| templates/project.md            | .planning/PROJECT.md                       |
| templates/state.md              | .planning/STATE.md                         |
| templates/roadmap.md            | .planning/ROADMAP.md                       |
| templates/requirements.md       | .planning/REQUIREMENTS.md                  |
| templates/config.json           | .planning/config.json                      |
| templates/summary.md            | .planning/phases/XX/XX-NN-SUMMARY.md       |
| templates/context.md            | .planning/phases/XX/XX-CONTEXT.md          |
| templates/research-project/     | .planning/research/                        |
| templates/codebase/             | .planning/codebase/                        |

## User Project Output Structure

When GSD is used on a real project, it creates:

```
.planning/
├── PROJECT.md                    - vision, core value, requirements, constraints
├── config.json                   - workflow mode, depth, parallelization
├── REQUIREMENTS.md               - REQ-IDs, v1/v2/out-of-scope, traceability
├── ROADMAP.md                    - phase structure, goals, success criteria
├── STATE.md                      - current position, metrics, decisions, session info
├── research/                     - domain research
│   ├── STACK.md
│   ├── FEATURES.md
│   ├── ARCHITECTURE.md
│   ├── PITFALLS.md
│   └── SUMMARY.md
├── codebase/                     - brownfield analysis (from /gsd:map-codebase)
│   ├── STACK.md
│   ├── INTEGRATIONS.md
│   ├── ARCHITECTURE.md
│   ├── STRUCTURE.md
│   ├── CONVENTIONS.md
│   ├── TESTING.md
│   └── CONCERNS.md
├── todos/
│   ├── pending/                  - captured ideas
│   └── done/                     - completed todos
├── debug/                        - active debug sessions
│   └── resolved/                 - archived debug sessions
├── milestones/                   - archived milestone data
└── phases/
    └── XX-name/
        ├── XX-CONTEXT.md         - user's vision (from discuss-phase)
        ├── XX-RESEARCH.md        - phase research (from research-phase)
        ├── XX-NN-PLAN.md         - execution plan (from plan-phase)
        ├── XX-NN-SUMMARY.md      - execution result (from executor)
        ├── XX-VERIFICATION.md    - goal verification (from verifier)
        └── XX-UAT.md             - user acceptance test results

```

## Design Patterns

1. Meta-Prompting / Prompt-as-Code    - markdown files ARE the prompts that instruct the AI; commands, workflows, and agents are all declarative
2. Orchestrator-Subagent              - thin orchestrators spawn heavyweight specialized agents with fresh context windows
3. Goal-Backward Methodology          - derives what must be TRUE/EXIST/WIRED for a goal to be achieved
4. Wave-Based Parallel Execution      - plans grouped by dependency into waves, parallel within wave, sequential across waves
5. Document-Driven State Machine      - project state tracked entirely through markdown files in .planning/
6. Multi-Runtime Adapter              - install.js converts Claude Code format to OpenCode (YAML/permissions) and Gemini (TOML)
7. Checkpoint Protocol                - executor stops at human-verify/decision/action checkpoints, orchestrator resumes with fresh agent
8. Deviation Rules                    - auto-fix hierarchy (bugs > missing features > blockers > ask about architecture)
9. File Manifest + Local Patches      - SHA256 hashes track installed files, user modifications backed up and reapplied on update
