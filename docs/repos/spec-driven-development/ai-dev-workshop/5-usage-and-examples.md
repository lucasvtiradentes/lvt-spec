# AI Dev Workshop - Usage and Examples

## Quick Start

1. Clone/copy `.claude/` directory into your project root
2. Copy `CLAUDE.md.example` to your project as `CLAUDE.md` and customize
3. Install prerequisites: `gh` CLI, `git`, `uv`, Claude Code
4. Configure MCP servers (Context7, Perplexity, Code Expert) as needed
5. Start using slash commands in Claude Code

For Claude Desktop (product role):
1. Create a project in Claude Desktop
2. Paste `claude-desktop/product-agent.md` into project instructions
3. Attach product slash commands as project documents

## Command Reference

### Engineering Commands

| Command    | Invocation                        | Purpose                                                       |
|------------|-----------------------------------|---------------------------------------------------------------|
| /start     | `/engineer/start <feature_slug>`  | Init feature dev: branch, context.md, architecture.md         |
| /plan      | `/engineer/plan`                  | Create phased implementation plan (plan.md)                   |
| /work      | `/engineer/work <session_folder>` | Execute current phase, delegate to sub-agents                 |
| /pre-pr    | `/engineer/pre-pr`                | Run 4 pre-PR agents (metaspec, review, docs, tests)           |
| /pr        | `/engineer/pr`                    | Run tests, commit, open PR, handle review comments            |
| /bump      | `/engineer/bump`                  | Version bump in pyproject.toml + uv sync                      |
| /warm-up   | `/engineer/warm-up`               | Refresh agent context: read README, docs/, metaspecs          |
| /docs      | `/engineer/docs`                  | Invoke branch-documentation-writer agent                      |

### Product Commands

| Command        | Invocation                             | Purpose                                               |
|----------------|----------------------------------------|-------------------------------------------------------|
| /warm-up       | `/product/warm-up <project_name>`      | Load metaspecs index + README into context            |
| /collect       | `/product/collect <description>`       | Quick capture of feature/bug idea into Linear         |
| /refine        | `/product/refine <requirement>`        | Refine requirement into WHY/WHAT/HOW format           |
| /spec          | `/product/spec <requirement>`          | Full PRD with all sections                            |
| /architecture  | `/product/architecture <feature_slug>` | Architecture design with iterative human approval     |
| /check         | `/product/check <features>`            | Validate features against metaspecs                   |

### Metaspecs Commands

| Command                          | Invocation                                         | Purpose                                         |
|----------------------------------|----------------------------------------------------|-------------------------------------------------|
| /build-index                     | `/metaspecs/build-index [project-name]`            | Build root index or project-level index         |
| /build-tech-docs                 | `/metaspecs/build-tech-docs <sources>`             | Generate full technical documentation           |
| /build-business-docs             | `/metaspecs/build-business-docs <sources>`         | Generate full business context documentation    |
| /build-repo-summary              | `/metaspecs/build-repo-summary <path> [output]`    | Create executive summary of repo                |
| /extract-ecosystem-architecture  | `/metaspecs/extract-ecosystem-architecture [args]` | Cross-repo architecture and ADRs                |
| /extract-adr-from-repo-docs      | `/metaspecs/extract-adr-from-repo-docs [args]`     | Extract ADRs from repo docs                     |

### Repodocs Commands

| Command        | Invocation                          | Purpose                                          |
|----------------|-------------------------------------|--------------------------------------------------|
| /generate-docs | `/repodocs/generate-docs [args]`    | Generate full ai_docs/ folder for a repository   |

## Common Workflows

### Workflow A: Full Feature Development

```
Step 1: /engineer/start my-feature
        - Creates feature branch
        - Creates .claude/sessions/my-feature/
        - Asks clarifying questions
        - Generates context.md + architecture.md
        - PAUSES for human approval

Step 2: /engineer/plan
        - Reads context.md + architecture.md
        - Creates plan.md with phased implementation
        - Each phase ~2 hours of work

Step 3: /engineer/work .claude/sessions/my-feature/
        - Reads plan.md, finds current phase
        - Delegates to python-developer / react-developer
        - Runs code-reviewer + test-engineer
        - PAUSES after each phase for validation
        - Updates plan.md with progress

Step 4: /engineer/pre-pr
        - Runs branch-metaspec-checker
        - Runs branch-code-reviewer
        - Runs branch-documentation-writer
        - Runs branch-test-planner
        - Applies fixes from feedback

Step 5: /engineer/pr
        - Runs tests, fixes failures
        - Commits changes
        - Moves Linear card to "In Review"
        - Opens PR via gh CLI
        - Waits for automated review
        - Addresses review comments
```

### Workflow B: Product Requirements

```
Step 1: /product/collect "Add user SSO login"
        - Asks minimal clarifying questions
        - Drafts title + description
        - Saves to Linear

Step 2: /product/refine <Linear card or text>
        - Deeper WHY/WHAT/HOW clarification
        - Creates or updates requirement document

Step 3: /product/spec <requirement>
        - Full PRD with functional/non-functional reqs
        - UX considerations, risks, constraints

Step 4: /product/architecture <feature>
        - Technical architecture proposal
        - Components, trade-offs, diagrams
        - Saves as Linear card comment

Step 5: /product/check <features>
        - Validates against metaspecs
        - Reports alignment/misalignment
```

### Workflow C: Multi-Repo Documentation

```bash
# Step 1: In each repository, generate per-repo docs
/repodocs/generate-docs

# Step 2: In metaspecs repo, summarize each repo
/metaspecs/build-repo-summary ~/dev/payment-api
/metaspecs/build-repo-summary ~/dev/payment-api apis/payment.md
/metaspecs/build-repo-summary https://github.com/org/core-lib core/lib.md

# Step 3: Build ecosystem architecture
/metaspecs/extract-ecosystem-architecture

# Step 4: Extract ADRs
/metaspecs/extract-adr-from-repo-docs

# Step 5: Update index
/metaspecs/build-index
```

## Agent Usage Patterns

### Development Agents

| Agent              | Model  | When Invoked                  | Key Behavior                                   |
|--------------------|--------|-------------------------------|------------------------------------------------|
| python-developer   | sonnet | During /work for Python tasks | PEP 8, type hints, uv, loguru, composition     |
| react-developer    | sonnet | During /work for React tasks  | shadcn/ui, Tailwind, TypeScript strict, Zod    |
| test-engineer      | sonnet | During /work for tests        | pytest, AAA pattern, flag-not-fix              |

### Review Agents (Pre-PR)

| Agent                        | Model  | What It Checks                                  |
|------------------------------|--------|-------------------------------------------------|
| branch-code-reviewer         | opus   | Code quality, bugs, performance, security       |
| branch-metaspec-checker      | sonnet | Alignment with project meta specs               |
| branch-documentation-writer  | sonnet | Documentation gaps from branch changes          |
| branch-test-planner          | sonnet | Test coverage gaps from branch changes          |

### Research Agent

Three-tool methodology:

1. Web Search   - general discovery and current information
2. Perplexity   - complex analysis and synthesis
3. Context7     - library-specific documentation lookup

### Orchestration Principle

The `/work` command delegates to specialized sub-agents to "preserve as much context as possible" in the main conversation. The main agent handles high-level decisions while sub-agents handle implementation details.

## MCP Server Setup

### Context7 (library docs)

Provides up-to-date library/framework documentation. Referenced in multiple agents for looking up best practices.

### Perplexity (research)

Used by `research-agent` for complex analysis and synthesis tasks.

### Code Expert (repo analysis)

Used for accessing other repositories' codebases during documentation generation.

### Configuration

MCPs are configured in your Claude client (Desktop or Code). Each MCP server has its own installation instructions. Once configured, they become available automatically in conversations.

## Tips and Best Practices

### Session Management
- Store intermediate documents in `.claude/sessions/<branch-name>/` for resumability
- Each plan phase should be completable in ~2 hours
- Commit per phase so you can revert if problems arise
- Annotate plan progress with decisions, learnings, and direction changes

### PR Quality
- Only commit files you changed - never use `git add .`
- Run `/pre-pr` before `/pr` for comprehensive quality checks
- Do not mention Claude/AI in commit messages or PR descriptions

### Documentation
- Generate per-repo docs before summaries (`/generate-docs` before `/build-repo-summary`)
- Capture tacit knowledge in gotchas documentation
- ADR rule of thumb: if reversal would be costly/complex, it deserves an ADR
- Never delete ADRs - mark as Superseded or Deprecated

### Product Workflow
- Can skip `/spec` or `/refine` depending on card complexity
- Do `/refine` quickly for standardized documentation, then `/spec` when deeper work is needed
- Use `/check` to validate features against metaspecs before engineering starts

### Metaspecs Structure (Multi-Repo)

Recommended folder organization:

```
metaspecs/
  technical/
    core/
      main-app.md
      shared-lib.md
    apis/
      payment.md
      user.md
      notification.md
    services/
      auth-service.md
      analytics-service.md
    frontend/
      web-app.md
      mobile-app.md
  index.md
```
