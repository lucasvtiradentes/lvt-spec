
---

## Phase 4 - Iterate

Continue or improve existing generated documentation.

### Step 4.1 - Read Current Docs

Read all markdown files in `docs/` and build a summary:
- List files with their h1 titles
- Identify doc types (overview, architecture, features, etc.)
- Detect project type (single repo vs monorepo) from structure

### Step 4.2 - Show Current Structure

Display to the user:

```
Existing documentation: docs/

Files:
├── overview.md           - {h1 title}
├── architecture.md       - {h1 title}
├── concepts.md           - {h1 title}
├── repo/
│   ├── structure.md      - {h1 title}
│   └── ...
├── features/
│   └── ...
└── ...

What's next?
1. update - describe what you want to change
2. exit   - done, no changes
```

### Step 4.3 - Interactive Menu

CRITICAL: After displaying the menu you MUST STOP and produce NO further output. The NEXT message MUST come from the USER.

Option 1 - update:
- User describes what they want in free text:
  - "update architecture.md with the new auth flow"
  - "add a new feature doc for payments"
  - "refresh the local-setup instructions"
  - "add missing diagrams to architecture"
  - "fix outdated commands in cicd.md"
- Proceed to `Step 4.4`

Option 2 - exit:
- Stop, no changes made

### Step 4.4 - Execute Update

Based on user description, launch agent(s) to:
<!--@claude-->
Use `Task` with `subagent_type: "general-purpose"`.
<!--@end-->

Possible actions:
- **Add content** - scan codebase + append/modify existing file
- **Add new file** - scan codebase + create new doc file
- **Update existing** - re-scan relevant code + modify file
- **Fix formatting** - Read file + apply fixes

Each agent receives:
- The user's request
- The current file content (if modifying)
- The Doc Specs from `## Reference` section
- Instruction to scan the actual codebase for accurate information

### Step 4.5 - Align and Show Result

1. Run align-docs on docs/
<!--@claude,gemini-->
   Use `/docs:align-docs docs/`.
<!--@codex-->
   Use `$align-docs docs/`.
<!--@end-->

2. Show what changed:
```
Updated: {list of modified/added files}
```

3. Return to `Step 4.2` (show structure + menu again)
