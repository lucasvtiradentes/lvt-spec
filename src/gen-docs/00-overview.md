# Gen Docs

Interactive, state-aware command that generates structured project documentation for AI context.
  - Supports single repo and monorepo.
  - Tracks progress in a state file so interrupted sessions can resume from where they left off.

```
┌─────────────┐    ┌─────────────┐    ┌──────────────────────────────┐    ┌───────────────┐
│  PHASE 0    │    │  PHASE 1    │    │  PHASE 2                     │    │  PHASE 3      │
│  Resume     │    │  Setup      │    │  Preview Loop                │    │  Generate     │
│             │    │             │    │                              │    │               │
│ read .tmp   │───>│ project     │───>│ 2.1 launch agents → scan     │───>│ write docs/   │
│ resume or   │    │ type?       │    │ 2.2 build preview in .tmp    │    │ from approved │
│ start fresh │    │ parts?      │    │ 2.3 show preview to user     │    │ preview       │
│             │    │ skip docs?  │    │      <loop until "go">       │    │               │
└─────────────┘    └─────────────┘    └──────────────────────────────┘    └───────────────┘
```

## Temp Files

All progress is tracked in `.docs-state.tmp` (single file, no folder needed).

After `Step 1.4` (header only):
```
phase: 2
type: monorepo
parts: apps/api,apps/web,packages/infra
docs: overview,architecture,repo,concepts,db,cicd,rules,guides,features,integrations,parts,problems
```

After `Step 2.2` (preview appended, phase stays 2 until user picks "generate"):
```
phase: 2
type: monorepo
parts: apps/api,apps/web,packages/infra
docs: overview,architecture,repo,concepts,db,cicd,rules,guides,features,integrations,parts,problems

--- PREVIEW ---

overview.md:
  - project: My App - description here
  - related repos: repo-a, repo-b
  - doc index: 12 files across docs/

features/auth.md:
  - email/password + Google OAuth
  - JWT with refresh rotation
  - role-based: guest, host, admin

features/booking.md:
  - availability check → hold → payment → confirm
  - cancellation policies: flexible, moderate, strict

...etc
```

The phase stays at 2 until docs are fully generated. There is no `phase: 3` - when the user picks "generate", we go straight to Phase 3 without updating the phase. If interrupted during generation, resume will show the preview menu again so the user can re-trigger.
