# Align Docs

Auto-fix alignment issues in documentation files (tables and ASCII diagrams).

## Arguments

- $ARGUMENTS: file or folder paths to check (optional, defaults to docs/)

## Instructions

1. Run the alignment script on the target files:

```bash
python3 .claude/commands/docs/align-docs.py $ARGUMENTS
```

The script auto-fixes tables and ASCII box diagrams by default. It reports what was fixed and any remaining unfixable issues.

2. If unfixable issues remain, read each reported file and fix manually.

3. Re-run to verify. Repeat until clean.

## Flags

- `--check` - detect-only mode, no files modified

```bash
python3 .claude/commands/docs/align-docs.py --check docs/overview.md
```

## What It Fixes

### Tables

Every cell in a column MUST have the same width as the separator row.

- Widens separator and pads all cells to match the widest content in each column.

### ASCII Diagrams - Box Widths

Every line in a box group MUST have the same total character length.

- Border lines (┌─┐ / └─┘): adjusts dash count
- Content lines (│...│): adds/removes trailing spaces before closing │
- Skips tree structures (├── with /)
- Never removes non-space characters (reports as unfixable instead)

### ASCII Diagrams - Rail Alignment

Vertically adjacent box chars (│ ┌ └ ┐ ┘ ├ ┤ ┬ ┴ ┼) at the same logical rail MUST be at the same column.

- Groups nearby columns (±1) into rails, segments by line gap
- Uses structural priority: ┬/┴ (pipe origins) > ┌/└/┐/┘/├/┤ (borders) > ┼ (crossings) > │ (content)
- Adjusts spaces/dashes around box chars to shift them to the correct column
- Clusters same-count lines by position similarity to avoid false positives

### ASCII Diagrams - Arrow Alignment

Standalone v/^ arrows MUST align with the nearest box char above (for v) or below (for ^).

- Only checks arrows surrounded by spaces (not embedded in borders like ─v─)
- Shifts arrows by adjusting adjacent spaces, works on mixed-content lines too

### Wide Characters

NEVER use emojis or wide Unicode chars inside ASCII diagrams. They break alignment. Use ASCII equivalents.

## Examples

```bash
# auto-fix all docs
python3 .claude/commands/docs/align-docs.py

# auto-fix specific files
python3 .claude/commands/docs/align-docs.py docs/overview.md docs/architecture.md

# check-only (no writes)
python3 .claude/commands/docs/align-docs.py --check docs/overview.md
```
