
---

## Phase 2 - Preview Loop

This phase builds a compact preview outline. Only 2 discovery agents scan the codebase. The heavy 12-agent generation only happens in Phase 3 when the user says "generate".

### Step 2.1 - Launch 2 Discovery Agents

Launch exactly 2 Explore agents in PARALLEL using `Task` with `subagent_type: "Explore"` and `run_in_background: true`.

Each agent gets in its prompt:
- the project type and parts list
- the list of selected docs (only scan for selected ones)
- the `### Preview Format` template so it returns in the correct format
- if deepening: the current preview content for its doc types, with instruction to find GAPS
- if deepening with direction: the user's focus area

Agent 1 (100-200 lines):
- covers: overview, architecture, repo, concepts, db, cicd
- scan README, package.json (root + per-part), pyproject.toml, go.mod, tsconfig, docker-compose
- scan entry points: main/index files, route definitions, main exports
- grep for type definitions, interfaces, enums, DB models/schemas/entities
- grep for env var references (process.env, os.environ), read .env.example
- read CI workflows (.github/workflows/, .gitlab-ci.yml, Jenkinsfile)
- glob folder structure, identify directory organization
- scan tooling configs: eslint, prettier, husky, lint-staged, commitlint
- read Makefile, package.json scripts, shell scripts in scripts/
- scan for DB config (connection pooling, replicas, migrations, seeds, caching)
- scan for observability (logging, tracing, monitoring, error tracking)
- scan for cloud resources (Cloud Run, GCS, Pub/Sub, Lambda, S3, etc.)
- MONOREPO: distinguish root vs part-specific tooling

Agent 2 (100-200 lines):
- covers: rules, guides, features, integrations, parts, problems
- grep for coding conventions docs, CLAUDE.md, .editorconfig, lint configs
- scan for consistent coding patterns, principles, anti-patterns
- scan test files to understand testing patterns, frameworks, test locations
- scan for repetitive patterns: how controllers/entities/routes are created
- look for existing docs, READMEs in subdirectories, inline "how to" comments
- read route definitions, page components, CLI commands, API endpoints
- scan for 3rd party integrations (payment, email, SMS, storage, search, auth)
- for each monorepo part: read package.json, scan entry points, identify patterns
- check for ADRs, CHANGELOG, postmortems, solved problem docs
- MONOREPO: identify per-part rules, per-part guides

Each agent returns its output in `### Preview Format` (bullet-point outlines per file, NOT full documentation).

IMPORTANT: agents produce OUTLINES (3-8 bullets per doc), not full docs. Full docs are written in Phase 3.

AGENT PROMPT SCOPING: The prompt sent to each Explore agent must ONLY contain:
1. Project type and parts list
2. The list of selected docs it covers
3. Its specific scanning instructions (from Agent 1 / Agent 2 above)
4. The `### Preview Format` template
5. If deepening: the current preview content + direction
6. This explicit instruction at the end of each agent prompt: "Your ONLY task is to scan the codebase and return bullet-point outlines in the Preview Format. Do NOT proceed to any other step, do NOT show menus, do NOT generate documentation files, do NOT write any files. Return ONLY the outline text."

Do NOT include in the agent prompt: the interactive menu (Step 2.4), Phase 3 instructions, or any reference to "generate", "deepen", or "adjust" options. The agents must have ZERO awareness of the overall workflow beyond their scanning task.

Wait for both agents using TaskOutput(block=true), then proceed to `Step 2.2`.

### Step 2.2 - Assemble Preview

Combine both agent results into `.docs-state.tmp` after the header, prefixed with `--- PREVIEW ---`.

Observability and cloud/infra findings always go into the architecture.md preview entry.

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
