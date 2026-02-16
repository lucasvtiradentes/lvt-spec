
## Phase 3 - Generate

### Step 3.1 - Create Folder

Create the output folder from `.research-state.tmp`:
```bash
mkdir -p {folder}
```

### Step 3.2 - Launch Generation Agents

Launch one agent per doc file in PARALLEL.
<!--@claude-->
Use `Task` with `subagent_type: "general-purpose"` and `run_in_background: true` for each agent.
<!--@end-->

Each agent receives:
- The topic
- The preview bullets for its doc
- The Doc Specs from `## Reference` section
- Instruction to WebSearch for detailed content and write the file

Doc writing rules (include in every agent prompt):
- Follow `docs/doc-style.md` formatting rules
- Use tables for commands/options/flags
- Include code examples with proper syntax highlighting
- Keep explanations concise, no fluff
- Write in English
- No bold text, no emojis
- The `references.md` file collects ALL URLs used across all docs during research

Wait for all agents to complete.
<!--@claude-->
Use `TaskOutput(block=true)` to wait for each agent.
<!--@end-->

### Step 3.3 - Align Docs

Run align-docs on the generated folder. Re-run until clean.
<!--@claude,gemini-->
Use `/docs:align-docs {folder}`.
<!--@codex-->
Use `$align-docs {folder}`.
<!--@end-->

### Step 3.4 - Cleanup

1. Delete `.research-state.tmp`
2. Show the folder structure created:

```
{folder}/
├── 1-overview.md
├── 2-{subtopic}.md
├── 3-{subtopic}.md
├── ...
├── {N-1}-best-practices.md
└── {N}-references.md

Done! Generated {N} files. Review and adjust as needed.
```
