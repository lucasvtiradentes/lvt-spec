# Technical Details

## Tech Stack

| Aspect    | Detail                                                  |
|-----------|---------------------------------------------------------|
| Type      | Claude Code Plugin Marketplace (not a traditional app)  |
| Language  | Markdown (`.md` files are the "source code")            |
| Runtime   | Claude Code CLI (`claude` command)                      |
| Framework | Claude Code Plugin System (`.claude-plugin/` convention)|
| Version   | Plugin `por-dev` at v1.1.0                              |

This is NOT a software application. It is a collection of structured markdown prompt templates that serve as slash commands inside the Claude Code CLI. There is no compiled code, no server, no build step.

## Dependencies

Zero external dependencies. No `package.json`, `pyproject.toml`, `requirements.txt`, `Dockerfile`, or `Makefile` exist.

The only runtime requirement is the Claude Code CLI itself, which must support the plugin marketplace feature.

Some command files reference tools the user's Claude Code session may have available:

| Tool/Integration | Referenced In         | Purpose                              |
|------------------|-----------------------|--------------------------------------|
| WebSearch        | `design.md`           | Research unfamiliar libraries        |
| Context7         | `design.md`           | Library documentation lookup         |
| Perplexity       | `design.md`           | Technical research                   |
| MCP Tools        | `discover.md`         | Project management card integration  |
| `uv add`         | `bug.md`, `feature.md`| Python dependency management         |
| `git`            | multiple commands     | Branching, diffing, file listing     |

## Installation

```bash
claude plugin marketplace add https://github.com/lfnovo/por-marketplace
claude plugin install por-dev@por-marketplace
```

No build, no `npm install`, no `pip install`. Just two CLI commands.

## Configuration

No env vars. No config files beyond the two plugin manifests:

| File                                | Purpose                                            |
|-------------------------------------|----------------------------------------------------|
| `.claude-plugin/marketplace.json`   | Marketplace manifest: name, owner, list of plugins |
| `por-dev/.claude-plugin/plugin.json`| Plugin manifest: name, description, version, author|

`marketplace.json` structure:
```json
{
  "name": "por-marketplace",
  "owner": { "name": "Luis Novo" },
  "plugins": [
    { "name": "por-dev", "source": "./por-dev", "description": "..." }
  ]
}
```

`plugin.json` structure:
```json
{
  "name": "por-dev",
  "description": "A development plugin for the Product on Rails methodology",
  "version": "1.1.0",
  "author": { "name": "Luis Novo" }
}
```

Some command files use YAML frontmatter for per-command config:

| Field          | Purpose                                              |
|----------------|------------------------------------------------------|
| `description`  | Command help text shown in Claude Code               |
| `argument-hint`| CLI argument placeholder (e.g., `[optional-context]`)|
| `model`        | Preferred model (e.g., `opus` in discover/design)    |

## Build/Run Commands

No build step. The plugin is used via slash commands in Claude Code sessions:

| Command                    | File                                       | Purpose                                      |
|----------------------------|--------------------------------------------|----------------------------------------------|
| `/prime`                   | `commands/prime.md`                        | Load codebase context (git ls-files, README) |
| `/discover <input>`        | `commands/discover.md`                     | Create feature spec from requirements        |
| `/design`                  | `commands/design.md`                       | Technical architecture design                |
| `/plan`                    | `commands/plan.md`                         | Break architecture into implementation tasks |
| `/implement [--ff/phases]` | `commands/implement.md`                    | Execute the plan                             |
| `/fast:bug <desc>`         | `commands/fast/bug.md`                     | Quick bug fix planning                       |
| `/fast:chore <desc>`       | `commands/fast/chore.md`                   | Quick maintenance task planning              |
| `/fast:feature <desc>`     | `commands/fast/feature.md`                 | Quick feature planning                       |
| `/all-tools`               | `commands/util/all-tools.md`               | List available Claude Code tools             |
| `/generate-all-claude-mds` | `commands/util/generate-all-claude-mds.md` | Generate CLAUDE.md docs for codebase         |

## Development Setup

No dev tooling. The `.gitignore` excludes `.beta/`, `.claude`, `.DS_Store`.

To develop/modify this plugin:

1. Clone the repo
2. Edit markdown files in `por-dev/commands/`
3. Update version in `por-dev/.claude-plugin/plugin.json`
4. To add a new plugin: create a new folder at root, add `.claude-plugin/plugin.json`, register in `.claude-plugin/marketplace.json`
