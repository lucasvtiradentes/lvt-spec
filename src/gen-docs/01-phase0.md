
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
