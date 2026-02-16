
## Phase 1 - Discovery

### Step 1.1 - Parse Topic

Convert the argument to kebab-case for the folder name:
- "gcloud cli" → "gcloud-cli"
- "Docker" → "docker"
- "Kubernetes basics" → "kubernetes-basics"

### Step 1.2 - Launch Discovery Agents

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

### Step 1.3 - Build Doc List

Combine agent results and build a numbered doc list:

Fixed files (always present):
- `1-overview.md` - What it is, installation, core concepts
- `5-best-practices.md` - Best practices, tips, troubleshooting, sources

Dynamic files (from discovery):
- `2-{subtopic}.md` - Main functionality (most important subtopic)
- `3-{subtopic}.md` - Secondary topic (use cases, examples)
- `4-{subtopic}.md` - Advanced topic (optional, only if relevant)

Name files as kebab-case nouns (e.g., `2-commands.md`, `3-networking.md`).

### Step 1.4 - Save State

Write `.research-state.tmp`:
```
phase: 2
topic: {original topic}
folder: docs/research/{kebab-case-topic}
docs: {comma-separated list of files}
```

Proceed to `## Phase 2`.
