# Markdown Guides

Formatting rules for markdown documentation files.

## General

- No bold text (`**text**`) - use headers or plain text instead
- No emojis or wide Unicode characters
- Prefer bullet points and tables over long paragraphs
- Reference file paths with inline code: `src/module/file.ts`
- 2-space indentation for nested content

## Headers

```md
# Page Title (one per file)

## Section

### Subsection
```

- `#` for the file title (exactly one per file)
- `##` for top-level sections
- `###` for subsections
- No deeper than `###` - use bullet lists instead

## Tables

Every column must be padded to equal width (enforced by mdalign):

```md
| Name   | Type   | Description        |
|--------|--------|--------------------|
| foo    | string | short description  |
| longer | number | another description|
```

- Header row, separator row, then data rows
- Left-aligned by default (no `:---:` centering)

## Lists

Simple lists:

```md
- item one
- item two
- item three
```

List items with aligned descriptions (dash separator):

```md
- docs/repo.md                    - mirrors CI steps
- docs/guides/testing-strategy.md - test suite overview
```

Definition-style lists (colon separator):

```md
- pooling: 5 connections per instance
- timeout: 5 minutes
- ssl:     enabled in production
```

## ASCII Diagrams

### Allowed characters

Single-width box-drawing only:

```
borders:  ─ │ ┌ ┐ └ ┘ ├ ┤ ┬ ┴ ┼
arrows:   → ← ↑ ↓ v ^
connectors: ───> <─── ────────────>
```

Forbidden: any double-width or special unicode (▶ ▷ ◆ ◇ ● ○ ■ □ ★ ☆ etc.)

### Box diagrams

```md
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  PHASE 0     │    │  PHASE 1     │    │  PHASE 2     │
│  Preflight   │    │  Check       │    │  Auto-fix    │
│              │    │              │    │              │
│  check tools │───>│  run check   │───>│  run fix     │
└──────────────┘    └──────────────┘    └──────────────┘
```

Rules:
- All lines in a box must have the same total character length
- Content lines have 1-2 spaces of padding before closing │
- Border lines (┌─┐ / └─┘) match the box width
- Use ───> for horizontal flow between boxes

### Flow diagrams

```md
┌───────────┐    step name    ┌───────────┐
│ source    │────────────────>│ target    │
│           │                 │           │
└───────────┘                 └─────┬─────┘
                                    │
                               side effect
                                    │
                                    v
                              ┌───────────┐
                              │ result    │
                              └───────────┘
```

### State machines

```md
              ┌──────────┐
              │ pending  │
              └────┬─────┘
                   │
              confirm / pay
                   │
                   v
          ┌─────────────┐
    ┌─────│  confirmed  │──────┐
    │     └──────┬──────┘      │
    │            │             │
  cancel    reschedule     complete
    │            │              │
    v            v              v
┌──────────┐ ┌─────────────┐ ┌───────────┐
│ canceled │ │ rescheduled │ │ completed │
└──────────┘ └─────────────┘ └───────────┘
```

### Entity relationships

```md
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ Brand        │────>│ User         │     │ Experience   │
│              │     │ (membership) │     │              │
└──────┬───────┘     └──────────────┘     └──────┬───────┘
       │                                         │
       │ owns                               has events
       │                                         │
       v                                         v
┌──────────────┐                           ┌──────────────┐
│ Experience   │<──────────────────────────│ Event        │
│              │                           │              │
└──────────────┘                           └──────────────┘
```

## File Trees

```md
project/
├── src/
│   ├── main.ts               entry point
│   ├── core/                  shared infrastructure
│   ├── feature/               feature module
│   │   ├── feature.module.ts  module definition
│   │   ├── entities/          data models
│   │   ├── commands/          write operations
│   │   └── queries/           read operations
│   └── config/                configuration files
├── test/
│   ├── unit/                  unit tests
│   └── functional/            functional tests
└── package.json               project manifest
```

- Use `├──` for items, `└──` for last item, `│` for continuation
- Add inline descriptions after the file/folder name (aligned when possible)

## Code Blocks

Commands:

```md
npm run dev
docker-compose up
```

Code snippets with language tag:

```md
```typescript
const result = await service.create(input);
```                                            (close fence)
```

## Alignment

Use mdalign to auto-fix alignment issues in tables, diagrams, and lists:

```bash
mdalign --fix docs/
```
