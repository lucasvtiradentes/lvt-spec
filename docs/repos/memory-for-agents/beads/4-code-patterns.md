# Code Patterns

## Coding Style

Language: Go 1.25.6. Codebase stats: 949 Go files, 424 test files, ~344k lines of Go code.

Naming conventions:
- Standard Go idioms: `camelCase` locals, `PascalCase` exports, `snake_case` JSON tags
- Short receiver names: `i *Issue`, `s Status`, `w hashFieldWriter`
- Type aliases for public API: `type Storage = beads.Storage` (re-export internal types)
- Custom string types for enums: `Status`, `IssueType`, `DependencyType`, `AgentState`
- Each enum type has `IsValid()` and `IsValidWithCustom()` methods

Formatting:
- Standard `gofmt` enforced in CI via `make fmt-check`
- No custom formatting rules beyond gofmt

Go idioms:
- Cobra CLI framework for all commands
- Viper for configuration
- Context-first function signatures (`ctx context.Context` as first param)
- Interface-driven storage layer
- Type assertions for optional capabilities (`CompactableStorage`, `MultiRepoStorage`)
- Sentinel errors: `var ErrAlreadyClaimed = errors.New(...)`
- Heavy `json:"...,omitempty"` on struct tags
- Internal packages under `internal/` with thin public re-export layer

## Testing Approach

Framework: standard `testing` package. No third-party test frameworks.

| Aspect           | Details                                                     |
|------------------|-------------------------------------------------------------|
| Test count       | 1646+ test functions across 182 test files                  |
| Structure        | colocated `foo.go` / `foo_test.go`                          |
| Helpers          | `setupTestDB(t)` returning `(store, cleanup)`               |
| Style            | table-driven tests with `t.Run()` subtests                  |
| Parallelism      | minimal `t.Parallel()` usage (~7 occurrences)               |
| Cleanup          | `defer cleanup()` pattern with temp dirs                    |
| Temp dirs        | `os.MkdirTemp` + `/dev/shm` via `testutil.TempDirInMemory()`|

Test categories:

| Category    | Build Tag      | Example                                   |
|-------------|----------------|-------------------------------------------|
| Unit        | (none)         | `_test.go` alongside source               |
| Integration | `integration`  | 49 files with `//go:build integration`    |
| E2E         | (none)         | `contributor_routing_e2e_test.go`         |
| Race        | (none)         | `*_race_test.go` files                    |
| Benchmark   | `bench`        | `*_bench_test.go` files                   |
| Script      | (none)         | `scripttest_test.go` using `rsc.io/script`|

Coverage:

| Threshold | CI (PR) | Nightly |
|-----------|---------|---------|
| Fail      | 42%     | 50%     |
| Warn      | 55%     | 55%     |

Coverage via `go test -coverprofile` with Codecov integration.

## CI/CD Setup

GitHub Actions (5 workflows):

| Workflow         | Trigger               | Purpose                                    |
|------------------|-----------------------|--------------------------------------------|
| ci.yml           | push/PR to main       | Lint, fmt, test (Linux+macOS), Win smoke   |
| nightly.yml      | cron 2am UTC + manual | Full suite with integration tests          |
| release.yml      | tag push `v*`         | GoReleaser + PyPI + npm publish            |
| deploy-docs.yml  | push to `website/**`  | Build/deploy docs to GitHub Pages          |
| test-pypi.yml    | (exists)              | Python package testing                     |

CI matrix:

| Platform | Tests                          | Coverage |
|----------|--------------------------------|----------|
| Linux    | full + race detection          | yes      |
| macOS    | full + race detection          | no       |
| Windows  | smoke only (build + CRUD)      | no       |
| Nix      | build + help text verification | no       |

Linting: golangci-lint v2 with `errcheck`, `gosec`, `misspell`, `unconvert`, `unparam`, `sloglint`. Extensive exclusion rules per file/pattern in `.golangci.yml`.

Release: GoReleaser v2 builds 8 platforms. CGO_ENABLED=0 for all release builds. Windows code signing via Authenticode. Distribution via Homebrew, npm, PyPI.

Dependency management: Dependabot weekly for Go modules, GitHub Actions, Python pip.

## Error Handling

Documented patterns from `cmd/bd/errors.go`:

| Pattern                    | Function                    | Behavior                                |
|----------------------------|-----------------------------|-----------------------------------------|
| Fatal                      | `FatalError(format, args)`  | stderr + exit 1                         |
| Fatal JSON                 | `FatalErrorRespectJSON()`   | JSON output if --json flag set          |
| Fatal with hint            | `FatalErrorWithHint()`      | error + actionable suggestion           |
| Warn                       | `WarnError(format, args)`   | stderr, continues execution             |
| Readonly guard             | `CheckReadonly(operation)`  | prevents writes in readonly mode        |

Error creation:
- `fmt.Errorf()` as primary error creation
- `errors.New` for sentinel errors
- No pkg/errors dependency
- Standard `errors.Is`/`errors.As` for checks

Validation:
- Multi-level: `Validate()`, `ValidateWithCustomStatuses()`, `ValidateForImport()`
- Returns `error` (nil = valid)

## Logging

| Layer      | Approach                                                     |
|------------|--------------------------------------------------------------|
| Production | `log/slog` (Go structured logging), 56 occurrences           |
| Rotation   | Lumberjack (50MB max, 7 backups, 30 day retention, compress) |
| Debug      | Custom `internal/debug` package, toggled via `BEADS_DEBUG`   |
| Legacy     | Nearly zero `log.Print` (19 occurrences, 4 in examples)      |
| CLI output | stdout (normal), stderr (errors), --json/--quiet flags       |

`sloglint` enforced by golangci-lint to maintain consistent structured logging.

## Conventions

- `internal/` for all non-public code (standard Go encapsulation)
- One command per file in `cmd/bd/`
- Storage backends implement shared `Storage` interface
- Optional capabilities via interface extensions
- Platform-specific files: `*_unix.go`, `*_windows.go`, `*_wasm.go`, `*_freebsd.go`
- Build tags: `integration`, `bench`, `gms_pure_go`
- Section comments in large structs: `// ===== Core Identification =====`
- Issue references in code comments: `// bd-2c5a:`, `// GH#748`
- `#nosec G304` pragmas for known-safe gosec suppressions
- `t.Helper()` in test setup functions
- `.test-skip` file for known broken tests

## Notable Anti-Patterns

- Massive `cmd/bd/` package: 300+ files in single package (Go has no sub-package access control for main)
- Heavy use of package-level globals in `cmd/bd/main.go` (`store`, `dbPath`, `actor`, `daemonClient`)
- `os.Exit(1)` in error helpers (`FatalError`) makes those paths untestable in unit tests
- Very few `t.Parallel()` calls despite 1600+ tests (test suite slower than needed)
- Some validation code duplication between `Validate()` and `ValidateForImport()`
