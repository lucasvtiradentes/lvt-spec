# AI Dev Workshop - Technical

## Tech Stack

| Category          | Technology                                          |
|-------------------|-----------------------------------------------------|
| AI Platform       | Anthropic Claude (Claude Code CLI + Claude Desktop) |
| Protocol          | Model Context Protocol (MCP)                        |
| Language (target) | Python (primary), React/TypeScript (secondary)      |
| Package Manager   | uv (Python), npm/yarn/pnpm (JS/TS)                  |
| Project Mgmt      | Linear                                              |
| VCS               | Git + GitHub (via `gh` CLI)                         |
| Documentation     | Markdown (all files are `.md`)                      |
| Diagrams          | Mermaid (embedded in markdown)                      |

The repository itself contains zero executable code. It is 100% markdown configuration files.

## Required Host Environment

No `package.json`, `requirements.txt`, or `pyproject.toml` exists. The framework assumes these tools are installed:

| Dependency      | Purpose                                         |
|-----------------|-------------------------------------------------|
| Claude Code CLI | Primary execution environment for all commands  |
| Claude Desktop  | Alternative execution for product commands      |
| `gh` CLI        | GitHub operations (PRs, issues, comments)       |
| `git`           | Version control                                 |
| `uv`            | Python environment / dependency management      |
| Linear (SaaS)   | Project management integration                  |

## Optional MCP Servers

| MCP Server      | Purpose                                   | URL                                                |
|-----------------|-------------------------------------------|----------------------------------------------------|
| Context7        | Up-to-date library/framework docs         | https://context7.com/                              |
| Code Expert     | Advanced Git repo analysis                | https://github.com/lfnovo/code-expert-mcp          |
| Repo Prompt     | Context generation for repos              | https://repoprompt.com/                            |
| GitHub MCP      | Official GitHub integration               | https://github.com/github/github-mcp-server        |
| Perplexity      | Complex analysis and research             | (MCP integration)                                  |
| Linear          | Natively supported via Claude connector   | -                                                  |
| Jira/Atlassian  | Native connector                          | -                                                  |
| Confluence MCP  | Confluence access                         | https://github.com/sooperset/mcp-atlassian         |
| Notion          | Native Claude connector                   | -                                                  |

### MCP Discovery Resources

| Resource              | URL                                                    |
|-----------------------|--------------------------------------------------------|
| Glama.ai              | https://glama.ai/                                      |
| Awesome MCP Servers   | https://github.com/punkpeye/awesome-mcp-servers        |
| MCP Official Registry | https://github.com/modelcontextprotocol/servers        |
| MCP Docs              | https://modelcontextprotocol.io/                       |
| MCP Spec              | https://spec.modelcontextprotocol.io/                  |

## Installation Steps

There is no build or install process. Setup involves:

1. Clone/copy the `.claude/` directory structure into your project root
2. Copy `CLAUDE.md.example` to `~/.claude/CLAUDE.md` (global) or project-level `CLAUDE.md` and customize
3. Configure MCP servers (Context7, Perplexity, Code Expert) in Claude Desktop or Claude Code
4. Ensure `gh` CLI, `git`, and `uv` are installed and authenticated
5. Configure Linear integration for project management features
6. Invoke slash commands via Claude Code (e.g., `/engineer/start`, `/product/collect`)

For Claude Desktop product role:
1. Create a project in Claude Desktop
2. Paste content from `claude-desktop/product-agent.md` into project instructions
3. Attach product slash commands as project documents

## Configuration

### CLAUDE.md (behavioral config)

The `CLAUDE.md.example` file establishes:

- Direct, concise tone
- Research before implementing unknown libraries
- Conventional commit formatting (feat/fix/chore)
- No mention of Claude/AI in commits or PR descriptions
- Use `gh cli` for GitHub interactions
- Use Context7 for third-party library documentation lookup
- Use sub-agents for complex multi-step tasks

### Agent Definition Schema

Each agent in `.claude/agents/` uses YAML frontmatter:

```yaml
name: agent-name
description: What the agent does
tools: Read, Write, Edit, Glob, Grep, Bash
model: opus | sonnet
color: green | red | blue | cyan
```

Model selection:
- `opus` - review and analysis tasks (higher reasoning)
- `sonnet` - development and research tasks (faster, cheaper)

### .gitignore

```
.DS_Store
claude-logs
```

### Environment Variables

No env vars defined in the framework. Delegates env var management to target projects.
