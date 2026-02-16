# Usage and Examples

## Quick Start

```bash
cd your-project
bd init                                   # initialize beads in repo
bd create "Set up database" -p 1 -t task  # create issue
bd create "Create API" -p 2 -t feature   # create another
bd dep add <api-id> <db-id>               # API depends on database
bd ready                                  # show tasks with no blockers
bd update <id> --claim                    # atomically claim task
bd close <id> --reason "Done"             # complete task
bd sync                                   # force immediate git sync
```

## Core CLI Commands

| Command                                       | Description                     |
|-----------------------------------------------|---------------------------------|
| `bd init`                                     | initialize in repo              |
| `bd create "Title" -t type -p 0-4 -d "desc"`  | create issue                    |
| `bd list --status open --json`                | list/filter issues              |
| `bd ready --json`                             | tasks with no open blockers     |
| `bd show <id> --json`                         | view issue details              |
| `bd update <id> --claim --json`               | atomically claim task           |
| `bd update <id> --status in_progress`         | change status                   |
| `bd close <id> --reason "text"`               | close issue                     |
| `bd reopen <id>`                              | reopen closed issue             |
| `bd dep add <child> <parent>`                 | add dependency                  |
| `bd dep tree <id>`                            | view dependency tree            |
| `bd label add <id> <label>`                   | add label                       |
| `bd blocked`                                  | show blocked issues             |
| `bd stats`                                    | statistics                      |
| `bd stale --days 30`                          | find stale issues               |
| `bd sync`                                     | export/commit/pull/import/push  |
| `bd info --json`                              | database path and daemon status |
| `bd kv set/get/list`                          | key-value store                 |
| `bd admin compact`                            | compaction (memory decay)       |
| `bd admin cleanup`                            | bulk delete closed issues       |
| `bd admin reset --force`                      | remove all local beads data     |
| `bd daemons list/health/killall`              | daemon management               |
| `bd import/export`                            | JSONL import/export             |
| `bd migrate`                                  | database migration              |
| `bd formula list`                             | template management             |
| `bd mol pour/bond/squash/burn`                | molecule commands               |
| `bd setup claude/cursor/aider/codex`          | editor integration setup        |

## Common Flags

| Flag             | Description                      |
|------------------|----------------------------------|
| `--json`         | machine-readable JSON output     |
| `--no-daemon`    | bypass background daemon         |
| `--sandbox`      | sandbox mode (no daemon/sync)    |
| `--allow-stale`  | skip staleness check             |
| `--actor <name>` | custom actor for audit trail     |
| `--db <path>`    | custom database path             |
| `--verbose/-v`   | verbose output                   |
| `--quiet/-q`     | suppress informational messages  |

## Issue Types, Statuses, Priorities

Types: `bug`, `feature`, `task`, `epic`, `chore`

Statuses: `open`, `in_progress`, `blocked`, `deferred`, `closed`, `tombstone`, `pinned`

Priorities: `0` (critical) through `4` (backlog)

Dependency types: `blocks`, `related`, `parent-child`, `discovered-from`

## Hierarchical IDs (Epics)

```bash
bd create "Auth System" -t epic -p 1           # bd-a3f8e9
bd create "Login UI" -p 1 --parent bd-a3f8e9   # bd-a3f8e9.1
bd create "Backend" -p 1 --parent bd-a3f8e9    # bd-a3f8e9.2
```

Up to 3 levels of nesting supported.

## Agent Workflow Pattern

Standard loop used by all agent examples:

```
  1. bd ready --json --limit 1         - find ready work
  2. bd update <id> --claim --json     - claim task
  3. (do the work)
  4. bd create "Found bug" \
       --deps discovered-from:<id>     - discover new issues during work
  5. bd close <id> --reason "Done"     - complete task
  6. bd sync                           - end of session sync
```

## Python Agent Example

```python
import subprocess, json

def bd(args):
    result = subprocess.run(["bd"] + args + ["--json"],
                          capture_output=True, text=True)
    return json.loads(result.stdout) if result.stdout else None

ready = bd(["ready", "--limit", "1"])
if ready and ready.get("issues"):
    issue = ready["issues"][0]
    bd(["update", issue["id"], "--claim"])
    # ... do work ...
    bd(["close", issue["id"], "--reason", "Completed by agent"])
```

## Bash Agent Example

```bash
#!/bin/bash
READY=$(bd ready --json --limit 1 | jq -r '.issues[0].id // empty')
[ -z "$READY" ] && echo "No ready work" && exit 0

bd update "$READY" --claim --json
# ... do work ...
bd close "$READY" --reason "Done" --json
bd sync
```

## Go Library API

```go
import "github.com/steveyegge/beads"

store, _ := beads.NewSQLiteStorage(ctx, dbPath)
defer store.Close()

// find ready work
ready, _ := store.GetReadyWork(ctx, beads.WorkFilter{Limit: 5})

// create issue
issue := &beads.Issue{Title: "Fix bug", Type: beads.IssueTypeBug, Priority: 1}
store.CreateIssue(ctx, issue)

// add dependency
store.AddDependency(ctx, beads.Dependency{
    SourceID: childID, TargetID: parentID, Type: beads.DependencyTypeBlocks,
})

// close issue
store.CloseIssue(ctx, issueID, "Done")

// access raw SQL for custom tables
db := store.UnderlyingDB()
db.Exec("CREATE TABLE IF NOT EXISTS myapp_data (...)")
```

## MCP Server (for Claude Desktop)

Install: `uv tool install beads-mcp` or `pip install beads-mcp`

Config (`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "beads": {
      "command": "beads-mcp"
    }
  }
}
```

MCP tools: `init`, `create`, `list`, `ready`, `show`, `update`, `close`, `dep`, `blocked`, `stats`, `reopen`, `set_context`.

## Editor Integrations

| Editor      | Setup command        | What it does                                |
|-------------|----------------------|---------------------------------------------|
| Claude Code | `bd setup claude`    | installs SessionStart/PreCompact hooks      |
| Cursor      | `bd setup cursor`    | creates `.cursor/rules/beads.mdc`           |
| Aider       | `bd setup aider`     | creates `.aider.conf.yml`                   |
| Codex       | `bd setup codex`     | creates/updates AGENTS.md                   |
| Factory.ai  | `bd setup factory`   | creates/updates AGENTS.md                   |
| Copilot     | MCP config           | uses beads-mcp server in `.vscode/mcp.json` |

## Init Modes

| Mode                    | Command                        |
|-------------------------|--------------------------------|
| Basic                   | `bd init`                      |
| Quiet (no prompts)      | `bd init --quiet`              |
| Stealth (local only)    | `bd init --stealth`            |
| Contributor (fork)      | `bd init --contributor`        |
| Team collaboration      | `bd init --team`               |
| Protected branches      | `bd init --branch beads-sync`  |
| Dolt backend            | `bd init --backend dolt`       |

## Example Directories

All at `examples/` in the repo:

| Example                    | Description                              |
|----------------------------|------------------------------------------|
| `python-agent/`            | Python agent using bd CLI via subprocess |
| `bash-agent/`              | Bash script full agent workflow          |
| `library-usage/`           | Go library usage (programmatic API)      |
| `claude-desktop-mcp/`      | MCP server for Claude Desktop            |
| `monitor-webui/`           | Web UI for issue monitoring              |
| `markdown-to-jsonl/`       | Convert markdown plans to bd issues      |
| `github-import/`           | Import from GitHub Issues                |
| `jira-import/`             | Import from Jira                         |
| `git-hooks/`               | Pre-configured git hooks                 |
| `startup-hooks/`           | Session startup scripts                  |
| `contributor-workflow/`    | OSS contributor setup                    |
| `team-workflow/`           | Team collaboration                       |
| `multi-phase-development/` | Organize by project phases               |
| `multiple-personas/`       | Architect/implementer/reviewer roles     |
| `protected-branch/`        | Protected branch workflow                |
| `linear-workflow/`         | Linear integration                       |
| `compaction/`              | Memory compaction                        |
| `bd-example-extension-go/` | Go extension example                     |

## Database Extension Pattern

Add custom tables to the same SQLite database:

```go
store, _ := beads.NewSQLiteStorage(ctx, dbPath)
db := store.UnderlyingDB()
db.Exec("CREATE TABLE IF NOT EXISTS myapp_executions (...)")
// join with issues table via foreign keys
```

Namespace tables with app prefix (e.g., `myapp_`).
