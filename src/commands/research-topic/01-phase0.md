
## Phase 0 - Resume Check

1. Check if `.research-state.tmp` exists in the project root
2. If it EXISTS:
<!--@claude-->
   - Use `AskUserQuestion` to ask:
     - question: "Found existing research session. Resume or start fresh?"
     - options:
       - "Resume" (Recommended)
       - "Start fresh (delete state)"
<!--@codex,gemini-->
   - Ask the user: "Found existing research session. Resume or start fresh?"
     - options: "Resume" (Recommended), "Start fresh (delete state)"
<!--@end-->
   - If resume: read phase from file
     - If `phase: 1` → jump to `## Phase 1`
     - If `phase: 2` → jump to `Step 2.2` (show preview + menu)
   - If fresh: delete `.research-state.tmp`, proceed to `## Phase 1`
3. If it does NOT exist:
   - Proceed to `## Phase 1`
