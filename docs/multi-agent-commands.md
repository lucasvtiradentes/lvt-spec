# Multi-Agent Commands

System for writing a single command source file that builds into CLI-specific formats for Claude Code, Codex CLI, and Gemini CLI.

## How it works

```
src/
├── config.json                central config (metadata + routing)
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
│  src/config.json │────>│  src/<command>/  │
│  (routing)       │     │  (source files)  │
└──────────────────┘     └────┬─────┬─────┬─┘
                              │     │     │
                              v     v     v
                           claude codex gemini
```

The build script auto-generates headers and footers per agent from config metadata. Source files contain only the shared body + agent-specific variant tags.

## Config

All commands are registered in `src/config.json`:

```json
{
  "align-docs": {
    "namespace": "docs",
    "title": "Align Docs",
    "description": "Auto-fix alignment issues in markdown files using mdalign..."
  },
  "analyse-repo": {
    "namespace": "research",
    "title": "Analyse Repo",
    "description": "Analyse a GitHub repository and create structured documentation..."
  },
  "gen-docs": {
    "namespace": "docs",
    "title": "Gen Docs",
    "description": "Interactive, state-aware command that generates structured project documentation..."
  },
  "repo-naming": {
    "namespace": "gh",
    "title": "Repo Naming",
    "description": "Generate GitHub repository names and/or descriptions following naming conventions..."
  }
}
```

| Field         | Required | Default                       | Description                                                                         |
|---------------|----------|-------------------------------|-------------------------------------------------------------------------------------|
| `namespace`   | yes      | -                             | output subdirectory (gh, docs, research)                                            |
| `title`       | yes      | -                             | command title (used in claude h1)                                                   |
| `description` | yes      | -                             | command description (all agents), include usage hints (when to use, when NOT to use)|
| `agents`      | no       | `["claude","codex","gemini"]` | which agents to build for                                                           |

## Auto-generated headers and footers

The build script prepends/appends the correct format per agent using config metadata:

| Agent  | Header                                       | Footer |
|--------|----------------------------------------------|--------|
| claude | `# {title}\n\n{description}`                 | -      |
| codex  | `---\nname: {name}\ndescription: {desc}\n---`| -      |
| gemini | `description = "{desc}"\nprompt = """`       | `"""`  |

Source files should NOT include these - they are injected automatically.

## Output paths

| Agent  | Output path                           | Format                 |
|--------|---------------------------------------|------------------------|
| claude | `.claude/commands/<ns>/<name>.md`     | plain md               |
| codex  | `.agents/skills/<name>/SKILL.md`      | md + yaml front matter |
| gemini | `.gemini/commands/<ns>/<name>.toml`   | toml wrapper           |

Note: Codex CLI does not support project-level custom slash commands. The only way to add project-scoped reusable prompts is through Agent Skills (`.agents/skills/`). Custom prompts (`~/.codex/prompts/`) exist but are global-only and deprecated.

## Invoking commands

| Agent  | Syntax         | Example               |
|--------|----------------|-----------------------|
| claude | `/<ns>:<name>` | `/docs:gen-docs`      |
| codex  | `$<name>`      | `$gen-docs`           |
| gemini | `/<ns>:<name>` | `/docs:gen-docs`      |

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

Tags are HTML comments, invisible if rendered as raw markdown. Only two tags exist: `<!--@agent-->` and `<!--@end-->`.

### Switch between agents

Each agent gets their own variant. Non-matching agents get nothing:

```md
<!--@claude-->
CLAUDE.md if it exists
<!--@codex-->
AGENTS.md if it exists
<!--@gemini-->
GEMINI.md if it exists
<!--@end-->
```

### Block for specific agents

Same syntax, just list the agents. Unlisted agents get nothing:

```md
<!--@codex,gemini-->
You may run read-only commands.
<!--@end-->
```

### Inline addendum

Shared generic line + agent-specific details below it. The shared line appears for all agents; the tagged block only for the matching agent:

```md
Launch exactly 3 agents in PARALLEL to explore the codebase.
<!--@claude-->
Use `Task` with `subagent_type: "Explore"` and `run_in_background: true` for each agent.
<!--@end-->
```

Claude output gets both lines. Codex/Gemini output gets only the shared line. Use this pattern for tool-specific instructions that augment shared text without duplicating it.

### No tag

Lines without any tag are shared and appear in every output.

## Tag reference

| Tag                     | Meaning                        |
|-------------------------|--------------------------------|
| `<!--@agent-->`         | variant for single agent       |
| `<!--@agent1,agent2-->` | variant for multiple agents    |
| `<!--@end-->`           | closes any variant block       |
| (no tag)                | shared, appears in all outputs |

## Adding a new command

1. Create `src/<command>/` with `<command>.md`
2. Add entry to `src/config.json` with namespace, title, description
3. Use `<!--@agent-->` tags for agent-specific content in the body
4. Run `make mount`

## CLI-specific differences to handle

| Concern      | Claude Code                            | Codex CLI                  | Gemini CLI                 |
|--------------|----------------------------------------|----------------------------|----------------------------|
| arguments    | `<arguments>#$ARGUMENTS</arguments>`   | `$ARGUMENTS`               | `{{args}}`                 |
| config file  | CLAUDE.md                              | AGENTS.md                  | GEMINI.md                  |
| tool ref     | AskUserQuestion                        | generic "ask the user"     | generic "ask the user"     |
| agent launch | Task (subagent_type, run_in_background)| generic "launch agent"     | generic "launch agent"     |
| agent wait   | TaskOutput(block=true)                 | generic "wait for agent"   | generic "wait for agent"   |
| permissions  | read-only by default                   | can run read-only commands | can run read-only commands |

## Current commands

| Command       | Namespace  | Source format  | Tags |
|---------------|------------|----------------|------|
| align-docs    | docs       | single-file    | yes  |
| analyse-repo  | research   | single-file    | yes  |
| gen-docs      | docs       | split (6 files)| yes  |
| repo-naming   | gh         | single-file    | yes  |
