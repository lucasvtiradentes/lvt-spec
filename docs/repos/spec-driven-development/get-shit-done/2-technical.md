# Technical Documentation

## Tech Stack

| Category       | Technology                              |
|----------------|-----------------------------------------|
| Language       | JavaScript (Node.js, CommonJS modules)  |
| Runtime        | Node.js >= 16.7.0                       |
| Package mgr    | npm                                     |
| Build tool     | esbuild (dev only, for hook bundling)   |
| Test framework | Node.js built-in test runner (node:test)|
| Distribution   | npm package (get-shit-done-cc)          |
| VCS            | Git                                     |

The project is NOT a web application. It is a meta-prompting system that installs as slash commands + agents into AI coding assistants. No databases, no servers, no Docker.

Target runtimes (AI coding tools it integrates with):

1. Claude Code (Anthropic) - primary target
2. OpenCode (open source)  - supported
3. Gemini CLI (Google)     - supported

## Dependencies

Production dependencies: none (zero runtime dependencies).

Dev dependencies:

| Package | Version  | Purpose                     |
|---------|----------|-----------------------------|
| esbuild | ^0.24.0  | Build hooks (copy to dist/) |

All code uses Node.js built-in modules only: `fs`, `path`, `os`, `readline`, `crypto`, `child_process`, `node:test`, `node:assert`.

## Installation

Standard install (end user):

```bash
npx get-shit-done-cc@latest
```

Interactive prompts ask for:
1. Runtime selection (Claude Code / OpenCode / Gemini / All)
2. Location (Global or Local to current project)

Non-interactive install:

```bash
npx get-shit-done-cc --claude --global     # Claude Code to ~/.claude/
npx get-shit-done-cc --claude --local      # Claude Code locally to ./.claude/
npx get-shit-done-cc --opencode --global   # OpenCode to ~/.config/opencode/
npx get-shit-done-cc --gemini --global     # Gemini to ~/.gemini/
npx get-shit-done-cc --all --global        # All runtimes
```

Development install:

```bash
git clone https://github.com/glittercowboy/get-shit-done.git
cd get-shit-done
node bin/install.js --claude --local
```

Uninstall:

```bash
npx get-shit-done-cc --claude --global --uninstall
```

What the installer does:

1. Copies `commands/gsd/` (slash commands) to target config dir
2. Copies `get-shit-done/` (workflows, templates, references, CLI tools) to target dir
3. Copies `agents/` (sub-agent prompts) to target dir
4. Copies built hooks from `hooks/dist/` (statusline, update checker)
5. Writes `VERSION` file and `gsd-file-manifest.json` for upgrade tracking
6. Configures `settings.json` (hooks for SessionStart, statusline)
7. For OpenCode: flattens command structure, converts YAML frontmatter, configures permissions
8. For Gemini: converts commands to TOML format, converts agent frontmatter

## Installer CLI Flags

| Flag                  | Short | Purpose                            |
|-----------------------|-------|------------------------------------|
| --global              | -g    | Install to global config dir       |
| --local               | -l    | Install to current project dir     |
| --claude              |       | Target Claude Code runtime         |
| --opencode            |       | Target OpenCode runtime            |
| --gemini              |       | Target Gemini CLI runtime          |
| --all                 |       | Target all runtimes                |
| --both                |       | Legacy: Claude + OpenCode          |
| --uninstall           | -u    | Remove GSD from target             |
| --config-dir <path>   | -c    | Custom config directory path       |
| --force-statusline    |       | Replace existing statusline config |
| --help                | -h    | Show help                          |

## Configuration

### Environment Variables

| Variable             | Purpose                                           |
|----------------------|---------------------------------------------------|
| CLAUDE_CONFIG_DIR    | Override Claude Code config directory (~/.claude) |
| OPENCODE_CONFIG_DIR  | Override OpenCode config directory                |
| OPENCODE_CONFIG      | OpenCode config file path (dir derived from it)   |
| XDG_CONFIG_HOME      | XDG base dir for OpenCode fallback                |
| GEMINI_CONFIG_DIR    | Override Gemini config directory (~/.gemini)      |

No `.env` files exist. The tool does not require API keys.

### Project Config (.planning/config.json)

Created per-project during `/gsd:new-project`:

```json
{
  "mode": "interactive",
  "depth": "standard",
  "workflow": {
    "research": true,
    "plan_check": true,
    "verifier": true
  },
  "planning": {
    "commit_docs": true,
    "search_gitignored": false
  },
  "parallelization": {
    "enabled": true,
    "plan_level": true,
    "task_level": false,
    "skip_checkpoints": true,
    "max_concurrent_agents": 3,
    "min_plans_for_parallel": 2
  },
  "gates": {
    "confirm_project": true,
    "confirm_phases": true,
    "confirm_roadmap": true,
    "confirm_breakdown": true,
    "confirm_plan": true,
    "execute_next_plan": true,
    "issues_review": true,
    "confirm_transition": true
  },
  "safety": {
    "always_confirm_destructive": true,
    "always_confirm_external_services": true
  }
}
```

### Settings Reference

| Setting                    | Options                              | Default       |
|----------------------------|--------------------------------------|---------------|
| mode                       | yolo, interactive                    | interactive   |
| depth                      | quick, standard, comprehensive       | standard      |
| model_profile              | quality, balanced, budget            | balanced      |
| workflow.research          | boolean                              | true          |
| workflow.plan_check        | boolean                              | true          |
| workflow.verifier          | boolean                              | true          |
| parallelization.enabled    | boolean                              | true          |
| planning.commit_docs       | boolean                              | true          |
| git.branching_strategy     | none, phase, milestone               | none          |

### Model Profiles

Control which Claude model each sub-agent uses:

| Agent                    | quality | balanced | budget |
|--------------------------|---------|----------|--------|
| gsd-planner              | opus    | opus     | sonnet |
| gsd-roadmapper           | opus    | sonnet   | sonnet |
| gsd-executor             | opus    | sonnet   | sonnet |
| gsd-phase-researcher     | opus    | sonnet   | haiku  |
| gsd-project-researcher   | opus    | sonnet   | haiku  |
| gsd-research-synthesizer | sonnet  | sonnet   | haiku  |
| gsd-debugger             | opus    | sonnet   | sonnet |
| gsd-codebase-mapper      | sonnet  | haiku    | haiku  |
| gsd-verifier             | sonnet  | sonnet   | haiku  |
| gsd-plan-checker         | sonnet  | sonnet   | haiku  |
| gsd-integration-checker  | sonnet  | sonnet   | haiku  |

## Build and Deploy

Build:

```bash
npm run build:hooks    # Copies hooks/*.js to hooks/dist/
```

Test:

```bash
npm test    # node --test get-shit-done/bin/gsd-tools.test.js
```

Publish:

```bash
npm publish    # Triggers prepublishOnly which runs build:hooks first
```

Published to npm as `get-shit-done-cc`. No CI/CD pipeline -- publishing is manual.
