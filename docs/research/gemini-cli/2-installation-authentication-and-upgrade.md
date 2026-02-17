# Installation, Authentication, and Upgrade

This document covers installing Gemini CLI, configuring authentication methods, understanding configuration files, working with hooks, and managing versions.

## Installation

### Requirements

- Node.js 20.0.0 or higher (recommended)
- Bash or Zsh shell
- Internet connection

### Installation Methods

| Method          | Command                                |
|-----------------|----------------------------------------|
| npm global      | `npm install -g @google/gemini-cli`    |
| npx (no install)| `npx @google/gemini-cli`               |
| Homebrew        | `brew install gemini-cli`              |

After installation, run `gemini` to start the CLI.

## Authentication

Gemini CLI supports three authentication methods.

### Google OAuth (Recommended for Local Development)

The simplest method for local machines. Run `gemini` and follow the browser-based login flow.

### API Key

| Step | Action                                              |
|------|-----------------------------------------------------|
| 1    | Obtain API key from Google AI Studio                |
| 2    | Set environment variable `GEMINI_API_KEY`           |

```bash
export GEMINI_API_KEY="your-api-key"
```

### Vertex AI

For enterprise/cloud deployments. Requires additional configuration.

| Environment Variable            | Description                              |
|---------------------------------|------------------------------------------|
| `GOOGLE_CLOUD_PROJECT`          | Google Cloud project ID                  |
| `GOOGLE_CLOUD_LOCATION`         | Vertex AI resource location              |
| `GOOGLE_APPLICATION_CREDENTIALS`| Path to service account JSON (optional)  |

Service account setup:
- Create service account and download JSON key file
- Assign "Vertex AI User" role
- Set `GOOGLE_APPLICATION_CREDENTIALS` to the JSON file path

Note: Vertex AI does not support API key authentication directly; use OAuth or service account credentials.

## Configuration Files

Gemini CLI uses two main configuration mechanisms: settings.json and GEMINI.md.

### settings.json

Configures CLI behavior, tool permissions, themes, and MCP servers.

| Location                     | Scope                        |
|------------------------------|------------------------------|
| `~/.gemini/settings.json`    | Global (user-level)          |
| `.gemini/settings.json`      | Project-level                |

Configuration precedence (highest to lowest):
- Environment variables
- Project settings
- Global settings
- Defaults

Example settings.json:

```json
{
  "theme": "dark",
  "sandbox": true,
  "tools": {
    "allowed": ["run_shell_command(git)", "run_shell_command(npm test)"]
  }
}
```

### GEMINI.md

Provides context and instructions to the AI model.

| Location                        | Scope                        |
|---------------------------------|------------------------------|
| `~/.gemini/GEMINI.md`           | Global (all projects)        |
| `.gemini/GEMINI.md`             | Project-level                |

Use GEMINI.md for:
- Project-specific instructions
- Coding style guides
- Background information
- Relevant documentation context

The context file name is configurable via `context.fileName` in settings.json.

## Hooks System

Hooks are scripts executed at specific points in the agentic loop, enabling customization without modifying source code.

### Hook Types

| Hook               | Trigger Point                      | Use Case                          |
|--------------------|------------------------------------|-----------------------------------|
| `BeforeModel`      | Before LLM request                 | Inject context, modify prompts    |
| `AfterModel`       | After LLM response                 | Process outputs, log interactions |
| `BeforeTool`       | Before tool execution              | Validate, intercept tool calls    |
| `AfterTool`        | After tool execution               | Process results, trigger actions  |
| `SessionStart`     | Session begins                     | Initialize resources              |
| `SessionEnd`       | Session ends                       | Cleanup, save state               |
| `BeforeAgent`      | Before agent loop                  | Pre-processing                    |
| `AfterAgent`       | After agent loop                   | Post-processing                   |

### Hook Configuration

Hooks are configured in settings.json:

```json
{
  "hooks": {
    "BeforeTool": [
      {
        "matcher": ".*",
        "command": "/path/to/your/script.sh"
      }
    ]
  }
}
```

### Hook Requirements

- Communicate via stdin (input) and stdout (output)
- Output must be valid JSON only
- Use stderr for logging and debugging
- Available since v0.26.0+

### Common Use Cases

- Inject recent git commits or Jira tickets before model requests
- Prevent writing sensitive data (API keys, passwords) to codebase
- Automate tasks with custom scripts
- Enforce security policies

## Upgrading and Version Management

### Update Command

```bash
npm install -g @google/gemini-cli
```

Or explicitly request latest:

```bash
npm install -g @google/gemini-cli@latest
```

### Release Channels

| Channel  | Command                                      | Description                     |
|----------|----------------------------------------------|---------------------------------|
| Stable   | `npm install -g @google/gemini-cli`          | Weekly releases, production use |
| Preview  | `npm install -g @google/gemini-cli@preview`  | Next week's stable candidate    |
| Nightly  | `npm install -g @google/gemini-cli@nightly`  | Cutting-edge development builds |

### Check Current Version

```bash
gemini --version
```

### Version Notes

- Stable releases publish weekly
- Preview releases are promoted to stable after testing
- Latest stable: v0.28.0 (February 2026)

## Sources

- [Gemini CLI Installation](https://geminicli.com/docs/get-started/installation/)
- [Gemini CLI Authentication](https://geminicli.com/docs/get-started/authentication/)
- [Gemini CLI Configuration](https://geminicli.com/docs/get-started/configuration/)
- [Gemini CLI Hooks](https://geminicli.com/docs/hooks/)
- [npm: @google/gemini-cli](https://www.npmjs.com/package/@google/gemini-cli)
- [GitHub: google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli)
