# Claude Code Capabilities

## What Matters Most

For power users, the highest-value areas are skills system (custom workflows), hooks (lifecycle automation), subagents (delegated tasks), and MCP integration (external tools). Mastering these transforms Claude Code from a coding assistant into a customizable agent operating system.

## Core Command Surface

### Built-in Commands

| Command                   | Purpose                                           | Notes                                    |
|---------------------------|---------------------------------------------------|------------------------------------------|
| `/help`                   | Show all available commands                       | Lists built-in, skills, and MCP prompts  |
| `/init`                   | Create CLAUDE.md for project                      | Run first in any new project             |
| `/clear`                  | Clear conversation history                        | Starts fresh session                     |
| `/compact [instructions]` | Compact conversation                              | Optional focus instructions              |
| `/resume [session]`       | Resume a conversation                             | By ID, name, or session picker           |
| `/plan`                   | Enter plan mode                                   | Also via Shift+Tab twice                 |
| `/model`                  | Select or change model                            | Left/right arrows adjust effort          |
| `/mcp`                    | Manage MCP servers and OAuth                      | Add, remove, authenticate servers        |
| `/memory`                 | Edit CLAUDE.md memory files                       | Manage persistent context                |
| `/permissions`            | View or update permissions                        | Configure tool access rules              |
| `/context`                | Visualize context usage                           | Colored grid showing token usage         |
| `/cost`                   | Show token usage statistics                       | Session and cumulative costs             |
| `/export [filename]`      | Export conversation                               | To file or clipboard                     |
| `/agents`                 | Manage subagents                                  | View, create, edit, delete               |
| `/hooks`                  | Manage lifecycle hooks                            | Interactive configuration                |
| `/tasks`                  | List background tasks                             | Manage concurrent operations             |
| `/debug [description]`    | Troubleshoot session                              | Read debug log with optional description |
| `/doctor`                 | Check installation health                         | Diagnose configuration issues            |

### Quick Commands

| Prefix   | Purpose              | Example                  |
|----------|----------------------|--------------------------|
| `/`      | Run command or skill | `/review-pr 123`         |
| `!`      | Bash mode            | `! npm test`             |
| `@`      | File path mention    | `@src/main.ts`           |
| `#`      | Save to CLAUDE.md    | `# Always use TypeScript`|

## Keyboard Shortcuts

### General Controls

| Shortcut              | Action                     | Context                              |
|-----------------------|----------------------------|--------------------------------------|
| `Ctrl+C`              | Cancel input or generation | Standard interrupt                   |
| `Ctrl+D`              | Exit session               | EOF signal                           |
| `Ctrl+G`              | Open in text editor        | Edit prompt externally               |
| `Ctrl+L`              | Clear terminal screen      | Keeps conversation history           |
| `Ctrl+O`              | Toggle verbose output      | Shows tool execution details         |
| `Ctrl+R`              | Reverse search history     | Search previous commands             |
| `Ctrl+B`              | Background running tasks   | Move tasks to background             |
| `Ctrl+T`              | Toggle task list           | Show/hide progress tracking          |
| `Shift+Tab`           | Cycle permission modes     | Normal -> Auto-Accept -> Plan        |
| `Alt+P` / `Option+P`  | Switch model               | Without clearing prompt              |
| `Alt+T` / `Option+T`  | Toggle extended thinking   | Enable deeper analysis               |
| `Esc` + `Esc`         | Rewind or summarize        | Restore to previous point            |
| `Up/Down arrows`      | Navigate history           | Recall previous inputs               |

### Text Editing

| Shortcut | Action                    |
|----------|---------------------------|
| `Ctrl+K` | Delete to end of line     |
| `Ctrl+U` | Delete entire line        |
| `Ctrl+Y` | Paste deleted text        |
| `Alt+B`  | Move cursor back one word |
| `Alt+F`  | Move forward one word     |

### Multiline Input

| Method       | Shortcut       | Terminals                          |
|--------------|----------------|------------------------------------|
| Quick escape | `\` + `Enter`  | All terminals                      |
| macOS        | `Option+Enter` | Default on macOS                   |
| Shift+Enter  | `Shift+Enter`  | iTerm2, WezTerm, Ghostty, Kitty    |
| Line feed    | `Ctrl+J`       | All terminals                      |

## Permission Modes

| Mode          | How to Enable   | Behavior                              |
|---------------|-----------------|---------------------------------------|
| Normal        | Default         | Standard permission prompts           |
| Auto-Accept   | `Shift+Tab` x1  | Auto-accept file edits                |
| Plan Mode     | `Shift+Tab` x2  | Read-only exploration, no edits       |
| Delegate Mode | Agent teams     | Coordination-only for team leads      |

## Configuration

### CLAUDE.md Memory Files

| Location                      | Scope                    | Purpose                                   |
|-------------------------------|--------------------------|-------------------------------------------|
| `~/.claude/CLAUDE.md`         | Global (all projects)    | Personal preferences and conventions      |
| `.claude/CLAUDE.md`           | Project                  | Team shared project context               |
| `.claude/CLAUDE.local.md`     | Project (gitignored)     | Local project overrides                   |
| `folder/.claude/CLAUDE.md`    | Subdirectory             | Monorepo package-specific context         |

Create with `/init` or manually. Claude reads these automatically. Start any message with `#` to save to CLAUDE.md.

### Settings Files

| Location                       | Scope          | Use Case                        |
|--------------------------------|----------------|---------------------------------|
| `~/.claude/settings.json`      | User           | Personal global settings        |
| `.claude/settings.json`        | Project        | Team shared settings            |
| `.claude/settings.local.json`  | Project local  | Local overrides (gitignored)    |

## MCP Integration

Model Context Protocol connects Claude Code to external tools, databases, and APIs.

### MCP Commands

| Command                             | Purpose                        | Example                                       |
|-------------------------------------|--------------------------------|-----------------------------------------------|
| `claude mcp add`                    | Add MCP server                 | `claude mcp add --transport http name url`    |
| `claude mcp add-json`               | Add from JSON config           | `claude mcp add-json name '{...}'`            |
| `claude mcp add-from-claude-desktop`| Import from Desktop            | Import existing configurations                |
| `claude mcp list`                   | List configured servers        | Show all MCP servers                          |
| `claude mcp get <name>`             | Get server details             | View specific configuration                   |
| `claude mcp remove <name>`          | Remove server                  | Delete configuration                          |
| `/mcp`                              | In-session management          | Authenticate, view status                     |

### Transport Types

| Transport | Flag                | Use Case                           |
|-----------|---------------------|------------------------------------|
| HTTP      | `--transport http`  | Remote servers (recommended)       |
| SSE       | `--transport sse`   | Server-sent events (deprecated)    |
| stdio     | `--transport stdio` | Local process servers              |

### MCP Scopes

| Scope   | Flag              | Storage               | Description                      |
|---------|-------------------|-----------------------|----------------------------------|
| local   | `--scope local`   | `~/.claude.json`      | Private to you, current project  |
| project | `--scope project` | `.mcp.json`           | Shared via version control       |
| user    | `--scope user`    | `~/.claude.json`      | Available across all projects    |

### Example: Add GitHub MCP

```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
```

Then authenticate in session:
```
> /mcp
```

## Git Integration

Claude Code works with git natively via Bash tool.

### Common Operations

| Task                 | Approach                                              |
|----------------------|-------------------------------------------------------|
| Create commit        | Ask Claude to commit with conventional message        |
| Review changes       | Use `/review` skill or ask to analyze git diff        |
| Create PR            | Ask Claude to create PR with gh CLI                   |
| Fix merge conflicts  | Claude can read conflicts and propose resolutions     |
| Branch management    | Create, switch, delete branches via Bash              |

### Best Practices

- Claude reads CLAUDE.md for commit conventions
- Use hooks to validate commits before creation
- Skills can automate PR templates
- Subagents can handle code review in isolation

## Hooks System

Hooks are shell commands or prompts that run at lifecycle events.

### Hook Events

| Event               | When It Fires                    | Can Block |
|---------------------|----------------------------------|-----------|
| `SessionStart`      | Session begins or resumes        | No        |
| `UserPromptSubmit`  | Before processing user prompt    | Yes       |
| `PreToolUse`        | Before tool call executes        | Yes       |
| `PermissionRequest` | Permission dialog appears        | Yes       |
| `PostToolUse`       | After tool succeeds              | No        |
| `PostToolUseFailure`| After tool fails                 | No        |
| `SubagentStart`     | Subagent spawned                 | No        |
| `SubagentStop`      | Subagent finishes                | Yes       |
| `Stop`              | Claude finishes responding       | Yes       |
| `TaskCompleted`     | Task marked complete             | Yes       |
| `PreCompact`        | Before context compaction        | No        |
| `SessionEnd`        | Session terminates               | No        |

### Hook Types

| Type      | Description                              | Use Case                          |
|-----------|------------------------------------------|-----------------------------------|
| `command` | Run shell script                         | Validation, logging, automation   |
| `prompt`  | Single LLM call for evaluation           | Policy checks with reasoning      |
| `agent`   | Multi-turn subagent with tool access     | Complex verification tasks        |

### Hook Configuration Example

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/lint.sh"
          }
        ]
      }
    ]
  }
}
```

## Skills System

Skills extend Claude Code with custom prompts and workflows.

### Skill Locations

| Location                            | Scope                      |
|-------------------------------------|----------------------------|
| `~/.claude/skills/<name>/SKILL.md`  | Personal (all projects)    |
| `.claude/skills/<name>/SKILL.md`    | Project                    |
| Plugin `skills/<name>/SKILL.md`     | Plugin scope               |

### Skill Frontmatter Fields

| Field                      | Purpose                                        |
|----------------------------|------------------------------------------------|
| `name`                     | Skill identifier (becomes /command)            |
| `description`              | When Claude should use this skill              |
| `disable-model-invocation` | Only user can invoke (not Claude)              |
| `user-invocable`           | Hide from / menu (Claude-only)                 |
| `allowed-tools`            | Restrict tool access                           |
| `model`                    | Override model                                 |
| `context`                  | Set to `fork` for subagent execution           |
| `agent`                    | Which subagent type when `context: fork`       |

### Skill Example

```yaml
---
name: review-pr
description: Review pull request changes
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(gh *)
---

Review PR $ARGUMENTS:
1. Read the diff
2. Check for issues
3. Suggest improvements
```

## Subagents

Subagents handle specialized tasks in isolated contexts.

### Built-in Subagents

| Agent     | Model   | Tools        | Purpose                        |
|-----------|---------|--------------|--------------------------------|
| Explore   | Haiku   | Read-only    | Fast codebase search           |
| Plan      | Inherit | Read-only    | Research for planning          |
| general   | Inherit | All          | Complex multi-step tasks       |

### Subagent Configuration

Place in `.claude/agents/` (project) or `~/.claude/agents/` (user):

```yaml
---
name: code-reviewer
description: Reviews code for quality
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: default
---

You are a code reviewer. Analyze code for quality, security, and best practices.
```

### Subagent Frontmatter

| Field            | Purpose                              |
|------------------|--------------------------------------|
| `name`           | Unique identifier                    |
| `description`    | When to delegate to this agent       |
| `tools`          | Allowed tools (inherits all if omit) |
| `disallowedTools`| Tools to deny                        |
| `model`          | `sonnet`, `opus`, `haiku`, `inherit` |
| `permissionMode` | `default`, `acceptEdits`, `plan`, etc|
| `maxTurns`       | Maximum agentic turns                |
| `skills`         | Preload specific skills              |
| `memory`         | Persistent memory scope              |
| `hooks`          | Lifecycle hooks for this agent       |

## Agent Teams

Multiple agents working in parallel with coordination.

### Team Configuration

Place in `.claude/teams/<name>.md`:

```yaml
---
name: my-team
lead: coordinator
teammates:
  - researcher
  - implementer
---

Project context and instructions here.
```

### Delegate Mode

Team leads can use delegate mode (`Shift+Tab` to cycle) for coordination-only operations.

## Advanced Features

### Environment Variables

| Variable                              | Purpose                             |
|---------------------------------------|-------------------------------------|
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS`| Disable background operations       |
| `ENABLE_TOOL_SEARCH`                  | Control MCP tool search behavior    |
| `MAX_MCP_OUTPUT_TOKENS`               | Increase MCP output limit           |
| `MCP_TIMEOUT`                         | MCP server startup timeout          |

### Running as MCP Server

```bash
claude mcp serve
```

Allows other applications to use Claude Code's tools.

### Headless Mode

Run Claude Code programmatically:

```bash
claude -p "your prompt" --output-format json
```

Useful for CI/CD, automation, and scripting.

## References

- [Slash commands documentation](https://code.claude.com/docs/en/slash-commands)
- [Interactive mode reference](https://code.claude.com/docs/en/interactive-mode)
- [MCP integration guide](https://code.claude.com/docs/en/mcp)
- [Hooks reference](https://code.claude.com/docs/en/hooks)
- [Skills documentation](https://code.claude.com/docs/en/skills)
- [Subagents guide](https://code.claude.com/docs/en/sub-agents)
