# Usage and Examples

## Getting Started

Install with one command:

```bash
npx get-shit-done-cc@latest
```

The interactive installer prompts for:
1. Runtime -- Claude Code, OpenCode, Gemini, or all
2. Location -- Global (all projects) or local (current project only)

Verify installation:

```
/gsd:help
```

Recommended runtime mode (skip permission prompts):

```bash
claude --dangerously-skip-permissions
```

## Slash Commands

### Core Workflow

| Command                     | Description                                                |
|-----------------------------|------------------------------------------------------------|
| /gsd:new-project [--auto]   | Full init: questions -> research -> requirements -> roadmap|
| /gsd:discuss-phase <N>      | Capture implementation decisions before planning           |
| /gsd:plan-phase [N]         | Research + plan + verify loop for a phase                  |
| /gsd:execute-phase <N>      | Execute all plans in parallel waves, verify on complete    |
| /gsd:verify-work [N]        | Manual user acceptance testing with auto-diagnosis         |
| /gsd:audit-milestone        | Verify milestone achieved its definition of done           |
| /gsd:complete-milestone     | Archive milestone, tag release                             |
| /gsd:new-milestone [name]   | Start next version cycle                                   |

### Navigation

| Command          | Description                      |
|------------------|----------------------------------|
| /gsd:progress    | Where am I? What's next?         |
| /gsd:help        | Show all commands and usage guide|
| /gsd:update      | Update GSD with changelog preview|

### Brownfield (Existing Codebase)

| Command            | Description                                  |
|--------------------|----------------------------------------------|
| /gsd:map-codebase  | Analyze existing codebase before new-project |

### Phase Management

| Command                         | Description                                    |
|---------------------------------|------------------------------------------------|
| /gsd:add-phase                  | Append phase to roadmap                        |
| /gsd:insert-phase [N]           | Insert urgent work between phases              |
| /gsd:remove-phase [N]           | Remove future phase, renumber                  |
| /gsd:list-phase-assumptions [N] | See Claude's intended approach before planning |
| /gsd:plan-milestone-gaps        | Create phases to close gaps from audit         |
| /gsd:research-phase [N]         | Standalone research                            |

### Session Management

| Command          | Description                          |
|------------------|--------------------------------------|
| /gsd:pause-work  | Create handoff (.continue-here.md)   |
| /gsd:resume-work | Restore from last session            |

### Utilities

| Command                      | Description                                    |
|------------------------------|------------------------------------------------|
| /gsd:settings                | Configure model profile and workflow agents    |
| /gsd:set-profile <profile>   | Switch model profile (quality/balanced/budget) |
| /gsd:add-todo [desc]         | Capture idea for later                         |
| /gsd:check-todos             | List pending todos                             |
| /gsd:debug [desc]            | Systematic debugging with persistent state     |
| /gsd:quick                   | Execute ad-hoc task with GSD guarantees        |
| /gsd:reapply-patches         | Merge local modifications after GSD update     |

### Command Flags

/gsd:plan-phase flags:

| Flag             | Purpose                                            |
|------------------|----------------------------------------------------|
| --research       | Force re-research even if RESEARCH.md exists       |
| --skip-research  | Skip research, go straight to planning             |
| --gaps           | Gap closure mode (reads VERIFICATION.md)           |
| --skip-verify    | Skip verification loop                             |

/gsd:execute-phase flags:

| Flag         | Purpose                                                |
|--------------|--------------------------------------------------------|
| --gaps-only  | Execute only gap closure plans (after verify-work)     |

/gsd:new-project flags:

| Flag   | Purpose                                                      |
|--------|--------------------------------------------------------------|
| --auto | Automatic mode, runs research -> requirements -> roadmap     |

## Common Workflows

### Workflow A: Greenfield Project (From Scratch)

```
/gsd:new-project                 # Questions -> research -> requirements -> roadmap
/gsd:discuss-phase 1             # Capture preferences for phase 1
/gsd:plan-phase 1                # Research + create execution plans
/gsd:execute-phase 1             # Parallel execution, atomic commits
/gsd:verify-work 1               # User acceptance testing
/gsd:discuss-phase 2             # Repeat for phase 2...
/gsd:plan-phase 2
/gsd:execute-phase 2
/gsd:verify-work 2
...
/gsd:complete-milestone          # Archive milestone, tag release
/gsd:new-milestone               # Start next version
```

### Workflow B: Brownfield Project (Existing Codebase)

```
/gsd:map-codebase                # Analyze existing code (spawns 4 parallel agents)
/gsd:new-project                 # Questions focus on what you're adding
...                              # Same discuss -> plan -> execute -> verify loop
```

### Workflow C: Quick Ad-Hoc Task

```
/gsd:quick
> What do you want to do? "Add dark mode toggle to settings"
```

Quick mode skips research, plan checker, and verifier. Lives in `.planning/quick/`.

### Workflow D: Debugging

```
/gsd:debug "Login fails after password reset"
```

Gathers symptoms (expected, actual, errors, timeline, reproduction), spawns a debugger agent, handles checkpoints, proposes fixes.

### Workflow E: Session Continuity

```
/gsd:pause-work          # Creates .continue-here.md handoff
# ... close session ...
/gsd:resume-work         # Restores context, routes to next action
```

### Workflow F: Mid-Milestone Adjustments

```
/gsd:add-phase "Add export functionality"       # Append new phase
/gsd:insert-phase 3 "Fix auth token expiry"     # Insert as 3.1
/gsd:remove-phase 7                              # Remove unneeded phase
```

## XML Plan Format

Plans use structured XML optimized for Claude:

```xml
<task type="auto">
  <name>Create login endpoint</name>
  <files>src/app/api/auth/login/route.ts</files>
  <action>
    Use jose for JWT (not jsonwebtoken - CommonJS issues).
    Validate credentials against users table.
    Return httpOnly cookie on success.
  </action>
  <verify>curl -X POST localhost:3000/api/auth/login returns 200 + Set-Cookie</verify>
  <done>Valid credentials return cookie, invalid return 401</done>
</task>
```

## Multi-Agent Architecture

GSD uses a thin orchestrator pattern: the main context spawns specialized agents, collects results, and routes to the next step.

| Stage        | Orchestrator Does                     | Agents Do                                                         |
|--------------|---------------------------------------|-------------------------------------------------------------------|
| Research     | Coordinates, presents findings        | 4 parallel researchers (stack, features, arch, pitfalls)          |
| Planning     | Validates, manages iteration          | Planner creates plans, checker verifies, loop until pass          |
| Execution    | Groups into waves, tracks progress    | Executors implement in parallel, each with fresh 200K context     |
| Verification | Presents results, routes next         | Verifier checks codebase, debuggers diagnose failures             |
| Codebase map | Coordinates 4 parallel mappers        | tech, arch, quality, concerns focus areas                         |

## Configuration Examples

Switch model profile at runtime:

```
/gsd:set-profile budget
```

Git branching strategies:

- `none`      - commits to current branch (default)
- `phase`     - creates a branch per phase, merges at phase completion
- `milestone` - creates one branch for entire milestone, merges at completion

Uncommitted mode (keep planning private):

```json
{ "planning": { "commit_docs": false, "search_gitignored": true } }
```

Then add `.planning/` to `.gitignore`.

## Troubleshooting

- Commands not found       - restart Claude Code, verify files in `~/.claude/commands/gsd/`
- Commands not working     - run `/gsd:help` to verify, re-run `npx get-shit-done-cc`
- Docker tilde path issues - set `CLAUDE_CONFIG_DIR` before installing
- Local mods after update  - GSD backs up changes to `gsd-local-patches/`, use `/gsd:reapply-patches`
