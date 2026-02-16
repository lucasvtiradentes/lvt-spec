# Get Shit Done (GSD)

## Info

| Field           | Value                                            |
|-----------------|--------------------------------------------------|
| repo_link       | https://github.com/glittercowboy/get-shit-done   |
| created_at      | 2025-12-14                                       |
| number_of_stars | 12418                                            |
| analysed_at     | 2026-02-08                                       |

## Purpose

GSD is a meta-prompting, context engineering, and spec-driven development system for AI coding assistants -- specifically Claude Code, OpenCode, and Gemini CLI. Distributed as an npm package (`get-shit-done-cc`), it installs slash commands, agent definitions, workflow orchestrations, and templates into the user's AI assistant config directory.

The primary problem it solves is "context rot" -- the quality degradation that happens as an LLM fills its context window during long coding sessions. GSD breaks work into small, atomic plans that each execute in a fresh context window, with structured handoff documents ensuring continuity.

## Features

1. Unified project init              - questioning, optional domain research, requirements extraction, roadmap creation (`/gsd:new-project`)
2. Phase-based workflow               - discuss, plan, execute, verify -- each phase is a discrete cycle
3. Multi-agent orchestration          - 11 specialized agents (planner, executor, verifier, debugger, roadmapper, etc.) spawned as subagents with fresh context windows
4. Wave-based parallel execution      - independent plans run simultaneously, dependent ones run sequentially
5. Atomic git commits                 - one commit per task with conventional commit format
6. Goal-backward verification         - verifies that phase goals were actually achieved, not just that tasks completed
7. Stub and anti-pattern detection    - catches generated code quality issues
8. UAT workflow                       - user acceptance testing with diagnosis of failures
9. Persistent debug sessions          - survive context resets (`/gsd:debug`)
10. Quick mode                        - ad-hoc tasks without full planning ceremony (`/gsd:quick`)
11. Session management                - pause/resume work across sessions via `STATE.md`
12. Brownfield support                - codebase mapping before starting new work (`/gsd:map-codebase`)
13. Milestone lifecycle               - complete, archive, tag releases, start new milestones
14. Model profile system              - quality/balanced/budget controlling which Claude model each agent uses
15. Configurable workflow agents      - research, plan-check, verifier can be toggled
16. Git branching strategies          - none, per-phase, per-milestone
17. Multi-runtime support             - Claude Code, OpenCode, Gemini CLI

## Core Concepts

1. `.planning/` directory             - all project state lives here: PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md, per-phase plans/summaries/verifications
2. Plans as prompts                   - PLAN.md files are not documentation, they ARE the prompts that executor agents receive, using XML-structured tasks
3. Context budget management          - plans target ~50% context window usage (2-3 tasks each) to stay in the LLM's quality zone
4. Goal-backward methodology          - derives what must be TRUE, what must EXIST, and what must be WIRED for a goal to be achieved
5. Deviation rules                    - during execution, the executor auto-fixes bugs, adds missing critical functionality, fixes blockers, and stops for architectural decisions
6. Orchestrator pattern               - thin orchestrators spawn heavyweight specialized agents, keeping the main context clean
7. State continuity                   - STATE.md tracks current position, decisions, blockers, metrics, and session info
8. Must-haves verification            - plans declare must_haves in YAML frontmatter that the verifier checks against the actual codebase
9. Wave system                        - plans assigned to execution waves based on dependency graphs
10. Discovery levels (0-3)            - determine how much research is needed before planning

## Possible Usages

- Solo developers using AI coding assistants who want structured, reliable output
- Greenfield projects going from idea to working code with consistent quality
- Brownfield projects adding features systematically using `/gsd:map-codebase`
- Developers experiencing inconsistent results on longer tasks due to context window filling up
- Non-traditional developers / "vibecoding" practitioners who need reliability guarantees
- Bug fixing via the systematic `/gsd:debug` flow
- Ad-hoc small tasks via `/gsd:quick` mode
- Teams using OpenCode or Gemini CLI as alternatives to Claude Code

## Documentation Files

| File                                                | Description                                       |
|-----------------------------------------------------|---------------------------------------------------|
| [2-technical.md](./2-technical.md)                  | Tech stack, dependencies, installation, config    |
| [3-architecture.md](./3-architecture.md)            | Folder structure, design patterns, data flow      |
| [4-code-patterns.md](./4-code-patterns.md)          | Coding style, testing, conventions                |
| [5-usage-and-examples.md](./5-usage-and-examples.md)| How to use, workflows, CLI commands               |
