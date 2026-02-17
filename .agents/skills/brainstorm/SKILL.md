---
name: brainstorm
description: Interactive brainstorm session that captures ideas, asks clarifying questions, and organizes decisions into a structured markdown file. Use when the user wants to brainstorm, explore ideas, or think through a topic. Pass a topic name for new session or existing file to continue.
---

```
┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│ PHASE 0           │    │ PHASE 1           │    │ PHASE 2           │    │ PHASE 3           │
│ Route             │    │ Initial Capture   │    │ Clarification     │    │ Menu Loop         │
│                   │    │                   │    │                   │    │                   │
│ file exists?      │───>│ user dumps ideas  │───>│ claude asks       │───>│ 1. questions      │
│ or new topic?     │    │ save raw          │    │ questions about   │    │ 2. web search     │
│                   │    │                   │    │ scope/intent      │    │ 3. codebase search│
└─────────┬─────────┘    └───────────────────┘    └───────────────────┘    │ 4. free dump      │
          │                                                                │ 5. done           │
          │ (file exists)                                                  └─────────┬─────────┘
          │                                                                          │
          └──────────────────────────────────────────────────────────────────────────┘
```

## Arguments

- $ARGUMENTS: The topic to brainstorm (e.g., "auth system", "api refactor", "new feature")

## Output Structure

Single file at project root:

```
brainstorm-{topic-kebab}.md
```

Example filenames:
- `brainstorm-auth-system.md`
- `brainstorm-api-refactor.md`
- `brainstorm-new-feature.md`

## File Format

```md
# Brainstorm: {Topic}

## Meta

- phase: capture | clarification | loop
- last-action: {description}

## Context

- accumulated understanding from Q&A
- processed insights

## Raw

```
{exact text as typed by user, original language, no processing}
```

## Raw Ideas

- initial idea 1
- initial idea 2
- ...

## Decisions

### {Subtopic 1}

- decision/conclusion 1
- decision/conclusion 2

### {Subtopic 2}

- decision/conclusion 1

## Open Questions

- unanswered question 1
- unanswered question 2

## Research Notes

### Web Findings

- [HIGH] finding 1
- [MED] finding 2

### Codebase Findings

- [HIGH] existing pattern 1
- [LOW] relevant file 1
```

## Phase 0 - Route

Determine entry point based on existing file.

### Step 0.1 - Check for existing file

Search for `brainstorm-*.md` files matching the topic in project root.

If file exists:
- Read the file content
- Check `## Meta` section for current phase:
  - `phase: capture` → jump to `## Phase 1` Step 1.3
  - `phase: clarification` → jump to `## Phase 2` Step 2.1
  - `phase: loop` → jump to `## Phase 3` Step 3.1

### Step 0.2 - New topic

If no matching file exists:
- Proceed to `## Phase 1`

## Phase 1 - Initial Capture

### Step 1.1 - Parse Topic

Convert the argument to kebab-case for the filename:
- "auth system" → "auth-system"
- "API Refactor" → "api-refactor"
- "New Feature ideas" → "new-feature-ideas"

### Step 1.2 - Prompt for Initial Ideas

Ask the user to dump their initial thoughts:

```
Brainstorm: {topic}

Tell me everything you have in mind about this topic.
What are you trying to achieve? What ideas do you have?

(just write freely, I'll organize it later)
```

CRITICAL: After displaying the prompt you MUST STOP. The NEXT message MUST come from the USER.

### Step 1.3 - Save Initial Ideas

When user responds with their ideas:

1. Create file `brainstorm-{topic-kebab}.md`
2. Write initial structure:

```md
# Brainstorm: {Topic}

## Meta

- phase: capture
- last-action: initial ideas captured

## Context

## Raw

```
{user's exact input here, unprocessed}
```

## Raw Ideas

- {parsed bullet 1 from user input}
- {parsed bullet 2 from user input}
- ...

## Decisions

## Open Questions

## Research Notes

### Web Findings

### Codebase Findings
```

1. Save user's exact input in `## Raw` section (inside code block, unprocessed)
2. Parse user's free-form text into bullet points for `## Raw Ideas`. Keep their words, just structure them.

Update `## Meta`: set `phase: clarification`, `last-action: initial ideas captured`.

Proceed to `## Phase 2`.

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

Launch an agent to:

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

Launch an exploration agent to:

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
- Append exact input to `## Raw` section (inside code block)
- Parse their input into bullet points
- Append parsed bullets to `## Raw Ideas`
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

## Raw
```
Exact user input, original language, no processing.
Appended on each dump. Preserved as-is.
```

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
- `## Raw` holds exact user input, unprocessed, in code block
- `## Raw Ideas` parses raw into bullet points
- Decisions are auto-consolidated by subtopic
- Research findings have confidence tags: `[HIGH]`, `[MED]`, `[LOW]`
- Questions use inline options format with [R] for recommended
- Menu supports inline direction: "2, search caching strategies"
- Always stop after menus/prompts, wait for user
