---
name: analyse-repo
description: Analyse a GitHub repository and create structured documentation about its codebase. Use when the user wants to understand or document an external repo. Do NOT use for the current project.
---

## Arguments

- $ARGUMENTS: GitHub repo URL (e.g., "https://github.com/user/repo") or shorthand "user/repo"

## Instructions

1. Parse Input: Extract owner and repo name from $ARGUMENTS. Support both full URL and shorthand format.

2. Fetch Repo Metadata: Use `gh repo view {owner}/{repo} --json url,createdAt,stargazerCount` to get repo info.

3. Clone Repo: Clone the repo to a temp directory using `gh repo clone` or `git clone`. Use `--depth 1` for speed.

4. Analyse with Agents: Launch parallel agents to analyse different aspects:
   - Agent 1: Overview      - README, project purpose, features, core concepts, possible usages
   - Agent 2: Technical     - tech stack, dependencies, installation, configuration
   - Agent 3: Architecture  - folder structure, entry points, design patterns, data flow, component relationships
   - Agent 4: Code Patterns - coding style, testing approach, CI/CD, conventions
   - Agent 5: Usage         - how to use, examples from README/docs, common workflows

   Each agent should read the actual source files in the cloned repo to extract accurate information. Do NOT rely on guessing.

5. Create Folder: Create folder at `docs/repos/{repo-name}/` where repo-name is the repository name in kebab-case.

6. Create Files: Split the analysis into these markdown files:
   - `1-overview.md`           - MUST start with an Info section containing repo metadata (see Info Section below). Then: what it is, purpose, features, core concepts, possible usages. Include a table at the end linking to all other doc files with a short description of each
   - `2-technical.md`          - tech stack, dependencies (with versions), installation steps, configuration options
   - `3-architecture.md`       - folder structure, entry points, design patterns. Include MANY ascii diagrams: component diagrams, data flow, request lifecycle, module dependency graph, etc
   - `4-code-patterns.md`      - coding style, testing approach, CI/CD, conventions, error handling patterns
   - `5-usage-and-examples.md` - how to use it, examples, common workflows, CLI commands if applicable
   - Additional files if the repo warrants it (e.g., `6-api-reference.md` for API-heavy projects, `6-plugins.md` for extensible systems)

7. Info Section (MANDATORY for `1-overview.md`): The file MUST start with an Info section right after the h1 title, using this exact format:

   ```
   ## Info

   | Field            | Value                                       |
   |------------------|---------------------------------------------|
   | repo_link        | https://github.com/owner/repo               |
   | created_at       | 2025-01-15                                  |
   | number_of_stars  | 42                                          |
   | analysed_at      | 2026-02-08                                  |
   ```

   - `repo_link`       - full GitHub URL from gh repo view
   - `created_at`      - repo creation date (YYYY-MM-DD), from gh repo view `createdAt`
   - `number_of_stars` - stargazer count at time of analysis, from gh repo view `stargazerCount`
   - `analysed_at`     - today's date (YYYY-MM-DD) when analysis was performed

8. Markdown Rules (MANDATORY):
   - NEVER use bold syntax (no `**text**` anywhere)
   - NEVER use unicode arrows (no ▶, ────▶, ◀, etc). Use ASCII only: `---->`, `<----`, `|`, `+`, `-`
   - NEVER use emojis or wide Unicode chars inside ASCII diagrams (they break alignment)
   - Use tables for dependencies/commands/options when applicable
   - Include code examples with proper syntax highlighting
   - Keep explanations concise, no fluff
   - Write in English
   - No emojis unless already present
   - Tables must have "|" aligned vertically, every cell in a column MUST have the same width as the separator row:
     ```
     | Dependency           | Purpose                                    |
     |----------------------|--------------------------------------------|
     | express              | HTTP server framework                      |
     | prisma               | Database ORM                               |
     ```
   - Lists with descriptions must have " - " aligned vertically:
     ```
     1. src/index.ts       - main entry point
     2. src/routes/         - API route definitions
     3. src/services/       - business logic layer
     ```
   - ASCII diagram box borders must align vertically. Inner content must have consistent padding
   - When boxes are nested or side-by-side, inner box borders and content borders must align at the same column

9. Architecture Diagrams (MANDATORY for `3-architecture.md`): Include multiple ascii diagrams using code blocks. Examples:

   ```
   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
   │   Client    │---->│   Server    │---->│  Database   │
   └─────────────┘     └─────────────┘     └─────────────┘
   ```

   ```
   src/
   ├── core/
   │   ├── engine.ts        - main processing engine
   │   └── parser.ts        - input parsing
   ├── api/
   │   ├── routes.ts        - route definitions
   │   └── middleware.ts    - auth, logging, error handling
   └── index.ts             - entry point
   ```

   Include at minimum:
   - High-level component/module diagram
   - Data flow or request lifecycle diagram
   - Folder structure with annotations
   - Module dependency graph if complex enough

10. Cleanup: Remove the cloned temp directory after analysis.

11. Post-Generation: After all docs are created, run `$align-docs` on the generated folder to auto-fix alignment issues in tables and ASCII diagrams. Re-run until clean.

12. Output: Show the folder structure created and a brief summary of findings.
