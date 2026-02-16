# Codex CLI Overview

## What It Is

Codex CLI is OpenAI's terminal agent for software tasks inside a repository: it can read files, propose/apply edits, run commands, and iterate with approvals.

## Why Use It

- Keep coding workflow in terminal without context switching
- Delegate repetitive repo tasks like refactors, test loops, and doc updates
- Control risk with sandbox and approval policies
- Run interactive sessions or non-interactive automation (`codex exec`)

## Installation Snapshot

| Step   | Command                       | Notes                       |
|--------|-------------------------------|-----------------------------|
| Install| `npm install -g @openai/codex`| Requires Node.js and npm    |
| Verify | `codex --version`             | Confirms binary is available|
| Start  | `codex`                       | Launches interactive session|

## Core Concepts

| Concept        | What It Means                                      | Practical Use                                   |
|----------------|----------------------------------------------------|-------------------------------------------------|
| Session        | Ongoing task context in CLI                        | Multi-step work without re-explaining everything|
| Model          | LLM used for reasoning and code actions            | Tune speed/quality with `-m <model>`            |
| Approval policy| When a command requires explicit user approval     | Safer execution in risky operations             |
| Sandbox mode   | Filesystem/network boundaries for command execution| Limit side effects while iterating              |
| Profile/config | Saved defaults in `~/.codex/config.toml`           | Reuse team or personal settings                 |

## Execution Model

```text
prompt -> plan/diff/command proposal -> approval/sandbox check -> execution -> verify -> iterate
```

## Platform Notes

- macOS and Linux are standard paths for CLI usage
- Windows commonly runs through WSL in many team setups
- If terminal tooling differs, validate shell, PATH, and git setup first
