# Agent OS - Usage and Examples

## Commands

### /discover-standards

Extract tribal knowledge from an existing codebase into documented standards.

Process:

1. Determine focus area (API routes, database, components, etc.)
2. Read 5-10 representative files, identify unusual/opinionated/consistent patterns
3. For each pattern: ask "why" questions, draft standard, get confirmation
4. Save to `agent-os/standards/[folder]/[standard].md`
5. Update `agent-os/standards/index.yml`
6. Offer to continue with another area

Output:

```
agent-os/standards/
├── api/
│   ├── response-format.md
│   └── error-handling.md
├── database/
│   └── migrations.md
└── index.yml
```

Guidelines for standards:

- Lead with the rule, explain why second
- Use code examples
- Bullet points over paragraphs
- Every word costs tokens; keep concise

### /index-standards

Rebuild the standards index file for quick discovery.

Process:

1. Scan all `.md` files in `agent-os/standards/` and subfolders
2. Compare against existing `index.yml`
3. Ask for descriptions of new files
4. Remove deleted entries
5. Write alphabetized YAML

When to run:

- After manually creating/deleting standards
- If inject suggestions seem out of sync
- To clean up outdated index

### /inject-standards

Inject relevant standards into the current AI context.

Two modes:

```
/inject-standards                                 # auto-suggest based on context
/inject-standards api                             # all standards in api/
/inject-standards api/response-format             # single file
/inject-standards api/response-format api/auth    # multiple files
/inject-standards root                            # files in standards/ root
```

Three scenarios with different output formats:

| Scenario            | Output Format                          |
|---------------------|----------------------------------------|
| Conversation        | Full text read into chat               |
| Creating a Skill    | File references or content for skill   |
| Shaping/Planning    | File references or content for plan    |

### /plan-product

Create foundational product documentation.

Process:

1. Check for existing `mission.md`, `roadmap.md`, `tech-stack.md`
2. Ask about problem, target users, unique solution
3. Ask about MVP features and post-launch features
4. Establish tech stack
5. Generate files

Output:

```
agent-os/product/
├── mission.md
├── roadmap.md
└── tech-stack.md
```

### /shape-spec

Structured feature planning. Must be run in plan mode.

Process:

1. Clarify scope of feature/change
2. Gather visuals (mockups, screenshots)
3. Identify reference implementations in codebase
4. Check product context (`agent-os/product/` if exists)
5. Surface and confirm relevant standards
6. Generate timestamped spec folder
7. Structure plan (Task 1 always saves spec docs first)

Output:

```
agent-os/specs/YYYY-MM-DD-HHMM-feature-slug/
├── plan.md
├── shape.md
├── standards.md
├── references.md
└── visuals/
```

## Common Workflows

### Workflow A: New Project Setup

```bash
cd /path/to/your/project
/path/to/agent-os/scripts/project-install.sh
```

Then in Claude Code:

```
/discover-standards
```

Select area (e.g., "API Routes"), answer questions about patterns, confirm generated standards. Repeat for other areas.

### Workflow B: Building a Feature

1. Enter plan mode in Claude Code
2. Run `/shape-spec`
3. Answer questions about scope, visuals, references
4. Review generated plan
5. Approve execution
6. Task 1 saves all spec docs, remaining tasks implement

### Workflow C: Working with Standards

```
/inject-standards                    # auto-suggest relevant ones
/inject-standards api database       # explicit folders
```

Standards loaded into context; implementation follows conventions.

### Workflow D: Syncing Standards to Profile

```bash
/path/to/agent-os/scripts/sync-to-profile.sh
```

Options:

| Flag               | Description                              |
|--------------------|------------------------------------------|
| --profile <name>   | Target profile                           |
| --all              | Select all files                         |
| --overwrite        | Overwrite without prompting              |
| --new-profile name | Create a new profile                     |
| --verbose          | Detailed output                          |

Interactive process: select profile, select files, handle conflicts with backups.

### Workflow E: Multi-Project Consistency

1. Create specialized profile:

```yaml
# config.yml
profiles:
  rails:
    inherits_from: default
  rails-api:
    inherits_from: rails
```

2. Install in new projects:

```bash
/path/to/agent-os/scripts/project-install.sh --profile rails-api
```

Gets: default standards + rails standards + rails-api standards.

## Profile System

### How Profiles Work

Profiles are folders under `profiles/` containing pre-defined standards:

```
profiles/
├── default/
│   └── standards/
│       ├── global/
│       │   └── tech-stack.md
│       └── api/
│           └── response-format.md
└── rails/
    └── standards/
        └── database/
            └── migrations.md
```

### Inheritance

Defined in `config.yml`. Child profiles extend parents:

```
default ---> rails ---> rails-api
```

Resolution: base standards copied first, then each child overwrites matching files.

### Creating a Profile

Option A - manually:

```bash
mkdir -p /path/to/agent-os/profiles/my-profile/standards/
```

Option B - from project:

```bash
/path/to/agent-os/scripts/sync-to-profile.sh --new-profile my-profile
```

### Configuring Default Profile

Edit `config.yml`:

```yaml
default_profile: my-profile
```

## Examples

### Example 1: Discovering API Standards

```
> /discover-standards

Agent: I'll scan your codebase. Which area should I focus on?
  1. API Routes (src/api/)
  2. Database (src/db/)
  3. Components (src/components/)
  4. Let me specify

User: 1

Agent: I found these patterns in your API routes:
  1. All responses use { data, error, meta } envelope
  2. Errors always include error code + message
  3. Pagination uses cursor-based approach

  Which should I document? (select multiple)

User: All three

Agent: For "response envelope" - why does the team use this format?

User: Consistent client parsing, makes error handling uniform

Agent: Here's the draft standard:
  [shows draft]
  Save to agent-os/standards/api/response-envelope.md?

User: Yes
```

### Example 2: Shaping a Feature

```
> /shape-spec

Agent: What are we building?

User: User authentication with email/password

Agent: What's the scope?
  1. Just login/signup
  2. Login/signup + password reset
  3. Full auth (login, signup, reset, email verification)

User: 2

Agent: Any mockups or screenshots?

User: [provides login screen mockup]

Agent: I found similar code in src/features/admin-auth/.
  Should I use it as reference?

User: Yes

Agent: These standards seem relevant:
  - api/response-format
  - database/migrations
  - testing/integration-tests
  Confirm?

User: Yes

Agent: [generates spec folder with plan.md, shape.md, etc.]
```

### Example 3: Commands-Only Update

When Agent OS is updated and you want new commands without touching standards:

```bash
/path/to/agent-os/scripts/project-install.sh --commands-only
```

Only `.claude/commands/agent-os/` is updated. Existing standards untouched.
