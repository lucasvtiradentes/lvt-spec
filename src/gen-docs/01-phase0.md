
---

## Phase 0 - Resume Check

1. Check if `.docs-state.tmp` exists in the project root
2. If it EXISTS:
   - Use `AskUserQuestion` to ask:
     - question: "Found existing gen-docs session. Resume or start fresh?"
     - options:
       - "Resume" (Recommended)
       - "Start fresh (delete state)"
   - If resume: jump to `Step 2.3` (show preview + menu)
   - If fresh: delete `.docs-state.tmp`, proceed to `## Phase 1`
3. If it does NOT exist (includes interruptions during Phase 1, before state is saved):
   - Proceed to `## Phase 1`
