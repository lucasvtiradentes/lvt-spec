```
┌──────────────┐    ┌──────────────┐    ┌─────────────────────────────┐    ┌──────────────┐
│ PHASE 0      │    │ PHASE 1      │    │ PHASE 2                     │    │ PHASE 3      │
│ Route        │    │ Discovery    │    │ Preview Loop                │    │ Generate     │
│              │    │              │    │                             │    │              │
│ .tmp exists? │───>│ WebSearch +  │───>│ show doc list to user       │───>│ write docs/  │
│ folder exists│    │ agents find  │    │ menu: adjust / generate     │    │ align-docs   │
│ or new topic │    │ subtopics    │    │      <loop until "go">      │    │ cleanup      │
└──────┬───────┘    └──────────────┘    └─────────────────────────────┘    └──────────────┘
       │
       │ (if folder exists)
       v
┌─────────────────────────────────┐
│ PHASE 4                         │
│ Iterate                         │
│                                 │
│ show current docs               │
│ menu: update / exit             │
│ user describes changes          │
│ agents update → align-docs      │
└─────────────────────────────────┘
```

## Arguments

<!--@claude,codex-->
- $ARGUMENTS: The topic to research (e.g., "gcloud cli", "docker", "kubernetes")
<!--@gemini-->
- {{args}}: The topic to research (e.g., "gcloud cli", "docker", "kubernetes")
<!--@end-->

## Output Structure

The number of files is variable based on what discovery agents find. Typical range: 5-8 files.

```
docs/research/{topic-name}/
├── 1-overview.md              - always: what it is, installation, core concepts
├── 2-{subtopic}.md            - discovered: main functionality area
├── 3-{subtopic}.md            - discovered: secondary topic
├── ...                        - discovered: additional topics as needed
├── {N-1}-best-practices.md    - always: best practices, tips, troubleshooting
└── {N}-references.md          - always last: sources, URLs, further reading
```

Examples of discovered structures:

```
docker/                          gcloud-cli/                     kubernetes/
├── 1-overview.md                ├── 1-overview.md               ├── 1-overview.md
├── 2-containers.md              ├── 2-core-commands.md          ├── 2-architecture.md
├── 3-images.md                  ├── 3-compute.md                ├── 3-workloads.md
├── 4-compose.md                 ├── 4-storage.md                ├── 4-networking.md
├── 5-networking.md              ├── 5-iam.md                    ├── 5-configuration.md
├── 6-best-practices.md          ├── 6-best-practices.md         ├── 6-scaling.md
└── 7-references.md              └── 7-references.md             ├── 7-best-practices.md
                                                                  └── 8-references.md
```

## Temp File

All progress is tracked in `.research-state.tmp`.

After Phase 1 Step 1.2 (before agents):
```
phase: 1
topic: docker
folder: docs/research/docker
```

After Phase 1 Step 1.5 (discovery complete):
```
phase: 2
topic: docker
folder: docs/research/docker
docs: 1-overview.md,2-containers.md,3-images.md,4-compose.md,5-networking.md,6-best-practices.md,7-references.md
```

After Phase 2 (preview added):
```
phase: 2
topic: docker
folder: docs/research/docker
docs: 1-overview.md,2-containers.md,3-images.md,4-compose.md,5-networking.md,6-best-practices.md,7-references.md

--- PREVIEW ---

1-overview.md:
  - what is Docker, containerization basics
  - installation on Linux/Mac/Windows
  - core concepts: images, containers, volumes, networks

2-containers.md:
  - container lifecycle: create, start, stop, remove
  - docker run flags and options
  - exec, logs, inspect commands

...
```
