---
name: gen-docs
description: Interactive, state-aware command that generates or updates structured project documentation for AI context. Supports single repo and monorepo. Use when the user asks to generate, create, or update project documentation.
---

```
┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│ PHASE 0           │    │ PHASE 1           │    │ PHASE 2           │    │ PHASE 3           │
│ Route             │    │ Setup             │    │ Preview Loop      │    │ Generate          │
│                   │    │                   │    │                   │    │                   │
│ .tmp exists?      │───>│ project type?     │───>│ launch agents     │───>│ write docs/       │
│ docs/ exists?     │    │ packages?         │    │ build preview     │    │ from approved     │
│ or new?           │    │ skip docs?        │    │ <loop until "go"> │    │ preview           │
└─────────┬─────────┘    └───────────────────┘    └───────────────────┘    └─────────┬─────────┘
          │                                                                          │
          │ (docs/ exists)                                                           │
          │                                                                          │
          │    ┌─────────────────────────────────────────────────────────────────────┘
          │    │
          v    v
    ┌───────────────────┐
    │ PHASE 4           │<───┐
    │ Iterate           │    │
    │                   │    │
    │ show current docs │    │ (update)
    │ menu: update/exit │    │
    │ agents + align    │────┘
    └─────────┬─────────┘
              │ (exit)
              v
           [done]
```

## Output Structure

```
docs/ (single repo)                  docs/ (monorepo)
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
│   └── {feature}.md                 │   └── {feature}.md
├── db.md                            └── packages/
├── rules.md                             └── {pkg}/
├── integrations.md                          ├── overview.md
├── testing.md                               ├── db.md
└── guides/                                  ├── rules.md
    └── {topic}.md                           ├── integrations.md
                                             ├── testing.md
                                             └── guides/
                                                 └── {topic}.md
```

Package-specific docs (db, rules, integrations, testing, guides) are at root in single repo, nested under `packages/{pkg}/` in monorepo.

All docs are generated unless the user explicitly skips them in Step 1.3.

| Id             | Output                 | Description                            |
|----------------|------------------------|----------------------------------------|
| overview       | overview.md            | project description, doc index         |
| architecture   | architecture.md        | system design, flows, observability    |
| concepts       | concepts.md            | domain glossary                        |
| repo           | repo/structure.md      | folder layout, key directories         |
|                | repo/tooling.md        | eslint, prettier, husky, tsconfig      |
|                | repo/local-setup.md    | how to run locally, docker, services   |
|                | repo/cicd.md           | pipelines, deploy, secrets, branches   |
|                | repo/infrastructure.md | cloud services, terraform, IaC         |
| features       | features/              | one doc per business capability        |
| db             | db.md                  | data model, migrations, caching        |
| rules          | rules.md               | principles, conventions, anti-patterns |
| integrations   | integrations.md        | 3rd party service integrations         |
| testing        | testing.md             | test frameworks, patterns, coverage    |
| guides         | guides/                | how-to docs, recipes                   |
| pkg-overview   | packages/{pkg}/overview| package entry point, stack, purpose    |

## Temp Files

All progress is tracked in `.docs-state.tmp` (single file, no folder needed).

After `Step 1.4` (header only, before agents):
```
phase: 1
type: monorepo
packages: apps/api,apps/web,packages/infra
docs: overview,architecture,concepts,repo,db,rules,integrations,testing,guides,features,pkg-overview
```

After `Step 2.2` (preview appended, phase updated to 2):
```
phase: 2
type: monorepo
packages: apps/api,apps/web,packages/infra
docs: overview,architecture,concepts,repo,db,rules,integrations,testing,guides,features,pkg-overview

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

## Phase 0 - Route

Determine which phase to enter based on existing state.

### Step 0.1 - Check if docs/ exists with gen-docs content

If `docs/` folder exists AND contains gen-docs generated files (overview.md, architecture.md, etc.):
- Proceed to `## Phase 4` (iterate over existing docs)

### Step 0.2 - Check for .tmp file

If `.docs-state.tmp` exists in the project root:
- Read phase from file and resume:
  - If `phase: 1` → jump to `Step 2.1` (launch discovery agents)
  - If `phase: 2` and NO preview → jump to `Step 2.1` (launch discovery agents)
  - If `phase: 2` and HAS preview → jump to `Step 2.3` (show preview + menu)

### Step 0.3 - New project

If neither docs/ nor .tmp exists:
- Proceed to `## Phase 1`

---

## Phase 1 - Setup

### Step 1.1 - Ask project type

Ask the user: "What type of project is this?"
- Single Repo: one language/concern, personal projects, libraries, single-service apps
- Monorepo: multiple packages (api, frontend, infra), multi-team, multiple package.json

### Step 1.2 - Identify packages (MONOREPO only)

Skip this step for single repo.

Do NOT scan or auto-detect packages. Simply output this message and wait for the user to type their answer:

```
List your monorepo packages (one path per line), e.g.:
  apps/api
  apps/web
  packages/infra
```

The user will type the paths. Store the confirmed packages list for use in `Step 1.4` and all agents. Package name is inferred from the last path segment (e.g. `apps/api` → `api`).

### Step 1.3 - Confirm doc structure

Show the user the relevant tree from the Output Structure section (single repo or monorepo, based on Step 1.1) and ask:

"This is the doc structure we'll generate. Want to remove or add anything? Or want me to keep as-is?"

Apply whatever the user says (remove docs, add custom ones, etc.). Docs to generate = final confirmed list.

### Step 1.4 - Save state

Write `.docs-state.tmp` BEFORE launching agents (so we can resume if agents fail):
```
phase: 1
type: {monorepo|single}
packages: {comma-separated paths, e.g. apps/api,apps/web - empty for single repo}
docs: {comma-separated list of selected docs}
```

Tell the user: "Setup complete. Selected {N} doc types for {type} project. Launching discovery agents..."

Proceed to `## Phase 2`.

---

## Phase 2 - Preview Loop

This phase builds a compact preview outline. 3 discovery agents scan the codebase in parallel. The heavy generation (one agent per doc type, up to 11 types) only happens in Phase 3 when the user says "generate".

### Step 2.1 - Launch 3 Discovery Agents

Launch exactly 3 agents in PARALLEL to explore the codebase.
Launch 3 background agents to explore the codebase in parallel.

Each agent gets in its prompt:
- the project type and packages list
- the scan + preview instructions from `### Doc Specs` ONLY for docs in the `docs:` list from `.docs-state.tmp` (skip doc types the user removed in Step 1.3)
- if deepening: the current preview content for its doc types, with instruction to find GAPS
- if deepening with direction: the user's focus area

Agent grouping (see `### Doc Specs` for per-doc details):
- Agent 1: overview, architecture, concepts
- Agent 2: repo, features
- Agent 3: db, rules, integrations, testing, guides, pkg-overview (skip pkg-overview for single repo)

IMPORTANT: agents produce OUTLINES (3-8 bullets per doc), not full docs. Full docs are written in Phase 3.

AGENT PROMPT SCOPING: The prompt sent to each agent must ONLY contain:
1. Project type and packages list
2. The scan + preview instructions from Doc Specs for its covered docs
3. If deepening: the current preview content + direction
4. This explicit instruction at the end: "Your ONLY task is to scan the codebase and return bullet-point outlines. Do NOT proceed to any other step, do NOT show menus, do NOT generate documentation files, do NOT write any files. Return ONLY the outline text."

Do NOT include in the agent prompt: the interactive menu (Step 2.4), Phase 3 instructions, or any reference to "generate", "deepen", or "adjust" options.

Wait for all 3 agents to complete.
Wait for all background agents to finish before proceeding.
If an agent fails or times out, log which agent failed and proceed with the results from the remaining agents. Then proceed to `Step 2.2`.

### Step 2.2 - Assemble Preview

Update `.docs-state.tmp`:
1. Change `phase: 1` to `phase: 2` (if not already)
2. Append preview after the header, prefixed with `--- PREVIEW ---`

On first run, write the preview as-is. On deepen runs, MERGE new findings into the existing preview (add new bullets, enrich existing ones) - do NOT replace the entire preview.

Observability findings go into the architecture.md preview entry. Cloud/infra findings go into the repo/infrastructure.md preview entry.

### Step 2.3 - Show Preview

Read `.docs-state.tmp` and display the preview section (everything after `--- PREVIEW ---`) to the user. Then proceed to Step 2.4.

### Step 2.4 - Interactive Menu

After showing the preview, display this menu:

```
What's next?
1. deepen   - launch agents again to find gaps and enrich the preview
2. adjust   - tell me what to add, remove, or change
3. generate - preview looks good, create the docs
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

The ENTIRE Phase 3 is executed by a SINGLE orchestrator agent to keep the main agent's context clean.

### Step 3.0 - Launch Orchestrator

Read `.docs-state.tmp` and launch a SINGLE orchestrator agent (NOT in background).
Launch a single foreground agent to orchestrate the generation.
Pass in the prompt:
- the full content of `.docs-state.tmp` (header + preview)
- the project type, packages list, selected docs
- the Output Structure tree (from `## Output Structure`)
- the full `### Doc Specs` section
- the full `### Metadata Format` section
- ALL the instructions below (Steps 3.1 through 3.4)

The orchestrator handles everything and replies with a short summary: "Done! Generated {N} files in docs/."

The main agent displays this summary to the user.

---

Instructions for the orchestrator agent (include everything below in its prompt):

### Step 3.1 - Create folder structure

Create directories based on the Output Structure tree. Generate all docs unless the user skipped them.

### Step 3.2 - Launch Generation Agents

Launch one agent per selected doc type (up to 11 doc types) in PARALLEL. Note: some doc types generate multiple files (e.g., repo generates 5 files).
Launch one background agent per doc type to generate content in parallel.
Each agent writes doc files directly to `docs/`. Each agent MUST reply with ONLY "done" when finished.

Each agent receives in its prompt:
- the approved preview for its doc(s)
- the project type and packages list
- the doc writing rules below
- the `### Metadata Format` template
- the scan instructions from `### Doc Specs` for its doc type

Wait for all agents to complete.
Wait for all background agents to finish before proceeding.
If an agent fails or times out, log the failure and continue with the remaining agents. After all agents finish, retry failed doc types once. If still failing, skip them and note in the final summary.

Doc writing rules (include in every agent prompt):
- Be concise, use bullet points and tables
- Reference actual codebase file paths
- Use ASCII diagrams generously. architecture.md should have multiple diagrams (request lifecycle, data flow, deploy topology, auth flow, etc.). Other docs should also include diagrams when they help explain flows or relationships.
- ALLOWED box-drawing chars (single-width only): ─ │ ┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼ and arrows → ← ↑ ↓. FORBIDDEN: any double-width or special unicode chars (▶ ▷ ◆ ◇ ● ○ ■ □ ★ ☆ etc.) - these break monospace alignment.
- No bold text, no emojis
- Headers: `#` for page title (one per file), `##` for sections, `###` for subsections, no deeper - use bullet lists instead
- File trees: use `├──`/`└──` with aligned inline descriptions after each entry
- The preview bullets are the OUTLINE - expand each into proper documentation
- overview.md MUST include a doc index listing all generated files with 1-line descriptions
- EVERY .md file MUST end with a metadata section (see Metadata Format)

### Step 3.3 - Align Docs (MANDATORY - do NOT skip)

AFTER all generation agents finish, you MUST run this step before cleanup:
1. Check if `docalign` is available (`which docalign`). If not, install: `pipx install docalign`
2. Run `docalign docs/` to check alignment issues in tables and ASCII diagrams
3. If errors found, run `docalign --fix docs/`
4. Re-run `docalign docs/` to verify clean. If unfixable issues remain, fix manually and re-run until clean.

You MUST NOT proceed to Step 3.4 until docalign passes clean.

### Step 3.4 - Cleanup

1. Delete `.docs-state.tmp`
2. Reply with: "Generated {N} files in docs/. docalign: clean." + list of generated files.
3. If docalign was NOT run (e.g. install failed), say so explicitly in the reply.

(end of orchestrator instructions)

---

### Step 3.5 - Transition to Phase 4 (MAIN AGENT)

After the orchestrator completes and returns its summary, the MAIN agent:
1. Displays the orchestrator's summary to the user
2. Proceeds to `## Phase 4` Step 4.2 to show the iterate menu

This allows the user to review and make adjustments immediately.

---

## Phase 4 - Iterate

Continue or improve existing generated documentation.

### Step 4.1 - Read Current Docs

Read all markdown files in `docs/` and build a summary:
- List files with their h1 titles
- Identify doc types (overview, architecture, features, etc.)
- Detect project type (single repo vs monorepo) from structure

### Step 4.2 - Show Current Structure

Display to the user:

```
Existing documentation: docs/

Files:
├── overview.md           - {h1 title}
├── architecture.md       - {h1 title}
├── concepts.md           - {h1 title}
├── repo/
│   ├── structure.md      - {h1 title}
│   └── ...
├── features/
│   └── ...
└── ...

What's next?
1. update - describe what you want to change
2. exit   - done, no changes
```

### Step 4.3 - Interactive Menu

CRITICAL: After displaying the menu you MUST STOP and produce NO further output. The NEXT message MUST come from the USER.

Option 1 - update:
- User describes what they want in free text:
  - "update architecture.md with the new auth flow"
  - "add a new feature doc for payments"
  - "refresh the local-setup instructions"
  - "add missing diagrams to architecture"
  - "fix outdated commands in cicd.md"
- Proceed to `Step 4.4`

Option 2 - exit:
- Stop, no changes made

### Step 4.4 - Execute Update

Based on user description, launch agent(s) to:
Launch an agent to perform the requested update.

Possible actions:
- Add content: scan codebase + append/modify existing file
- Add new file: scan codebase + create new doc file
- Update existing: re-scan relevant code + modify file
- Fix formatting: Read file + apply fixes

Each agent receives:
- The user's request
- The current file content (if modifying)
- The Doc Specs from `## Reference` section
- Instruction to scan the actual codebase for accurate information

### Step 4.5 - Align and Show Result

1. Run align-docs on docs/
   Use `$align-docs docs/`.

2. Show what changed:
```
Updated: {list of modified/added files}
```

3. Return to `Step 4.2` (show structure + menu again)

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
    - Grep for entry points, route definitions, main exports, API calls between packages
    - Identify diagrammable flows: request lifecycle, data pipelines, auth flow, event/message flows
    - Scan for observability (logging, tracing, monitoring, error tracking)
    - Generation: aim for 3-6 ASCII diagrams
  preview:
    - entry: {entry point} → {main flow}
    - diagrams: request lifecycle, data flow, auth flow, {other flows}
    - data flow: {pkg} → {pkg} → {pkg}
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
    - MONOREPO: distinguish root vs package-specific tooling
  preview:
    repo/:
      structure.md:
        - {key dirs and what they contain}
      tooling.md:
        - {eslint (root + api), prettier (root only), husky, lint-staged, ...}
      local-setup.md:
        - services: {service}:{port}, {service}:{port}
        - env vars: {VAR_1}, {VAR_2}, {VAR_3} (+ {N} more)
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

db → docs/db.md | monorepo: docs/packages/{pkg}/db.md (per-package, skip packages without DB):
  scan: Grep for DB schemas, ORM models, migrations, seeds. Read DB config, scan for caching layer.
  preview:
    - entities: {entity1}, {entity2}, {entity3} (+ {N} more)
    - key relationships: {entity} → {entity}, {entity} → {entity}
    - config: {pooling, replicas, timeouts}
    - migrations: {count} migrations, {strategy}
    - seeds: {how seeding works}
    - caching: {redis/in-memory, strategy}
    - patterns: {soft deletes, views, indexes, etc.}

rules → docs/rules.md | monorepo: docs/packages/{pkg}/rules.md (per-package):
  scan: Grep for conventions docs, coding patterns. Sections: principles, conventions, anti-patterns.
  preview:
    - principles: {principle 1}, {principle 2}
    - conventions: {convention 1}, {convention 2}
    - anti-patterns: {anti-pattern 1}, {anti-pattern 2}

integrations → docs/integrations.md | monorepo: docs/packages/{pkg}/integrations.md (per-package):
  scan: Scan for 3rd party service integrations (payment, email, SMS, storage, search, auth, PMS)
  preview:
    - {service}: {purpose} ({N} integrations total)
    - {service}: {purpose}

testing → docs/testing.md | monorepo: docs/packages/{pkg}/testing.md (per-package):
  scan: Scan test files, frameworks, patterns, test locations, coverage config
  preview:
    - framework: {jest/playwright/vitest}
    - patterns: {unit, functional, e2e}
    - locations: {test dirs}

guides → docs/guides/*.md | monorepo: docs/packages/{pkg}/guides/*.md (per-package):
  scan: Scan for repetitive patterns, existing docs/READMEs
  grouping: one file per how-to topic. Name files as kebab-case actions (add-migration.md, deploy-staging.md). Only create guides for non-obvious multi-step procedures found in the codebase.
  preview:
    guides/{topic}.md:
      - {bullet 1}
      - {bullet 2}
      - {bullet 3}

features → docs/features/*.md:
  scan: Read route definitions, page components, CLI commands, API endpoints
  grouping: one file per user-facing capability (e.g. auth, billing, search). Name files as kebab-case nouns (auth.md, not authenticate.md). Group related endpoints/pages into a single feature; don't create one file per route.
  preview:
    features/{feature-name}.md:
      - {bullet 1}
      - {bullet 2}
      - {bullet 3}

pkg-overview (monorepo only) → docs/packages/{pkg}/overview.md:
  scan: Read package.json per package, scan entry points, identify stack and patterns
  preview:
    packages/{name}/:
      overview.md:
        - {what it does}, entry: {file}
        - stack: {package-specific stack}

(metadata hints example)
features/booking.md:
  - availability check → hold → payment → confirm
  - cancellation policies: flexible, moderate, strict
  > related docs: concepts.md, features/auth.md, packages/api/overview.md
  > related sources: src/features/booking/, src/models/booking.model.ts, src/routes/booking.routes.ts
```

### Metadata Format

Appended at the bottom of every generated .md file:

```md
---

related docs:
- docs/concepts.md - booking entity definition, states
- docs/features/auth.md - user must be authenticated to book
- docs/packages/api/overview.md - booking endpoints live here

related sources:
- src/features/booking/ - booking module root
- src/features/booking/service.ts - core booking logic
- src/models/booking.model.ts - DB model
- src/routes/booking.routes.ts - API endpoints
- tests/booking/ - booking tests
```

Rules:
- related docs: other docs that THIS doc PULLS information from (true dependencies only)
  - UNIDIRECTIONAL: if A references B, do NOT add B references A (creates circular deps)
  - Ask: "does this doc need info from that doc to be correct?" - if yes, add it; if it's just "see also", don't
  - Example: features/auth.md depends on concepts.md (uses types defined there) → add
  - Example: concepts.md does NOT depend on features/auth.md (just "see also") → don't add
- related sources: actual codebase files AND folders relevant to this doc's topic
- list folders when the whole directory is relevant, list specific files when only that file matters
- keep it focused: only list things that are directly relevant, not tangentially related
- overview.md does NOT need related docs (it IS the index) but should list key source files/folders

---

## Important Rules

- ALWAYS update `.docs-state.tmp` after completing each sub-step
- If the user interrupts and runs gen-docs again, `## Phase 0` will resume from the last saved state
- Generate all docs unless the user skipped them in Step 1.3
- The preview in `.docs-state.tmp` is the SOURCE OF TRUTH for `## Phase 3` - only generate what's in the preview
- Phase 2 uses 3 agents for discovery (compact outlines). Phase 3 is delegated to a SINGLE orchestrator agent that internally launches up to 11 generation agents. The main agent NEVER launches 11 agents directly.
- Phase 4 allows iterating on existing docs without regenerating everything
- Phase 2: launch 3 background agents, wait for completion. Phase 3: single foreground orchestrator that launches generation agents in background.
- Phase 4: launch agents for targeted updates based on user request.
- Step 2.2 is done by the MAIN agent (combines 3 agent results into .docs-state.tmp).
