# Code Patterns

## Coding Style

Language and runtime: Node.js (CommonJS), minimum version 16.7.0. Zero runtime dependencies -- only `esbuild` as a devDependency for hook bundling.

Formatting:

- 2-space indentation throughout all JS files
- No linting or formatting tools configured (no ESLint, Prettier, or EditorConfig)
- Consistent use of single quotes for strings
- Semicolons always present
- No trailing commas in function parameters, present in object/array literals

Naming conventions:

| Type       | Convention     | Example                                |
|------------|----------------|----------------------------------------|
| Functions  | camelCase      | cmdGenerateSlug, cmdStateLoad          |
| Variables  | camelCase      | phaseIdx, rawValue                     |
| Constants  | UPPER_SNAKE    | MODEL_PROFILES, PATCHES_DIR_NAME       |
| Files (JS) | kebab-case     | gsd-tools.js, gsd-check-update.js      |
| Files (MD) | kebab-case     | new-project.md, execute-phase.md       |

File organization: two large monolithic JS files rather than a modular approach. Both `install.js` (1740 lines) and `gsd-tools.js` (4597 lines) contain all functionality in a single file with no imports of local modules.

## Module Pattern

The `gsd-tools.js` file follows a clear internal structure:

```
1. Constants/tables (e.g., MODEL_PROFILES)
2. Helper functions (pure utilities)
3. cmd* functions (one per CLI command)
4. CLI router (main() with nested switch/case)
```

Imports -- CommonJS `require()` exclusively, standard lib only:

```javascript
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const os = require('os');
const crypto = require('crypto');
const readline = require('readline');
```

No `module.exports` -- both main JS files are CLI entry points executed directly, not imported as libraries.

## CLI Argument Parsing

Hand-rolled, no argument parsing library. Uses `process.argv.slice(2)` with manual `indexOf` for named flags:

```javascript
const phaseIdx = args.indexOf('--phase');
const phase = phaseIdx !== -1 ? args[phaseIdx + 1] : null;
```

## Output Protocol

All commands produce either JSON (default) or raw text (with `--raw` flag) via a single output function:

```javascript
function output(result, raw, rawValue) {
  if (raw && rawValue !== undefined) {
    process.stdout.write(String(rawValue));
  } else {
    process.stdout.write(JSON.stringify(result, null, 2));
  }
  process.exit(0);
}
```

## Error Handling

Centralized error output function:

```javascript
function error(message) {
  process.stderr.write('Error: ' + message + '\n');
  process.exit(1);
}
```

Patterns used consistently:

- Silent `try/catch` with empty catch blocks for non-critical file reads:

```javascript
function safeReadFile(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf-8');
  } catch {
    return null;
  }
}
```

- Parameterless catch blocks (`catch {}`) for optional data
- `process.exit(1)` for fatal errors with descriptive messages
- `process.exit(0)` for successful output
- In hooks: outer try/catch that silently fails to avoid breaking the Claude Code UI

Input validation at command entry using the `error()` helper:

```javascript
if (!text) {
  error('text required for slug generation');
}
```

## Custom Parsers

YAML frontmatter parsed with a hand-written parser (`extractFrontmatter`), not a YAML library. Similarly, JSONC (JSON with comments) has a custom inline parser (`parseJsonc`). This keeps the zero-dependency approach.

## Git Integration

Direct `execSync('git ...')` calls through a helper:

```javascript
function execGit(cwd, args) {
  try {
    const escaped = args.map(a => {
      if (/^[a-zA-Z0-9._\-/=:@]+$/.test(a)) return a;
      return "'" + a.replace(/'/g, "'\\''") + "'";
    });
    const stdout = execSync('git ' + escaped.join(' '), {
      cwd, stdio: 'pipe', encoding: 'utf-8',
    });
    return { exitCode: 0, stdout: stdout.trim(), stderr: '' };
  } catch (err) {
    return { exitCode: err.status ?? 1, stdout: '...', stderr: '...' };
  }
}
```

## Testing

Framework: Node.js built-in test runner (`node:test`) -- no external test dependencies.

Test structure:

- Uses `describe` / `test` / `beforeEach` / `afterEach` from `node:test`
- Uses `assert` from `node:assert` (strict assertions)
- 18 `describe` blocks covering major CLI commands
- Tests execute the CLI as a subprocess via `execSync` (black box testing)

Test helper pattern:

```javascript
function runGsdTools(args, cwd = process.cwd()) {
  try {
    const result = execSync(`node "${TOOLS_PATH}" ${args}`, {
      cwd,
      encoding: 'utf-8',
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    return { success: true, output: result.trim() };
  } catch (err) {
    return {
      success: false,
      output: err.stdout?.toString().trim() || '',
      error: err.stderr?.toString().trim() || err.message,
    };
  }
}
```

Fixture pattern: each test suite creates a temp directory with `fs.mkdtempSync`, populates it with the needed `.planning/` structure, then cleans up:

```javascript
function createTempProject() {
  const tmpDir = fs.mkdtempSync(path.join(require('os').tmpdir(), 'gsd-test-'));
  fs.mkdirSync(path.join(tmpDir, '.planning', 'phases'), { recursive: true });
  return tmpDir;
}
```

Coverage: tests cover `gsd-tools.js` commands only. No tests for `install.js`, hooks, or the build script. Edge cases like malformed YAML, missing files, and backward compatibility are explicitly tested.

## CI/CD

No CI/CD pipeline exists. No GitHub Actions workflows.

The only automation:

1. `npm run build:hooks` - copies hook files to `hooks/dist/`
2. `prepublishOnly` script runs `build:hooks` before `npm publish`
3. PR template at `.github/pull_request_template.md` with a checklist for cross-platform testing

## Logging

No logging framework. The codebase uses:

- `process.stdout.write()` for CLI output (structured JSON or raw values)
- `process.stderr.write()` for error messages (only via the `error()` function)
- `console.log()` with ANSI color codes in the installer for user-facing messages
- No debug logging, no log levels, no log file output

## Style Enforcement

No automated tooling. The PR template mentions "Follows GSD style (no enterprise patterns, no filler)" as a manual checklist item, indicating style enforcement via code review only.
