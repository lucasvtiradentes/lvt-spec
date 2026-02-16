# Usage and Examples

## Installation

### As a Claude Code Plugin (primary use case)

Step 1 - add the marketplace:

```bash
/plugin marketplace add https://github.com/EveryInc/compound-engineering-plugin
```

Step 2 - install the plugin:

```bash
/plugin install compound-engineering
```

After installation: 29 agents, 25 commands, 16 skills, and 1 MCP server are available in Claude Code.

### As a CLI Tool (for OpenCode/Codex conversion)

Install and convert to OpenCode:

```bash
bunx @every-env/compound-plugin install compound-engineering --to opencode
```

Install and convert to Codex:

```bash
bunx @every-env/compound-plugin install compound-engineering --to codex
```

Install to both simultaneously:

```bash
bunx @every-env/compound-plugin install compound-engineering --to opencode --also codex
```

### For Local Development

```bash
git clone https://github.com/EveryInc/compound-engineering-plugin
cd compound-engineering-plugin
bun install
bun run src/index.ts install ./plugins/compound-engineering --to opencode
```

## Core Workflow

The compound engineering cycle follows: Plan ---> Work ---> Review ---> Compound ---> Repeat.

### 1. Brainstorm

Explore options and clarify requirements before committing to a plan:

```bash
/workflows:brainstorm
```

### 2. Plan

Create a detailed implementation plan using parallel research agents:

```bash
/workflows:plan
```

Plans are saved as markdown files in `docs/plans/`. This launches 5 research agents in parallel:
- repo-research-analyst
- learnings-researcher
- best-practices-researcher
- framework-docs-researcher
- spec-flow-analyzer

Optionally deepen the plan with additional research:

```bash
/deepen-plan
```

### 3. Work

Execute the plan with incremental commits, branch safety, and task tracking:

```bash
/workflows:work
```

This sets up git branches or worktrees, breaks work into TodoWrite tasks, implements with incremental commits, runs quality checks, and creates PRs. Supports swarm mode for parallel execution.

### 4. Review

Multi-agent code review before merging:

```bash
/workflows:review
```

Launches 13+ review agents in parallel (security-sentinel, performance-oracle, architecture-strategist, dhh-rails-reviewer, etc.), synthesizes findings, assigns severity levels (P1/P2/P3), and creates structured todo files.

### 5. Compound

Document what was learned for future reference:

```bash
/workflows:compound
```

Runs 5 parallel subagents (context analyzer, solution extractor, related docs finder, prevention strategist, category classifier) to capture solutions in `docs/solutions/` with YAML frontmatter for searchability.

## Autonomous Workflows

### LFG (Let's F-ing Go)

Run the entire pipeline sequentially:

```bash
/lfg
```

Chains: plan ---> deepen-plan ---> work ---> review ---> resolve todos ---> browser test ---> feature video.

### SLFG (Swarm LFG)

Same as LFG but with swarm mode for parallel execution:

```bash
/slfg
```

## Utility Commands

| Command                  | Purpose                                              |
|--------------------------|------------------------------------------------------|
| /technical_review        | multi-agent technical review in parallel             |
| /test-browser            | browser tests on PR-affected pages                   |
| /resolve_todo_parallel   | resolve TODO comments in parallel                    |
| /resolve_pr_parallel     | resolve PR comments in parallel                      |
| /triage                  | triage and categorize issues                         |
| /changelog               | generate changelog from recent changes               |
| /feature-video           | create feature demo video                            |

## CLI Usage Examples

### Convert a Local Plugin

```bash
bunx @every-env/compound-plugin convert ./my-plugin --to opencode
```

### Convert with Custom Output Directory

```bash
bunx @every-env/compound-plugin convert ./my-plugin --to opencode --output ./output
```

### Convert with Permission Mapping

```bash
# All tools allowed
bunx @every-env/compound-plugin install compound-engineering --permissions broad

# No permissions set
bunx @every-env/compound-plugin install compound-engineering --permissions none

# Derive from each command's allowed-tools
bunx @every-env/compound-plugin install compound-engineering --permissions from-commands
```

### Convert with Custom Codex Home

```bash
bunx @every-env/compound-plugin install compound-engineering --to codex --codex-home ~/my-codex
```

### List Available Plugins

```bash
bunx @every-env/compound-plugin list
```

### Sync Personal Config to OpenCode

```bash
bunx @every-env/compound-plugin sync --target opencode
```

This syncs personal skills as symlinks (changes propagate automatically) and MCP servers from `~/.claude/settings.json`.

### Sync Personal Config to Codex

```bash
bunx @every-env/compound-plugin sync --target codex
```

### Override GitHub Source

```bash
COMPOUND_PLUGIN_GITHUB_SOURCE=https://github.com/your-fork/repo \
  bunx @every-env/compound-plugin install compound-engineering --to opencode
```

## Plugin Component Formats

### Agent Format

Markdown files with YAML frontmatter in the `agents/` directory:

```markdown
---
name: kieran-rails-reviewer
description: "Rails code review with strict conventions"
model: inherit
---

You are Kieran, a super senior Rails developer...
```

### Command Format

Markdown files with YAML frontmatter in the `commands/` directory:

```markdown
---
name: resolve_todo_parallel
description: Resolve all pending CLI todos using parallel processing
argument-hint: "[optional: specific todo ID or pattern]"
---

Resolve all TODO comments using parallel processing...
```

### Skill Format

Directories containing a `SKILL.md` file in the `skills/` directory:

```markdown
---
name: brainstorming
description: This skill should be used before implementing features...
---

# Brainstorming

This skill provides detailed process knowledge...
```

### Plugin Manifest

`.claude-plugin/plugin.json`:

```json
{
  "name": "compound-engineering",
  "version": "2.30.0",
  "description": "AI-assisted engineering workflow",
  "author": "Kieran Klaassen",
  "keywords": ["workflow", "review", "planning"]
}
```

## MCP Server Configuration

Context7 MCP server (bundled with compound-engineering plugin):

```json
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

## Available Agents (by category)

Review (13 agents):
- security-sentinel, performance-oracle, architecture-strategist
- dhh-rails-reviewer, python-reviewer, typescript-reviewer
- data-integrity-guardian, data-migration-expert
- deployment-verification, agent-native-compliance
- and more

Research (5 agents):
- repo-research-analyst, learnings-researcher
- best-practices-researcher, framework-docs-researcher
- spec-flow-analyzer

Design (3 agents):
- design-implementation-reviewer, design-iterator, figma-design-sync

Workflow (5+ agents):
- bug-reproduction-validator, lint, pr-comment-resolver, etc.

Docs (1 agent):
- ankane-readme-writer

## Available Skills (16 total)

| Skill                        | Purpose                                         |
|------------------------------|-------------------------------------------------|
| agent-native-architecture    | architecture patterns for agent-native systems  |
| brainstorming                | pre-implementation exploration                  |
| create-agent-skills          | guide for building new skills                   |
| dhh-rails-style              | Rails conventions from DHH/37signals            |
| gemini-imagegen              | image generation via Google Gemini API          |
| orchestrating-swarms         | multi-agent coordination patterns               |
| compound-docs                | knowledge capture system                        |
| git-worktree                 | parallel development with git worktrees         |
| every-style-editor           | Every's writing style guide                     |
| coding-tutor                 | personalized coding tutorials                   |
| and 6 more                   |                                                 |

## Testing

Run the test suite:

```bash
bun test
```

Tests cover: parsing, conversion (both targets), writing, AGENTS.md generation, frontmatter, and CLI integration.
