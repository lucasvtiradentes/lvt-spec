
---

## Phase 1 - Setup

### Step 1.1 - Ask project type

<!--@claude-->
Use `AskUserQuestion`:
- question: "What type of project is this?"
- header:   "Project type"
- options:
  - label: "Single Repo"
    description: "One language/concern, personal projects, libraries, single-service apps"
  - label: "Monorepo"
    description: "Multiple packages (api, frontend, infra), multi-team, multiple package.json"
<!--@codex,gemini-->
Ask the user: "What type of project is this?"
- Single Repo: one language/concern, personal projects, libraries, single-service apps
- Monorepo: multiple packages (api, frontend, infra), multi-team, multiple package.json
<!--@end-->

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
