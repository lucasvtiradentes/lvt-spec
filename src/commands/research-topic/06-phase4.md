
## Phase 4 - Iterate

Continue or improve an existing research.

### Step 4.1 - Read Current Docs

Read all markdown files in the provided folder and build a summary:
- List files with their h1 titles
- Count total lines/sections per file

### Step 4.2 - Show Current Structure

Display to the user:

```
Existing research: {folder}

Files:
├── 1-overview.md         - {h1 title}
├── 2-{subtopic}.md       - {h1 title}
├── ...
├── {N-1}-best-practices.md
└── {N}-references.md

What's next?
1. update - describe what you want to change
2. exit   - done, no changes
```

### Step 4.3 - Interactive Menu

CRITICAL: After displaying the menu you MUST STOP and produce NO further output. The NEXT message MUST come from the USER.

Option 1 - update:
- User describes what they want in free text:
  - "add a section about security"
  - "deep dive into networking"
  - "update the installation steps for v2"
  - "add new file about plugins"
  - "fix the table alignment in overview"
- Proceed to `Step 4.4`

Option 2 - exit:
- Stop, no changes made

### Step 4.4 - Execute Update

Based on user description, launch agent(s) to:
<!--@claude-->
Use `Task` with `subagent_type: "general-purpose"`.
<!--@end-->

Possible actions:
- **Add content** - WebSearch + append/modify existing file
- **Add new file** - WebSearch + create new numbered file, renumber if needed
- **Update existing** - WebSearch for fresh info + modify file
- **Fix formatting** - Read file + apply fixes

Each agent receives:
- The user's request
- The current file content (if modifying)
- The Doc Specs from `## Reference`
- Instruction to write changes

### Step 4.5 - Align and Show Result

1. Run align-docs on the folder
<!--@claude,gemini-->
   Use `/docs:align-docs {folder}`.
<!--@codex-->
   Use `$align-docs {folder}`.
<!--@end-->

2. Show what changed:
```
Updated: {list of modified/added files}
```

3. Return to `Step 4.2` (show structure + menu again)
