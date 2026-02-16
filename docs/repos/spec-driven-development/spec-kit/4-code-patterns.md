# Spec Kit - Code Patterns

## Coding Style and Conventions

### Naming Conventions

| Context    | Convention        | Examples                                              |
|------------|-------------------|-------------------------------------------------------|
| Python     | snake_case        | `check_tool`, `run_command`, `download_template`      |
| Constants  | UPPER_SNAKE_CASE  | `AGENT_CONFIG`, `BANNER`, `SCRIPT_TYPE_CHOICES`       |
| Bash       | snake_case        | `get_repo_root`, `check_feature_branch`               |
| PowerShell | PascalCase        | `Get-RepoRoot`, `Test-FeatureBranch`, `Build-Variant` |

### File Organization

The entire Python CLI lives in a single `__init__.py` file (~1370 lines). No module splitting, no separate packages. All functions, classes, and constants coexist in one file.

```
src/specify_cli/__init__.py   - single-file Python CLI (1370 lines, monolithic)
scripts/bash/                  - POSIX shell scripts
scripts/powershell/            - PowerShell equivalents (1:1 parity)
templates/commands/            - markdown command templates
.github/workflows/scripts/     - CI helper scripts
```

### Import Pattern

All imports at the top of the single file. Stdlib first, then third-party:

```python
import os
import subprocess
import sys
import zipfile
import tempfile
import shutil
import shlex
import json
from pathlib import Path
from typing import Optional, Tuple

import typer
import httpx
from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, TextColumn
```

No `__all__` export list. Single entry point via `main()` --> `app()`.

### Shell Script Pattern

Bash scripts use `source "$SCRIPT_DIR/common.sh"` for shared functions. Path resolution via `BASH_SOURCE[0]`. PowerShell uses dot-sourcing with `. "$PSScriptRoot/common.ps1"`.

## Testing Approach

No tests exist. Zero test files -- no `tests/` directory, no `test_*.py`, no test configuration. CONTRIBUTING.md states "Write tests for new functionality" but the project itself has none.

Testing is entirely manual:
- `uv run specify --help`
- Test CLI commands with a sample project
- Build release packages locally and verify

## CI/CD Setup

Three GitHub Actions workflows:

| Workflow     | Trigger                              | Steps                                     |
|--------------|--------------------------------------|-------------------------------------------|
| lint.yml     | push to main + PRs                   | markdownlint-cli2 on all *.md             |
| release.yml  | push to main (template/script paths) | version bump, build 34 zips, GH Release   |
| docs.yml     | push to main (docs/)                 | build DocFX docs, deploy to GH Pages      |

Release pipeline sequence:

```
get-next-version.sh
       │
       v
check-release-exists.sh ----> skip if exists
       │
       v
create-release-packages.sh ----> 34 ZIP archives
       │
       v
generate-release-notes.sh ----> changelog from git log
       │
       v
create-github-release.sh ----> upload all zips
       │
       v
update-version.sh ----> bump pyproject.toml
```

All CI scripts use `set -euo pipefail` for strict error handling.

## Error Handling Patterns

### Python CLI

Uses `try/except` with `raise typer.Exit(1)` for user-facing errors. Rich console panels for formatted error output:

```python
except Exception as e:
    console.print(f"[red]Error downloading template[/red]")
    if zip_path.exists():
        zip_path.unlink()
    console.print(Panel(detail, title="Download Error", border_style="red"))
    raise typer.Exit(1)
```

GitHub API errors include rate-limit header parsing with actionable troubleshooting tips. Network errors are caught, displayed, and cleaned up (zip files deleted on failure).

### Bash Scripts

`set -e` (some also `set -u` and `set -o pipefail`). Explicit error messages to stderr with `>&2`. Cleanup traps for temp files:

```bash
trap cleanup EXIT INT TERM
```

### PowerShell Scripts

`$ErrorActionPreference = "Stop"` for fail-fast behavior.

## Logging Approach

No structured logging framework. All output goes through:

| Context    | Method                                                     |
|------------|------------------------------------------------------------|
| Python     | `rich.console.Console` with color-coded messages           |
| Python     | `StepTracker` class with `Rich.Tree` for progress display  |
| Bash       | `echo` with prefixes via helpers (log_info, log_error)     |
| PowerShell | Write-Host, Write-Warning, Write-Error                     |

No log files, no log levels, no logging configuration. The `--debug` flag enables extra diagnostic output.

## Type System Usage

Python 3.11+ required. Type hints used minimally:

```python
def run_command(cmd: list[str], check_return: bool = True, capture: bool = False, shell: bool = False) -> Optional[str]:
def init_git_repo(project_path: Path, quiet: bool = False) -> Tuple[bool, Optional[str]]:
def _github_token(cli_token: str | None = None) -> str | None:
```

Uses PEP 604 union syntax (`str | None`) and PEP 585 lowercase generics (`list[str]`). No `TypedDict`, `Protocol`, `dataclass`, or `Literal`. No type checker configured (no mypy, pyright).

## Code Quality Tools

| Tool              | Config File                  | Scope   |
|-------------------|------------------------------|---------|
| markdownlint-cli2 | .markdownlint-cli2.jsonc     | *.md    |
| .gitattributes    | * text=auto eol=lf           | all     |

Not present: Python linter (ruff, flake8, pylint), Python formatter (black, isort), .editorconfig, pre-commit hooks, Makefile, type checker.

The markdownlint config disables MD013 (line length), MD033 (inline HTML), MD041 (first-line-h1), and enforces ATX-style headings with asterisk-style emphasis.

## Documentation Patterns

Python CLI uses extensive docstrings:

```python
def merge_json_files(existing_path: Path, new_content: dict, verbose: bool = False) -> dict:
    """Merge new JSON content into existing JSON file.

    Performs a deep merge where:
    - New keys are added
    - Existing keys are preserved unless overwritten by new content
    - Nested dictionaries are merged recursively
    - Lists and other values are replaced (not merged)

    Args:
        existing_path: Path to existing JSON file
        new_content: New JSON content to merge in
        verbose: Whether to print merge details

    Returns:
        Merged JSON content as dict
    """
```

Bash scripts use header comment blocks with purpose, usage, options, and examples. PowerShell scripts use formal `<# .SYNOPSIS .DESCRIPTION .PARAMETER .EXAMPLE #>` comment-based help.

AGENTS.md serves as the primary contributor documentation with step-by-step guide for adding new AI agents.

## State Management

No persistent state management. The CLI is stateless -- each invocation reads from filesystem and GitHub API, writes to filesystem.

Runtime state:
- `StepTracker` class holds mutable step list with status tracking (pending/running/done/error/skipped)
- Global `console = Console()` singleton
- Global `client = httpx.Client(verify=ssl_context)` HTTP client singleton
- `sys._specify_tracker_active = True` -- private attribute on sys module for cross-function state

Feature state managed via filesystem convention:
- Feature branches: `NNN-feature-name` pattern
- Spec directories: `specs/NNN-feature-name/`
- Environment variable `SPECIFY_FEATURE` for non-git repos
