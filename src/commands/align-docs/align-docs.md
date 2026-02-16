```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌───────────────┐
│ PHASE 0      │    │  PHASE 1     │    │ PHASE 2      │    │ PHASE 3       │
│ Preflight    │    │  Check       │    │ Auto-fix     │    │ Manual fix    │
│              │    │              │    │              │    │               │
│ mdalign      │───>│ mdalign      │───>│ mdalign      │───>│ read files    │
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

Check if mdalign is installed:

```bash
which mdalign
```

If not found, ask the user if they want to install it (`pipx install mdalign`). Stop if they decline.

### Phase 1 - Check

Run alignment check on target files:

<!--@claude,codex-->
```bash
mdalign --verbose $ARGUMENTS
```
<!--@gemini-->
```bash
mdalign --verbose {{args}}
```
<!--@end-->

If exit code 0 (all aligned), report success and stop.

### Phase 2 - Auto-fix

If errors found, auto-fix them:

<!--@claude,codex-->
```bash
mdalign --fix $ARGUMENTS
```
<!--@gemini-->
```bash
mdalign --fix {{args}}
```
<!--@end-->

### Phase 3 - Manual fix

If unfixable issues remain after --fix, read each reported file and fix manually.
<!--@claude,codex-->
Re-run `mdalign $ARGUMENTS` to verify. Repeat until clean.
<!--@gemini-->
Re-run `mdalign {{args}}` to verify. Repeat until clean.
<!--@end-->
