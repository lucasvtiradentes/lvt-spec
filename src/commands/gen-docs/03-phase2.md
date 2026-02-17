
---

## Phase 2 - Preview Loop

This phase builds a compact preview outline. 3 discovery agents scan the codebase in parallel. The heavy 11-agent generation only happens in Phase 3 when the user says "generate".

### Step 2.1 - Launch 3 Discovery Agents

Launch exactly 3 agents in PARALLEL to explore the codebase.
<!--@claude-->
Use `Task` with `subagent_type: "Explore"` and `run_in_background: true` for each agent.
<!--@gemini,codex-->
Launch 3 background agents to explore the codebase in parallel.
<!--@end-->

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
<!--@claude-->
Use `TaskOutput(block=true)` to wait for each agent.
<!--@gemini,codex-->
Wait for all background agents to finish before proceeding.
<!--@end-->
If an agent fails or times out, log which agent failed and proceed with the results from the remaining agents. Then proceed to `Step 2.2`.

### Step 2.2 - Assemble Preview

Update `.docs-state.tmp`:
1. Change `phase: 1` to `phase: 2` (if not already)
2. Append preview after the header, prefixed with `--- PREVIEW ---`

On first run, write the preview as-is. On deepen runs, MERGE new findings into the existing preview (add new bullets, enrich existing ones) - do NOT replace the entire preview.

Observability findings go into the architecture.md preview entry. Cloud/infra findings go into the repo/infrastructure.md preview entry.

### Step 2.3 - Show Preview

Read `.docs-state.tmp` and display the preview section (everything after `--- PREVIEW ---`) to the user.

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
