
---

## Reference

### Doc Specs

Per-doc scanning and preview instructions. Used by Phase 2 (discovery outlines) and Phase 3 (full generation).

Preview notes:
- Preview is PER-FILE with bullet points (3-8 bullets per doc in Phase 2)
- Lines starting with `>` are metadata hints (related docs/sources) so Phase 3 can write metadata without re-scanning

```
overview → docs/overview.md:
  scan: Read README.md, package.json, top-level config files
  preview:
    - project: {name} - {description}
    - related repos: {repo-a}, {repo-b}
    - doc index: {N} files across docs/

architecture → docs/architecture.md:
  scan:
    - Grep for entry points, route definitions, main exports, API calls between parts
    - Identify diagrammable flows: request lifecycle, data pipelines, auth flow, event/message flows
    - Scan for observability (logging, tracing, monitoring, error tracking)
    - Generation: aim for 3-6 ASCII diagrams
  preview:
    - entry: {entry point} → {main flow}
    - diagrams: request lifecycle, data flow, auth flow, {other flows}
    - data flow: {part} → {part} → {part}
    - observability: {logging framework}, {tracing}, {monitoring}

concepts → docs/concepts.md:
  scan: Grep for type definitions, interfaces, enums, DB models. Document domain entities, relationships, business rules.
  preview:
    - {concept}: {1-line description}
    - {concept}: {1-line description}
    - {concept}: {1-line description}

repo → docs/repo/*.md:
  scan:
    - structure.md: Glob folder structure, identify directory organization
    - tooling.md: scan tooling configs (eslint, prettier, husky), read tsconfig, docker-compose
    - local-setup.md: read docker-compose, .env.example, package.json scripts, Makefile
    - cicd.md: read .github/workflows/, CI config, Grep for deploy scripts
    - infrastructure.md: scan for cloud services (Cloud Run, GCS, Pub/Sub, Lambda, S3), terraform/IaC configs
    - MONOREPO: distinguish root vs part-specific tooling
  preview:
    repo/:
      structure.md:
        - {key dirs and what they contain}
      tooling.md:
        - {eslint (root + api), prettier (root only), husky, lint-staged, ...}
        - env vars: {VAR_1}, {VAR_2}, {VAR_3} (+ {N} more)
      local-setup.md:
        - services: {service}:{port}, {service}:{port}
        - {key steps to run locally}
      cicd.md:
        - pipelines: {pipeline 1}, {pipeline 2}
        - deploy: {environments and targets}
        - secrets: {required secrets}
        - branch strategy: {strategy description}
      infrastructure.md:
        - cloud services: {service}: {purpose}, {service}: {purpose}
        - IaC: {terraform/pulumi/cdk}, {key resources}
        - deployment targets: {environments and platforms}

db → docs/db.md | monorepo: docs/parts/{part}/db.md (per-part, skip parts without DB):
  scan: Grep for DB schemas, ORM models, migrations, seeds. Read DB config, scan for caching layer.
  preview:
    - entities: {entity1}, {entity2}, {entity3} (+ {N} more)
    - key relationships: {entity} → {entity}, {entity} → {entity}
    - config: {pooling, replicas, timeouts}
    - migrations: {count} migrations, {strategy}
    - seeds: {how seeding works}
    - caching: {redis/in-memory, strategy}
    - patterns: {soft deletes, views, indexes, etc.}

rules → docs/rules.md | monorepo: docs/parts/{part}/rules.md (per-part):
  scan: Grep for conventions docs, coding patterns. Sections: principles, conventions, anti-patterns.
  preview:
    - principles: {principle 1}, {principle 2}
    - conventions: {convention 1}, {convention 2}
    - anti-patterns: {anti-pattern 1}, {anti-pattern 2}

integrations → docs/integrations.md | monorepo: docs/parts/{part}/integrations.md (per-part):
  scan: Scan for 3rd party service integrations (payment, email, SMS, storage, search, auth, PMS)
  preview:
    - {service}: {purpose} ({N} integrations total)
    - {service}: {purpose}

testing → docs/testing.md | monorepo: docs/parts/{part}/testing.md (per-part):
  scan: Scan test files, frameworks, patterns, test locations, coverage config
  preview:
    - framework: {jest/playwright/vitest}
    - patterns: {unit, functional, e2e}
    - locations: {test dirs}

guides → docs/guides/*.md | monorepo: docs/parts/{part}/guides/*.md (per-part):
  scan: Scan for repetitive patterns, existing docs/READMEs
  preview:
    guides/{topic}.md:
      - {bullet 1}
      - {bullet 2}
      - {bullet 3}

features → docs/features/*.md:
  scan: Read route definitions, page components, CLI commands, API endpoints
  preview:
    features/{feature-name}.md:
      - {bullet 1}
      - {bullet 2}
      - {bullet 3}

parts-overview (monorepo only) → docs/parts/{part}/overview.md:
  scan: Read package.json per part, scan entry points, identify stack and patterns
  preview:
    parts/{name}/:
      overview.md:
        - {what it does}, entry: {file}
        - stack: {part-specific stack}

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
- Generate all docs unless the user skipped them in Step 1.3
- The preview in `.docs-state.tmp` is the SOURCE OF TRUTH for `## Phase 3` - only generate what's in the preview
- Phase 2 uses 3 Explore agents (compact outlines returned via TaskOutput). Phase 3 is delegated to a SINGLE orchestrator subagent that internally launches up to 12 generation agents. The main agent NEVER launches 12 agents directly.
- Step 2.2 is done by the MAIN agent (combines 3 agent results into .docs-state.tmp).
