# Multi-Agent Commands

System for writing a single command source file that builds into CLI-specific formats for Claude Code, Codex CLI, and Gemini CLI.

## How it works

```
src/
├── config.json                central config for all commands
├── <command>/
│   └── <command>.md           single-file source with agent tags
└── <command>/
    ├── 00-section.md          split source (concat alphabetically)
    ├── 01-section.md
    └── _generated.md          auto-generated intermediate (gitignored)

     scripts/build.sh
            │
            v
┌──────────────────┐     ┌──────────────────┐
│  src/config.json │────>│  src/<command>/   │
│  (routing)       │     │  (source files)  │
└──────────────────┘     └────┬─────┬─────┬─┘
                              │     │     │
                              v     v     v
                           claude codex gemini
```

## Config

All commands are registered in `src/config.json`:

```json
{
  "repo-naming": { "namespace": "gh" },
  "align-docs": { "namespace": "docs" },
  "gen-docs": { "namespace": "docs", "agents": ["claude"] }
}
```

| Field       | Required | Default                      | Description                     |
|-------------|----------|------------------------------|---------------------------------|
| `namespace` | yes      | -                            | output subdirectory (gh, docs)  |
| `agents`    | no       | `["claude","codex","gemini"]` | which agents to build for      |

## Output paths

| Agent  | Output path                           | Format                 |
|--------|---------------------------------------|------------------------|
| claude | `.claude/commands/<ns>/<name>.md`     | plain md               |
| codex  | `.agents/skills/<name>/SKILL.md`      | md + yaml front matter |
| gemini | `.gemini/commands/<ns>/<name>.toml`   | toml wrapper           |

Note: Codex CLI does not support project-level custom slash commands. The only way to add project-scoped reusable prompts is through Agent Skills (`.agents/skills/`). Custom prompts (`~/.codex/prompts/`) exist but are global-only and deprecated.

## Invoking commands

| Agent  | Syntax         | Example            |
|--------|----------------|--------------------|
| claude | `/<ns>:<name>` | `/gh:repo-naming`  |
| codex  | `$<name>`      | `$repo-naming`     |
| gemini | `/<ns>:<name>` | `/gh:repo-naming`  |

- Claude and Gemini use slash commands with namespace derived from subdirectory path
- Codex uses `$` prefix to mention a skill by name (no namespace support)

## Source formats

### Single-file command

One `.md` file with agent tags. Used when the command is small enough for a single file:

```
src/repo-naming/
└── repo-naming.md
```

### Split command

Multiple `.md` files prefixed with numbers for ordering. The build script concatenates them alphabetically into `_generated.md`, then processes tags:

```
src/gen-docs/
├── 00-overview.md
├── 01-phase0.md
├── 02-phase1.md
├── 03-phase2.md
├── 04-phase3.md
├── 05-reference.md
└── _generated.md      (auto-generated, gitignored)
```

## Tag syntax

Tags are HTML comments, invisible if rendered as raw markdown.

### Variant blocks

Switch content per agent. Only the matching agent's lines are emitted:

```md
<!--@claude-->
CLAUDE.md if it exists
<!--@codex-->
AGENTS.md if it exists
<!--@gemini-->
GEMINI.md if it exists
<!--@end-->
```

Multiple agents in one variant:

```md
<!--@codex,gemini-->
Ask the user what they need:
<!--@end-->
```

### Only blocks

Entire block appears only for listed agents, omitted for all others:

```md
<!--@only codex-->
---
name: my-skill
description: does something
---
<!--@end-->
```

```md
<!--@only gemini-->
"""
<!--@end-->
```

### No tag

Lines without any tag are shared and appear in every output.

## Tag reference

| Tag                          | Meaning                        |
|------------------------------|--------------------------------|
| `<!--@only agent1,agent2-->` | block for listed agents only   |
| `<!--@agent-->`              | variant for single agent       |
| `<!--@agent1,agent2-->`      | variant for multiple agents    |
| `<!--@end-->`                | closes any block               |
| (no tag)                     | shared, appears in all outputs |

## Adding a new command

1. Create `src/<command>/` with `<command>.md`
2. Add agent-specific headers via `<!--@only-->` tags (codex yaml, gemini toml, claude intro)
3. Add entry to `src/config.json` with namespace and optionally agents
4. Run `make mount`

## CLI-specific differences to handle

| Concern      | Claude Code                          | Codex CLI                  | Gemini CLI                 |
|--------------|--------------------------------------|----------------------------|----------------------------|
| header       | plain text intro                     | yaml front matter          | toml (description, prompt) |
| arguments    | `<arguments>#$ARGUMENTS</arguments>` | `$ARGUMENTS`               | `{{args}}`                 |
| config file  | CLAUDE.md                            | AGENTS.md                  | GEMINI.md                  |
| tool ref     | AskUserQuestion                      | generic "ask the user"     | generic "ask the user"     |
| permissions  | read-only by default                 | can run read-only commands | can run read-only commands |
