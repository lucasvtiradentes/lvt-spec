# Technical Details

## Tech Stack

| Layer             | Technology                                              |
|-------------------|---------------------------------------------------------|
| Language          | TypeScript (ES2022 target, ESNext modules, strict mode) |
| Runtime           | Bun                                                     |
| CLI Framework     | citty (v0.1.6, by UnJS)                                 |
| Module System     | ESM ("type": "module")                                  |
| Module Resolution | Bundler                                                 |
| Test Framework    | bun:test (built-in)                                     |
| Package Manager   | Bun                                                     |

No frontend framework. No build step - Bun runs TypeScript directly.

## Dependencies

Runtime:

| Package   | Version  | Purpose                                |
|-----------|----------|----------------------------------------|
| citty     | ^0.1.6   | CLI framework (commands, args parsing) |
| js-yaml   | ^4.1.0   | YAML parsing for frontmatter in .md    |

Dev:

| Package   | Version  | Purpose                                |
|-----------|----------|----------------------------------------|
| bun-types | ^1.0.0   | TypeScript type definitions for Bun    |

Transitive (from bun.lock):

| Package        | Resolved | Required By |
|----------------|----------|-------------|
| consola        | 3.4.2    | citty       |
| argparse       | 2.0.1    | js-yaml     |
| @types/node    | 25.0.9   | bun-types   |
| undici-types   | 7.16.0   | @types/node |

Total: 2 runtime + 1 dev + 4 transitive = 7 packages.

## Scripts

| Script      | Command                          | Purpose                         |
|-------------|----------------------------------|---------------------------------|
| dev         | `bun run src/index.ts`           | Run CLI in development          |
| convert     | `bun run src/index.ts convert`   | Shortcut for convert subcommand |
| list        | `bun run src/index.ts list`      | Shortcut for list subcommand    |
| cli:install | `bun run src/index.ts install`   | Shortcut for install subcommand |
| test        | `bun test`                       | Run test suite                  |

The `bin` field registers `compound-plugin` as the CLI entry point via `./src/index.ts`.

## Installation

As a Claude Code plugin (primary method):

```bash
/plugin marketplace add https://github.com/EveryInc/compound-engineering-plugin
/plugin install compound-engineering
```

As a CLI tool via bunx (for OpenCode/Codex conversion):

```bash
bunx @every-env/compound-plugin install compound-engineering --to opencode
bunx @every-env/compound-plugin install compound-engineering --to codex
```

For local development:

```bash
git clone https://github.com/EveryInc/compound-engineering-plugin
cd compound-engineering-plugin
bun install
bun run src/index.ts install ./plugins/compound-engineering --to opencode
```

## CLI Commands

The CLI binary `compound-plugin` has 4 subcommands:

### install

Install and convert a Claude plugin. Accepts local paths, plugin names (resolved under `plugins/`), or fetches from GitHub.

| Argument             | Type    | Default    | Description                                       |
|----------------------|---------|------------|---------------------------------------------------|
| `plugin`             | string  | (required) | Plugin name, path, or GitHub URL                  |
| `--to`               | string  | opencode   | Target format: opencode or codex                  |
| `--output, -o`       | string  | auto       | Output directory                                  |
| `--codex-home`       | string  | ~/.codex   | Codex root directory                              |
| `--also`             | string  | none       | Extra targets (comma-separated)                   |
| `--permissions`      | string  | broad      | Permission mapping: none, broad, or from-commands |
| `--agentMode`        | string  | subagent   | Default agent mode: primary or subagent           |
| `--inferTemperature` | boolean | true       | Infer agent temperature from name/description     |

### convert

Convert a local Claude Code plugin directory to another format. Same args as `install` but takes a `source` path instead of resolving from GitHub.

### list

List available Claude plugins under the `plugins/` directory.

### sync

Sync personal Claude Code config to another platform.

| Argument       | Type   | Default  | Description                 |
|----------------|--------|----------|-----------------------------|
| `--target`     | string | required | Target: opencode or codex   |
| `--claude-home`| string | ~/.claude| Path to Claude home dir     |

## Configuration

Environment variables:

| Variable                          | Purpose                                                                  |
|-----------------------------------|--------------------------------------------------------------------------|
| COMPOUND_PLUGIN_GITHUB_SOURCE     | Override GitHub source URL for install command (default: EveryInc's repo)|

Config files (input):

| File                                | Format | Purpose                                    |
|-------------------------------------|--------|--------------------------------------------|
| .claude-plugin/marketplace.json     | JSON   | Marketplace catalog listing plugins        |
| plugins/*/.claude-plugin/plugin.json| JSON   | Per-plugin metadata (name, version, etc.)  |
| plugins/*/.mcp.json                 | JSON   | Optional MCP server definitions per plugin |
| plugins/*/hooks/hooks.json          | JSON   | Optional hook definitions per plugin       |

Output config files:

| Target   | File                             | Format   |
|----------|----------------------------------|----------|
| OpenCode | ~/.config/opencode/opencode.json | JSON     |
| Codex    | ~/.codex/config.toml             | TOML     |
| Codex    | ~/.codex/AGENTS.md               | Markdown |

## TypeScript Configuration

From `tsconfig.json`:
- target:            ES2022
- module:            ESNext
- moduleResolution:  Bundler
- strict:            true
- resolveJsonModule: true
- esModuleInterop:   true
- types:             ["bun-types"]
- include:           src/**/*.ts

No build/compile step needed since Bun runs TypeScript directly.

## CI/CD

Two GitHub Actions workflows:

ci.yml (push to main + all PRs):
1. Checkout code
2. Setup Bun (latest)
3. `bun install`
4. `bun test`

deploy-docs.yml (push to main when `plugins/compound-engineering/docs/**` changes):
1. Deploy static HTML docs to GitHub Pages
2. Uses `actions/deploy-pages@v4`
3. Concurrency group "pages" with cancel-in-progress: false
