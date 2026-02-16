
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
<!--@claude-->
Use `Task` with `subagent_type: "general-purpose"` and `run_in_background: true` for each agent.
<!--@end-->

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
<!--@claude-->
Use `TaskOutput(block=true)` to wait for each agent.
<!--@end-->

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
