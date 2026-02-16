
## Phase 0 - Route

Determine which phase to enter based on the argument.

### Step 0.1 - Check if argument is existing folder

If the argument is a path to an existing `docs/research/{topic}/` folder:
- Proceed to `## Phase 4` (iterate over existing research)

### Step 0.2 - Check for .tmp file

If `.research-state.tmp` exists in the project root:
- Read phase from file and resume:
  - If `phase: 1` → jump to `Step 1.3` (re-run discovery agents)
  - If `phase: 2` and NO preview → jump to `Step 2.1` (build preview)
  - If `phase: 2` and HAS preview → jump to `Step 2.2` (show preview + menu)

### Step 0.3 - New topic

If neither folder nor .tmp exists:
- Proceed to `## Phase 1`
