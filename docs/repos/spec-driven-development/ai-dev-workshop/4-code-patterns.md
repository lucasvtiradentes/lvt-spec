# AI Dev Workshop - Code Patterns

## Language and Style

All prompts are written in Brazilian Portuguese. Some files mix Portuguese and English (section headers, code examples, technical terms remain in English).

Markdown formatting conventions:
- Consistent `##` and `###` heading hierarchy
- Heavy use of markdown tables with aligned columns
- Code fences for templates, examples, and output formats
- Mermaid diagrams for workflow visualization

## Prompt Engineering Patterns

### Role Assignment

Every agent and command starts with an explicit role declaration:

```
Voce e um revisor de codigo especialista...
Voce e um engenheiro de testes focado em...
Voce e um arquiteto de documentacao tecnica...
```

### Structured Phased Workflows

Nearly all commands follow a multi-phase pattern:

1. Phase 1: Discovery/Analysis - read, scan, understand
2. Phase 2: Discussion/Validation - ask questions, iterate with user
3. Phase 3: Generation/Output - produce artifacts

### Template-Driven Output

Every command includes a full markdown template showing the exact expected output format, embedded in the prompt using code fences. Examples include code review reports with traffic-light severity, ADR templates, test coverage reports, and documentation proposals.

### Explicit Pause/Gate

Several commands contain explicit STOP instructions to wait for user approval:

```
IMPORTANT: Neste momento, PARE e espere a aprovacao expressa do usuario
```

### `#$ARGUMENTS` Placeholder

Commands accept dynamic input via `#$ARGUMENTS` placeholders wrapped in XML-like tags:

```xml
<arguments>
#$ARGUMENTS
</arguments>
```

### Anti-Pattern Sections

Multiple agents include explicit "do not do this" sections (negative-example prompting):
- Code reviewer:  "Do not nitpick style when functionality is correct"
- Test engineer:  "Do not modify code to make tests pass"
- Research agent: "Single-source claims not supported elsewhere"

### Confidence/Uncertainty Signals

The research-agent explicitly reports confidence levels (High/Medium/Low), distinguishes verified vs. unverified information, and flags information gaps.

### Quality Assurance Checklists

Metaspec generation commands include markdown checkbox lists for content accuracy, AI optimization, and completeness validation.

## Python Conventions

From the `python-developer` agent:

- PEP 8 compliance
- Type hints mandatory
- `uv` for dependency management (not pip/poetry)
- `loguru` for logging
- Composition over inheritance
- Standard library first, third-party sparingly
- References external instruction files: `python.md`, `ai_prompter.md`, `esperanto.md`, `surrealdb.md`

## React/TypeScript Conventions

From the `react-developer` agent:

- TypeScript with strict typing
- shadcn/ui + Radix UI primitives
- Tailwind CSS for styling
- Component-first architecture, small/focused/reusable
- React Hook Form + Zod for forms/validation
- `useState` local-first, then Context/Zustand/Redux
- React Testing Library (not implementation-detail testing)

## Testing Approach

### Test Planning

Agents: `test-planner` (full codebase) and `branch-test-planner` (branch-scoped)

- Systematic scan to map tested vs. untested functionality
- Gap analysis identifying critical paths without coverage
- Output: `test_report.md` or `test_coverage_branch_report.md`
- Prioritization by business impact and risk

### Test Engineering

Agent: `test-engineer`

- AAA pattern (Arrange/Act/Assert)
- Naming: `test_function_name_with_condition_returns_expected_result`
- Priority: Happy path > Edge cases > Error conditions
- Framework: `pytest` with `unittest.mock` for mocking
- Run: `uv run pytest test_filename.py -v`
- Key rule: test code as-is, never modify implementation to fit tests
- Flag-not-fix: report implementation problems to main agent rather than working around them

### Code Review

Agents: `code-reviewer` (opus, full codebase) and `branch-code-reviewer` (opus, branch-scoped)

- Traffic-light severity system: green / yellow / red
- Priority: correctness > security > clarity > adequacy
- Focus on real-world impact, not theoretical perfection
- Start reviews with what works well
- Distinguish must-fix from nice-to-have

## CI/CD

No CI/CD configuration files exist (no `.github/workflows/`). The PR workflow command (`/pr`) defines a manual CI/CD-like process:

1. Run all tests, fix failures
2. Commit changes with clear message
3. Move Linear card to "In Review"
4. Open PR (no mention of AI/Claude)
5. Wait for automated review comments (3-6 min)
6. Address automated review comments
7. Push fixes
8. Notify user

The `/pre-pr` command runs 4 agents as a pre-merge quality gate:

| Agent                        | Check                   |
|------------------------------|-------------------------|
| branch-metaspec-checker      | Alignment with specs    |
| branch-code-reviewer         | Code quality            |
| branch-documentation-writer  | Documentation updates   |
| branch-test-planner          | Test coverage           |

## Error Handling Patterns

For code review agents:
- Evaluate error handling as high-priority review item
- Check: missing null/undefined checks, resource leaks, race conditions, unhandled edge cases
- Categorize as high/medium/low priority

For test agents:
- Error condition tests are third priority after happy path and edge cases
- Pattern: `with pytest.raises(ValueError, match="expected error message")`
- Flag missing error handling to main agent

For documentation generation:
- Mark missing sections as "A SER COMPLETADO" (TO BE COMPLETED)
- Create TODOs for follow-up

For Python development:
- Custom exceptions for domain-specific errors
- Built-in exceptions otherwise
- No over-engineering of error handling

## Naming Conventions

| Item            | Convention               | Example                                |
|-----------------|--------------------------|----------------------------------------|
| Agent files     | kebab-case.md            | branch-code-reviewer.md                |
| Command files   | kebab-case.md in folders | engineer/start.md                      |
| Session folders | feature slug             | .claude/sessions/auth-flow/            |
| Generated docs  | snake_case or kebab-case | test_report.md, business-rules.md      |
| Branch names    | feature slug             | feature/auth-flow                      |

## Model Selection Strategy

| Model  | Used For                                             |
|--------|------------------------------------------------------|
| opus   | Code review, metaspec gate-keeping, branch review    |
| sonnet | Development, research, test engineering, gate-keeping|

Higher-reasoning `opus` is reserved for review/analysis tasks where judgment matters. Faster/cheaper `sonnet` handles development and research.

## Agent Tool Permissions

| Agent                        | Tools                                           |
|------------------------------|-------------------------------------------------|
| python-developer             | Read, Write, Edit, MultiEdit, Glob, Grep, Bash  |
| react-developer              | Read, Write, Edit, MultiEdit, Glob, Grep, Bash  |
| code-reviewer                | Read, Glob, Grep, LS, Bash                      |
| branch-code-reviewer         | Read, Glob, Grep, LS, Bash                      |
| test-engineer                | Read, Write, Edit, MultiEdit, Glob, Grep, Bash  |
| test-planner                 | Read, Write, Edit, Glob, Grep, Bash             |
| branch-test-planner          | Read, Write, Glob, Grep, Bash                   |
| research-agent               | Read, Glob, Grep, Bash                          |
| metaspec-gate-keeper         | Read, Glob, Grep                                |
| branch-metaspec-checker      | Read, Glob, Grep, Bash                          |
| branch-documentation-writer  | Read, Write, Edit, Glob, Grep, Bash             |

Review agents are read-only (no Write/Edit). Development agents have full write access.
