# Code Patterns

## Coding Style and Conventions

This is NOT a source code repo. It is a Claude Code plugin marketplace containing only Markdown and JSON files. No programming language code exists.

Naming conventions:
- Kebab-case for directories and files: `por-dev`, `all-tools.md`, `generate-all-claude-mds.md`
- Feature slugs expected to be git-branch-friendly: kebab-case
- Task IDs use `T001` format with zero-padded sequential numbering
- User stories use `US-001` / `US1` notation
- Functional requirements use `FR-001` notation
- Success criteria use `SC-001` notation

## Plugin Structure Convention

```
root/
  .claude-plugin/marketplace.json   -- marketplace registry
  <plugin-name>/                    -- individual plugin
    .claude-plugin/plugin.json      -- plugin metadata (name, version, author)
    commands/                       -- slash commands as .md files
      <command>.md                  -- top-level command (/command)
      <subdir>/                     -- grouped subcommands
        <sub>.md                    -- becomes /<subdir>:<sub>
```

## Command File Format

Some commands use YAML frontmatter for metadata:

```yaml
---
description: Create or update the feature specification
argument-hint: [optional-context]
model: opus
---
```

Only `discover.md` and `design.md` specify `model: opus`. Other commands use the default model.

## Testing Approach

No tests exist in this repo. The command templates themselves reference testing patterns for target projects:
- `uv run pytest` as default validation command (Python/uv ecosystem assumed)
- Plans prescribe TDD: "Tests should come BEFORE implementation"
- Test phases embedded in plan templates (Unit Tests, Integration Tests, Edge Cases sections)

## CI/CD Setup

No CI/CD configuration exists. No `.github/workflows`, no Makefile, no Dockerfile. Distribution is via `claude plugin marketplace add <git-url>`.

## Error Handling Patterns

Error handling is defined as prompt conventions within command templates:

- Prerequisite checks  - each command defines explicit prereqs and checks for required files
- Error format         - plain text blocks with `ERROR:` prefix and actionable next steps
- Marker validation    - `[NEEDS CLARIFICATION]` markers in specs trigger blocking errors in design phase
- Graceful degradation - `contracts.md` is optional, only generated when APIs/data models are involved

Example error pattern from `design.md`:
```
ERROR: No specs found at ./specs/<feature_slug>/specs.md
Please run `/discover` first to create the feature specification.
```

## Workflow Chaining

Commands auto-chain to the next stage:
- `/discover` ends with "run `/design`"
- `/design` ends with "run `/plan`"

## Output Convention

All commands write to the `specs/` directory in the target project:
- Full workflow: `specs/<feature_slug>/spec.md`, `architecture.md`, `contracts.md`, `plan.md`
- Fast track:    `specs/<task-name>.md` (single file)

## Notable Patterns

- Phased execution       - `/implement` supports `--ff` (autonomous) and `--phases` (stop-and-review) modes
- Plan-as-code           - markdown plans serve as executable specifications with checkbox tracking
- Parallelization        - tasks marked with `[P]` indicate safe parallel execution
- MVP-first              - plans prioritize P1 user story as MVP with "STOP and VALIDATE" checkpoints
- Model pinning          - only `discover` and `design` pin to `model: opus` via frontmatter
- Variable interpolation - `$ARGUMENTS` placeholder for user input injection
