<!--@only codex-->
---
name: repo-naming
description: Generate GitHub repository names and/or descriptions following established naming conventions. Use when the user asks for help naming a repo, generating a repo description, or both. Do NOT use for renaming existing repos or updating GitHub settings.
---
<!--@end-->
<!--@only claude-->
You help the user generate GitHub repository names and/or descriptions following their established conventions.
<!--@end-->
<!--@only gemini-->
description = "Generate GitHub repository names and/or descriptions following naming conventions"
prompt = """
<!--@end-->

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  PHASE 0    │    │  PHASE 1    │    │  PHASE 2    │    │  PHASE 3    │    │  PHASE 4    │
│  Input      │    │  Scope      │    │  Scan Repo  │    │  Analyze    │    │  Suggest    │
│             │    │             │    │             │    │             │    │             │
│ read args   │───>│ ask: name,  │───>│ read README │───>│ combine     │───>│ present     │
│ or ask user │    │ desc, or    │    │ pkg.json,   │    │ args + repo │    │ options,    │
│ to describe │    │ both?       │    │ structure,  │    │ data to id  │    │ wait for    │
<!--@claude-->
│             │    │             │    │ CLAUDE.md   │    │ core func   │    │ user choice │
<!--@codex-->
│             │    │             │    │ AGENTS.md   │    │ core func   │    │ user choice │
<!--@gemini-->
│             │    │             │    │ GEMINI.md   │    │ core func   │    │ user choice │
<!--@end-->
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## Input

The user MUST provide a brief description of what the project does as argument. If the argument is empty, ask the user to describe the project and STOP.

<!--@claude-->
<arguments>
#$ARGUMENTS
</arguments>
<!--@codex-->
User input: $ARGUMENTS
<!--@gemini-->
User input: {{args}}
<!--@end-->

## Naming Conventions

### Repository Name
- lowercase kebab-case
- concise: 1-3 words preferred, max 4
- descriptive but short
- no prefixes like "my-" or "node-"
- compound tools can use a suffix like `-cmd`, `-api`, `-action`
- suggestions must be in English

### Description
- format: `{emoji} {lowercase description}`
- starts with a single relevant emoji
- lowercase after the emoji (no capital letter)
- action-oriented or defines what it is
- often ends with a benefit/qualifier phrase (e.g. "for power users", "effortlessly", "from the command line")
- no period at the end
- keep it under ~80 characters
- suggestions must be in English

### Reference Examples
- tscanner: `🔍 code quality scanner for the AI-generated code era`
- ominidocs: `📚 unified docs for humans and agents`
- claude-code-scheduler: `🤖 automated claude code session runner for power users`
- repositories-manager: `🔄 sync and manage your git repositories effortlessly`
- md-align: `📏 Auto-fix alignment in markdown docs`

## Process

### Phase 0: Input

Read the user's argument. If empty, ask for a project description and STOP.

### Phase 1: Scope

<!--@claude-->
Ask the user what they need using AskUserQuestion:
<!--@codex,gemini-->
Ask the user what they need:
<!--@end-->
- Name only
- Description only
- Both (name + description)

STOP and wait for the answer before proceeding.

### Phase 2: Scan Repo

Explore the current repo to understand what the project actually does. Read these in parallel:
- README.md (or README) at repo root
- package.json, pyproject.toml, Cargo.toml, go.mod, or equivalent manifest
- Top-level folder structure (ls root)
<!--@claude-->
- CLAUDE.md if it exists
<!--@codex-->
- AGENTS.md if it exists
<!--@gemini-->
- GEMINI.md if it exists
<!--@end-->

Use this data together with the user's argument to build a complete picture.

### Phase 3: Analyze

Combine the user's description + repo scan to identify:
- core functionality
- target audience
- key differentiator

### Phase 4: Suggest

Generate 3-5 options based on scope chosen in Phase 1.

If scope is "name only":

```
# Repo Name Suggestions

1. name-one
2. name-two
3. name-three
4. name-four
5. name-five
```

If scope is "description only":

```
# Repo Description Suggestions

1. 📦 short description that explains the project
2. 🔧 alternative description angle
3. ⚡ yet another take on it
```

If scope is "both":

```
# Repo Name Suggestions

1. name-one
2. name-two
3. name-three
4. name-four
5. name-five

# Repo Description Suggestions

1. 📦 short description that explains the project
2. 🔧 alternative description angle
3. ⚡ yet another take on it
```

After presenting, STOP and ask which one they prefer, or if they want to mix-and-match parts from different options. The user may also ask for more options or tweaks.

<!--@claude-->
Do NOT run any commands or create anything — this is purely a suggestion tool.
<!--@codex-->
You may run read-only commands to inspect the repo (e.g., `ls`, `rg`, `cat`, `sed`) as part of Phase 2. Do not create or modify files.
<!--@gemini-->
You may run read-only commands to inspect the repo as part of Phase 2. Do not create or modify files.
<!--@end-->
<!--@only gemini-->
"""
<!--@end-->
