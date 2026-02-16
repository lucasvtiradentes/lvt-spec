# Code Patterns

## Coding Style

Naming conventions:
- File names              - lowercase kebab-case (`claude-to-codex.ts`, `codex-agents.ts`)
- Type names              - PascalCase with domain prefix (`ClaudePlugin`, `OpenCodeBundle`, `CodexPrompt`)
- Function names          - camelCase, verb-first (`loadClaudePlugin`, `convertClaudeToOpenCode`)
- Constants               - UPPER_SNAKE_CASE (`CODEX_AGENTS_BLOCK_START`, `PLUGIN_MANIFEST`)
- Object-map constants    - UPPER_SNAKE_CASE (`TOOL_MAP`, `HOOK_EVENT_MAP`)
- Helper functions        - camelCase, descriptive (`normalizeName`, `expandHome`, `resolveWithinRoot`)

Formatting:
- 2-space indentation
- No trailing semicolons
- Double quotes for strings
- Trailing commas in multi-line constructs
- Line length not enforced but generally under ~120 characters
- Single blank line between function definitions
- No linter/formatter configured (ESLint, Prettier, Biome, etc.)

## TypeScript Patterns

- Strict mode enabled
- ESM-only (`"type": "module"`)
- No classes anywhere; entirely functional codebase
- `export type` for type-only exports
- `type` keyword preferred over `interface` for data shapes
- Optional properties use `?` consistently
- Union types for enum-like values (`"none" | "broad" | "from-commands"`)
- `Record<string, T>` for dictionary types
- Type assertions minimal, only at JSON parse boundaries
- No generic utility types or complex conditional types
- Arrow functions for inline callbacks
- No explicit return types; relies on TypeScript inference
- Underscore prefix for unused parameters (`_options`, `_match`)

## File Organization

Each layer has a clear responsibility:

```
commands/    - CLI arg wiring + orchestration
parsers/     - read and structure input data
converters/  - pure transformation logic (no side effects)
targets/     - write output + target registry
types/       - type definitions only, no runtime code
utils/       - shared helpers (files, frontmatter, symlink)
sync/        - personal config sync implementations
```

## Import Conventions

- Node builtins and external packages imported at top (ordering not strictly enforced)
- `import type` used for type-only imports
- Named imports preferred (`import { defineCommand } from "citty"`)
- Default exports used for CLI command definitions
- Relative imports with `../` paths, no path aliases
- No barrel exports except `targets/index.ts`

Example:

```typescript
import { defineCommand } from "citty"
import os from "os"
import path from "path"
import { loadClaudePlugin } from "../parsers/claude"
import { targets } from "../targets"
import type { PermissionMode } from "../converters/claude-to-opencode"
```

## Error Handling

Thrown errors with descriptive messages for critical failures:

```typescript
throw new Error(`Unknown target: ${targetName}`)
throw new Error(`Could not find ${PLUGIN_MANIFEST} under ${inputPath}`)
throw new Error(`Invalid ${label}: ${entry}. Paths must stay within the plugin root.`)
throw new Error(`Failed to clone ${source}. ${stderr.trim()}`)
```

`console.warn()` with `continue` for non-fatal issues:

```typescript
console.warn(`Skipping unknown target: ${extra}`)
console.warn(`Skipping skill with invalid name: ${skill.name}`)
```

Empty catch for optional file operations:

```typescript
try {
  await fs.access(skillPath)
} catch {
  // No SKILL.md, skip
}
```

ENOENT checking when missing files are expected but other errors should propagate:

```typescript
} catch (err) {
  if ((err as NodeJS.ErrnoException).code !== "ENOENT") {
    throw err
  }
}
```

Cleanup with `try/finally` for temp directories:

```typescript
try {
  // ... process plugin
} finally {
  if (resolvedPlugin.cleanup) {
    await resolvedPlugin.cleanup()
  }
}
```

Backup before overwrite for config files:

```typescript
const backupPath = await backupFile(paths.configPath)
if (backupPath) {
  console.log(`Backed up existing config to ${backupPath}`)
}
```

## Testing

Framework: Bun's built-in test runner (`bun:test`). Run with `bun test`.

Test files:

| File                      | Scope                                                 |
|---------------------------|-------------------------------------------------------|
| claude-parser.test.ts     | plugin parsing, path security, component loading      |
| cli.test.ts               | end-to-end CLI commands (install, convert, list)      |
| codex-agents.test.ts      | AGENTS.md block generation (create, append, update)   |
| codex-converter.test.ts   | Claude-to-Codex conversion logic                      |
| codex-writer.test.ts      | Codex bundle file output                              |
| converter.test.ts         | Claude-to-OpenCode conversion logic                   |
| frontmatter.test.ts       | YAML frontmatter parse/format round-trip              |
| opencode-writer.test.ts   | OpenCode bundle file output                           |

Test patterns:
- Temp directories (`os.tmpdir()` + `fs.mkdtemp()`) for file I/O tests
- Fixture-based testing with `tests/fixtures/` containing sample plugin structures
- Negative test fixtures for path traversal rejection
- CLI tests spawn actual `bun run src/index.ts` processes via `Bun.spawn()`
- Helper functions redefined locally in each test file (not shared)
- No mocking framework; tests use real filesystem operations
- `expect().rejects.toThrow()` for error case assertions

Coverage: no explicit coverage configuration or thresholds.

## CI/CD

ci.yml:
- Triggers on push to main and all PRs
- Single job: `bun install` then `bun test` on ubuntu-latest
- No linting, type-checking, or build steps

deploy-docs.yml:
- Triggers on push to main when `plugins/compound-engineering/docs/**` changes
- Deploys static HTML docs to GitHub Pages

## Notable Design Decisions

- No build step: Bun runs TypeScript directly from `src/index.ts`
- `implemented: boolean` flag on TargetHandler allows registering future targets without breaking CLI
- TOML output generated manually with string formatting rather than using a library
- Some code duplication between convert.ts and install.ts (`expandHome()`, `resolveCodexRoot()`, etc.)
- `convertMcp()` appears in both converters and sync with identical logic
- Minimal JSDoc (only 2 comments in the entire codebase, both in `utils/symlink.ts`)
