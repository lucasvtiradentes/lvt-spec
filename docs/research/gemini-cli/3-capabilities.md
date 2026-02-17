# Gemini CLI Capabilities

## Built-in Tools

Gemini CLI provides a comprehensive set of built-in tools that enable file system operations, web interactions, shell commands, and memory management.

### File System Tools

| Tool Name     | Internal Name   | Description                                    |
|---------------|-----------------|------------------------------------------------|
| ReadFile      | read_file       | Read file content (text, images, audio, PDFs)  |
| WriteFile     | write_file      | Write content to files, creates directories    |
| FindFiles     | glob            | Search files matching glob patterns            |
| SearchText    | grep_search     | Search regex patterns within file content      |
| ReadFolder    | list_directory  | List files and subdirectories                  |
| Edit          | replace         | Replace text within files with context         |
| ReadManyFiles | read_many_files | Read content from multiple files at once       |

### Web and Search Tools

| Tool Name    | Internal Name     | Description                        |
|--------------|-------------------|------------------------------------|
| GoogleSearch | google_web_search | Perform web searches               |
| WebFetch     | web_fetch         | Retrieve content from URLs         |

### System Tools

| Tool Name  | Internal Name     | Description                              |
|------------|-------------------|------------------------------------------|
| Shell      | run_shell_command | Execute shell commands in terminal       |
| SaveMemory | save_memory       | Save information across sessions         |
| WriteTodos | write_todos       | Manage subtasks for complex requests     |
| AskUser    | ask_user          | Gather user input for decisions          |

## Slash Commands

Slash commands provide meta-level control over the CLI session.

### Session Management

| Command       | Syntax                                  | Description                              |
|---------------|-----------------------------------------|------------------------------------------|
| /chat         | /chat save\                             |resume\                                   |list\|delete <tag>| Save and resume conversation history|
| /restore      | /restore [tool_call_id]                 | Undo file edits from tool execution      |
| /clear        | /clear                                  | Remove terminal display and history      |
| /compress     | /compress                               | Replace chat context with summary        |
| /copy         | /copy                                   | Copy last output to clipboard            |
| /export       | /export [filename]                      | Write conversation to markdown/JSON file |

### Configuration

| Command    | Syntax                       | Description                              |
|------------|------------------------------|------------------------------------------|
| /settings  | /settings                    | Open settings editor                     |
| /memory    | /memory add\                 |show\                                     |refresh                      | Manage AI instructional context|
| /directory | /directory add\              |show <path>                               | Manage workspace directories|
| /theme     | /theme                       | Change visual theme                      |
| /auth      | /auth                        | Change authentication method             |
| /editor    | /editor                      | Open editor selection dialog             |
| /vim       | /vim                         | Toggle vim mode for editing              |

### Information and Tools

| Command      | Syntax               | Description                              |
|--------------|----------------------|------------------------------------------|
| /mcp         | /mcp desc\           |nodesc                                    | List MCP servers and tools|
| /tools       | /tools desc\         |nodesc                                    | List available tools      |
| /extensions  | /extensions          | List active extensions                   |
| /stats       | /stats               | Display token usage and session stats    |
| /help        | /help or /?          | Display help information                 |
| /about       | /about               | Show version information                 |
| /bug         | /bug <description>   | File issue to GitHub repository          |
| /init        | /init                | Generate tailored GEMINI.md file         |
| /privacy     | /privacy             | View privacy notice and consent options  |

## CLI Flags

### Primary Flags

| Flag            | Alias | Type    | Description                              |
|-----------------|-------|---------|------------------------------------------|
| --prompt        | -p    | string  | Provide prompt text (enables headless)   |
| --model         | -m    | string  | Specify model (default: auto)            |
| --output-format | -o    | string  | Output as text, json, or stream-json     |
| --sandbox       | -s    | boolean | Execute in sandboxed environment         |
| --approval-mode | -     | string  | Set to default, auto_edit, or yolo       |
| --yolo          | -y    | boolean | Auto-approve all tool actions            |
| --resume        | -r    | string  | Resume previous session                  |
| --extensions    | -e    | array   | Load specific extensions                 |
| --debug         | -d    | boolean | Run with verbose logging                 |
| --help          | -h    | -       | Display help information                 |
| --version       | -v    | -       | Show CLI version                         |

### Model Aliases

| Alias      | Description                          |
|------------|--------------------------------------|
| auto       | Default; uses preview or standard    |
| pro        | For complex reasoning tasks          |
| flash      | Fast, balanced performance           |
| flash-lite | Optimized for simple tasks           |

## MCP Integration

Model Context Protocol (MCP) enables extending Gemini CLI with external tools and resources through a standardized interface.

### Configuration

MCP servers are defined in `settings.json` under the `mcpServers` object:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["server.js"],
      "env": {
        "API_KEY": "$MY_API_KEY"
      },
      "timeout": 30000,
      "trust": false
    }
  }
}
```

### Transport Options

| Transport | Config Key | Description                    |
|-----------|------------|--------------------------------|
| Stdio     | command    | Subprocess communication       |
| SSE       | url        | Server-Sent Events             |
| HTTP      | httpUrl    | Streamable HTTP                |

### Server Configuration Options

| Property     | Description                               |
|--------------|-------------------------------------------|
| command      | Command to start server (Stdio)           |
| args         | Command-line arguments                    |
| env          | Environment variables ($VAR_NAME syntax)  |
| timeout      | Request timeout in milliseconds           |
| trust        | Bypass confirmation dialogs when true     |
| includeTools | Whitelist specific tools                  |
| excludeTools | Blacklist specific tools                  |

### CLI Management Commands

```bash
gemini mcp add <name> <command>
gemini mcp list
gemini mcp remove <name>
```

### MCP Features

- Tools from MCP servers become available to the Gemini model
- Prompts exposed by MCP servers work as custom slash commands
- Rich content returns (text, images, audio, embedded resources)
- OAuth 2.0 support for remote servers with automatic discovery

## Headless Mode

Headless mode enables programmatic execution for scripting, automation, and CI/CD pipelines.

### Input Methods

```bash
gemini --prompt "What is machine learning?"

echo "Explain this code" | gemini

cat README.md | gemini --prompt "Summarize this documentation"
```

### Output Formats

| Format      | Flag Value   | Description                              |
|-------------|--------------|------------------------------------------|
| Text        | text         | Human-readable responses (default)       |
| JSON        | json         | Structured object with response/stats    |
| Stream JSON | stream-json  | Real-time newline-delimited JSON (JSONL) |

JSON output structure:

```json
{
  "response": "AI-generated content",
  "stats": {
    "tokens": {},
    "model": "",
    "toolCalls": []
  },
  "error": null
}
```

### CI/CD Examples

Code review with git diff:

```bash
git diff HEAD~1 | gemini -p "Review for security issues" --output-format json
```

Auto-generate commit messages:

```bash
git diff --staged | gemini -p "Generate commit message" -y
```

Batch file analysis:

```bash
for file in src/*.ts; do
  gemini -p "Analyze $file for issues" --output-format json
done
```

Generate release notes:

```bash
git log --oneline v1.0..v2.0 | gemini -p "Generate release notes"
```
