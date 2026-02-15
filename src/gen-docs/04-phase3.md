
---

## Phase 3 - Generate

The ENTIRE Phase 3 is executed by a SINGLE orchestrator subagent to keep the main agent's context clean. The main agent only makes 1 Task call.

### Step 3.0 - Launch Orchestrator

Read `.docs-state.tmp` and launch a SINGLE `Task` with `subagent_type: "general-purpose"` (NOT in background). Pass in the prompt:
- the full content of `.docs-state.tmp` (header + preview)
- the project type, parts list, selected docs
- ALL the instructions below (Steps 3.1 through 3.4)

The orchestrator handles everything and replies with a short summary: "Done! Generated {N} files in docs/."

The main agent displays this summary to the user.

---

Instructions for the orchestrator agent (include everything below in its prompt):

### Step 3.1 - Create folder structure

Create directories based on project type and selected docs (only include docs that were selected):

For single repo:
```
docs/
├── overview.md                          (always)
├── architecture.md                      (always)
├── concepts.md                          (if selected)
├── repo/                                (if selected)
│   ├── structure.md
│   ├── tooling.md
│   ├── local-setup.md
│   └── cicd.md
├── db.md                                (if selected)
├── rules.md                             (if selected)
├── integrations.md                      (if selected)
├── testing.md                           (if selected)
├── guides/                              (if selected)
│   └── {topic}.md
└── features/                            (if selected)
    └── {feature-name}.md
```

For monorepo:
```
docs/
├── overview.md                          (always)
├── architecture.md                      (always)
├── concepts.md                          (if selected)
├── repo/                                (if selected)
│   ├── structure.md
│   ├── tooling.md
│   ├── local-setup.md
│   └── cicd.md
├── features/                            (if selected)
│   └── {feature-name}.md
└── parts/
    └── {part-name}/
        ├── overview.md                  (always)
        ├── db.md                        (if selected)
        ├── rules.md                     (if selected)
        ├── integrations.md              (if selected)
        ├── testing.md                   (if selected)
        └── guides/                      (if selected)
            └── {topic}.md
```

### Step 3.2 - Launch Generation Agents

Launch one agent per selected doc type (up to 12 agents) in PARALLEL using `Task` with `subagent_type: "general-purpose"` and `run_in_background: true`. Each agent writes doc files directly to `docs/`. Each agent MUST reply with ONLY "done" when finished.

Each agent receives in its prompt:
- the approved preview for its doc(s)
- the project type and parts list
- the doc writing rules below
- the `### Metadata Format` template (see Reference section)
- its specific scanning instructions (see below)

Wait for all agents using TaskOutput(block=true).

Doc writing rules (include in every agent prompt):
- Be concise, use bullet points and tables
- Reference actual codebase file paths
- Use ASCII diagrams generously (box-drawing chars: ─ │ ┌ ┐ └ ┘ ├ ┤). architecture.md should have multiple diagrams (request lifecycle, data flow, deploy topology, auth flow, etc.). Other docs should also include diagrams when they help explain flows or relationships.
- No bold text, no emojis
- The preview bullets are the OUTLINE - expand each into proper documentation
- overview.md MUST include a doc index listing all generated files with 1-line descriptions
- EVERY .md file MUST end with a metadata section (see Metadata Format)

Per-agent scanning instructions:

overview agent → `docs/overview.md`:
- Read README.md, package.json, top-level config files

architecture agent → `docs/architecture.md`:
- Use Grep for entry points, route definitions, main exports, API calls between parts
- Identify all diagrammable flows: request lifecycle, data pipelines, auth flow, deploy pipeline, event/message flows, dependency graph
- Scan for observability setup (logging, tracing, monitoring, error tracking) and include as a section
- Scan for cloud/infra services (Cloud Run, GCS, Pub/Sub, Lambda, S3, etc.) and include as a section
- Aim for 3-6 ASCII diagrams minimum

concepts agent → `docs/concepts.md`:
- Use Grep for type definitions, interfaces, enums, DB models
- Document domain entities, relationships, key business rules

repo agent → `docs/repo/*.md` (structure.md, tooling.md, local-setup.md, cicd.md):
- structure.md: Use Glob to map folder structure, identify directory organization
- tooling.md: scan for tooling configs (eslint, prettier, husky, etc.), read tsconfig, docker-compose
- local-setup.md: read docker-compose, .env.example, package.json scripts, Makefile
- cicd.md: read .github/workflows/, CI config files, use Grep for deploy scripts
- MONOREPO: distinguish root vs part-specific tooling

db agent → `docs/db.md` (single) or `docs/parts/{part}/db.md` (monorepo, per-part):
- Use Grep for DB schemas, ORM models, migrations, seeds
- Read DB config files, scan for caching layer
- MONOREPO: generate one db.md per part that has DB, skip parts without DB

rules agent → `docs/rules.md` (single) or `docs/parts/{part}/rules.md` (monorepo, per-part):
- Use Grep for conventions docs, coding patterns
- Sections: principles, conventions, anti-patterns
- MONOREPO: generate one rules.md per part with part-specific conventions

integrations agent → `docs/integrations.md` (single) or `docs/parts/{part}/integrations.md` (monorepo, per-part):
- Scan for 3rd party service integrations (payment, email, SMS, storage, search, auth, PMS)
- MONOREPO: generate one integrations.md per part with part-specific integrations

testing agent → `docs/testing.md` (single) or `docs/parts/{part}/testing.md` (monorepo, per-part):
- Scan test files, frameworks, patterns, test locations, coverage config
- MONOREPO: generate one testing.md per part with part-specific test setup

guides agent → `docs/guides/*.md` (single) or `docs/parts/{part}/guides/*.md` (monorepo, per-part):
- Scan for repetitive patterns, existing docs/READMEs
- MONOREPO: generate guides per part

features agent → `docs/features/*.md`:
- Read route definitions, page components, CLI commands, API endpoints

parts-overview agent (monorepo only) → `docs/parts/{part}/overview.md`:
- For each part: read package.json, scan entry points, identify stack and patterns

### Step 3.3 - Align Docs

AFTER all generation agents finish, run `mdalign docs/` to check for alignment issues in tables and ASCII diagrams. If errors are found, run `mdalign --fix docs/` to auto-fix them. If unfixable issues remain, fix them manually and re-run until clean. Do NOT skip this step.

### Step 3.4 - Cleanup

AFTER align-docs passes clean:
1. Delete `.docs-state.tmp`
2. Reply with: "Done! Generated {N} files in docs/. Review them and adjust as needed." + list of generated files.
