# Multi-Agent Commands

System for writing a single command source file that builds into CLI-specific formats for Claude Code, Codex CLI, and Gemini CLI.

## How it works

```
src/<command>/
├── <command>.md    single source with agent tags
└── build.sh        generates output for each CLI

          build.sh
             │
             v
┌────────────────────────────┐
│  src/<command>/<command>.md │
│  (tagged source)           │
└─────┬──────────┬───────────┘
      │          │          │
      v          v          v
   claude      codex      gemini
```

## Output paths

| Agent  | Output path                                | Format             |
|--------|--------------------------------------------|--------------------|
| claude | `.claude/commands/<ns>/<name>.md`          | plain md           |
| codex  | `.agents/skills/<name>/SKILL.md`           | md + yaml front matter |
| gemini | `.gemini/commands/<ns>/<name>.toml`        | toml wrapper       |

Note: Codex CLI does not support project-level custom slash commands. The only way to add project-scoped reusable prompts is through Agent Skills (`.agents/skills/`). Custom prompts (`~/.codex/prompts/`) exist but are global-only and deprecated.

## Invoking commands

| Agent  | Syntax             | Example              |
|--------|--------------------|----------------------|
| claude | `/<ns>:<name>`     | `/gh:repo-naming`    |
| codex  | `$<name>`          | `$repo-naming`       |
| gemini | `/<ns>:<name>`     | `/gh:repo-naming`    |

- Claude and Gemini use slash commands with namespace derived from subdirectory path
- Codex uses `$` prefix to mention a skill by name (no namespace support)

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

| Tag                          | Meaning                            |
|------------------------------|------------------------------------|
| `<!--@only agent1,agent2-->` | block for listed agents only       |
| `<!--@agent-->`              | variant for single agent           |
| `<!--@agent1,agent2-->`      | variant for multiple agents        |
| `<!--@end-->`                | closes any block                   |
| (no tag)                     | shared, appears in all outputs     |

## Adding a new command

1. Create `src/<command>/` with `<command>.md` and `build.sh`
2. Define output paths in `build.sh` for each agent
3. Add `./src/<command>/build.sh` to the Makefile `mount` target
4. Run `make mount`

## CLI-specific differences to handle

| Concern        | Claude Code                     | Codex CLI                            | Gemini CLI                         |
|----------------|---------------------------------|--------------------------------------|------------------------------------|
| header         | plain text intro                | yaml front matter (name, desc)       | toml (description, prompt)         |
| arguments      | `<arguments>#$ARGUMENTS</arguments>` | `$ARGUMENTS`                    | `{{args}}`                         |
| config file    | CLAUDE.md                       | AGENTS.md                            | GEMINI.md                          |
| tool reference | AskUserQuestion                 | generic "ask the user"               | generic "ask the user"             |
| permissions    | read-only by default            | can run read-only commands            | can run read-only commands         |
