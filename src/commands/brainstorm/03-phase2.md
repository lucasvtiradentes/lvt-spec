
## Phase 2 - Clarification

Ask questions to understand scope and intent.

### Step 2.1 - Analyze Context

Read the current brainstorm file and analyze:
- What is clear vs ambiguous
- What decisions need to be made
- What context is missing
- What trade-offs exist

### Step 2.2 - Generate Questions

Generate 3-5 clarifying questions based on analysis.

Questions should:
- Help understand the user's intent
- Clarify scope and boundaries
- Identify key decisions to make
- Uncover implicit assumptions
- Consider the codebase context if relevant

Format: free-form with inline options. Mark recommended with [R].

```
Based on what you shared, I have some questions:

1. What database do you want? (a. postgres [R], b. mongo, c. other)
2. Should auth be stateless or session-based? (a. JWT [R], b. session, c. other)
3. What's the expected scale? (a. <1k users, b. 1k-100k [R], c. >100k)
...

Answer any/all, or "next" to skip
```

CRITICAL: After displaying questions you MUST STOP. The NEXT message MUST come from the USER.

### Step 2.3 - Process Answers

When user responds:

1. If user says "next" or "skip" → proceed to `## Phase 3`
2. Otherwise:
   - Parse user's answers
   - Update `## Context` with accumulated understanding
   - Update `## Decisions` section with conclusions (grouped by subtopic)
   - Auto-consolidate: merge similar decisions under same subtopic
   - Move answered items from `## Open Questions` if applicable
   - Keep unanswered questions in `## Open Questions`
   - Update `## Meta`: set `phase: loop`, `last-action: clarification complete`

Proceed to `## Phase 3`.
