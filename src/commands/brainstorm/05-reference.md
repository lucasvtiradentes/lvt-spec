
## Reference

### File Sections

```
# Brainstorm: {Topic}

## Meta
- phase: capture | clarification | loop
- last-action: {description of last action}

## Context
- Accumulated understanding from Q&A
- Processed insights (not raw)
- Key constraints identified

## Raw Ideas
- Unprocessed user thoughts
- Kept as-is, user's words
- New dumps appended here

## Decisions
### {Subtopic Name}
- Concluded decisions grouped by topic
- Updated when questions are answered
- Updated when research provides clarity
- Auto-consolidated: similar decisions merged

## Open Questions
- Unanswered questions
- Questions raised by research
- Removed when answered

## Research Notes
### Web Findings
- [HIGH] high confidence finding
- [MED] medium confidence finding
- [LOW] low confidence finding

### Codebase Findings
- [HIGH] existing pattern confirmed
- [MED] possible relevant file
- [LOW] might be related
```

### Parsing Rules

When parsing user free-form input into bullets:
- Split by sentences or clear thought boundaries
- Preserve user's original wording
- One idea per bullet
- Don't over-structure, keep it raw

### Grouping Decisions

When adding to `## Decisions`:
- Group related decisions under subtopic headers
- Create new subtopic if doesn't fit existing ones
- Subtopic names should be short, descriptive (2-4 words)
- Use kebab-case for consistency in headers

### Question Generation

Format: free-form with inline options. Mark recommended with [R].

Good examples:
- "What db? (a. postgres [R], b. mongo, c. other)"
- "Expected scale? (a. <1k, b. 1k-100k [R], c. >100k)"
- "Auth type? (a. JWT [R], b. session, c. OAuth only)"
- "Deploy where? (a. AWS [R], b. GCP, c. self-hosted)"

Avoid:
- Yes/no questions (too narrow)
- Questions without options (too open)
- Questions already answered in Raw Ideas

### Auto-Consolidation

When updating `## Decisions`:
- Check if new decision fits existing subtopic
- If yes: add under that subtopic
- If similar subtopic exists: merge them
- Keep subtopics broad (max 8-12 groups)
- Never duplicate subtopic names

---

## Important Rules

- File is always at project root: `brainstorm-{topic-kebab}.md`
- `## Meta` tracks phase + last-action for resume capability
- `## Context` holds processed understanding (not raw)
- Raw Ideas preserve user's words, minimal processing
- Decisions are auto-consolidated by subtopic
- Research findings have confidence tags: `[HIGH]`, `[MED]`, `[LOW]`
- Questions use inline options format with [R] for recommended
- Menu supports inline direction: "2, search caching strategies"
- Always stop after menus/prompts, wait for user
<!--@claude-->
- Web search: `Task` with `subagent_type: "general-purpose"`
- Codebase search: `Task` with `subagent_type: "Explore"`
<!--@end-->
