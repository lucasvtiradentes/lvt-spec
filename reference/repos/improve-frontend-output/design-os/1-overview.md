# Design OS

## Info

| Field            | Value                                          |
|------------------|------------------------------------------------|
| repo_link        | https://github.com/buildermethods/design-os    |
| created_at       | 2025-12-16                                     |
| number_of_stars  | 1384                                           |
| analysed_at      | 2026-02-08                                     |

## What It Is

Design OS is a product planning and design tool that bridges the gap between having a product idea and implementing it in code. It is a standalone React application (runs locally via Vite) that guides users through a structured, AI-assisted design process using Claude Code slash commands.

The core problem it solves: AI coding tools produce generic or misaligned results when asked to simultaneously figure out what to build AND build it. Design OS separates the "what to build" phase from the "build it" phase, producing a complete design handoff package that any AI coding agent can consume.

Created by Brian Casel of Builder Methods (CasJam Media LLC). Licensed under MIT.

## Purpose

- Capture product vision, data architecture, UI design, and implementation specs before any coding begins
- Generate production-ready React components with realistic sample data
- Export a self-contained handoff package usable by any AI coding agent (Claude Code, Cursor, Copilot, etc.)

## Core Concepts

| Concept              | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| Product Overview     | The "what and why" -- product name, description, problems/solutions, key features            |
| Sections             | Self-contained feature areas (3-5) that map to nav items and development phases              |
| Data Model           | Conceptual entity definitions and relationships (the "nouns" of the system)                  |
| Design Tokens        | Color palette (Tailwind names) and typography (Google Fonts)                                 |
| Application Shell    | Persistent navigation/layout wrapper (sidebar, top nav, or minimal header)                   |
| Spec                 | A section's scope definition: overview, user flows, UI requirements, scope boundaries        |
| Sample Data          | Realistic JSON data + TypeScript types for populating screen designs                         |
| Screen Design        | Props-based React components representing the actual UI for a section                        |
| Export / Handoff     | The generated product-plan/ directory containing everything needed for implementation        |
| Four Pillars         | Product Overview, Data Model, Design System, Application Shell                               |

## Phased Workflow

The tool enforces a 3-phase sequential workflow:

1. Phase 1 - Product Planning: Define vision, roadmap (3-5 sections), data model, design tokens, application shell
2. Phase 2 - Section Design (repeat per section): Shape section spec, generate sample data, create screen designs, capture screenshots
3. Phase 3 - Export: Generate complete handoff package with prompts, instructions, components, types, and test specs

Each phase is driven by Claude Code slash commands defined in `.claude/commands/design-os/`.

## Key Features

- Guided product vision definition through conversational AI
- Automatic section breakdown and roadmap creation
- Conceptual data model definition (no database schemas)
- Design token selection from Tailwind palettes and Google Fonts
- Application shell design with multiple layout patterns
- Per-section spec writing with user flows and scope boundaries
- Realistic sample data generation with TypeScript type inference
- Production-grade React screen design creation (props-based, portable)
- Screenshot capture via Playwright MCP
- Complete export/handoff package with ready-to-use prompts for coding agents
- Milestone-based implementation instructions with TDD test specs
- ZIP file download for the export package

## Target Audience

- Technical builders who want full control over architecture and design decisions
- Non-technical product builders with a strong product vision but no coding background
- Teams using AI coding agents that need structured design input

## Possible Usages

- Planning a new SaaS product before implementation
- Creating a design spec/handoff package for a development team
- Generating a structured brief for any AI coding agent
- Establishing a source of truth for product design before code is written
- Iterating on UI designs with realistic data before committing to implementation

## Claude Code Commands

| Command              | Phase   | Purpose                                              |
|----------------------|---------|------------------------------------------------------|
| /product-vision      | Phase 1 | Define product name, description, problems, features |
| /product-roadmap     | Phase 1 | Break product into 3-5 buildable sections            |
| /data-model          | Phase 1 | Define core entities and relationships               |
| /design-tokens       | Phase 1 | Choose colors and typography                         |
| /design-shell        | Phase 1 | Design navigation and layout                         |
| /shape-section       | Phase 2 | Define a section's scope and requirements            |
| /sample-data         | Phase 2 | Generate sample data and TypeScript types            |
| /design-screen       | Phase 2 | Create screen design React components                |
| /screenshot-design   | Phase 2 | Capture screenshots of designs                       |
| /export-product      | Phase 3 | Generate complete handoff package                    |

There is also a frontend-design skill (`.claude/skills/frontend-design/SKILL.md`) invoked during `/design-screen` to ensure high design quality.

## Documentation Files

| File                                              | Description                                              |
|---------------------------------------------------|----------------------------------------------------------|
| [2-technical.md](2-technical.md)                  | Tech stack, dependencies, installation, configuration    |
| [3-architecture.md](3-architecture.md)            | Folder structure, entry points, design patterns, diagrams|
| [4-code-patterns.md](4-code-patterns.md)          | Coding style, conventions, CI/CD, TypeScript patterns    |
| [5-usage-and-examples.md](5-usage-and-examples.md)| How to use, workflows, command details, export structure |
