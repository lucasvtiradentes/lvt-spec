
---

## Phase 3 - Generate

The ENTIRE Phase 3 is executed by a SINGLE orchestrator agent to keep the main agent's context clean.
<!--@claude-->
The main agent only makes 1 `Task` call.
<!--@end-->

### Step 3.0 - Launch Orchestrator

Read `.docs-state.tmp` and launch a SINGLE orchestrator agent (NOT in background).
<!--@claude-->
Use `Task` with `subagent_type: "general-purpose"` (NOT `run_in_background`).
<!--@gemini,codex-->
Launch a single foreground agent to orchestrate the generation.
<!--@end-->
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
<!--@claude-->
Use `Task` with `subagent_type: "general-purpose"` and `run_in_background: true` for each agent.
<!--@gemini,codex-->
Launch one background agent per doc type to generate content in parallel.
<!--@end-->
Each agent writes doc files directly to `docs/`. Each agent MUST reply with ONLY "done" when finished.

Each agent receives in its prompt:
- the approved preview for its doc(s)
- the project type and packages list
- the doc writing rules below
- the `### Metadata Format` template
- the scan instructions from `### Doc Specs` for its doc type

Wait for all agents to complete.
<!--@claude-->
Use `TaskOutput(block=true)` to wait for each agent.
<!--@gemini,codex-->
Wait for all background agents to finish before proceeding.
<!--@end-->
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
