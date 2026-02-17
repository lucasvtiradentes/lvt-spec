
## Phase 3 - Menu Loop

Main interaction loop for the brainstorm session.

### Step 3.1 - Show Menu

Display current state and menu:

```
Brainstorm: {topic}
File: brainstorm-{topic-kebab}.md

Current state:
- Raw Ideas: {count} items
- Decisions: {count} items across {count} subtopics
- Open Questions: {count} items

What's next?
1. questions - I ask more clarifying questions (or: "1, ask about auth")
2. web       - search web for insights (or: "2, search caching strategies")
3. codebase  - search codebase for patterns (or: "3, find db models")
4. dump      - add more ideas freely
5. done      - finish brainstorm session
```

User can type just "1"-"5" OR add direction: "2, search best practices for rate limiting".

CRITICAL: After displaying the menu you MUST STOP. The NEXT message MUST come from the USER.

### Step 3.2 - Handle Menu Choice

#### Option 1 - questions

Return to `## Phase 2` Step 2.1 to generate new questions based on current context.

#### Option 2 - web

<!--@claude-->
Use `Task` with `subagent_type: "general-purpose"` to:
<!--@gemini,codex-->
Launch an agent to:
<!--@end-->

- If user gave direction, search for that specific topic
- Otherwise: WebSearch for "{topic}" + key concepts from Decisions/Raw Ideas
- WebSearch for best practices, patterns, common approaches
- Return relevant findings with confidence: `[HIGH]`, `[MED]`, `[LOW]`

Update file:
- Add findings to `## Research Notes > ### Web Findings` with confidence tags
- If findings suggest decisions, add to `## Decisions` (auto-consolidate with existing)
- If findings raise questions, add to `## Open Questions`
- Update `## Meta`: `last-action: web search - {topic searched}`

Show summary of what was found and return to `Step 3.1`.

#### Option 3 - codebase

<!--@claude-->
Use `Task` with `subagent_type: "Explore"` to:
<!--@gemini,codex-->
Launch an exploration agent to:
<!--@end-->

- If user gave direction, search for that specific pattern/file
- Otherwise: search codebase for patterns related to the topic
- Find existing implementations, conventions, relevant files
- Identify constraints or dependencies
- Return findings with confidence: `[HIGH]`, `[MED]`, `[LOW]`

Update file:
- Add findings to `## Research Notes > ### Codebase Findings` with confidence tags
- If findings suggest decisions, add to `## Decisions` (auto-consolidate with existing)
- If findings raise questions, add to `## Open Questions`
- Update `## Meta`: `last-action: codebase search - {pattern searched}`

Show summary of what was found and return to `Step 3.1`.

#### Option 4 - dump

Prompt user:

```
Go ahead, tell me more:
```

CRITICAL: After prompting you MUST STOP. The NEXT message MUST come from the USER.

When user responds:
- Parse their input into bullet points
- Append to `## Raw Ideas`
- Analyze new input and optionally update `## Decisions` if clear conclusions emerge
- Auto-consolidate: merge related decisions under same subtopic
- Update `## Meta`: `last-action: user dump`

Return to `Step 3.1`.

#### Option 5 - done

Show final summary:

```
Brainstorm complete: brainstorm-{topic-kebab}.md

Summary:
- {count} raw ideas captured
- {count} decisions made across {count} subtopics
- {count} open questions remaining

File saved at project root.
```

Stop execution.
