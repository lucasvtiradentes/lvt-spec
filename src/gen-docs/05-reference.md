
---

## Reference

### Single Repo vs Monorepo

| Output           | Single Repo                            | Monorepo                               |
|------------------|----------------------------------------|----------------------------------------|
| overview.md      | yes                                    | yes                                    |
| architecture.md  | yes (includes observability + infra)   | yes (includes observability + infra)   |
| repo.md          | yes                                    | yes                                    |
| concepts.md      | skippable                              | skippable                              |
| db.md            | skippable                              | skippable                              |
| cicd.md          | skippable                              | skippable                              |
| rules.md         | skippable                              | skippable                              |
| guides/          | skippable                              | skippable (part guides live in parts/) |
| features/        | skippable                              | skippable                              |
| integrations.md  | skippable                              | skippable                              |
| parts/           | N/A                                    | skippable (overview + rules + guides)  |
| problems/        | skippable                              | skippable                              |

### Preview Format

The preview is PER-FILE with bullet points. Each file entry should ALSO include related docs and sources when known (lines starting with `>` are metadata hints so Phase 3 can write metadata without re-scanning).

```
--- PREVIEW ---

overview.md:
  - project: {name} - {description}
  - related repos: {repo-a}, {repo-b}
  - doc index: {N} files across docs/

architecture.md:
  - entry: {entry point} → {main flow}
  - diagrams: request lifecycle, data flow, deploy topology, {other identified flows}
  - data flow: {part} → {part} → {part}
  - deployment: {how/where deployed}
  - observability: {logging framework}, {tracing}, {monitoring}
  - cloud/infra: {service}: {purpose}, {service}: {purpose}

concepts.md:
  - {concept}: {1-line description}
  - {concept}: {1-line description}
  - {concept}: {1-line description}

repo.md:
  - stack: {language}, {framework}, {ORM}, {DB}
  - folder structure: {key dirs and what they contain}
  - tooling: {eslint (root + api), prettier (root only), husky, lint-staged, ...}
  - scripts: {available commands from Makefile/package.json}
  - env vars: {VAR_1}, {VAR_2}, {VAR_3} (+ {N} more)
  - services: {service}:{port}, {service}:{port}
  - setup: {key steps to run locally}

db.md:
  - entities: {entity1}, {entity2}, {entity3} (+ {N} more)
  - key relationships: {entity} → {entity}, {entity} → {entity}
  - config: {pooling, replicas, timeouts}
  - migrations: {count} migrations, {strategy}
  - seeds: {how seeding works}
  - caching: {redis/in-memory, strategy}
  - patterns: {soft deletes, views, indexes, etc.}

cicd.md:
  - pipelines: {pipeline 1}, {pipeline 2}
  - deploy: {environments and targets}
  - secrets: {required secrets}
  - branch strategy: {strategy description}

rules.md:
  - principles: {principle 1}, {principle 2}
  - conventions: {convention 1}, {convention 2}
  - anti-patterns: {anti-pattern 1}, {anti-pattern 2}

guides/{topic}.md:
  - {bullet 1}
  - {bullet 2}
  - {bullet 3}

features/{feature-name}.md:
  - {bullet 1}
  - {bullet 2}
  - {bullet 3}

integrations.md:
  - {service}: {purpose} ({N} integrations total)
  - {service}: {purpose}

parts/{name}/:                          (monorepo only)
  overview.md:
    - {what it does}, entry: {file}
    - stack: {part-specific stack}
  rules.md:
    - {part-specific rules that override/extend root}
  guides/{topic}.md:
    - {bullet 1}
    - {bullet 2}

problems/:
  - (empty on first gen - grows over time as problems are solved)

(metadata hints example)
features/booking.md:
  - availability check → hold → payment → confirm
  - cancellation policies: flexible, moderate, strict
  > related docs: concepts.md, features/auth.md, parts/api/overview.md
  > related sources: src/features/booking/, src/models/booking.model.ts, src/routes/booking.routes.ts
```

### Metadata Format

Appended at the bottom of every generated .md file:

```md
---

related docs:
- docs/concepts.md - booking entity definition, states
- docs/features/auth.md - user must be authenticated to book
- docs/parts/api/overview.md - booking endpoints live here

related sources:
- src/features/booking/ - booking module root
- src/features/booking/service.ts - core booking logic
- src/models/booking.model.ts - DB model
- src/routes/booking.routes.ts - API endpoints
- tests/booking/ - booking tests
```

Rules:
- related docs: other docs in docs/ that THIS doc depends on (unidirectional, no back-links)
- related sources: actual codebase files AND folders relevant to this doc's topic
- list folders when the whole directory is relevant, list specific files when only that file matters
- keep it focused: only list things that are directly relevant, not tangentially related
- overview.md does NOT need related docs (it IS the index) but should list key source files/folders

---

## Important Rules

- ALWAYS update `.docs-state.tmp` after completing each sub-step
- If the user interrupts and runs `/gen-docs` again, `## Phase 0` will resume from the last saved state
- Do NOT create files that were not selected in `Step 1.3`
- The preview in `.docs-state.tmp` is the SOURCE OF TRUTH for `## Phase 3` - only generate what's in the preview
- Phase 2 uses 2 Explore agents (compact outlines returned via TaskOutput). Phase 3 is delegated to a SINGLE orchestrator subagent that internally launches up to 12 generation agents. The main agent NEVER launches 12 agents directly.
- Step 2.2 is done by the MAIN agent (combines 2 agent results into .docs-state.tmp).
