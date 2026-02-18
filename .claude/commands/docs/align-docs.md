# Align Docs

Auto-fix alignment issues in markdown files using docalign (tables, ASCII diagrams, lists). Use when the user asks to fix or check markdown alignment. Do NOT use for general markdown editing.

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌───────────────┐
│ PHASE 0      │    │  PHASE 1     │    │ PHASE 2      │    │ PHASE 3       │
│ Preflight    │    │  Check       │    │ Auto-fix     │    │ Manual fix    │
│              │    │              │    │              │    │               │
│ docalign     │───>│ docalign     │───>│ docalign     │───>│ read files    │
│ installed?   │    │ check target │    │ --fix        │    │ fix remaining │
│ ask to       │    │              │    │ target       │    │ re-run until  │
│ install      │    │              │    │              │    │ clean         │
└──────────────┘    └──────────────┘    └──────────────┘    └───────────────┘
```

## Arguments

- $ARGUMENTS: file or folder paths to check (optional, defaults to docs/)

## Instructions

### Phase 0 - Preflight

Check if docalign is installed:

```bash
which docalign
```

If not found, ask the user if they want to install it (`pipx install docalign`). Stop if they decline.

### Phase 1 - Check

Run alignment check on target files:

```bash
docalign --verbose $ARGUMENTS
```

If exit code 0 (all aligned), report success and stop.

### Phase 2 - Auto-fix

If errors found, auto-fix them:

```bash
docalign --fix $ARGUMENTS
```

### Phase 3 - Manual fix

If unfixable issues remain after --fix, read each reported file and fix manually.
Re-run `docalign $ARGUMENTS` to verify. Repeat until clean.
