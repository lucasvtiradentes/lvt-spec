# Gemini CLI

Gemini CLI is an open-source AI agent by Google that brings Gemini directly into your terminal. It uses a ReAct (Reason and Act) loop combined with built-in tools and MCP servers to complete complex development tasks.

## Core Concepts

### Agentic Loop

The CLI operates using a ReAct loop where the model:
- Receives a prompt from the user
- Reasons about the task and decides which tools to use
- Acts by calling tools (file operations, shell commands, web search)
- Observes the results and continues reasoning until the task is complete

### Built-in Tools

| Tool               | Description                                      |
|--------------------|--------------------------------------------------|
| read_file          | Read contents of a single file                   |
| read_many_files    | Read multiple files at once                      |
| write_file         | Create new files                                 |
| replace            | Modify existing files by replacing text          |
| glob               | Find files using glob patterns                   |
| search_file_content| Search for text within files                     |
| list_directory     | List contents of a directory                     |
| run_shell_command  | Execute shell commands                           |
| GoogleSearch       | Search the web for current information           |
| WebFetch           | Fetch and read web page content                  |
| save_memory        | Save context to GEMINI.md files                  |

### MCP Servers for Extensibility

Model Context Protocol (MCP) servers extend Gemini CLI capabilities:
- Act as bridges between the model and external systems (databases, APIs, custom scripts)
- Expose tools, resources, and prompts through standardized schema definitions
- Support rich content responses including text, images, audio, and binary data
- Can be local STDIO servers or remote HTTP servers

Configuration in settings.json:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"]
    }
  }
}
```

## Installation

Prerequisites: Node.js 18+

```bash
npm install -g @google/gemini-cli

gemini
```

Alternative without permanent installation:

```bash
npx @google/gemini-cli
```

## Free Tier Limits

| Metric              | Limit                  |
|---------------------|------------------------|
| Requests per minute | 60 RPM                 |
| Requests per day    | 1,000 RPD              |
| Model               | Gemini 2.5 Pro         |
| Authentication      | Personal Google account|

Note: A single user prompt can trigger multiple model requests (API calls), so actual prompt count may be lower than the request limit.

## Configuration

### GEMINI.md Files

Context files provide instructions to the model:

| Location                     | Scope                           |
|------------------------------|---------------------------------|
| ~/.gemini/GEMINI.md          | Global defaults for all projects|
| ./GEMINI.md                  | Project-specific instructions   |
| Parent directories up to .git| Hierarchical context            |

### Memory Commands

| Command            | Description                              |
|--------------------|------------------------------------------|
| /memory show       | Display current concatenated context     |
| /memory refresh    | Reload all GEMINI.md files               |
| /memory add <text> | Append text to global GEMINI.md          |

### Approval Modes

| Mode      | Behavior                                       |
|-----------|------------------------------------------------|
| default   | Prompts for approval on each tool call         |
| auto_edit | Auto-approves file edits, prompts for others   |
| yolo      | Auto-approves all tool calls (use with caution)|

Enable YOLO mode:

```bash
gemini -y

gemini --yolo
```

Or press Ctrl+Y during an interactive session.

## Use Cases

- Code explanation and understanding large codebases
- Bug fixing with context from error messages and stack traces
- Test generation with knowledge of existing test patterns
- Documentation generation from code
- CI/CD automation and deployment script creation
- Refactoring across multiple files
- Code review assistance

## Comparison with Alternatives

| Feature            | Gemini CLI                | Claude Code             | Codex CLI              |
|--------------------|---------------------------|-------------------------|------------------------|
| Provider           | Google                    | Anthropic               | OpenAI                 |
| License            | Apache 2.0                | Proprietary             | Apache 2.0             |
| Free tier          | Yes (1000 req/day)        | No                      | No                     |
| Context window     | 1M tokens                 | 200K tokens             | 128K tokens            |
| MCP support        | Yes                       | Yes                     | Yes                    |
| Multimodal         | Full (images, PDFs, video)| Images, PDFs            | Images                 |
| Sandbox mode       | Docker-based              | Built-in                | Built-in               |
| Web search         | Built-in GoogleSearch     | WebSearch tool          | Via plugins            |

### Strengths by Tool

- Gemini CLI:  Largest context window, generous free tier, multimodal capabilities, Google Search grounding
- Claude Code: Higher code quality on first attempt, excellent multi-file coordination, strong reasoning
- Codex CLI:   Good for complete features with tests, integrates with ChatGPT subscription

## Resources

- Repository:    https://github.com/google-gemini/gemini-cli
- Documentation: https://geminicli.com/docs/
- npm:           https://www.npmjs.com/package/@google/gemini-cli
