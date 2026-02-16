```
┌──────────────┐    ┌──────────────┐    ┌─────────────────────────────┐    ┌──────────────┐
│ PHASE 0      │    │ PHASE 1      │    │ PHASE 2                     │    │ PHASE 3      │
│ Resume       │    │ Discovery    │    │ Preview Loop                │    │ Generate     │
│              │    │              │    │                             │    │              │
│ read .tmp    │───>│ WebSearch +  │───>│ show doc list to user       │───>│ write docs/  │
│ resume or    │    │ agents find  │    │ menu: adjust / generate     │    │ align-docs   │
│ start fresh  │    │ subtopics    │    │      <loop until "go">      │    │ cleanup      │
└──────────────┘    └──────────────┘    └─────────────────────────────┘    └──────────────┘
```

## Arguments

<!--@claude,codex-->
- $ARGUMENTS: The topic to research (e.g., "gcloud cli", "docker", "kubernetes")
<!--@gemini-->
- {{args}}: The topic to research (e.g., "gcloud cli", "docker", "kubernetes")
<!--@end-->

## Output Structure

```
docs/research/{topic-name}/
├── 1-overview.md        - what it is, installation, core concepts
├── 2-{subtopic}.md      - main functionality/commands
├── 3-{subtopic}.md      - common use cases/examples
├── 4-{subtopic}.md      - advanced topics (optional)
└── 5-best-practices.md  - best practices, tips, sources
```

Subtopic names are discovered in Phase 1 based on the topic. For example:
- "docker" → 2-containers.md, 3-images.md, 4-compose.md
- "gcloud cli" → 2-commands.md, 3-services.md, 4-iam.md

## Temp File

All progress is tracked in `.research-state.tmp`.

After Phase 1 (discovery):
```
phase: 2
topic: docker
folder: docs/research/docker
docs: 1-overview.md,2-containers.md,3-images.md,4-compose.md,5-best-practices.md
```

After Phase 2 adjustments (preview updated):
```
phase: 2
topic: docker
folder: docs/research/docker
docs: 1-overview.md,2-containers.md,3-images.md,4-networking.md,5-best-practices.md

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
