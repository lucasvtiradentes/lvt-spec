# Best Practices

## Do This

- Define scope in one sentence before each run
- Include acceptance criteria in prompt (tests, files, behavior)
- Prefer incremental edits over large one-shot rewrites
- Commit often so rollback is cheap
- Validate with `test`, `lint`, and minimal manual checks

## Avoid This

| Anti-pattern                  | Why It Fails                | Better Approach                                 |
|-------------------------------|-----------------------------|-------------------------------------------------|
| Vague prompts                 | Unstable output, scope drift| Specify files, constraints, and success criteria|
| Full-auto in unprepared repo  | Hard-to-review broad changes| Use approval mode and small batches             |
| Skipping verification         | Hidden regressions          | Always run project checks before closing        |
| Editing without policy context| Rule violations and churn   | Read AGENTS.md first                            |

## Preventing Common Problems

| Risk                             | Prevention                                              |
|----------------------------------|---------------------------------------------------------|
| Secret exposure                  | Never paste credentials; use env vars and secret tooling|
| Destructive commands             | Keep sandbox/approval enabled for normal work           |
| Context drift in long tasks      | Re-anchor every few turns with explicit goals           |
| Broken state after failed command| Retry with smaller scope and clear fallback             |

## Troubleshooting Playbook

### Session seems stuck

1. Interrupt with `Ctrl-C`
2. Resume with `codex resume --last`
3. Restate task in smaller chunks

### Bad patch output

1. Inspect diff carefully
2. Re-run with tighter constraints
3. Apply only verified hunks and test

### Permission blockers

1. Confirm sandbox mode and approval policy
2. Grant only the minimum required escalation
3. Re-run the specific blocked step

## Reliability and Performance Tips

- Keep prompts concrete and file-targeted
- Use profiles for stable per-project defaults
- Use MCP only where external context is genuinely needed
- Prefer deterministic scripts for repetitive post-processing
