# Capabilities

## What Matters Most

For advanced usage, the highest-value areas are command/mode control, AGENTS.md guardrails, reusable skills/commands, MCP integration, and practical automation hooks.

## Core Command Surface

| Command       | Purpose                        | Typical Use                           |
|---------------|--------------------------------|---------------------------------------|
| `codex`       | Interactive TUI session        | Day-to-day coding tasks               |
| `codex exec`  | Non-interactive run            | CI scripts, one-shot generation/review|
| `codex review`| Code review workflow           | Focused review pass in repo           |
| `codex apply` | Apply latest agent diff        | Controlled patch application          |
| `codex resume`| Continue previous session      | Recover long task context             |
| `codex fork`  | Branch from prior session state| Try alternate approach safely         |

## High-Impact Flags and Modes

| Flag                                        | Purpose                   | Notes                                               |
|---------------------------------------------|---------------------------|-----------------------------------------------------|
| `-m, --model`                               | Select model              | Per-run model override                              |
| `-s, --sandbox`                             | Sandbox policy            | `read-only`, `workspace-write`, `danger-full-access`|
| `-a, --ask-for-approval`                    | Approval behavior         | `untrusted`, `on-failure`, `on-request`, `never`    |
| `--full-auto`                               | Low-friction automation   | Uses sandboxed automatic execution defaults         |
| `--dangerously-bypass-approvals-and-sandbox`| Disable safety checks     | Only in externally sandboxed environments           |
| `-c, --config key=value`                    | Override config at runtime| Useful for temporary experiments                    |
| `--profile`                                 | Load profile from config  | Team-specific defaults                              |

## AGENTS.md as Behavior Contract

AGENTS.md defines repository-specific operating rules for the agent. In practice it is used to enforce:

- coding conventions and formatting rules
- safety constraints for shell commands
- review/test expectations before finalizing changes
- project-specific workflows and boundaries

Practical pattern:

- Keep AGENTS.md strict on safety and quality gates
- Keep task instructions in prompts focused on outcomes
- Let AGENTS.md carry stable team policy

## Skills and Reusable Commands

Many teams structure reusable workflows in `.agents/skills/<name>/SKILL.md` and trigger them with command-like invocations (for example `$gen-docs`, `$research-topic`).

| Capability           | Typical Location                | Result                               |
|----------------------|---------------------------------|--------------------------------------|
| Skill definition     | `.agents/skills/<name>/SKILL.md`| Repeatable workflow with clear phases|
| Shared command source| `src/commands/<name>/...`       | Multi-agent command generation       |
| Team instructions    | `AGENTS.md`                     | Consistent behavior across tasks     |

This turns ad-hoc prompting into versioned, reviewable repo automation.

## MCP Integration

Codex provides MCP server management via `codex mcp`.

| MCP Command                        | Purpose                      |
|------------------------------------|------------------------------|
| `codex mcp list`                   | Show configured MCP servers  |
| `codex mcp get <name>`             | Show a single server config  |
| `codex mcp add <name> --url <URL>` | Add HTTP MCP server          |
| `codex mcp add <name> -- <command>`| Add stdio MCP server         |
| `codex mcp remove <name>`          | Remove server config         |
| `codex mcp login <name>`           | Authenticate server if needed|
| `codex mcp logout <name>`          | Clear server auth            |

Example setup:

```bash
codex mcp add docs --url https://example.com/mcp
codex mcp list
```

## Hooks and Workflow Automation

Codex CLI provides two notification mechanisms: external program hooks via `notify` and built-in TUI notifications.

### Available Event Types

| Event               | Trigger                          | Use Case                          |
|---------------------|----------------------------------|-----------------------------------|
| agent-turn-complete | Agent finishes processing a task | Desktop toast, webhook, CI update |
| approval-requested  | User approval needed             | Sound alert, interrupt workflow   |

### External Notify Hook

The `notify` setting triggers an external program whenever Codex emits supported events. The command receives a JSON payload as a single argument.

JSON payload structure:

```json
{
  "type": "agent-turn-complete",
  "thread-id": "abc123",
  "turn-id": "turn-1",
  "cwd": "/path/to/project",
  "input-messages": [...],
  "last-assistant-message": "All tasks complete!"
}
```

Config.toml examples:

```toml
# Play sound on macOS
notify = ["bash", "-lc", "afplay /System/Library/Sounds/Blow.aiff"]

# Custom notification script
notify = ["/bin/bash", "/Users/YOU/.codex/hooks/notify.sh"]

# Third-party chime tool
notify = ["codex-notify-chime"]

# Desktop notification via terminal-notifier
notify = ["terminal-notifier", "-title", "Codex", "-message", "Task complete"]
```

Root keys must appear before any `[tables]` in config.toml.

### TUI Built-in Notifications

| Setting                   | Type              | Description                              |
|---------------------------|-------------------|------------------------------------------|
| tui.notifications         | bool or string[]  | Enable/disable or filter by event type   |
| tui.notification_method   | string            | `auto`, `osc9`, or `bel`                 |

```toml
[tui]
notifications = ["agent-turn-complete", "approval-requested"]
notification_method = "osc9"
```

### Notification Script Example

```bash
#!/bin/bash
# ~/.codex/hooks/notify.sh
payload="$1"
message=$(echo "$payload" | jq -r '.["last-assistant-message"]')
terminal-notifier -title "Codex" -message "$message" -sound default
```

### Workflow Automation Patterns

Shell wrappers that extend Codex behavior:

```bash
# Run tests after applying patch
codex apply && npm test

# Lint after codex completes
codex exec "fix the bug" && eslint . --fix

# Standardized project defaults
alias cx='codex -m gpt-5 -s workspace-write -a on-request'
```

CI integration via non-interactive mode:

```bash
# Automated changelog update in CI
codex exec "Update CHANGELOG.md for version $VERSION" --full-auto

# Pre-PR validation
codex exec "Review and fix any type errors" -s workspace-write
```

### OpenTelemetry Events (Observability)

For advanced monitoring, Codex emits events via OpenTelemetry:

| Event                    | Description                           |
|--------------------------|---------------------------------------|
| codex.conversation_starts| Session start with model/sandbox info |
| codex.tool_result        | Tool execution duration and success   |
| codex.api_request        | API request timing                    |
| codex.approval.requested | Approval outcome (approved/denied)    |

```toml
[otel]
exporter = "otlp-http"
```

## Operational Playbooks

### Repo onboarding

1. Read AGENTS.md and repository docs
2. Ask Codex to summarize architecture
3. Generate targeted questions for missing context

### Safe refactor

1. Start with narrow prompt and acceptance criteria
2. Keep `workspace-write` and approval enabled
3. Apply patch, run tests, inspect diffs, then continue

### Documentation sprint

1. Use reusable skill command (`$research-topic`, `$gen-docs`)
2. Generate section-by-section docs
3. Align tables/lists and verify links
