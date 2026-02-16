---
name: research-topic
description: Research a topic and create structured documentation, or iterate on existing research. Use when the user wants to learn about a technology, tool, or concept. Pass a topic name for new research or a folder path to update existing.
---

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

- $ARGUMENTS: The topic to research (e.g., "gcloud cli", "docker", "kubernetes")

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

## Phase 0 - Route

Determine which phase to enter based on the argument.

### Step 0.1 - Check if argument is existing folder

If the argument is a path to an existing `docs/research/{topic}/` folder:
- Proceed to `## Phase 4` (iterate over existing research)

### Step 0.2 - Check for .tmp file

If `.research-state.tmp` exists in the project root:
- Ask the user: "Found existing research session for '{topic}'. Resume or start fresh?"
  - options: "Resume" (Recommended), "Start fresh (delete state)"
- If resume: read phase from file
  - If `phase: 1` → jump to `Step 1.3` (re-run discovery agents)
  - If `phase: 2` and NO preview → jump to `Step 2.1` (build preview)
  - If `phase: 2` and HAS preview → jump to `Step 2.2` (show preview + menu)
- If fresh: delete `.research-state.tmp`, proceed to `## Phase 1`

### Step 0.3 - New topic

If neither folder nor .tmp exists:
- Proceed to `## Phase 1`

## Phase 1 - Discovery

### Step 1.1 - Parse Topic

Convert the argument to kebab-case for the folder name:
- "gcloud cli" → "gcloud-cli"
- "Docker" → "docker"
- "Kubernetes basics" → "kubernetes-basics"

### Step 1.2 - Save Initial State

Write `.research-state.tmp` BEFORE launching agents (so we can resume if agents fail):
```
phase: 1
topic: {original topic}
folder: docs/research/{kebab-case-topic}
```

### Step 1.3 - Launch Discovery Agents

Launch 2 agents in PARALLEL to discover relevant subtopics.

Agent 1 - Official Sources:
- WebSearch for "{topic} official documentation 2026"
- WebSearch for "{topic} getting started guide"
- Identify: main concepts, installation steps, core features

Agent 2 - Community Sources:
- WebSearch for "{topic} tutorial 2026"
- WebSearch for "{topic} best practices"
- WebSearch for "{topic} common use cases examples"
- Identify: practical subtopics, common patterns, tips

Each agent returns a bullet list of discovered subtopics with 1-line descriptions.

Wait for both agents to complete.

### Step 1.4 - Build Doc List

Combine agent results and build a numbered doc list. Typical range: 5-8 files.

Fixed positions:
- `1-overview.md` - always first: what it is, installation, core concepts
- `{N-1}-best-practices.md` - always second-to-last: best practices, tips, troubleshooting
- `{N}-references.md` - always last: sources, URLs, further reading

Discovered files (variable count):
- `2-{subtopic}.md` through `{N-2}-{subtopic}.md` - based on discovery results
- Group related concepts into single files
- Name files as kebab-case nouns (e.g., `2-commands.md`, `3-networking.md`)
- Aim for 3-6 subtopic files depending on topic complexity

### Step 1.5 - Update State

Update `.research-state.tmp` with discovered docs:
```
phase: 2
topic: {original topic}
folder: docs/research/{kebab-case-topic}
docs: {comma-separated list of files}
```

Proceed to `## Phase 2`.

## Phase 2 - Preview Loop

### Step 2.1 - Build Preview

If no preview exists yet in `.research-state.tmp`, launch a single agent to build preview outlines.

The agent receives:
- The topic and doc list from `.research-state.tmp`
- Instruction to WebSearch for each doc and return 3-5 bullet points per file

Agent returns preview in this format:
```
1-overview.md:
  - bullet 1
  - bullet 2
  - bullet 3

2-{subtopic}.md:
  - bullet 1
  - bullet 2
  - bullet 3

...
```

Append preview to `.research-state.tmp` after `--- PREVIEW ---`.

### Step 2.2 - Show Preview

Read `.research-state.tmp` and display to the user:

```
Research: {topic}
Output: {folder}

Docs to generate:
{numbered list of docs with bullet previews}

What's next?
1. adjust   - add, remove, or change docs
2. generate - looks good, create the docs
```

### Step 2.3 - Interactive Menu

CRITICAL: After displaying the menu you MUST STOP and produce NO further output. Do NOT pick an option. The NEXT message MUST come from the USER.

User can type "1" or "2", or add details: "1, add a section about security", "1, remove the advanced topic".

Option 1 - adjust:
- User provides changes (add doc, remove doc, rename, change scope)
- Apply changes to the doc list and preview in `.research-state.tmp`
- Return to `Step 2.2` (show updated preview + menu)

Option 2 - generate:
- Proceed to `## Phase 3`

## Phase 3 - Generate

### Step 3.1 - Create Folder

Create the output folder from `.research-state.tmp`:
```bash
mkdir -p {folder}
```

### Step 3.2 - Launch Generation Agents

Launch one agent per doc file in PARALLEL.

Each agent receives:
- The topic
- The preview bullets for its doc
- The Doc Specs from `## Reference` section
- Instruction to WebSearch for detailed content and write the file

Doc writing rules (include in every agent prompt):
- Follow `docs/doc-style.md` formatting rules
- Use tables for commands/options/flags
- Include code examples with proper syntax highlighting
- Keep explanations concise, no fluff
- Write in English
- No bold text, no emojis
- The `references.md` file collects ALL URLs used across all docs during research

Wait for all agents to complete.

### Step 3.3 - Align Docs

Run align-docs on the generated folder. Re-run until clean.
Use `$align-docs {folder}`.

### Step 3.4 - Cleanup

1. Delete `.research-state.tmp`
2. Show the folder structure created:

```
{folder}/
├── 1-overview.md
├── 2-{subtopic}.md
├── 3-{subtopic}.md
├── ...
├── {N-1}-best-practices.md
└── {N}-references.md

Done! Generated {N} files. Review and adjust as needed.
```

## Reference

### Doc Specs

Per-doc content guidelines. Used by Phase 2 (preview outlines) and Phase 3 (full generation).

```
1-overview.md (always first):
  content:
    - What is {topic}? 1-2 sentence definition
    - Why use it? Key benefits
    - Installation steps for major platforms
    - Core concepts/terminology table
    - Architecture overview (if applicable)
  preview:
    - definition: {1-line what it is}
    - benefits: {key benefits}
    - install: {platforms supported}
    - concepts: {concept1}, {concept2}, {concept3}

2 to {N-2} (discovered subtopics):
  content:
    - Commands/API table with syntax and description
    - Code examples with proper syntax highlighting
    - Common flags/options table
    - Gotchas and edge cases
  preview:
    - {main concept}: {1-line description}
    - commands: {cmd1}, {cmd2}, {cmd3}
    - examples: {example scenarios}

{N-1}-best-practices.md (always second-to-last):
  content:
    - Best practices list (do's)
    - Common mistakes (don'ts)
    - Performance tips
    - Security considerations
    - Troubleshooting common issues
  preview:
    - practices: {practice1}, {practice2}
    - avoid: {mistake1}, {mistake2}
    - tips: {tip1}, {tip2}

{N}-references.md (always last):
  content:
    - Official documentation links
    - Tutorials and guides used
    - Community resources
    - Further reading
    - Related tools/projects
  preview:
    - official: {N} docs
    - tutorials: {N} guides
    - related: {tool1}, {tool2}
```

### Content Format

Follow `docs/doc-style.md` for all files. Key rules:

- Use tables for commands, flags, options, comparisons
- Include code blocks with proper language tags
- No bold text, no emojis
- Keep explanations concise
- Align table columns and list descriptions

Command tables:
```md
| Command          | Description                    |
|------------------|--------------------------------|
| `docker run`     | Create and start a container   |
| `docker build`   | Build an image from Dockerfile |
```

Flag tables:
```md
| Flag        | Short | Description              |
|-------------|-------|--------------------------|
| `--detach`  | `-d`  | Run in background        |
| `--publish` | `-p`  | Map port host:container  |
```

### References Format

The `{N}-references.md` file lists all sources used during research:

```md
# References

## Official Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Docker CLI Reference](https://docs.docker.com/engine/reference/commandline/cli/)

## Tutorials and Guides

- [Getting Started with Docker](https://docs.docker.com/get-started/)
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## Related Tools

- [Docker Compose](https://docs.docker.com/compose/)
- [Podman](https://podman.io/) - Docker alternative
```

Include all URLs used during research. Prefer official docs over blog posts.

---

## Important Rules

- Discovery agents determine the number and names of subtopic files
- The user can add/remove/rename files during Phase 2 adjust loop
- `1-overview.md` is always first
- `{N-1}-best-practices.md` is always second-to-last
- `{N}-references.md` is always last
- Preview in `.research-state.tmp` is the SOURCE OF TRUTH for Phase 3
- Each generation agent writes ONE file and does its own WebSearch for detailed content
- Phase 4 allows iterating on existing research without starting over
- When adding new files in Phase 4, renumber subsequent files to maintain order

## Phase 4 - Iterate

Continue or improve an existing research.

### Step 4.1 - Read Current Docs

Read all markdown files in the provided folder and build a summary:
- List files with their h1 titles
- Count total lines/sections per file

### Step 4.2 - Show Current Structure

Display to the user:

```
Existing research: {folder}

Files:
├── 1-overview.md         - {h1 title}
├── 2-{subtopic}.md       - {h1 title}
├── ...
├── {N-1}-best-practices.md
└── {N}-references.md

What's next?
1. update - describe what you want to change
2. exit   - done, no changes
```

### Step 4.3 - Interactive Menu

CRITICAL: After displaying the menu you MUST STOP and produce NO further output. The NEXT message MUST come from the USER.

Option 1 - update:
- User describes what they want in free text:
  - "add a section about security"
  - "deep dive into networking"
  - "update the installation steps for v2"
  - "add new file about plugins"
  - "fix the table alignment in overview"
- Proceed to `Step 4.4`

Option 2 - exit:
- Stop, no changes made

### Step 4.4 - Execute Update

Based on user description, launch agent(s) to:

Possible actions:
- **Add content** - WebSearch + append/modify existing file
- **Add new file** - WebSearch + create new numbered file, renumber if needed
- **Update existing** - WebSearch for fresh info + modify file
- **Fix formatting** - Read file + apply fixes

Each agent receives:
- The user's request
- The current file content (if modifying)
- The Doc Specs from `## Reference`
- The existing `references.md` content as context (sources already consulted)
- Instruction to:
  - Use existing sources as starting point, NOT as limit
  - WebSearch for new/updated information beyond existing sources
  - Add any new sources used to `references.md`

### Step 4.5 - Align and Show Result

1. Run align-docs on the folder
   Use `$align-docs {folder}`.

2. Show what changed:
```
Updated: {list of modified/added files}
```

3. Return to `Step 4.2` (show structure + menu again)
