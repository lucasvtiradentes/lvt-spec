
## Phase 0 - Route

Determine which phase to enter based on the argument.

### Step 0.1 - Check if argument is existing folder

If the argument is a path to an existing `docs/research/{topic}/` folder:
- Proceed to `## Phase 4` (iterate over existing research)

### Step 0.2 - Check for .tmp file

If `.research-state.tmp` exists in the project root:
<!--@claude-->
- Use `AskUserQuestion` to ask:
  - question: "Found existing research session for '{topic}'. Resume or start fresh?"
  - options:
    - "Resume" (Recommended)
    - "Start fresh (delete state)"
<!--@codex,gemini-->
- Ask the user: "Found existing research session for '{topic}'. Resume or start fresh?"
  - options: "Resume" (Recommended), "Start fresh (delete state)"
<!--@end-->
- If resume: read phase from file
  - If `phase: 1` → jump to `Step 1.3` (re-run discovery agents)
  - If `phase: 2` and NO preview → jump to `Step 2.1` (build preview)
  - If `phase: 2` and HAS preview → jump to `Step 2.2` (show preview + menu)
- If fresh: delete `.research-state.tmp`, proceed to `## Phase 1`

### Step 0.3 - New topic

If neither folder nor .tmp exists:
- Proceed to `## Phase 1`
