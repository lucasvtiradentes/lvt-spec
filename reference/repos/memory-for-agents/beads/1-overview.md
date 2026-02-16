# Beads (bd)

## Info

| Field            | Value                                       |
|------------------|---------------------------------------------|
| repo_link        | https://github.com/steveyegge/beads         |
| created_at       | 2025-10-12                                  |
| number_of_stars  | 15710                                       |
| analysed_at      | 2026-02-09                                  |

## What It Is

Beads (`bd`) is a distributed, git-backed, graph-aware issue tracker built for AI coding agents. It replaces unstructured markdown plans with a dependency-aware graph stored in git, giving agents persistent structured memory across sessions.

Issues are stored as JSONL in `.beads/issues.jsonl` (git-tracked), with SQLite or Dolt as local cache for fast queries. Hash-based IDs (`bd-a1b2`) prevent merge collisions when multiple agents create issues on concurrent branches.

## Purpose

Give AI coding agents (Claude Code, Copilot, Aider, Junie, etc.) a local-first, offline-capable task management system that:

- Tracks dependencies and computes ready work (`bd ready` in ~10ms offline)
- Prevents merge collisions across concurrent branches/agents via hash-based IDs
- Syncs automatically through git with zero infrastructure beyond the repo itself
- Provides structured JSON output for every command (`--json` flag)

## Key Features

1. Git as database          - JSONL source of truth, versioned/branched/merged like code
2. Agent-optimized          - `--json` output, MCP server, Claude Code plugin, Junie integration
3. Hash-based IDs           - UUID-derived short hashes (`bd-a1b2`), grow as DB grows, no collisions
4. Dependency graph         - typed deps (`blocks`, `parent-child`, `related`, `discovered-from`, etc.)
5. Hierarchical IDs         - dot notation for epics (`bd-a3f8.1`, `bd-a3f8.1.1`)
6. Background daemon        - per-workspace daemon (Unix socket) for auto-sync, connection pooling
7. 3-way sync               - pull-first merge (base/local/remote) prevents data loss
8. Compaction               - semantic "memory decay" summarizes old closed issues to save tokens
9. Inter-agent messaging    - `type: message` issues with threading via `replies-to`
10. Molecules and wisps     - template workflows (molecules) with ephemeral local-only steps (wisps)
11. Multi-repo routing      - auto-detects maintainer vs contributor role, routes planning issues separately
12. Stealth mode            - `bd init --stealth` for local-only usage without committing to shared repo
13. Atomic claim            - `bd update <id> --claim` atomically sets assignee + in_progress
14. Extensible              - custom SQLite tables, custom statuses/types via config
15. Tombstone soft delete   - configurable TTL (default 30 days)
16. Dolt backend support    - version-controlled SQL database as alternative to SQLite

## Core Concepts

| Term       | Meaning                                                                        |
|------------|--------------------------------------------------------------------------------|
| Bead       | A work item / issue in the system                                              |
| bd         | The CLI command (short for "beads")                                            |
| Dependency | Typed relationship between issues (blocks, related, parent-child, etc.)        |
| Ready work | Issues with no open blockers, computed by `bd ready`                           |
| Molecule   | An epic with children defining a workflow with execution intent                |
| Proto      | A molecule template (epic with `template` label)                               |
| Wisp       | Ephemeral local-only child issue, never synced to git                          |
| Compaction | Semantic summarization of old closed issues to reduce context window size      |
| Tombstone  | Soft-deleted issue with TTL-based expiry                                       |
| Flush      | Export from SQLite to JSONL (debounced, background)                            |
| Hydration  | Importing issues from multiple repos into unified view                         |
| Routing    | Auto-directing issues to correct repo based on maintainer/contributor role     |
| Gate       | Async coordination primitive (wait for CI, PR, timer, human approval)          |
| Bond       | Combining two molecules into a compound (sequential, parallel, conditional)    |
| Formula    | Workflow template with variables, conditions, loops, and AOP-style advice      |

Status flow: `open` ----> `in_progress` ----> `closed` (also: `blocked`, `deferred`, `tombstone`, `pinned`)

Issue types: `bug`, `feature`, `task`, `epic`, `chore` (built-in) + custom types via config

Priority: 0 (critical/P0) through 4 (backlog)

## Possible Usages

1. AI agent task memory       - structured persistent memory across sessions for any AI coding agent
2. Multi-agent coordination   - concurrent branch work without collision via hash IDs + JSONL merge
3. Epic decomposition         - break large features into dependency graphs, agents work through ready tasks
4. OSS contributor workflow   - local planning without polluting upstream PRs
5. CI/CD integration          - gates block work until external conditions resolve (PR merged, CI passed)
6. Lightweight team tracker   - CLI issue tracker with dependency awareness, no external services needed
7. Knowledge graphs           - link related issues, deduplicate, chain via graph links
8. Swarm orchestration        - molecules define multi-step workflows agents execute in parallel/sequential

## Target Audience

- Primary    - AI coding agents (Claude Code, GitHub Copilot, Aider, Junie, custom agents)
- Secondary  - developers using AI agents who need to manage and coordinate agent work
- Tertiary   - individual developers and small teams wanting a lightweight git-native CLI issue tracker

## Documentation Index

| File                                                | Description                                    |
|-----------------------------------------------------|------------------------------------------------|
| [2-technical.md](./2-technical.md)                  | Tech stack, dependencies, installation, config |
| [3-architecture.md](./3-architecture.md)            | Folder structure, entry points, design patterns|
| [4-code-patterns.md](./4-code-patterns.md)          | Coding style, testing, CI/CD, conventions      |
| [5-usage-and-examples.md](./5-usage-and-examples.md)| How to use, CLI commands, agent workflows      |
