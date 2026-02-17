
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
