# Architecture

## Folder Structure

```
compound-engineering-plugin/
├── .claude-plugin/
│   └── marketplace.json                 - marketplace catalog listing available plugins
├── .github/workflows/
│   ├── ci.yml                           - CI: runs bun test on push/PR
│   └── deploy-docs.yml                  - deploys docs/ to GitHub Pages
├── src/                                 - CLI tool source code
│   ├── index.ts                         - entry point, CLI router (citty)
│   ├── commands/
│   │   ├── convert.ts                   - "convert" subcommand
│   │   ├── install.ts                   - "install" subcommand (resolve + convert + write)
│   │   ├── list.ts                      - "list" subcommand
│   │   └── sync.ts                      - "sync" subcommand
│   ├── parsers/
│   │   ├── claude.ts                    - parse Claude plugin dir into ClaudePlugin model
│   │   └── claude-home.ts               - parse ~/.claude home dir (skills + settings)
│   ├── converters/
│   │   ├── claude-to-opencode.ts        - Claude ---> OpenCode conversion logic
│   │   └── claude-to-codex.ts           - Claude ---> Codex conversion logic
│   ├── targets/
│   │   ├── index.ts                     - target registry (opencode, codex)
│   │   ├── opencode.ts                  - OpenCode bundle writer
│   │   └── codex.ts                     - Codex bundle writer
│   ├── types/
│   │   ├── claude.ts                    - Claude plugin type definitions
│   │   ├── opencode.ts                  - OpenCode output type definitions
│   │   └── codex.ts                     - Codex output type definitions
│   ├── sync/
│   │   ├── opencode.ts                  - sync ~/.claude to OpenCode config
│   │   └── codex.ts                     - sync ~/.claude to Codex config
│   └── utils/
│       ├── files.ts                     - FS helpers (read, write, walk, copy, backup)
│       ├── frontmatter.ts               - YAML frontmatter parse/format
│       ├── symlink.ts                   - safe symlink creation + skill name validation
│       └── codex-agents.ts              - generate/upsert AGENTS.md block for Codex
├── tests/                               - test suite
│   ├── cli.test.ts                      - end-to-end CLI tests
│   ├── claude-parser.test.ts            - parser tests
│   ├── converter.test.ts                - OpenCode converter tests
│   ├── codex-converter.test.ts          - Codex converter tests
│   ├── codex-writer.test.ts             - Codex writer output tests
│   ├── codex-agents.test.ts             - AGENTS.md generation tests
│   ├── opencode-writer.test.ts          - OpenCode writer output tests
│   ├── frontmatter.test.ts              - frontmatter utility tests
│   └── fixtures/                        - test fixture plugins
│       ├── sample-plugin/               - full fixture with all components
│       ├── custom-paths/                - fixture with custom component paths
│       ├── mcp-file/                    - fixture with .mcp.json file
│       ├── invalid-command-path/        - path traversal rejection fixture
│       ├── invalid-hooks-path/          - path traversal rejection fixture
│       └── invalid-mcp-path/            - path traversal rejection fixture
├── plugins/                             - actual plugin content
│   ├── compound-engineering/            - main plugin (29 agents, 25 commands, 16 skills)
│   │   ├── .claude-plugin/plugin.json
│   │   ├── CLAUDE.md
│   │   ├── agents/                      - 29 agent markdown files
│   │   │   ├── design/                  - design-implementation-reviewer, design-iterator, figma-design-sync
│   │   │   ├── docs/                    - ankane-readme-writer
│   │   │   ├── research/                - best-practices-researcher, framework-docs-researcher, etc.
│   │   │   ├── review/                  - security-sentinel, performance-oracle, dhh-rails-reviewer, etc.
│   │   │   └── workflow/                - bug-reproduction-validator, lint, pr-comment-resolver, etc.
│   │   ├── commands/                    - 25 command markdown files
│   │   │   ├── workflows/               - brainstorm, compound, plan, review, work
│   │   │   └── (top-level)              - lfg, slfg, triage, changelog, etc.
│   │   └── skills/                      - 16 skill directories with SKILL.md
│   │       ├── agent-native-architecture/
│   │       ├── brainstorming/
│   │       ├── create-agent-skills/
│   │       ├── dhh-rails-style/
│   │       ├── gemini-imagegen/
│   │       └── ... (11 more)
│   └── coding-tutor/                    - secondary plugin (3 commands, 1 skill)
│       ├── .claude-plugin/plugin.json
│       ├── commands/
│       └── skills/coding-tutor/
├── docs/                                - static documentation site (GitHub Pages)
├── CLAUDE.md
├── AGENTS.md
├── package.json
├── tsconfig.json
└── bun.lock
```

## High-Level Component Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLI Entry Point                             │
│                          src/index.ts                               │
│                           (citty)                                   │
└───────┬──────────┬──────────────┬──────────────────┬────────────────┘
        |          |              |                  |
        v          v              v                  v
┌──────────┐ ┌──────────┐ ┌────────────┐     ┌────────────┐
│ convert  │ │   list   │ │  install   │     │    sync    │
│ command  │ │ command  │ │  command   │     │  command   │
└────┬─────┘ └──────────┘ └─────┬──────┘     └─────┬──────┘
     |                          |                   |
     +-----------+--------------+                   |
                 |                                  |
                 v                                  v
     ┌───────────────────┐              ┌───────────────────┐
     │  parsers/claude   │              │parsers/claude-home│
     │  (plugin loader)  │              │ (home config)     │
     └────────┬──────────┘              └────────┬──────────┘
              |                                   |
              v                                   v
     ┌───────────────────┐              ┌───────────────────┐
     │  Target Registry  │              │   sync/opencode   │
     │  targets/index    │              │   sync/codex      │
     └───┬──────────┬────┘              └───────────────────┘
         |          |
         v          v
┌─────────────┐ ┌─────────────┐
│  Converter  │ │  Converter  │
│  (OpenCode) │ │   (Codex)   │
└──────┬──────┘ └──────┬──────┘
       |               |
       v               v
┌─────────────┐ ┌─────────────┐
│   Writer    │ │   Writer    │
│  (OpenCode) │ │   (Codex)   │
└──────┬──────┘ └──────┬──────┘
       |               |
       v               v
┌─────────────┐ ┌─────────────┐
│ ~/.config/  │ │  ~/.codex/  │
│  opencode/  │ │             │
└─────────────┘ └─────────────┘
```

## ETL Pipeline (Parse ---> Convert ---> Write)

```
┌─────────────────────┐      ┌──────────────────────┐      ┌─────────────────────┐
│       PARSE         │      │       CONVERT        │      │        WRITE        │
│                     │      │                      │      │                     │
│  Plugin directory   │      │  ClaudePlugin model  │      │  Target-specific    │
│  with .md files     │----->│  is transformed to   │----->│  bundle is written  │
│  and plugin.json    │      │  target bundle type  │      │  to filesystem      │
│                     │      │                      │      │                     │
│  parsers/claude.ts  │      │  converters/*.ts     │      │  targets/*.ts       │
└─────────────────────┘      └──────────────────────┘      └─────────────────────┘
```

Detailed data flow:

```
┌──────────────────────────┐
│     Plugin Directory     │
│                          │
│  .claude-plugin/         │
│    plugin.json           │
│  agents/**/*.md          │
│  commands/**/*.md        │
│  skills/**/SKILL.md      │
│  hooks/hooks.json        │
│  .mcp.json               │
└────────────┬─────────────┘
             |
             v
┌─────────────────────────────────────────────────────────────────────┐
│   loadClaudePlugin()                                                │
│                                                                     │
│  1. Read plugin.json     -----> ClaudeManifest                      │
│  2. Walk agents/*.md     -----> ClaudeAgent[]     (frontmatter)     │
│  3. Walk commands/*.md   -----> ClaudeCommand[]   (frontmatter)     │
│  4. Walk skills/SKILL.md -----> ClaudeSkill[]                       │
│  5. Read hooks.json      -----> ClaudeHooks       (merged)          │
│  6. Read MCP configs     -----> Record<string, ClaudeMcpServer>     │
│                                                                     │
│  Path traversal check on all custom paths                           │
└──────────────────────────────────┬──────────────────────────────────┘
             |
             v
┌──────────────────────────┐
│      ClaudePlugin        │
│  (canonical input model) │
└─────┬──────────────┬─────┘
      |              |
      v              v
┌────────────┐   ┌──────────────┐
│  OpenCode  │   │    Codex     │
│  Convert   │   │   Convert    │
│            │   │              │
│ agents     │   │ commands     │
│   -> .md   │   │  -> prompts  │
│ commands   │   │    + skills  │
│   -> cfg   │   │ agents       │
│ hooks      │   │  -> skills   │
│   -> .ts   │   │ syntax       │
│ MCP        │   │  transform   │
│   -> cfg   │   │ MCP          │
│ perms      │   │  -> TOML     │
└─────┬──────┘   └──────┬───────┘
     |              |
     v              v
┌──────────┐   ┌──────────┐
│ OpenCode │   │  Codex   │
│  Bundle  │   │  Bundle  │
└────┬─────┘   └────┬─────┘
     |              |
     v              v
┌──────────┐   ┌──────────┐
│  Writer  │   │  Writer  │
│          │   │          │
│ backup   │   │ backup   │
│ write    │   │ write    │
│ config   │   │ config   │
│ agents/  │   │ prompts/ │
│ skills/  │   │ skills/  │
│ plugins/ │   │ AGENTS.md│
└──────────┘   └──────────┘
```

## Install Command Lifecycle

```
┌───────────────┐
│  User Input   │
│  plugin name  │
│  or path      │
└───────┬───────┘
        |
        v
┌───────────────────────────────────────────┐
│           resolvePluginPath()             │
│                                           │
│  1. Try local absolute/relative path      │
│  2. Try plugins/<name> under CWD          │
│  3. Fallback: git clone from GitHub       │
│     (shallow, temp dir, cleanup finally)  │
└───────────────────┬───────────────────────┘
                    |
                    v
┌───────────────────────────────────────────┐
│         loadClaudePlugin(path)            │
│                                           │
│  Read manifest + walk dirs + parse        │
│  frontmatter + validate paths             │
└───────────────────┬───────────────────────┘
                    |
                    v
┌───────────────────────────────────────────┐
│      target.convert(plugin, options)      │
│                                           │
│  Primary target + extra targets (--also)  │
│  Model normalization, temp inference,     │
│  permission mapping, syntax transform     │
└───────────────────┬───────────────────────┘
                    |
                    v
┌───────────────────────────────────────────┐
│      target.write(outputRoot, bundle)     │
│                                           │
│  Backup existing configs, write new       │
│  config + agent/prompt files + skills     │
└───────────────────┬───────────────────────┘
                    |
                    v
┌───────────────────────────────────────────┐
│          Post-processing                  │
│                                           │
│  Codex: ensureCodexAgentsFile()           │
│  Create/upsert AGENTS.md tool mapping     │
└───────────────────┬───────────────────────┘
                    |
                    v
┌───────────────────────────────────────────┐
│              Cleanup                      │
│                                           │
│  If cloned from GitHub: delete temp dir   │
└───────────────────────────────────────────┘
```

## Module Dependency Graph

```
                            ┌──────────────┐
                            │   index.ts   │
                            └──┬──┬──┬──┬──┘
                               |  |  |  |
              +----------------+  |  |  +----------------+
              |                   |  |                    |
              v                   |  v                    v
       ┌────────────┐            |  ┌────────────┐  ┌──────────┐
       │  convert   │            |  │  install   │  │   sync   │
       └──────┬─────┘            |  └──────┬─────┘  └────┬─────┘
              |                  v         |              |
              |           ┌──────────┐     |     ┌────────+────────┐
              |           │   list   │     |     |                 |
              |           └──────────┘     |     v                 v
              |                |           |  ┌──────────┐  ┌──────────┐
              |           utils/files      |  │  sync/   │  │  sync/   │
              |                            |  │ opencode │  │  codex   │
              +-------------+--------------+  └────┬─────┘  └────┬─────┘
                            |                      |              |
                            v                      |              |
                                                   |              |
                   parsers/claude              parsers/        utils/
                            |                 claude-home     symlink
                            |
                   +--------+--------+
                   |                 |
              utils/files    utils/frontmatter
                                     |
                            +--------+--------+
                            |                 |
                    ┌───────────────┐  ┌──────────────┐
                    │ targets/index │  │ types/claude │
                    └───┬───────┬───┘  └──────────────┘
                        |       |
              +---------+       +---------+
              |                           |
              v                           v
     ┌────────────────┐          ┌────────────────┐
     │  converters/   │          │  converters/   │
     │  opencode      │          │  codex         │
     └───────┬────────┘          └───────┬────────┘
             |                           |
             v                           v
     ┌────────────────┐          ┌────────────────┐
     │  targets/      │          │  targets/      │
     │  opencode      │          │  codex         │
     └───────┬────────┘          └───────┬────────┘
             |                           |
             v                           v
     ┌────────────────┐          ┌────────────────┐
     │ types/opencode │          │  types/codex   │
     └────────────────┘          └────────────────┘
```

## Conversion Mapping

### Claude ---> OpenCode

| Claude Concept | OpenCode Equivalent                       |
|----------------|-------------------------------------------|
| Agent .md      | .opencode/agents/*.md (with frontmatter)  |
| Command .md    | config.command entries in opencode.json   |
| Skill dir      | .opencode/skills/<name>/ (copied)         |
| hooks.json     | .opencode/plugins/converted-hooks.ts      |
| MCP (stdio)    | mcp.local (command array)                 |
| MCP (http)     | mcp.remote (url)                          |
| Tool perms     | config.permission + config.tools          |

### Claude ---> Codex

| Claude Concept    | Codex Equivalent                        |
|-------------------|-----------------------------------------|
| Command .md       | .codex/prompts/*.md + .codex/skills/*/  |
| Agent .md         | .codex/skills/*/SKILL.md (generated)    |
| Skill dir         | .codex/skills/<name>/ (copied)          |
| MCP servers       | .codex/config.toml [mcp_servers.*]      |
| Task agent(args)  | Use the $skill to: args                 |
| /command          | /prompts:command                        |
| @agent-name       | $skill-name skill                       |

## Design Patterns

Strategy Pattern (Target Handlers):
- `targets/index.ts` defines a `TargetHandler` interface with `convert` and `write` methods
- Each target (opencode, codex) implements this interface
- New targets added by inserting a registry entry with `implemented: false`

Pipeline / ETL Pattern:
- Three-stage pipeline: Parse ---> Convert ---> Write
- Clear separation of concerns at each stage

Type-First Design:
- Separate type modules define domain models
- Parsers produce Claude types; converters transform between types; writers consume output types

Registry Pattern:
- `targets/index.ts` is a Record-based registry mapping target names to handlers
- Supports `implemented: boolean` flag for future targets

Frontmatter as Data Contract:
- Both input and output use YAML frontmatter in Markdown as metadata transport

Security Patterns:
- `resolveWithinRoot()` rejects paths escaping plugin root (path traversal prevention)
- `isValidSkillName()` prevents directory traversal via skill names
- `forceSymlink()` refuses to delete real directories, only replaces symlinks
- Sync command warns on sensitive-looking env var keys
- Config files written with mode 0o600 (owner-only read/write)
