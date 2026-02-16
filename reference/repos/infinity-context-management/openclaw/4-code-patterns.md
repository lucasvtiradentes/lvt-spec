# Code Patterns

## Coding Style

- TypeScript strict mode, ES2023 target, NodeNext module resolution
- ESM throughout (`"type": "module"` in package.json)
- File extensions always `.js` in imports (even for `.ts` files)
- No JSDoc -- types serve as documentation
- Barrel exports via `index.ts` files
- Config types split into focused modules (e.g., `types.agents.ts`, `types.channels.ts`, `types.gateway.ts`)
- `oxlint-disable-next-line` for intentional lint suppressions
- Naming: camelCase for variables/functions, PascalCase for types/classes, kebab-case for files
- Prefer `type` imports (`import type { ... }`) for type-only imports
- Re-export patterns: `export * from "./module.js"` and `export type { ... } from "./module.js"`
- Async/await throughout, no callbacks

## Testing

Framework: Vitest 4.x with forks pool

Configuration:
- Workers: 2-3 in CI, 4-16 locally (based on CPU count)
- Timeout: 120s per test
- Coverage: v8 provider, thresholds: 70% lines/functions/statements, 55% branches
- Separate configs: `vitest.config.ts` (main), `vitest.unit.config.ts`, `vitest.e2e.config.ts`, `vitest.extensions.config.ts`, `vitest.gateway.config.ts`, `vitest.live.config.ts`
- Setup file: `test/setup.ts`

Test patterns:
- Co-located test files (e.g., `config.test.ts` next to `config.ts`)
- `describe` / `it` blocks with descriptive names
- Direct imports from `vitest` (`import { describe, expect, it } from "vitest"`)
- Mock configs as plain objects matching type shapes
- Null/undefined edge case coverage

Example test structure:

```typescript
import { describe, expect, it } from "vitest";
import { getAccountConfig } from "./config.js";

describe("getAccountConfig", () => {
  it("returns account config for valid account ID", () => {
    const result = getAccountConfig(mockConfig, "default");
    expect(result).not.toBeNull();
    expect(result?.username).toBe("testbot");
  });

  it("returns null for non-existent account", () => {
    const result = getAccountConfig(mockConfig, "nonexistent");
    expect(result).toBeNull();
  });
});
```

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- `ci.yml` -- main CI pipeline: lint, typecheck (tsgo), build, test (unit + e2e + extensions), Docker tests
- Security scanning: `detect-secrets` for secret detection in CI
- `zizmor.yml` -- GitHub Actions security linting

Pipeline stages:
1. Lint (oxlint with type-aware rules)
2. Format check (oxfmt)
3. Type check (tsgo / tsc)
4. Build (tsdown)
5. Unit tests (vitest)
6. E2E tests (vitest.e2e.config.ts)
7. Extension tests (vitest.extensions.config.ts)
8. Docker tests (8 sub-test suite)
9. Live model tests (optional, requires OPENCLAW_LIVE_TEST=1)

## Linting and Formatting

| Tool        | Config File              | Purpose                        |
|-------------|--------------------------|--------------------------------|
| oxlint      | .oxlintrc.json           | TypeScript linter (type-aware) |
| oxfmt       | .oxfmtrc.jsonc           | Code formatter (Rust-based)    |
| swiftlint   | .swiftlint.yml           | Swift linter                   |
| swiftformat | .swiftformat             | Swift formatter                |
| markdownlint| .markdownlint-cli2.jsonc | Markdown linter                |
| shellcheck  | .shellcheckrc            | Shell script linter            |

## Error Handling

- Channel status issues reported via `ChannelStatusIssue` type with kind: `intent | permissions | config | auth | runtime`
- Config validation via Zod schema (`OpenClawSchema`) and AJV (TypeBox)
- Graceful degradation: channels that fail to initialize are skipped, not fatal
- Reply dispatch wraps errors and marks dispatch idle
- `soul-evil.ts` -- prompt injection detection for inbound messages

## Git Hooks

Pre-commit via `.pre-commit-config.yaml`:
- `detect-secrets` -- scan for accidentally committed secrets
- `run-node-tool.sh` -- wrapper that finds the right package manager (pnpm > bun > npm)
- Git hooks directory: `git-hooks/`
- Configured via `prepare` script: `git config core.hooksPath git-hooks`

## Security Practices

- `detect-secrets` for CI/CD secret scanning with `.secrets.baseline`
- DM pairing policy: unknown senders must be approved before processing
- Docker sandbox for non-main agent sessions (network=none, read-only root, pidsLimit, seccomp, AppArmor)
- `openclaw security audit --deep` and `--fix` for hardening
- `openclaw doctor` for configuration auditing and migration
- Non-root Docker user (node, uid 1000)
- Gateway auth required by default (token/password)
- Anti-clickjacking headers on Control UI
- Same-origin WebSocket enforcement unless `allowedOrigins` configured
- Node.js >= 22.12.0 required for security patches (CVE-2025-59466, CVE-2026-21636)

## Code Organization Conventions

- Core channels live in `src/<channel>/` (whatsapp, telegram, slack, discord, signal, imessage, line)
- Extension channels live in `extensions/<channel>/` (matrix, msteams, twitch, nostr, feishu, etc.)
- Each extension has: `index.ts`, `openclaw.plugin.json`, `package.json`, `src/` directory
- Config types are split per domain in `src/config/types.<domain>.ts`
- Channel plugin interface defined in `src/channels/plugins/types.plugin.ts`
- Skills are markdown files with YAML frontmatter in `skills/<name>/SKILL.md`
