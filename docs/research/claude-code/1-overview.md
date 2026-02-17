# Claude Code Overview

## What It Is

Claude Code is Anthropic's agentic coding tool that lives in your terminal. It reads your codebase, edits files, runs commands, and handles git workflows through natural language. It understands your project structure, framework, libraries, and coding style.

Sessions are not tied to a single surface - you can move work between terminal, IDE, browser, and desktop app. Each surface connects to the same underlying engine.

## Why Use It

- Terminal-first design keeps coding workflow in one place
- Native git integration handles commits, branches, and PRs
- Agentic execution runs multi-step tasks autonomously
- Multi-platform access lets you start work anywhere and continue elsewhere
- Plugin ecosystem extends functionality with custom tools

## Installation Snapshot

| Method    | Command                                             | Notes                                 |
|-----------|-----------------------------------------------------|---------------------------------------|
| curl      | `curl -fsSL https://claude.ai/install.sh \   | bash`| macOS/Linux, auto-updates, recommended|
| PowerShell| `irm https://claude.ai/install.ps1 \         | iex` | Windows native, auto-updates          |
| Homebrew  | `brew install --cask claude-code`                   | macOS/Linux, manual updates needed    |
| WinGet    | `winget install Anthropic.ClaudeCode`               | Windows, manual updates needed        |
| npm       | `npm install -g @anthropic-ai/claude-code`          | Deprecated, use native installer      |

Native installer downloads a standalone binary with its own runtime - Node.js is not required.

## Core Concepts

| Concept    | What It Means                                              | Practical Use                                      |
|------------|------------------------------------------------------------|----------------------------------------------------|
| Session    | Ongoing task context in CLI                                | Multi-step work without re-explaining everything   |
| CLAUDE.md  | Persistent memory file loaded at session start             | Store project guidelines, coding standards, context|
| Plan Mode  | Read-only analysis mode (Shift+Tab twice)                  | Let Claude think and plan before executing         |
| MCP        | Model Context Protocol for external tool connections       | Connect to GitHub, Slack, databases, JIRA          |
| Hooks      | Scripts triggered at points in Claude's agentic lifecycle  | Run commands before/after Claude actions           |
| Skills     | Bundled instructions with SKILL.md files                   | Teach Claude specialized workflows and procedures  |
| Plugins    | Shareable extensions with commands, agents, hooks          | Extend functionality across projects and teams     |

## Plan Mode Example

```
> /plan analyze this codebase for security issues
```

Or press `Shift+Tab` twice to enter planning mode. Claude analyzes without making changes until you approve.

## CLAUDE.md Structure

Place in project root or `.claude/` directory:

```
# Project Guidelines

- Use TypeScript strict mode
- Follow conventional commits
- Run tests before committing

# Architecture Notes

- API routes in /src/api
- Shared utils in /src/lib
```

## Sources

- https://github.com/anthropics/claude-code
- https://code.claude.com/docs/en/overview
- https://code.claude.com/docs/en/setup
- https://code.claude.com/docs/en/skills
