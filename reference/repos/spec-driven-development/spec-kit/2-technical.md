# Spec Kit - Technical Details

## Tech Stack

| Aspect       | Value                                    |
|--------------|------------------------------------------|
| Language     | Python 3                                 |
| Runtime      | CPython >=3.11                           |
| CLI          | Typer + Rich (terminal UI)               |
| HTTP         | httpx with truststore SSL                |
| Package mgr  | uv (astral-sh), pip-compatible           |
| Build system | Hatchling                                |
| Docs         | DocFX (.NET-based static site generator) |
| CI/CD        | GitHub Actions                           |
| Linting      | markdownlint-cli2                        |
| License      | MIT                                      |

## Production Dependencies

| Package       | Version Constraint | Purpose                              |
|---------------|--------------------|--------------------------------------|
| typer         | (unpinned)         | CLI framework                        |
| rich          | (unpinned)         | Terminal UI (panels, progress, trees)|
| httpx[socks]  | (unpinned)         | HTTP client (GitHub API, downloads)  |
| platformdirs  | (unpinned)         | Platform-specific directory paths    |
| readchar      | (unpinned)         | Cross-platform keyboard input        |
| truststore    | >=0.10.4           | SSL/TLS certificate handling         |

## Dev Dependencies

No declared dev dependencies. No test framework configured. The devcontainer post-create script installs AI agent CLIs and tooling:

| Tool                         | Install Method |
|------------------------------|----------------|
| @anthropic-ai/claude-code    | npm            |
| @google/gemini-cli           | npm            |
| @github/copilot              | npm            |
| @openai/codex                | npm            |
| @augmentcode/auggie          | npm            |
| @qwen-code/qwen-code         | npm            |
| opencode-ai                  | npm            |
| @tencent-ai/codebuddy-code   | npm            |
| Amazon Q Developer CLI       | binary         |
| uv                           | pipx           |
| docfx                        | dotnet tool    |

## Installation

Persistent install (recommended):

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

One-time usage:

```bash
uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>
```

Editable/dev install:

```bash
uv venv && source .venv/bin/activate
uv pip install -e .
```

Upgrade:

```bash
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git
```

## Build System

| Field          | Value                          |
|----------------|--------------------------------|
| build-backend  | hatchling.build                |
| build-requires | hatchling                      |
| wheel packages | src/specify_cli                |
| entry point    | specify = "specify_cli:main"   |
| CLI version    | 0.0.22                         |

## Configuration

### Environment Variables

| Variable         | Purpose                                                     |
|------------------|-------------------------------------------------------------|
| GH_TOKEN         | GitHub API auth (increases rate limit from 60 to 5000/hr)   |
| GITHUB_TOKEN     | Same as GH_TOKEN (fallback)                                 |
| SPECIFY_FEATURE  | Override feature detection for non-Git repos                |
| AGENTS           | Filter which agents to build in release script              |
| SCRIPTS          | Filter which script types to build (sh, ps)                 |
| CODEX_HOME       | Set by user for Codex CLI integration                       |

### CLI Flags (specify init)

| Flag                   | Type   | Description                              |
|------------------------|--------|------------------------------------------|
| `<project-name>`       | arg    | Project directory name (or `.` for cwd)  |
| `--ai`                 | option | AI assistant selection (17 agents)       |
| `--script`             | option | Script type: sh or ps                    |
| `--ignore-agent-tools` | flag   | Skip CLI tool checks                     |
| `--no-git`             | flag   | Skip git init                            |
| `--here`               | flag   | Init in current directory                |
| `--force`              | flag   | Skip confirmation on non-empty dir       |
| `--skip-tls`           | flag   | Skip SSL/TLS verification                |
| `--debug`              | flag   | Verbose diagnostic output                |
| `--github-token`       | option | GitHub token for API requests            |

### Config Files

| File                             | Purpose                               |
|----------------------------------|---------------------------------------|
| pyproject.toml                   | Python project metadata, deps, build  |
| .markdownlint-cli2.jsonc         | Markdown linting rules                |
| .devcontainer/devcontainer.json  | Dev container config (Python 3.13)    |
| .gitattributes                   | Forces LF line endings                |
| docs/docfx.json                  | DocFX documentation site config       |
| templates/vscode-settings.json   | VS Code settings for Copilot          |

## CI/CD Workflows

| Workflow     | Trigger                                        | Purpose                                   |
|--------------|------------------------------------------------|-------------------------------------------|
| lint.yml     | push to main, PRs                              | markdownlint-cli2 on all *.md             |
| release.yml  | push to main (memory/scripts/templates), manual| auto-version, build 34 zips, GH release   |
| docs.yml     | push to main (docs/), manual                   | build DocFX site, deploy to GH Pages      |

### Release Pipeline

| Script                       | Purpose                                    |
|------------------------------|--------------------------------------------|
| get-next-version.sh          | Auto-increment patch version from last tag |
| check-release-exists.sh      | Skip if release already exists             |
| create-release-packages.sh   | Build 34 zip archives (17 agents x 2)      |
| generate-release-notes.sh    | Generate changelog from git log            |
| create-github-release.sh     | Upload all zips to GitHub Release          |
| update-version.sh            | Update pyproject.toml version              |

## Minimum Requirements

| Requirement | Version  | Source              |
|-------------|----------|---------------------|
| Python      | >=3.11   | pyproject.toml      |
| uv          | any      | README              |
| Git         | any      | optional            |
| .NET        | 8.x      | docs.yml (DocFX)    |

## Supported AI Agents (17)

claude, gemini, copilot, cursor-agent, qwen, opencode, codex, windsurf, kilocode, auggie, roo, codebuddy, qoder, amp, shai, q (Amazon Q), bob (IBM Bob)
