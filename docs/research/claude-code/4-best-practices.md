# Claude Code Best Practices

## Do This

### Give precise instructions

- Define scope in one sentence before each run
- Include acceptance criteria in prompt (tests, files, behavior)
- Reference specific files and point to example patterns
- Describe symptoms with likely location and what "fixed" looks like
- Prefer incremental edits over large one-shot rewrites

### Use Plan Mode

- Separate research and planning from implementation
- Enter Plan Mode to read files and explore without making changes
- Ask Claude to create detailed implementation plan before coding
- Press Ctrl+G to edit the plan in your text editor
- Skip planning for simple tasks you can describe in one sentence

### Manage context aggressively

- Run /clear between unrelated tasks to reset context
- Use /compact with instructions to focus summarization
- Track token usage with custom status line
- Create HANDOFF.md files when switching to fresh conversations
- Use subagents for research to keep main context clean

### Use checkpoints

- Every Claude action creates a checkpoint
- Double-tap Escape or run /rewind to restore previous state
- Restore conversation only, code only, or both
- Checkpoints persist across sessions

### Include verification

- Provide tests, screenshots, or expected outputs so Claude can check itself
- Write a failing test first, then have Claude fix it
- Use Playwright MCP or Chrome extension for UI verification
- Run linters and type checkers after code changes

## Avoid This

| Anti-pattern                          | Why It Fails                                  | Better Approach                                             |
|---------------------------------------|-----------------------------------------------|-------------------------------------------------------------|
| Vague prompts                         | Unstable output, scope drift                  | Specify files, constraints, and success criteria            |
| Kitchen sink sessions                 | Context full of irrelevant information        | /clear between unrelated tasks                              |
| Correcting over and over              | Context polluted with failed approaches       | After two corrections, /clear and write better prompt       |
| Over-specified CLAUDE.md              | Important rules get lost in noise             | Prune ruthlessly; keep only what prevents mistakes          |
| Trust-then-verify gap                 | Plausible-looking code with hidden edge cases | Always provide verification before shipping                 |
| Infinite exploration                  | Claude reads hundreds of files filling context| Scope investigations narrowly or use subagents              |
| Full-auto without sandbox             | Risk of data loss, system corruption          | Use /sandbox or container without internet access           |
| Jumping straight to code              | Solves wrong problem                          | Explore and plan first using Plan Mode                      |
| Letting context accumulate            | Performance degrades as context fills         | /clear frequently and start fresh with better prompts       |

## Preventing Common Problems

| Risk                             | Prevention                                                                  |
|----------------------------------|-----------------------------------------------------------------------------|
| Secret exposure                  | Never paste credentials; use env vars and allowlist with /permissions       |
| Context window overflow          | Monitor token usage; use /clear and /compact regularly                      |
| Prompt injection                 | Use --dangerously-skip-permissions only in sandboxed container without net  |
| File system damage               | Enable /sandbox for OS-level isolation; restrict allowedTools in batch ops  |
| Scope creep                      | Define task in one sentence; use subagents for tangential research          |
| Inconsistent code style          | Add code style rules to CLAUDE.md; use hooks for linting after edits        |
| Lost progress on failures        | Create checkpoints before risky changes; use git commits as save points     |
| Rate limiting on GitHub API      | Install gh CLI for authenticated access                                     |
| Bloated CLAUDE.md being ignored  | Keep it short; only include what Claude cannot infer from code              |
| Unverified UI changes            | Use Chrome extension or Playwright MCP to verify visually                   |

## Troubleshooting Playbook

### Session seems stuck

1. Interrupt with Escape key
2. Context is preserved; redirect Claude with new prompt
3. If still stuck, use /rewind to restore previous checkpoint
4. Start fresh with /clear and more specific prompt

### Claude keeps making the same mistake

1. Check if CLAUDE.md has conflicting or ambiguous rules
2. Remove verbose instructions that may be getting lost
3. Run /clear to reset polluted context
4. Write explicit constraint in prompt: "Do NOT do X because Y"

### Context window is full

1. Auto-compaction triggers automatically but may lose details
2. Run /compact with custom instructions to preserve key info
3. Create HANDOFF.md summarizing progress and next steps
4. Start fresh session with claude --continue or --resume

### Claude writes code that looks right but fails

1. Verify you provided testable success criteria
2. Ask Claude to write tests first, then implementation
3. Use subagent to review for edge cases
4. Include error messages and expected behavior in prompt

### Changes broke something elsewhere

1. Run /rewind to restore code checkpoint
2. Use git diff to see all changes
3. Ask Claude to run test suite after each change
4. Break large changes into smaller verified steps

### Claude ignores CLAUDE.md instructions

1. File may be too long; prune to essentials
2. Add emphasis with IMPORTANT or MUST
3. Move critical rules to top of file
4. Convert to hooks for guaranteed execution

### Headless mode fails in CI

1. Check --output-format matches your parser (json or stream-json)
2. Use --allowedTools to restrict permissions for batch operations
3. Add --verbose for debugging, remove in production
4. Verify claude -p prompt returns expected format

### Subagent returns incomplete results

1. Scope the investigation more narrowly
2. Specify exact files or directories to search
3. Provide clear output format requirements
4. Use multiple subagents for different aspects
