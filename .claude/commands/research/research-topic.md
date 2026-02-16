# Topic

Research a topic and create structured documentation. Use when the user wants to learn about a technology, tool, or concept. Creates docs/research/{topic}/ with numbered markdown files.

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

- $ARGUMENTS: The topic to research (e.g., "gcloud cli", "docker", "kubernetes")

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

## Phase 0 - Resume Check

1. Check if `.research-state.tmp` exists in the project root
2. If it EXISTS:
   - Use `AskUserQuestion` to ask:
     - question: "Found existing research session for '{topic}'. Resume or start fresh?"
     - options:
       - "Resume" (Recommended)
       - "Start fresh (delete state)"
   - If resume: read phase from file
     - If `phase: 1` → jump to `Step 1.3` (re-run discovery agents)
     - If `phase: 2` and NO preview → jump to `Step 2.1` (build preview)
     - If `phase: 2` and HAS preview → jump to `Step 2.2` (show preview + menu)
   - If fresh: delete `.research-state.tmp`, proceed to `## Phase 1`
3. If it does NOT exist:
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
Use `Task` with `subagent_type: "general-purpose"` and `run_in_background: true` for each agent.

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
Use `TaskOutput(block=true)` to wait for each agent.

### Step 1.4 - Build Doc List

Combine agent results and build a numbered doc list:

Fixed files (always present):
- `1-overview.md` - What it is, installation, core concepts
- `5-best-practices.md` - Best practices, tips, troubleshooting, sources

Dynamic files (from discovery):
- `2-{subtopic}.md` - Main functionality (most important subtopic)
- `3-{subtopic}.md` - Secondary topic (use cases, examples)
- `4-{subtopic}.md` - Advanced topic (optional, only if relevant)

Name files as kebab-case nouns (e.g., `2-commands.md`, `3-networking.md`).

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
Use `Task` with `subagent_type: "general-purpose"`.

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
Use `Task` with `subagent_type: "general-purpose"` and `run_in_background: true` for each agent.

Each agent receives:
- The topic
- The preview bullets for its doc
- The doc writing rules (see below)
- Instruction to WebSearch for detailed content and write the file

Doc writing rules:
- Follow `docs/doc-style.md` formatting rules
- Use tables for commands/options/flags
- Include code examples with proper syntax highlighting
- Keep explanations concise, no fluff
- Write in English
- No bold text, no emojis
- `5-best-practices.md` MUST end with a Sources section listing URLs used

Wait for all agents to complete.
Use `TaskOutput(block=true)` to wait for each agent.

### Step 3.3 - Align Docs

Run align-docs on the generated folder. Re-run until clean.
Use `/docs:align-docs {folder}`.

### Step 3.4 - Cleanup

1. Delete `.research-state.tmp`
2. Show the folder structure created:

```
{folder}/
├── 1-overview.md
├── 2-{subtopic}.md
├── 3-{subtopic}.md
├── 4-{subtopic}.md (if generated)
└── 5-best-practices.md

Done! Generated {N} files. Review and adjust as needed.
```
