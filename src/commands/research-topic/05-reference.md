
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
<!--@claude-->
- Phase 1 agents: `Task` with `subagent_type: "general-purpose"`, `run_in_background: true`
- Phase 3 agents: `Task` with `subagent_type: "general-purpose"`, `run_in_background: true`, one per file
- Phase 4 agents: `Task` with `subagent_type: "general-purpose"`, targeted updates
<!--@end-->
