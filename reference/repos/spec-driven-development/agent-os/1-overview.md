# Agent OS

## Info

| Field            | Value                                       |
|------------------|---------------------------------------------|
| repo_link        | https://github.com/buildermethods/agent-os  |
| created_at       | 2025-07-16                                  |
| number_of_stars  | 3737                                        |
| analysed_at      | 2026-02-08                                  |

## What It Is

Agent OS is a lightweight framework for helping AI coding agents build software more effectively by establishing and enforcing development standards. Created by Brian Casel at Builder Methods, it works alongside AI tools like Claude Code, Cursor, and Antigravity.

The system bridges the gap between rough ideas and well-structured implementations by extracting patterns from existing codebases and intelligently injecting them when building new features. It supports any programming language or framework.

Current version: 3.0 (released 2026-01-20).

## Purpose

- Capture tribal knowledge from codebases into concise, documented standards
- Inject relevant standards into AI context during development
- Shape better feature specs that lead to higher-quality builds
- Maintain consistency across multiple projects via reusable profiles

## Core Concepts

- Standards       - markdown files documenting coding patterns, conventions, and best practices extracted from a codebase
- Profiles        - reusable collections of standards with inheritance support; a child profile extends a parent profile
- Commands        - Claude Code slash commands that drive interactive workflows (discover, index, inject, plan, shape)
- Index           - a YAML registry (`index.yml`) mapping each standard to a description for fast AI matching without reading all files
- Specs           - timestamped feature specification folders created by `/shape-spec` containing plan, shape, standards, references, and visuals
- Product Context - optional mission, roadmap, and tech-stack docs that inform feature planning

## Key Features

1. Discover Standards   - extract patterns from existing codebases interactively
2. Index Standards      - maintain a searchable registry of all standards
3. Inject Standards     - context-aware injection of relevant standards into conversations, skills, or plans
4. Shape Spec           - structured feature planning with standards, references, and visuals
5. Plan Product         - create foundational product documentation (mission, roadmap, tech stack)
6. Profile Inheritance  - layered profiles with override support and circular dependency detection
7. Sync to Profile      - push project-specific standards back to base profiles for reuse

## Possible Usages

- Onboarding AI agents to existing codebase conventions
- Maintaining code consistency across multiple projects
- Creating reusable standards libraries per tech stack (Rails, Next.js, etc.)
- Enhancing AI-generated specs with project-specific context
- Team collaboration with shared standards across AI-assisted development

## Target Audience

- Professional software developers building with AI tools
- Development teams wanting consistent code patterns across projects
- AI-first builders using Claude Code, Cursor, or similar tools

## License

MIT License - Copyright (c) 2025 CasJam Media LLC (Builder Methods)

## Documentation

| File                                              | Description                                           |
|---------------------------------------------------|-------------------------------------------------------|
| [2-technical.md](2-technical.md)                  | Tech stack, dependencies, installation, configuration |
| [3-architecture.md](3-architecture.md)            | Folder structure, design patterns, data flow diagrams |
| [4-code-patterns.md](4-code-patterns.md)          | Coding style, CI/CD, conventions, error handling      |
| [5-usage-and-examples.md](5-usage-and-examples.md)| Commands, workflows, examples, profile system         |
