
```
┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│ PHASE 0           │    │ PHASE 1           │    │ PHASE 2           │    │ PHASE 3           │
│ Route             │    │ Setup             │    │ Preview Loop      │    │ Generate          │
│                   │    │                   │    │                   │    │                   │
│ .tmp exists?      │───>│ project type?     │───>│ launch agents     │───>│ write docs/       │
│ docs/ exists?     │    │ packages?         │    │ build preview     │    │ from approved     │
│ or new?           │    │ skip docs?        │    │ <loop until "go"> │    │ preview           │
└─────────┬─────────┘    └───────────────────┘    └───────────────────┘    └─────────┬─────────┘
          │                                                                          │
          │ (docs/ exists)                                                           │
          │                                                                          │
          │    ┌─────────────────────────────────────────────────────────────────────┘
          │    │
          v    v
    ┌───────────────────┐
    │ PHASE 4           │<───┐
    │ Iterate           │    │
    │                   │    │
    │ show current docs │    │ (update)
    │ menu: update/exit │    │
    │ agents + align    │────┘
    └─────────┬─────────┘
              │ (exit)
              v
           [done]
```

## Output Structure

```
docs/ (single repo)                  docs/ (monorepo)
├── overview.md                      ├── overview.md
├── architecture.md                  ├── architecture.md
├── concepts.md                      ├── concepts.md
├── repo/                            ├── repo/
│   ├── structure.md                 │   ├── structure.md
│   ├── tooling.md                   │   ├── tooling.md
│   ├── local-setup.md               │   ├── local-setup.md
│   ├── cicd.md                      │   ├── cicd.md
│   └── infrastructure.md            │   └── infrastructure.md
├── features/                        ├── features/
│   └── {feature}.md                 │   └── {feature}.md
├── db.md                            └── packages/
├── rules.md                             └── {pkg}/
├── integrations.md                          ├── overview.md
├── testing.md                               ├── db.md
└── guides/                                  ├── rules.md
    └── {topic}.md                           ├── integrations.md
                                             ├── testing.md
                                             └── guides/
                                                 └── {topic}.md
```

Package-specific docs (db, rules, integrations, testing, guides) are at root in single repo, nested under `packages/{pkg}/` in monorepo.

All docs are generated unless the user explicitly skips them in Step 1.3.

| Id             | Output                 | Description                            |
|----------------|------------------------|----------------------------------------|
| overview       | overview.md            | project description, doc index         |
| architecture   | architecture.md        | system design, flows, observability    |
| concepts       | concepts.md            | domain glossary                        |
| repo           | repo/structure.md      | folder layout, key directories         |
|                | repo/tooling.md        | eslint, prettier, husky, tsconfig      |
|                | repo/local-setup.md    | how to run locally, docker, services   |
|                | repo/cicd.md           | pipelines, deploy, secrets, branches   |
|                | repo/infrastructure.md | cloud services, terraform, IaC         |
| features       | features/              | one doc per business capability        |
| db             | db.md                  | data model, migrations, caching        |
| rules          | rules.md               | principles, conventions, anti-patterns |
| integrations   | integrations.md        | 3rd party service integrations         |
| testing        | testing.md             | test frameworks, patterns, coverage    |
| guides         | guides/                | how-to docs, recipes                   |
| pkg-overview   | packages/{pkg}/overview| package entry point, stack, purpose    |

## Temp Files

All progress is tracked in `.docs-state.tmp` (single file, no folder needed).

After `Step 1.4` (header only, before agents):
```
phase: 1
type: monorepo
packages: apps/api,apps/web,packages/infra
docs: overview,architecture,concepts,repo,db,rules,integrations,testing,guides,features,pkg-overview
```

After `Step 2.2` (preview appended, phase updated to 2):
```
phase: 2
type: monorepo
packages: apps/api,apps/web,packages/infra
docs: overview,architecture,concepts,repo,db,rules,integrations,testing,guides,features,pkg-overview

--- PREVIEW ---

overview.md:
  - project: My App - description here
  - related repos: repo-a, repo-b
  - doc index: 12 files across docs/

features/auth.md:
  - email/password + Google OAuth
  - JWT with refresh rotation
  - role-based: guest, host, admin

...etc
```

The phase stays at 2 until docs are fully generated. There is no `phase: 3` - when the user picks "generate", we go straight to Phase 3 without updating the phase. If interrupted during generation, resume will show the preview menu again so the user can re-trigger.
