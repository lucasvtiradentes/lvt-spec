# Gemini CLI Best Practices

This document covers best practices, common pitfalls, and troubleshooting techniques for Gemini CLI.

## Context and Project Setup

### Launch from Project Root

Always launch Gemini CLI from your project root directory to ensure correct context loading:

- The CLI searches from the current working directory upwards for GEMINI.md files
- Context is assembled at startup time based on where you launch
- Global context from ~/.gemini/GEMINI.md is also loaded
- Sub-directory GEMINI.md files provide component-specific instructions

Context loading hierarchy:

| Priority | Location                   | Scope                    |
|----------|----------------------------|--------------------------|
| 1        | ~/.gemini/GEMINI.md        | All projects (global)    |
| 2        | Project root GEMINI.md     | Current project          |
| 3        | Sub-directory GEMINI.md    | Component-specific       |

### Use @ References for Explicit Context

Use @ references to inject file content directly instead of summarizing or relying on model memory:

```bash
# Single file reference
@./src/config.ts

# Multiple files comparison
Compare @./foo.py and @./bar.py

# URL reference (fetches content)
@https://example.com/docs
```

Benefits of @ references:
- More precise than summarizing content yourself
- Prevents hallucination of file contents
- CLI warns if reference is too large or skipped

Caveats:
- Multiple large files consume significant context window tokens
- Respects .gitignore and .geminiignore by default

## Safety and Rollback

### Enable Checkpointing

Checkpointing automatically saves project state before file modifications, allowing instant rollback.

To enable checkpointing, add to your settings.json:

```json
{
  "general": {
    "checkpointing": {
      "enabled": true
    }
  }
}
```

Note: The --checkpointing command-line flag was removed in version 0.11.0.

How checkpoints work:
- Created automatically when approving file-modifying tools (write_file, replace)
- Stored as Git snapshots in ~/.gemini/history/<project_hash>
- Captures working directory state and conversation history

### Using /restore for Rollback

| Command          | Description                              |
|------------------|------------------------------------------|
| /restore         | List available checkpoints               |
| /restore <name>  | Restore to specific checkpoint           |

What gets restored:
- All project files to captured state
- Conversation history in the CLI
- Original tool prompt reappears

Limitations:
- Cannot undo external side effects (database migrations, API calls)
- Only file system and chat context are reverted

### Commit After Each Successful Step

Use git milestones to create recovery points:

- Break work into small, testable steps
- Commit after each step passes tests
- Provides recovery independent of checkpointing
- Enables selective rollback via standard git commands

## Common Pitfalls to Avoid

### Vague Prompts

| Bad                                      | Better                                                    |
|------------------------------------------|-----------------------------------------------------------|
| "analyze this code"                      | "identify performance bottlenecks in @./api/handler.ts"   |
| "make it better"                         | "refactor to use async/await instead of callbacks"        |
| "do deep analysis on this CSV"           | "calculate average and median for column 3 in @./data.csv"|

Use the prompt blueprint: Role, Goal, Inputs, Constraints, Output, Quality bar

### Wrong Model Selection

| Model | Best For                                  |
|-------|-------------------------------------------|
| Pro   | Complex reasoning, multi-step tasks       |
| Flash | Speed-critical, simple transformations    |
| Auto  | Recommended default, selects best model   |

Use /model command to switch models during a session if results are unsatisfactory.

### Multiple Instructions in One Prompt

Cramming multiple objectives causes:
- Jumbled responses
- AI focusing on one part and ignoring others
- Inconsistent output quality

Solution: Break down into sequential prompts.

### Ignoring Version Control

Risks of not using version control:
- No recovery from bad AI-generated changes
- Cannot compare before/after states
- Difficult to identify what changed

Always initialize git before starting AI-assisted coding sessions.

## Troubleshooting

### Debug Mode

Launch with debug flag for verbose output:

```bash
gemini -d
# or
gemini --debug
```

Debug output shows:
- File operations
- API calls
- Internal decision-making process

For interactive mode, press F12 to view the debug console.

### Diagnostic Commands

| Command     | Description                                           |
|-------------|-------------------------------------------------------|
| /stats      | Session token usage, cached savings, duration         |
| /mcp        | List MCP servers, connection status, available tools  |
| /mcp status | Detailed MCP server connectivity information          |

Note: Cached token info in /stats only appears with API key authentication, not OAuth.

### Memory Commands

| Command          | Description                                    |
|------------------|------------------------------------------------|
| /memory show     | Display full concatenated context              |
| /memory refresh  | Re-scan and reload all GEMINI.md files         |
| /memory add      | Quick notes (faster than editing GEMINI.md)    |

### Common Issues

| Issue                          | Solution                                              |
|--------------------------------|-------------------------------------------------------|
| Wrong context loaded           | Launch from correct directory, use /memory show       |
| MCP server not connecting      | Check /mcp status, verify server configuration        |
| Unexpected model behavior      | Enable debug mode, check /stats for token usage       |
| Checkpoints not created        | Verify checkpointing enabled in settings.json         |

## Sources

- [Gemini CLI Tips and Tricks - Addy Osmani](https://addyosmani.com/blog/gemini-cli/)
- [Gemini CLI Checkpointing Documentation](https://geminicli.com/docs/cli/checkpointing/)
- [Gemini CLI Commands Reference](https://geminicli.com/docs/cli/commands/)
- [Gemini CLI Configuration Guide](https://geminicli.com/docs/get-started/configuration/)
- [Gemini CLI Troubleshooting Guide](https://geminicli.com/docs/troubleshooting/)
- [MCP Servers with Gemini CLI](https://geminicli.com/docs/tools/mcp-server/)
- [Provide Context with GEMINI.md Files](https://geminicli.com/docs/cli/gemini-md/)
- [Google Gemini CLI Cheatsheet - Phil Schmid](https://www.philschmid.de/gemini-cli-cheatsheet)
