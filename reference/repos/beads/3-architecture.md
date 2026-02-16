# Architecture

## High-Level Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLI (cmd/bd/)                           │
│  ~80 cobra commands, PersistentPreRun/PostRun lifecycle         │
└────────┬──────────────────┬──────────────────┬─────────────────-┘
         |                  |                  |
         v                  v                  v
┌────────────────┐ ┌────────────────┐ ┌────────────────────────┐
│ Daemon Client  │ │ Direct Storage │ │ Formula / Molecule     │
│ (rpc.Client)   │ │ Access         │ │ System                 │
└───────┬────────┘ └───────┬────────┘ └───────┬────────────────┘
        |                  |                  |
        v                  |                  |
┌────────────────┐         |                  |
│ Daemon Server  │         |                  |
│ (rpc.Server)   │         |                  |
│ event loop     │         |                  |
│ auto-sync      │         |                  |
└───────┬────────┘         |                  |
        |                  |                  |
        +--------+---------+                  |
                 |                            |
                 v                            |
        ┌────────────────┐                    |
        │ Storage Iface  │<-------------------+
        │ (~60 methods)                       │
        └──┬─────┬─────┬──────────────────────┘
           |     |     |
           v     v     v
     ┌────────┐ ┌──────┐ ┌────────┐
     │ SQLite │ │ Dolt │ │ Memory │
     └───┬────┘ └─┬────┘ └────────┘
         |        |
         v        v
     ┌────────┐ ┌─────────┐
     │ JSONL  │ │ Dolt    │
     │ Export │ │ Native  │
     │ Import │ │ Sync    │
     └───┬────┘ └─────────┘
         |
         v
     ┌────────┐
     │ Git    │
     │ Sync   │
     └───┬────┘
         |
         v
     ┌────────┐
     │ Remote │
     │ (GH)   │
     └────────┘
```

## Data Flow (Write Command)

```
  User: bd create "Fix bug" -p 1
         |
         v
  ┌──────────────────────────┐
  │ PersistentPreRun         │
  │  1. Config init (viper)  │
  │  2. Find .beads/ + DB    │
  │  3. Try daemon connect   │
  │  4. Fallback: open DB    │
  └──────────┬───────────────┘
             |
     ┌───────+───────┐
     |               |
     v               v
  [DAEMON]        [DIRECT]
  rpc.Client      storage.Storage
  JSON/socket     SQLite/Dolt
     |               |
     v               |
  rpc.Server         |
  handleCreate()     |
     |               |
     +-------+-------+
             |
             v
  ┌──────────────────────────┐
  │ storage.CreateIssue()    │
  │ SQLite INSERT            │
  └──────────┬───────────────┘
             |
             v
  ┌──────────────────────────┐
  │ FlushManager             │
  │ DB dirty ----> JSONL     │
  │ (debounced, incremental) │
  └──────────┬───────────────┘
             |
             v
  ┌──────────────────────────┐
  │ PersistentPostRun        │
  │ Final flush, cleanup     │
  └──────────────────────────┘
```

## Sync Flow

```
  bd sync
    |
    v
  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
  │ 1. Export        │--->│ 2. Git commit    │--->│ 3. Git push      │
  │ DB ----> JSONL   │    │  .beads/issues.  │    │  origin          │
  │ (dirty issues)   │    │  jsonl           │    │                  │
  └──────────────────┘    └──────────────────┘    └──────────────────┘
                                                          |
                                                          v
  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
  │ 6. Done          │<---│ 5. Import        │<---│ 4. Git pull      │
  │                  │    │ JSONL ----> DB   │    │ origin           │
  │                  │    │ (content-hash    │    │                  │
  │                  │    │  dedup)          │    │                  │
  └──────────────────┘    └──────────────────┘    └──────────────────┘
```

## Folder Structure

```
beads/
├── beads.go                          - public Go library API (thin re-export layer)
├── beads_test.go                     - public API tests
├── go.mod / go.sum                   - Go module definition
├── Makefile                          - build, test, install, benchmark targets
├── flake.nix / default.nix           - Nix package definitions
├── .goreleaser.yml                   - GoReleaser cross-platform release config
├── install.ps1                       - Windows PowerShell installer
│
├── cmd/bd/                           - CLI ENTRY POINT (~300+ files)
│   ├── main.go                       - main(), rootCmd, PersistentPreRun/PostRun
│   ├── version.go                    - version constants
│   ├── daemon.go                     - `bd daemon` command
│   ├── daemon_*.go                   - daemon subsystem (~30 files)
│   ├── create.go                     - `bd create`
│   ├── list.go / list_*.go           - `bd list` + formatting/tree views
│   ├── show.go / show_*.go           - `bd show` + display/threading
│   ├── update.go                     - `bd update`
│   ├── close.go                      - `bd close`
│   ├── ready.go                      - `bd ready` (unblocked work)
│   ├── sync.go / sync_*.go           - `bd sync` (git sync)
│   ├── export.go                     - `bd export` (DB ----> JSONL)
│   ├── import.go                     - `bd import` (JSONL ----> DB)
│   ├── dep.go                        - `bd dep` (dependency management)
│   ├── compact.go                    - `bd compact` (memory decay)
│   ├── search.go                     - `bd search` (full-text)
│   ├── init.go / init_*.go           - `bd init`
│   ├── config.go                     - `bd config`
│   ├── doctor.go / doctor_*.go       - `bd doctor` (health checks)
│   ├── mol*.go                       - molecule commands (pour, bond, burn, seed)
│   ├── formula.go / cook.go          - formula parsing and instantiation
│   ├── gate.go                       - async gates
│   ├── slot.go                       - exclusive access slots
│   ├── agent.go / swarm.go           - agent/swarm coordination
│   ├── graph.go                      - dependency graph visualization
│   ├── autoflush.go                  - auto-export DB changes to JSONL
│   ├── autoimport.go                 - auto-import JSONL when newer
│   ├── context.go                    - CommandContext (runtime state)
│   ├── errors.go                     - error handling helpers
│   ├── doctor/                       - health fix routines
│   ├── setup/                        - editor integrations
│   └── templates/                    - issue creation templates
│
├── internal/                         - INTERNAL PACKAGES
│   ├── types/                        - core domain types
│   │   ├── types.go                  - Issue struct (~130 fields), enums
│   │   ├── id_generator.go           - hash-based issue ID generation
│   │   ├── lock.go                   - advisory lock types
│   │   └── orphans.go                - orphan issue detection
│   │
│   ├── storage/                      - STORAGE ABSTRACTION LAYER
│   │   ├── storage.go                - Storage interface (~60 methods)
│   │   ├── batch.go                  - batch operation options
│   │   ├── provider.go               - storage provider abstraction
│   │   ├── versioned.go              - versioned storage (Dolt version ctrl)
│   │   ├── factory/                  - BACKEND FACTORY
│   │   │   ├── factory.go            - NewWithOptions(), backend registry
│   │   │   └── factory_dolt.go       - Dolt backend registration (CGO-gated)
│   │   ├── sqlite/                   - SQLite backend (~60 files)
│   │   │   ├── sqlite.go             - constructor, connection management
│   │   │   ├── store.go              - SQLiteStore struct
│   │   │   ├── schema.go             - DDL (tables: issues, deps, labels, events)
│   │   │   ├── issues.go             - issue CRUD
│   │   │   ├── queries.go            - complex SQL queries
│   │   │   ├── ready.go              - ready-work query (dependency-aware)
│   │   │   ├── search.go             - full-text search
│   │   │   ├── dependencies.go       - dependency graph queries
│   │   │   ├── dirty.go              - dirty tracking for incremental export
│   │   │   ├── compact.go            - compaction operations
│   │   │   └── migrations/           - schema migration files
│   │   ├── dolt/                     - Dolt backend (~40 files)
│   │   │   ├── store.go              - DoltStore struct
│   │   │   ├── server.go             - embedded Dolt server management
│   │   │   ├── versioned.go          - version control ops (commit, log, diff)
│   │   │   └── federation.go         - Dolt-native federation (push/pull)
│   │   └── memory/                   - in-memory backend (--no-db mode)
│   │       └── memory.go             - MemoryStorage (backed by maps)
│   │
│   ├── rpc/                          - RPC SUBSYSTEM (daemon communication)
│   │   ├── protocol.go               - request/response types (~55 operations)
│   │   ├── client.go                 - RPC client (Unix socket, JSON-line)
│   │   ├── server_core.go            - server struct, mutation events
│   │   ├── server_lifecycle_conn.go  - start/stop, connection handling
│   │   ├── server_routing_*.go       - request dispatch
│   │   ├── server_issues_epics.go    - issue CRUD via RPC
│   │   ├── metrics.go                - request metrics collection
│   │   ├── socket_path.go            - socket path resolution
│   │   └── transport_*.go            - platform-specific transport
│   │
│   ├── beads/                        - core logic (DB discovery, context)
│   ├── config/                       - viper-based configuration
│   ├── configfile/                   - metadata.json config file
│   ├── formula/                      - FORMULA SYSTEM
│   │   ├── types.go                  - Formula, Step, VarDef, ComposeRules
│   │   ├── parser.go                 - TOML/JSON formula parsing
│   │   ├── expand.go                 - inline expansion
│   │   ├── condition.go              - conditional step evaluation
│   │   ├── controlflow.go            - loop expansion
│   │   └── advice.go                 - AOP-style before/after/around insertion
│   ├── molecules/                    - molecule catalog loading
│   ├── compact/                      - compaction engine
│   ├── importer/                     - JSONL import (dedup, conflict resolution)
│   ├── export/                       - JSONL export (incremental, full)
│   ├── merge/                        - 3-way merge for concurrent edits
│   ├── query/                        - query language (lexer, parser, evaluator)
│   ├── routing/                      - maintainer vs contributor detection
│   ├── syncbranch/                   - dedicated sync branch support
│   ├── daemon/                       - daemon discovery and registry
│   ├── lockfile/                     - cross-platform file locking
│   ├── hooks/                        - pre/post hooks for commands
│   ├── git/                          - git directory/worktree detection
│   ├── idgen/                        - hash-based unique ID generation
│   ├── ui/                           - terminal UI (markdown, pager, styles)
│   ├── validation/                   - input validation
│   ├── timeparsing/                  - NLP time parsing
│   ├── debug/                        - conditional debug output
│   └── audit/                        - audit trail operations
│
├── integrations/                     - EXTERNAL INTEGRATIONS
│   ├── beads-mcp/                    - Python MCP server for AI agents
│   ├── claude-code/                  - Claude Code integration commands
│   └── junie/                        - JetBrains Junie integration
│
├── claude-plugin/                    - Claude plugin (skills, commands, agents)
│   ├── commands/                     - 30+ command definitions (markdown)
│   ├── skills/beads/                 - beads skill for Claude
│   └── agents/                       - task agent definition
│
├── npm-package/                      - npm distribution
│   ├── bin/bd.js                     - Node wrapper, downloads platform binary
│   └── scripts/postinstall.js        - auto-download on npm install
│
├── website/                          - documentation site (Docusaurus)
├── examples/                         - 18 usage examples
├── scripts/                          - build/release/test scripts
├── docs/                             - 50+ markdown documentation files
├── .beads/                           - self-hosted issue tracking
└── .github/workflows/                - CI/CD workflows
```

## Entry Points

| Entry Point    | File                                       | Description                              |
|----------------|--------------------------------------------|------------------------------------------|
| CLI main       | `cmd/bd/main.go` (line ~1124)              | `main()` ----> `rootCmd.Execute()`       |
| Root command   | `cmd/bd/main.go` (line ~242)               | cobra rootCmd with lifecycle hooks       |
| Daemon server  | `cmd/bd/daemon.go`                         | `bd daemon start` launches RPC server    |
| RPC server     | `internal/rpc/server_core.go` (line ~100)  | `NewServer()` creates daemon handler     |
| Public Go API  | `beads.go`                                 | library entry for Go extensions          |
| MCP server     | `integrations/beads-mcp/src/beads_mcp/`    | Python MCP server for AI agents          |
| NPM entry      | `npm-package/bin/bd.js`                    | Node wrapper delegates to native binary  |

## Design Patterns

| Pattern              | Where                            | Description                                        |
|----------------------|----------------------------------|----------------------------------------------------|
| Repository/Storage   | `internal/storage/storage.go`    | Storage interface (~60 methods), decouples backends|
| Factory              | `internal/storage/factory/`      | BackendFactory registry, creates SQLite/Dolt/Mem   |
| Strategy             | `internal/storage/factory/`      | Backend selection via metadata.json `backend` key  |
| Client-Server RPC    | `internal/rpc/`                  | JSON-line over Unix sockets; daemon holds DB       |
| Command              | `cmd/bd/*.go` (cobra)            | Each CLI subcommand is a self-contained handler    |
| Middleware/Lifecycle | `cmd/bd/main.go`                 | PersistentPreRun/PostRun for cross-cutting logic   |
| Observer/Event       | `internal/rpc/server_core.go`    | MutationEvent channel for daemon sync              |
| Template Method      | `internal/formula/`              | Formulas define workflow skeletons, filled at cook |
| Aspect-Oriented      | `internal/formula/advice.go`     | AdviceRules inject before/after/around steps       |
| Decorator/Extension  | `internal/storage/storage.go`    | CompactableStorage, MultiRepoStorage extend base   |
| Hierarchical Config  | `internal/molecules/`            | built-in < town < user < project cascade           |
| Transaction          | `internal/storage/storage.go`    | RunInTransaction() for atomic operations           |
| Content-Addressable  | `internal/types/types.go`        | SHA256 content hash for dedup across clones        |
| Soft Delete          | `internal/types/types.go`        | Tombstone status with TTL-based expiration         |
| Registry             | `internal/daemon/registry.go`    | Global daemon registry at ~/.beads/registry.json   |

## Module Dependency Graph

```
beads.go (public API)
│
├── internal/beads         - DB discovery, redirect following
│   ├── internal/configfile
│   ├── internal/git
│   └── internal/storage/sqlite
│
└── internal/types         - Issue, Status, Dependency (ZERO deps)

cmd/bd/main.go (CLI)
│
├── internal/beads         - DB path discovery
├── internal/config        - viper config
├── internal/configfile    - metadata.json
├── internal/rpc           - daemon client/server
│   ├── internal/storage
│   ├── internal/types
│   └── internal/lockfile
├── internal/storage/factory
│   ├── internal/storage/sqlite
│   ├── internal/storage/dolt
│   └── internal/storage/memory
├── internal/hooks         - extensibility hooks
├── internal/molecules     - molecule catalog
├── internal/formula       - workflow templates
├── internal/routing       - maintainer/contributor
├── internal/syncbranch    - dedicated sync branch
├── internal/compact       - issue compaction
├── internal/importer      - JSONL import
├── internal/export        - JSONL export
├── internal/merge         - 3-way merge
├── internal/query         - query language
├── internal/ui            - terminal rendering
├── internal/validation    - input validation
├── internal/timeparsing   - NLP dates
└── internal/debug         - verbose logging
```

## Dual-Mode Execution

Every command transparently tries daemon first, falls back to direct DB:

```
  CLI command
      |
      v
  ┌────────────────────────────┐
  │ PersistentPreRun           │
  │ Try connect to daemon      │
  └─────────┬──────────────────┘
            |
    ┌───────+───────┐
    | daemon up?    |
    |  YES    NO    |
    v               v
  ┌─────────┐  ┌─────────────┐
  │ RPC     │  │ Direct DB   │
  │ Client  │  │ open SQLite │
  │ (fast)  │  │ (fallback)  │
  └─────────┘  └─────────────┘
```

## Storage Layer

```
  ┌──────────────────────────────────────────────┐
  │          storage.Storage interface           │
  │             (~60 methods)                    │
  ├──────────────────────────────────────────────┤
  │ Optional extensions:                         │
  │  - CompactableStorage                        │
  │  - MultiRepoStorage                          │
  │  - BatchDeleter                              │
  │  - Transaction                               │
  └──────┬──────────┬──────────┬─────────────────┘
         |          |          |
         v          v          v
  ┌──────────┐ ┌────────┐ ┌──────────┐
  │ SQLite   │ │ Dolt   │ │ Memory   │
  │ (default)│ │(opt.)  │ │(--no-db) │
  │ Wasm-    │ │CGO req.│ │ Maps     │
  │ based    │ │embed+  │ │          │
  │ ncruces  │ │server  │ │          │
  └──────────┘ └────────┘ └──────────┘
```

## JSONL Exchange Format

The JSONL file is the git-tracked source of truth:

```
  ┌──────────┐    flush     ┌────────────────┐    git commit   ┌─────────┐
  │ SQLite   │ -----------> │ issues.jsonl   │ ------------->  │Git Repo │
  │ (cache)  │              │ (source of     │                 │(shared) │
  │          │ <----------- │  truth)        │ <-------------  │         │
  └──────────┘   import     └────────────────┘    git pull     └─────────┘
```

Content-hash deduplication (SHA256) prevents unnecessary writes during import/export cycles.
