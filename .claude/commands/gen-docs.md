# Gen Docs

Interactive, state-aware command that generates structured project documentation for AI context.
  - Supports single repo and monorepo.
  - Tracks progress in a state file so interrupted sessions can resume from where they left off.

```
┌─────────────┐    ┌─────────────┐    ┌──────────────────────────────┐    ┌───────────────┐
│  PHASE 0    │    │  PHASE 1    │    │  PHASE 2                     │    │  PHASE 3      │
│  Resume     │    │  Setup      │    │  Preview Loop                │    │  Generate     │
│             │    │             │    │                              │    │               │
│ read .tmp   │───>│ project     │───>│ 2.1 launch agents → scan     │───>│ write docs/   │
│ resume or   │    │ type?       │    │ 2.2 build preview in .tmp    │    │ from approved │
│ start fresh │    │ parts?      │    │ 2.3 show preview to user     │    │ preview       │
│             │    │ skip docs?  │    │      <loop until "go">       │    │               │
└─────────────┘    └─────────────┘    └──────────────────────────────┘    └───────────────┘
```

## Output Structure

```
single repo:                         monorepo:
docs/                                docs/
├── overview.md                      ├── overview.md
├── architecture.md                  ├── architecture.md
├── concepts.md                      ├── concepts.md
├── repo/                            ├── repo/
│   ├── structure.md                 │   ├── structure.md
│   ├── tooling.md                   │   ├── tooling.md
│   ├── local-setup.md               │   ├── local-setup.md
│   ├── cicd.md                      │   ├── cicd.md
│   └── infrastructure.md            │   └── infrastructure.md
├── features/                        ├── features/
---------------------------------------------------
├── db.md                            └── parts/
├── rules.md                             └── {part}/
├── integrations.md                          ├── overview.md
├── testing.md                               ├── db.md
└── guides/                                  ├── rules.md
                                             ├── integrations.md
                                             ├── testing.md
                                             └── guides/
(above the line: shared between both types)
(below the line: single repo has files at root, monorepo nests them under parts/{part}/)
```

All docs are generated unless the user explicitly skips them in Step 1.3.

| Output                | Description                             |
|-----------------------|-----------------------------------------|
| overview.md           | project description, doc index          |
| architecture.md       | system design, flows, observability     |
| concepts.md           | domain glossary                         |
| repo/structure.md     | folder layout, key directories          |
| repo/tooling.md       | eslint, prettier, husky, tsconfig       |
| repo/local-setup.md   | how to run locally, docker, services    |
| repo/cicd.md          | pipelines, deploy, secrets, branches    |
| repo/infrastructure.md| cloud services, terraform, IaC          |
| features/             | one doc per business capability         |
| db.md                 | data model, migrations, caching         |
| rules.md              | principles, conventions, anti-patterns  |
| integrations.md       | 3rd party service integrations          |
| testing.md            | test frameworks, patterns, coverage     |
| guides/               | how-to docs, recipes                    |
| parts/overview        | part entry point, stack, purpose        |

## Temp Files

All progress is tracked in `.docs-state.tmp` (single file, no folder needed).

After `Step 1.4` (header only):
```
phase: 2
type: monorepo
parts: apps/api,apps/web,packages/infra
docs: overview,architecture,concepts,repo,db,rules,integrations,testing,guides,features
```

After `Step 2.2` (preview appended, phase stays 2 until user picks "generate"):
```
phase: 2
type: monorepo
parts: apps/api,apps/web,packages/infra
docs: overview,architecture,concepts,repo,db,rules,integrations,testing,guides,features

--- PREVIEW ---

overview.md:
  - project: My App - description here
  - related repos: repo-a, repo-b
  - doc index: 12 files across docs/

features/auth.md:
  - email/password + Google OAuth
  - JWT with refresh rotation
  - role-based: guest, host, admin

...etc
```

The phase stays at 2 until docs are fully generated. There is no `phase: 3` - when the user picks "generate", we go straight to Phase 3 without updating the phase. If interrupted during generation, resume will show the preview menu again so the user can re-trigger.

---

## Phase 0 - Resume Check

1. Check if `.docs-state.tmp` exists in the project root
2. If it EXISTS:
   - Read it and parse the phase number
   - Use `AskUserQuestion` to ask:
     - question: "Found existing gen-docs session at phase {N}. What do you want to do?"
     - options:
       - "Resume from phase {N}" (Recommended)
       - "Start fresh (delete state)"
   - If resume: if phase is 2, jump to `Step 2.3` (show preview + menu)
   - If fresh: delete `.docs-state.tmp`, proceed to `## Phase 1`
3. If it does NOT exist:
   - Proceed to `## Phase 1`

---

## Phase 1 - Setup

### Step 1.1 - Ask project type

Use `AskUserQuestion`:
- question: "What type of project is this?"
- header: "Project type"
- options:
  - label: "Single Repo"
    description: "One language/concern, personal projects, libraries, single-service apps"
  - label: "Monorepo"
    description: "Multiple parts (api, frontend, infra), multi-team, multiple package.json"

### Step 1.2 - Identify parts (MONOREPO only)

Skip this step for single repo.

Do NOT scan or auto-detect parts. Simply output this message and wait for the user to type their answer:

```
List your monorepo parts (one path per line), e.g.:
  apps/api
  apps/web
  packages/infra
```

The user will type the paths. Store the confirmed parts list for use in `Step 1.4` and all agents. Part name is inferred from the last path segment (e.g. `apps/api` → `api`).

### Step 1.3 - Confirm doc structure

Show the user the relevant tree from the Output Structure section (single repo or monorepo, based on Step 1.1) and ask:

"This is the doc structure we'll generate. Want to remove or add anything? Or want me to keep as-is?"

Apply whatever the user says (remove docs, add custom ones, etc.). Docs to generate = final confirmed list.

### Step 1.4 - Save state

Write `.docs-state.tmp`:
```
phase: 2
type: {monorepo|single}
parts: {comma-separated paths, e.g. apps/api,apps/web - empty for single repo}
docs: {comma-separated list of selected docs}
```

Tell the user: "Setup complete. Selected {N} doc types for {type} project. Launching discovery agents..."

Proceed to `## Phase 2`.

---

## Phase 2 - Preview Loop

This phase builds a compact preview outline. 3 discovery agents scan the codebase in parallel. The heavy 12-agent generation only happens in Phase 3 when the user says "generate".

### Step 2.1 - Launch 3 Discovery Agents

Launch exactly 3 Explore agents in PARALLEL using `Task` with `subagent_type: "Explore"` and `run_in_background: true`.

Each agent gets in its prompt:
- the project type and parts list
- the scan + preview instructions from `### Doc Specs` for its covered docs
- if deepening: the current preview content for its doc types, with instruction to find GAPS
- if deepening with direction: the user's focus area

Agent grouping (see `### Doc Specs` for per-doc details):
- Agent 1: overview, architecture, concepts
- Agent 2: repo, features
- Agent 3: db, rules, integrations, testing, guides, parts-overview

IMPORTANT: agents produce OUTLINES (3-8 bullets per doc), not full docs. Full docs are written in Phase 3.

AGENT PROMPT SCOPING: The prompt sent to each Explore agent must ONLY contain:
1. Project type and parts list
2. The scan + preview instructions from Doc Specs for its covered docs
3. If deepening: the current preview content + direction
4. This explicit instruction at the end: "Your ONLY task is to scan the codebase and return bullet-point outlines. Do NOT proceed to any other step, do NOT show menus, do NOT generate documentation files, do NOT write any files. Return ONLY the outline text."

Do NOT include in the agent prompt: the interactive menu (Step 2.4), Phase 3 instructions, or any reference to "generate", "deepen", or "adjust" options.

Wait for all 3 agents using TaskOutput(block=true), then proceed to `Step 2.2`.

### Step 2.2 - Assemble Preview

Combine all 3 agent results into `.docs-state.tmp` after the header, prefixed with `--- PREVIEW ---`.

Observability findings go into the architecture.md preview entry. Cloud/infra findings go into the repo/infrastructure.md preview entry.

### Step 2.3 - Show Preview

Read `.docs-state.tmp` and display the preview section (everything after `--- PREVIEW ---`) to the user.

### Step 2.4 - Interactive Menu

After showing the preview, display this menu:

```
What's next?
1> deepen   - launch agents again to find gaps and enrich the preview
2> adjust   - tell me what to add, remove, or change
3> generate - preview looks good, create the docs
```

CRITICAL: After displaying this menu you MUST STOP and produce NO further output. Do NOT pick an option. Do NOT proceed to Phase 3. Do NOT call any tools. The NEXT message MUST come from the USER, not from you. Your response ends immediately after the menu text above. If background agent completion notifications arrive after the menu is displayed, IGNORE them completely - produce NO text, NO acknowledgments, NO status updates. The menu is the final output.

User can type just "1"-"3" OR add details: "1, dig deeper into the auth flow", etc.

Option 1 - deepen:
- Go back to `Step 2.1` with current preview as context for agents
- If user gave direction, focus agents on that specific area
- If no direction, agents look for gaps in the current preview
- After updating preview, return to MENU

Option 2 - adjust:
- User provides free text describing changes (add feature X, remove concept Y, rename Z, etc.)
- Apply the changes directly to the preview in `.docs-state.tmp`
- Show updated preview
- Return to MENU

Option 3 - generate:
- Do NOT update the phase (stays at 2 so resume shows menu if interrupted)
- Proceed to `## Phase 3`

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

Create directories based on the Output Structure defined above. Generate all docs unless the user skipped them.

### Step 3.2 - Launch Generation Agents

Launch one agent per selected doc type (up to 12 agents) in PARALLEL using `Task` with `subagent_type: "general-purpose"` and `run_in_background: true`. Each agent writes doc files directly to `docs/`. Each agent MUST reply with ONLY "done" when finished.

Each agent receives in its prompt:
- the approved preview for its doc(s)
- the project type and parts list
- the doc writing rules below
- the `### Metadata Format` template
- the scan instructions from `### Doc Specs` for its doc type

Wait for all agents using TaskOutput(block=true).

Doc writing rules (include in every agent prompt):
- Be concise, use bullet points and tables
- Reference actual codebase file paths
- Use ASCII diagrams generously (box-drawing chars: ─ │ ┌ ┐ └ ┘ ├ ┤). architecture.md should have multiple diagrams (request lifecycle, data flow, deploy topology, auth flow, etc.). Other docs should also include diagrams when they help explain flows or relationships.
- No bold text, no emojis
- The preview bullets are the OUTLINE - expand each into proper documentation
- overview.md MUST include a doc index listing all generated files with 1-line descriptions
- EVERY .md file MUST end with a metadata section (see Metadata Format)

### Step 3.3 - Align Docs

AFTER all generation agents finish, run `mdalign docs/` to check for alignment issues in tables and ASCII diagrams. If errors are found, run `mdalign --fix docs/` to auto-fix them. If unfixable issues remain, fix them manually and re-run until clean. Do NOT skip this step.

### Step 3.4 - Cleanup

AFTER align-docs passes clean:
1. Delete `.docs-state.tmp`
2. Reply with: "Done! Generated {N} files in docs/. Review them and adjust as needed." + list of generated files.

---

## Reference

### Doc Specs

Per-doc scanning and preview instructions. Used by Phase 2 (discovery outlines) and Phase 3 (full generation).

Preview notes:
- Preview is PER-FILE with bullet points (3-8 bullets per doc in Phase 2)
- Lines starting with `>` are metadata hints (related docs/sources) so Phase 3 can write metadata without re-scanning

```
overview → docs/overview.md:
  scan: Read README.md, package.json, top-level config files
  preview:
    - project: {name} - {description}
    - related repos: {repo-a}, {repo-b}
    - doc index: {N} files across docs/

architecture → docs/architecture.md:
  scan:
    - Grep for entry points, route definitions, main exports, API calls between parts
    - Identify diagrammable flows: request lifecycle, data pipelines, auth flow, event/message flows
    - Scan for observability (logging, tracing, monitoring, error tracking)
    - Generation: aim for 3-6 ASCII diagrams
  preview:
    - entry: {entry point} → {main flow}
    - diagrams: request lifecycle, data flow, auth flow, {other flows}
    - data flow: {part} → {part} → {part}
    - observability: {logging framework}, {tracing}, {monitoring}

concepts → docs/concepts.md:
  scan: Grep for type definitions, interfaces, enums, DB models. Document domain entities, relationships, business rules.
  preview:
    - {concept}: {1-line description}
    - {concept}: {1-line description}
    - {concept}: {1-line description}

repo → docs/repo/*.md:
  scan:
    - structure.md: Glob folder structure, identify directory organization
    - tooling.md: scan tooling configs (eslint, prettier, husky), read tsconfig, docker-compose
    - local-setup.md: read docker-compose, .env.example, package.json scripts, Makefile
    - cicd.md: read .github/workflows/, CI config, Grep for deploy scripts
    - infrastructure.md: scan for cloud services (Cloud Run, GCS, Pub/Sub, Lambda, S3), terraform/IaC configs
    - MONOREPO: distinguish root vs part-specific tooling
  preview:
    repo/:
      structure.md:
        - {key dirs and what they contain}
      tooling.md:
        - {eslint (root + api), prettier (root only), husky, lint-staged, ...}
        - env vars: {VAR_1}, {VAR_2}, {VAR_3} (+ {N} more)
      local-setup.md:
        - services: {service}:{port}, {service}:{port}
        - {key steps to run locally}
      cicd.md:
        - pipelines: {pipeline 1}, {pipeline 2}
        - deploy: {environments and targets}
        - secrets: {required secrets}
        - branch strategy: {strategy description}
      infrastructure.md:
        - cloud services: {service}: {purpose}, {service}: {purpose}
        - IaC: {terraform/pulumi/cdk}, {key resources}
        - deployment targets: {environments and platforms}

db → docs/db.md | monorepo: docs/parts/{part}/db.md (per-part, skip parts without DB):
  scan: Grep for DB schemas, ORM models, migrations, seeds. Read DB config, scan for caching layer.
  preview:
    - entities: {entity1}, {entity2}, {entity3} (+ {N} more)
    - key relationships: {entity} → {entity}, {entity} → {entity}
    - config: {pooling, replicas, timeouts}
    - migrations: {count} migrations, {strategy}
    - seeds: {how seeding works}
    - caching: {redis/in-memory, strategy}
    - patterns: {soft deletes, views, indexes, etc.}

rules → docs/rules.md | monorepo: docs/parts/{part}/rules.md (per-part):
  scan: Grep for conventions docs, coding patterns. Sections: principles, conventions, anti-patterns.
  preview:
    - principles: {principle 1}, {principle 2}
    - conventions: {convention 1}, {convention 2}
    - anti-patterns: {anti-pattern 1}, {anti-pattern 2}

integrations → docs/integrations.md | monorepo: docs/parts/{part}/integrations.md (per-part):
  scan: Scan for 3rd party service integrations (payment, email, SMS, storage, search, auth, PMS)
  preview:
    - {service}: {purpose} ({N} integrations total)
    - {service}: {purpose}

testing → docs/testing.md | monorepo: docs/parts/{part}/testing.md (per-part):
  scan: Scan test files, frameworks, patterns, test locations, coverage config
  preview:
    - framework: {jest/playwright/vitest}
    - patterns: {unit, functional, e2e}
    - locations: {test dirs}

guides → docs/guides/*.md | monorepo: docs/parts/{part}/guides/*.md (per-part):
  scan: Scan for repetitive patterns, existing docs/READMEs
  preview:
    guides/{topic}.md:
      - {bullet 1}
      - {bullet 2}
      - {bullet 3}

features → docs/features/*.md:
  scan: Read route definitions, page components, CLI commands, API endpoints
  preview:
    features/{feature-name}.md:
      - {bullet 1}
      - {bullet 2}
      - {bullet 3}

parts-overview (monorepo only) → docs/parts/{part}/overview.md:
  scan: Read package.json per part, scan entry points, identify stack and patterns
  preview:
    parts/{name}/:
      overview.md:
        - {what it does}, entry: {file}
        - stack: {part-specific stack}

(metadata hints example)
features/booking.md:
  - availability check → hold → payment → confirm
  - cancellation policies: flexible, moderate, strict
  > related docs: concepts.md, features/auth.md, parts/api/overview.md
  > related sources: src/features/booking/, src/models/booking.model.ts, src/routes/booking.routes.ts
```

### Metadata Format

Appended at the bottom of every generated .md file:

```md
---

related docs:
- docs/concepts.md - booking entity definition, states
- docs/features/auth.md - user must be authenticated to book
- docs/parts/api/overview.md - booking endpoints live here

related sources:
- src/features/booking/ - booking module root
- src/features/booking/service.ts - core booking logic
- src/models/booking.model.ts - DB model
- src/routes/booking.routes.ts - API endpoints
- tests/booking/ - booking tests
```

Rules:
- related docs: other docs in docs/ that THIS doc depends on (unidirectional, no back-links)
- related sources: actual codebase files AND folders relevant to this doc's topic
- list folders when the whole directory is relevant, list specific files when only that file matters
- keep it focused: only list things that are directly relevant, not tangentially related
- overview.md does NOT need related docs (it IS the index) but should list key source files/folders

---

## Important Rules

- ALWAYS update `.docs-state.tmp` after completing each sub-step
- If the user interrupts and runs `/gen-docs` again, `## Phase 0` will resume from the last saved state
- Generate all docs unless the user skipped them in Step 1.3
- The preview in `.docs-state.tmp` is the SOURCE OF TRUTH for `## Phase 3` - only generate what's in the preview
- Phase 2 uses 3 Explore agents (compact outlines returned via TaskOutput). Phase 3 is delegated to a SINGLE orchestrator subagent that internally launches up to 12 generation agents. The main agent NEVER launches 12 agents directly.
- Step 2.2 is done by the MAIN agent (combines 3 agent results into .docs-state.tmp).
