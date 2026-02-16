# Technical Details

## Tech Stack

| Layer         | Technology                                                    |
|---------------|---------------------------------------------------------------|
| Language      | Go 1.25.6                                                     |
| CLI           | spf13/cobra (commands) + spf13/viper (config)                 |
| Storage       | SQLite (ncruces/go-sqlite3 via Wasm) or Dolt (embedded + srv) |
| IPC/Daemon    | Unix domain socket RPC (custom `internal/rpc`)                |
| AI            | Anthropic SDK (`anthropic-sdk-go`)                            |
| TUI           | Charmbracelet stack (glamour, huh, lipgloss, bubbletea)       |
| Config        | YAML (gopkg.in/yaml.v3) + TOML (BurntSushi/toml)              |
| Build/Release | GoReleaser, Makefile, Nix flake                               |
| Website       | Docusaurus 3.9.2 (React 18, TypeScript)                       |
| MCP Server    | Python 3.10+ (fastmcp, pydantic, hatchling)                   |
| npm Wrapper   | Node.js >= 14 (binary download wrapper)                       |
| CI            | GitHub Actions (ubuntu, macos, windows)                       |
| Linting       | golangci-lint (errcheck, gosec, misspell, unconvert, unparam) |

## Go Dependencies

| Package                            | Version  |
|------------------------------------|----------|
| BurntSushi/toml                    | v1.6.0   |
| anthropics/anthropic-sdk-go        | v1.20.0  |
| cenkalti/backoff/v4                | v4.3.0   |
| charmbracelet/glamour              | v0.10.0  |
| charmbracelet/huh                  | v0.8.0   |
| charmbracelet/lipgloss             | v1.1.1   |
| dolthub/driver                     | v0.2.1   |
| fsnotify/fsnotify                  | v1.9.0   |
| go-sql-driver/mysql                | v1.9.3   |
| gofrs/flock                        | v0.13.0  |
| muesli/termenv                     | v0.16.0  |
| ncruces/go-sqlite3                 | v0.30.5  |
| olebedev/when                      | v1.1.0   |
| spf13/cobra                        | v1.10.2  |
| spf13/viper                        | v1.21.0  |
| tetratelabs/wazero                 | v1.11.0  |
| golang.org/x/mod                   | v0.32.0  |
| golang.org/x/sys                   | v0.40.0  |
| golang.org/x/term                  | v0.39.0  |
| natefinch/lumberjack.v2            | v2.2.1   |
| gopkg.in/yaml.v3                   | v3.0.1   |
| rsc.io/script                      | v0.0.2   |

Plus ~140 indirect dependencies (AWS SDK, GCP, Dolt internals, OpenTelemetry, etc.).

## Python MCP Server Dependencies

| Package           | Version   |
|-------------------|-----------|
| fastmcp           | 2.14.4    |
| pydantic          | 2.12.5    |
| pydantic-settings | 2.12.0    |

Dev: mypy >= 1.18.2, pytest >= 8.4.2, ruff >= 0.14.0

## Website Dependencies

| Package                       | Version |
|-------------------------------|---------|
| @docusaurus/core              | 3.9.2   |
| @docusaurus/preset-classic    | 3.9.2   |
| @docusaurus/theme-mermaid     | ^3.9.2  |
| react                         | ^18.3.1 |
| typescript                    | ~5.6.2  |

## Installation

End users (any of):

```bash
curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

npm install -g @beads/bd

brew install beads

go install github.com/steveyegge/beads/cmd/bd@latest

# Windows PowerShell
irm https://raw.githubusercontent.com/steveyegge/beads/main/install.ps1 | iex

nix run github:steveyegge/beads
```

From source:

```bash
git clone https://github.com/steveyegge/beads
cd beads
make build          # builds ./bd binary
make install        # copies to ~/.local/bin/bd + creates beads symlink
```

Requires: Go 1.25.6+, CGO_ENABLED=1, ICU4C (libicu-dev on Linux, `brew install icu4c` on macOS). Windows can build with CGO_ENABLED=0 using `-tags gms_pure_go`.

## Build Commands

| Command            | Action                                                    |
|--------------------|-----------------------------------------------------------|
| `make build`       | Build `bd` binary (CGO_ENABLED=1, ldflags for git rev)    |
| `make test`        | Run all tests via `scripts/test.sh`                       |
| `make bench`       | Run benchmarks with CPU profiling                         |
| `make bench-quick` | Quick benchmarks (shorter benchtime)                      |
| `make install`     | Build + copy to ~/.local/bin + create `beads` symlink     |
| `make fmt`         | Run gofmt on all files                                    |
| `make fmt-check`   | Check formatting (CI)                                     |
| `make clean`       | Remove build artifacts + benchmark profiles               |

Release builds use GoReleaser v2 targeting: linux/amd64, linux/arm64, darwin/amd64, darwin/arm64, windows/amd64, windows/arm64, android/arm64, freebsd/amd64.

## Configuration

Config file: `.beads/config.yaml`

| Key                | Type     | Default | Description                                      |
|--------------------|----------|---------|--------------------------------------------------|
| issue-prefix       | string   | auto    | Prefix for issue IDs (e.g., "bd" ----> "bd-a1b2")|
| no-db              | bool     | false   | JSONL-only mode, no SQLite                       |
| no-daemon          | bool     | false   | Disable daemon, force direct DB access           |
| no-auto-flush      | bool     | false   | Disable auto-flush DB to JSONL                   |
| no-auto-import     | bool     | false   | Disable auto-import from JSONL when newer        |
| json               | bool     | false   | Default JSON output                              |
| actor              | string   | ""      | Default actor for audit trails                   |
| db                 | string   | ""      | Database path override                           |
| auto-start-daemon  | bool     | true    | Auto-start daemon if not running                 |
| flush-debounce     | duration | "5s"    | Debounce for auto-flush                          |
| events-export      | bool     | false   | Export events to .beads/events.jsonl on flush    |
| sync-branch        | string   | ""      | Branch for multi-clone sync                      |
| sync.mode          | string   | ""      | Sync mode (e.g., "dolt-native")                  |
| types.custom       | string   | ""      | Comma-separated custom issue types               |
| status.custom      | string   | ""      | Comma-separated custom statuses                  |

## Environment Variables

| Variable                         | Purpose                                          |
|----------------------------------|--------------------------------------------------|
| BD_ACTOR / BEADS_ACTOR           | Actor name for audit trails                      |
| BEADS_DIR                        | Override .beads directory location               |
| BEADS_DB                         | Override database file path                      |
| BD_VERBOSE                       | Enable verbose output                            |
| BD_DEBUG                         | Enable debug logging                             |
| BD_DEBUG_RPC                     | Debug RPC calls                                  |
| BD_DEBUG_SYNC                    | Debug sync operations                            |
| BD_AGENT_MODE                    | Agent mode (disables emoji/styling)              |
| BD_NO_PAGER                      | Disable pager                                    |
| BD_PAGER                         | Custom pager command                             |
| BD_NO_EMOJI                      | Disable emoji in output                          |
| BD_SOCKET                        | Override daemon socket path                      |
| BD_LOCK_TIMEOUT                  | SQLite lock timeout override                     |
| BD_DAEMON_FOREGROUND             | Run daemon in foreground                         |
| BEADS_AUTO_START_DAEMON          | Control daemon auto-start                        |
| BEADS_NO_DAEMON                  | Disable daemon                                   |
| BEADS_FLUSH_DEBOUNCE             | Override flush debounce interval                 |
| BEADS_REMOTE_SYNC_INTERVAL       | Remote sync interval ("0" disables)              |
| BEADS_DAEMON_MAX_CONNS           | Max daemon connections                           |
| BEADS_AUTO_SYNC                  | Enable auto-sync                                 |
| BEADS_AUTO_COMMIT                | Enable auto-commit                               |
| BEADS_AUTO_PUSH                  | Enable auto-push                                 |
| BEADS_AUTO_PULL                  | Enable auto-pull                                 |
| BEADS_DOLT_SERVER_MODE           | Force Dolt server mode                           |
| BEADS_DOLT_SERVER_HOST           | Dolt server host                                 |
| BEADS_DOLT_SERVER_PORT           | Dolt server port                                 |

## CLI Persistent Flags

`--db`, `--actor`, `--json`, `--no-daemon`, `--no-auto-flush`, `--no-auto-import`, `--sandbox`, `--allow-stale`, `--no-db`, `--readonly`, `--dolt-auto-commit`, `--lock-timeout`, `--profile`, `--verbose/-v`, `--quiet/-q`, `--version/-V`

## Runtime Requirements

| Requirement | Details                                                     |
|-------------|-------------------------------------------------------------|
| OS          | Linux, macOS, Windows, FreeBSD, Android/Termux              |
| Go          | 1.25.6+ (building from source only)                         |
| Git         | Required at runtime (sync, hooks, actor detection)          |
| C compiler  | Required for CGO_ENABLED=1 builds (Dolt embedded backend)   |
| ICU4C       | Required on Linux/macOS for CGO builds                      |
| SQLite      | Bundled via go-sqlite3 (Wasm-based, no system lib needed)   |
| Dolt        | Optional backend; embedded or server mode                   |
| Node.js     | >= 14 (only for npm wrapper installation)                   |
| Python      | >= 3.10 (only for MCP server integration)                   |
