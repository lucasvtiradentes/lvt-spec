
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
