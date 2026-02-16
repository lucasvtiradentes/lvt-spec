
## Phase 2 - Preview Loop

### Step 2.1 - Build Preview

If no preview exists yet in `.research-state.tmp`, launch a single agent to build preview outlines.
<!--@claude-->
Use `Task` with `subagent_type: "general-purpose"`.
<!--@end-->

The agent receives:
- The topic and doc list from `.research-state.tmp`
- Instruction to WebSearch for each doc and return 3-5 bullet points per file

Agent returns preview in this format:
```
1-overview.md:
  - bullet 1
  - bullet 2
  - bullet 3

2-{subtopic}.md:
  - bullet 1
  - bullet 2
  - bullet 3

...
```

Append preview to `.research-state.tmp` after `--- PREVIEW ---`.

### Step 2.2 - Show Preview

Read `.research-state.tmp` and display to the user:

```
Research: {topic}
Output: {folder}

Docs to generate:
{numbered list of docs with bullet previews}

What's next?
1. adjust   - add, remove, or change docs
2. generate - looks good, create the docs
```

### Step 2.3 - Interactive Menu

CRITICAL: After displaying the menu you MUST STOP and produce NO further output. Do NOT pick an option. The NEXT message MUST come from the USER.

User can type "1" or "2", or add details: "1, add a section about security", "1, remove the advanced topic".

Option 1 - adjust:
- User provides changes (add doc, remove doc, rename, change scope)
- Apply changes to the doc list and preview in `.research-state.tmp`
- Return to `Step 2.2` (show updated preview + menu)

Option 2 - generate:
- Proceed to `## Phase 3`
