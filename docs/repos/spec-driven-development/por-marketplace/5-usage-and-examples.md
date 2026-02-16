# Usage and Examples

## Installation

```bash
claude plugin marketplace add https://github.com/lfnovo/por-marketplace
claude plugin install por-dev@por-marketplace
```

## Available Commands

| Command                    | Description                                 |
|----------------------------|---------------------------------------------|
| `/prime`                   | Load codebase context (always run first)    |
| `/discover <input>`        | Create feature spec from requirements       |
| `/design`                  | Design technical architecture from spec     |
| `/plan`                    | Break architecture into implementation tasks|
| `/implement [--ff/phases]` | Execute the implementation plan             |
| `/fast:bug <desc>`         | Quick bug fix planning                      |
| `/fast:chore <desc>`       | Quick maintenance task planning             |
| `/fast:feature <desc>`     | Quick small feature planning                |
| `/all-tools`               | List all available Claude Code tools        |
| `/generate-all-claude-mds` | Generate CLAUDE.md files across codebase    |

## Workflow Decision Guide

| Scenario             | Workflow                                                                    |
|----------------------|-----------------------------------------------------------------------------|
| Simple bug fix       | `/prime` ---> `/fast:bug` ---> `/implement`                                 |
| Dependency upgrade   | `/prime` ---> `/fast:chore` ---> `/implement`                               |
| Small UI feature     | `/prime` ---> `/fast:feature` ---> `/implement`                             |
| New API endpoint     | `/prime` ---> `/discover` ---> `/design` ---> `/plan` ---> `/implement`     |
| Complex feature      | `/prime` ---> `/discover` ---> `/design` ---> `/plan` ---> `/implement`     |
| Refactoring          | `/prime` ---> `/fast:chore` or complete workflow                            |
| Document codebase    | `/generate-all-claude-mds`                                                  |

## Complete Workflow Example

For a complex feature like "Add user authentication with OAuth support":

```
/prime
```
Reads `git ls-files`, `README.md`, and `tree docs` to prime the agent with codebase context.

```
/discover "Add user authentication with OAuth support"
```
Creates `specs/user-authentication/spec.md` with user stories, functional requirements, success criteria. Asks clarification questions. Creates a git branch.

```
/design
```
Reads `spec.md`, researches libraries via WebSearch/Context7/Perplexity, analyzes codebase patterns. Produces `architecture.md` and optionally `contracts.md`.

```
/plan
```
Reads `spec.md` + `architecture.md`. Produces `plan.md` with phased tasks:
- Phase 1:     Setup (dependencies, config)
- Phase 2:     Foundational (core infrastructure)
- Phase 3:     User Story P1 (MVP)
- Phase 4+:    Additional user stories by priority
- Final Phase: Polish (tests, docs)

```
/implement --phases
```
Executes the plan phase by phase, stopping after each for review. Marks tasks `[x]` in `plan.md`. Reports `git diff --stat` when done.

## Fast Track Example

For a simple bug fix:

```
/prime
/fast:bug "Login form crashes when email contains special characters"
/implement
```

This creates `specs/login-form-crash.md` with: bug description, root cause analysis, surgical fix steps, and validation commands.

## Discover Input Formats

`/discover` accepts multiple input types:

```
/discover "Add user authentication with OAuth support"
/discover ./requirements/auth-feature.md
/discover LINEAR-123
```

The third form uses MCP tools to pull requirements from project management tools.

## Implement Modes

Default mode (`--phases`): stops after each phase for user review.

```
/implement --phases
```

Fast-forward mode: runs autonomously, only stops for questions/blockers.

```
/implement --ff
```

## Output Structure

After using the plugin, the target project gains a `specs/` directory:

```
your-project/
  specs/
    fix-login-bug.md               # from /fast:bug
    upgrade-deps.md                # from /fast:chore
    user-authentication/           # from complete workflow
      spec.md                      # from /discover
      architecture.md              # from /design
      contracts.md                 # from /design (optional)
      plan.md                      # from /plan
```

## Plan Task Format

Tasks in `plan.md` follow this format:

```
- [ ] T001 [P] [US1] Create auth middleware in src/middleware/auth.ts
```

Where:
- `[ ]`  - checkbox (marked `[x]` when done)
- `T001` - task ID (zero-padded sequential)
- `[P]`  - parallelizable (safe to run concurrently with other `[P]` tasks)
- `[US1]`- linked user story

## Integration Patterns

- MCP Tools   - `/discover` can pull requirements from Linear, etc. via MCP
- WebSearch   - `/design` uses WebSearch, Context7, Perplexity for technical research
- Git         - `/discover` creates feature branches; `/implement` tracks changes via `git diff --stat`
- CLAUDE.md   - `/generate-all-claude-mds` creates hierarchical AI-context files for any codebase
