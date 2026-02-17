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

<!--@claude,codex-->
- $ARGUMENTS: The topic to brainstorm (e.g., "auth system", "api refactor", "new feature")
<!--@gemini-->
- {{args}}: The topic to brainstorm (e.g., "auth system", "api refactor", "new feature")
<!--@end-->

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
