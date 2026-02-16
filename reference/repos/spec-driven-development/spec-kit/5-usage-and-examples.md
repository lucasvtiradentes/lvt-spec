# Spec Kit - Usage and Examples

## How to Use

Spec Kit is a CLI tool + template system. You install the CLI, bootstrap a project, then use slash commands inside your AI coding agent.

## Installation

Persistent install:

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

One-time usage:

```bash
uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>
```

## CLI Commands

| Command           | Description                                  |
|-------------------|----------------------------------------------|
| `specify init`    | Initialize a new SDD project from templates  |
| `specify check`   | Check for installed tools                    |
| `specify version` | Display CLI and system information           |

### specify init Options

| Option                 | Description                           |
|------------------------|---------------------------------------|
| `<project-name>`       | Directory name (use `.` for cwd)      |
| `--ai <agent>`         | AI assistant (17 options)             |
| `--script sh/ps`       | Shell script type                     |
| `--ignore-agent-tools` | Skip AI tool checks                   |
| `--no-git`             | Skip git initialization               |
| `--here`               | Init in current directory             |
| `--force`              | Skip non-empty dir confirmation       |
| `--skip-tls`           | Skip SSL/TLS verification             |
| `--debug`              | Verbose output                        |
| `--github-token`       | GitHub token for API requests         |

### Examples

```bash
specify init my-project --ai claude
specify init . --ai copilot
specify init --here --force --ai gemini
specify init my-project --ai claude --no-git
specify init my-project --ai claude --github-token ghp_xxx
specify check
specify version
```

## Core Workflow (6 Steps)

After `specify init`, launch your AI agent and use slash commands:

### Step 1: Establish Project Principles

```text
/speckit.constitution Create principles focused on code quality, testing standards,
user experience consistency, and performance requirements
```

This creates `memory/constitution.md` with immutable project governance.

### Step 2: Create Feature Specification

```text
/speckit.specify Build an application that can help me organize my photos in separate
photo albums. Albums are grouped by date and can be re-organized by dragging and
dropping on the main page.
```

Creates a numbered feature branch and `specs/###-feature/spec.md` with user scenarios, acceptance criteria, and functional requirements.

### Step 3: Clarify Ambiguities (optional)

```text
/speckit.clarify Focus on security and performance requirements.
```

Asks up to 5 targeted questions and updates the spec with answers.

### Step 4: Create Technical Plan

```text
/speckit.plan The application uses Vite with minimal number of libraries. Use vanilla
HTML, CSS, and JavaScript as much as possible. Images are not uploaded anywhere and
metadata is stored in a local SQLite database.
```

Generates `plan.md`, `research.md`, `data-model.md`, `contracts/`, and `quickstart.md`.

### Step 5: Generate Task Breakdown

```text
/speckit.tasks
```

Produces `tasks.md` with dependency-ordered checklist organized by user story and phase.

### Step 6: Execute Implementation

```text
/speckit.implement
```

Executes tasks phase-by-phase, checking off items as they complete.

## Additional Commands

| Command                 | Usage                                              |
|-------------------------|----------------------------------------------------|
| `/speckit.analyze`      | Cross-artifact consistency check (read-only)       |
| `/speckit.checklist`    | Generate quality checklists for requirements       |
| `/speckit.taskstoissues`| Convert tasks.md into GitHub Issues                |

## Project Structure After Init

```
.specify/
  memory/
    constitution.md            - project principles template
  scripts/
    bash/ (or powershell/)
      check-prerequisites.sh
      common.sh
      create-new-feature.sh
      setup-plan.sh
      update-agent-context.sh
  templates/
    spec-template.md
    plan-template.md
    tasks-template.md
    checklist-template.md
    agent-file-template.md

.<agent-folder>/               - e.g., .claude/commands/
  commands/
    speckit.constitution.md
    speckit.specify.md
    speckit.clarify.md
    speckit.plan.md
    speckit.tasks.md
    speckit.checklist.md
    speckit.analyze.md
    speckit.implement.md
    speckit.taskstoissues.md
```

## Project Structure After Full Workflow

```
specs/
  001-feature-name/
    spec.md                    - feature specification
    plan.md                    - technical implementation plan
    research.md                - research findings
    data-model.md              - entity model
    quickstart.md              - validation scenarios
    tasks.md                   - dependency-ordered task list
    contracts/                 - API contracts (OpenAPI, etc.)
    checklists/                - quality checklists
      requirements.md
      ux.md
      security.md
      ...
```

## Environment Configuration

```bash
export GH_TOKEN=ghp_xxx                 # GitHub API auth (5000 req/hr vs 60)
export GITHUB_TOKEN=ghp_xxx             # alternative to GH_TOKEN
export SPECIFY_FEATURE="001-my-feature" # override feature detection for non-git repos
```

## Supported AI Agents

| Agent          | CLI Command    | Config Directory          |
|----------------|----------------|---------------------------|
| Claude Code    | claude         | .claude/commands/         |
| Gemini CLI     | gemini         | .gemini/commands/         |
| GitHub Copilot | copilot        | .github/agents/           |
| Cursor         | cursor-agent   | .cursor/                  |
| Qwen Code      | qwen           | .qwen/commands/           |
| opencode       | opencode       | .opencode/commands/       |
| Codex          | codex          | .codex/commands/          |
| Windsurf       | windsurf       | .windsurf/workflows/      |
| Kilo Code      | kilocode       | .kilocode/commands/       |
| Auggie         | auggie         | .auggie/commands/         |
| Roo Code       | roo            | .roo/commands/            |
| CodeBuddy      | codebuddy      | .codebuddy/commands/      |
| Qoder          | qoder          | .qoder/commands/          |
| Amp            | amp            | .amp/commands/            |
| SHAI           | shai           | .shai/commands/           |
| Amazon Q       | q              | .amazonq/commands/        |
| IBM Bob        | bob            | .bob/commands/            |

## Local Development

```bash
python -m src.specify_cli --help

uv venv && source .venv/bin/activate
uv pip install -e .
specify --help

uvx --from . specify init demo-project --ai claude --ignore-agent-tools

uv build
```

## Troubleshooting

| Issue                              | Solution                                                   |
|------------------------------------|------------------------------------------------------------|
| ModuleNotFoundError: typer         | Run `uv pip install -e .`                                  |
| Scripts not executable on Linux    | Re-run init or `chmod +x scripts/*.sh`                     |
| Wrong script type downloaded       | Pass `--script sh` or `--script ps` explicitly             |
| TLS errors on corporate network    | Use `--skip-tls` (not for production)                      |
| Rate limiting from GitHub API      | Set `GH_TOKEN` env var (5000/hr vs 60/hr)                  |
| Not on feature branch error        | Branch must match `NNN-feature-name` or set SPECIFY_FEATURE|
| Slash commands not showing in IDE  | Restart IDE; verify files exist in agent folder            |
| Constitution overwritten on upgrade| Back up before: `cp .specify/memory/constitution.md /tmp/` |
