
---

## Phase 3 - Generate

The ENTIRE Phase 3 is executed by a SINGLE orchestrator subagent to keep the main agent's context clean. The main agent only makes 1 Task call.

### Step 3.0 - Launch Orchestrator

Read `.docs-state.tmp` and launch a SINGLE `Task` with `subagent_type: "general-purpose"` (NOT in background). Pass in the prompt:
- the full content of `.docs-state.tmp` (header + preview)
- the project type, parts list, selected docs
- ALL the instructions below (Steps 3.1 through 3.4)

The orchestrator handles everything and replies with a short summary: "Done! Generated {N} files in docs/."

The main agent displays this summary to the user.

---

Instructions for the orchestrator agent (include everything below in its prompt):

### Step 3.1 - Create folder structure

Create directories based on the Output Structure defined above. Generate all docs unless the user skipped them.

### Step 3.2 - Launch Generation Agents

Launch one agent per selected doc type (up to 12 agents) in PARALLEL using `Task` with `subagent_type: "general-purpose"` and `run_in_background: true`. Each agent writes doc files directly to `docs/`. Each agent MUST reply with ONLY "done" when finished.

Each agent receives in its prompt:
- the approved preview for its doc(s)
- the project type and parts list
- the doc writing rules below
- the `### Metadata Format` template
- the scan instructions from `### Doc Specs` for its doc type

Wait for all agents using TaskOutput(block=true).

Doc writing rules (include in every agent prompt):
- Be concise, use bullet points and tables
- Reference actual codebase file paths
- Use ASCII diagrams generously (box-drawing chars: ─ │ ┌ ┐ └ ┘ ├ ┤). architecture.md should have multiple diagrams (request lifecycle, data flow, deploy topology, auth flow, etc.). Other docs should also include diagrams when they help explain flows or relationships.
- No bold text, no emojis
- The preview bullets are the OUTLINE - expand each into proper documentation
- overview.md MUST include a doc index listing all generated files with 1-line descriptions
- EVERY .md file MUST end with a metadata section (see Metadata Format)

### Step 3.3 - Align Docs

AFTER all generation agents finish, run `mdalign docs/` to check for alignment issues in tables and ASCII diagrams. If errors are found, run `mdalign --fix docs/` to auto-fix them. If unfixable issues remain, fix them manually and re-run until clean. Do NOT skip this step.

### Step 3.4 - Cleanup

AFTER align-docs passes clean:
1. Delete `.docs-state.tmp`
2. Reply with: "Done! Generated {N} files in docs/. Review them and adjust as needed." + list of generated files.
