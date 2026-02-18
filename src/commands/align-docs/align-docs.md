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

<!--@claude,codex-->
- $ARGUMENTS: file or folder paths to check (optional, defaults to docs/)
<!--@gemini-->
- {{args}}: file or folder paths to check (optional, defaults to docs/)
<!--@end-->

## Instructions

### Phase 0 - Preflight

Check if docalign is installed:

```bash
which docalign
```

If not found, ask the user if they want to install it (`pipx install docalign`). Stop if they decline.

### Phase 1 - Check

Run alignment check on target files:

<!--@claude,codex-->
```bash
docalign --verbose $ARGUMENTS
```
<!--@gemini-->
```bash
docalign --verbose {{args}}
```
<!--@end-->

If exit code 0 (all aligned), report success and stop.

### Phase 2 - Auto-fix

If errors found, auto-fix them:

<!--@claude,codex-->
```bash
docalign --fix $ARGUMENTS
```
<!--@gemini-->
```bash
docalign --fix {{args}}
```
<!--@end-->

### Phase 3 - Manual fix

If unfixable issues remain after --fix, read each reported file and fix manually.
<!--@claude,codex-->
Re-run `docalign $ARGUMENTS` to verify. Repeat until clean.
<!--@gemini-->
Re-run `docalign {{args}}` to verify. Repeat until clean.
<!--@end-->
