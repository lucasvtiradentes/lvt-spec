# Agent OS - Architecture

## Folder Structure

```
agent-os/
├── config.yml                              - system config: version, default profile, inheritance
├── README.md                               - project documentation
├── CHANGELOG.md                            - version history
├── LICENSE                                 - MIT license
├── .gitignore                              - ignore rules
│
├── commands/
│   └── agent-os/
│       ├── discover-standards.md           - extract patterns from codebase
│       ├── index-standards.md              - rebuild standards index
│       ├── inject-standards.md             - inject standards into AI context
│       ├── plan-product.md                 - create product docs (mission, roadmap, tech stack)
│       └── shape-spec.md                   - structured feature planning
│
├── profiles/
│   └── default/
│       └── global/
│           └── tech-stack.md               - example tech stack standard
│
├── scripts/
│   ├── common-functions.sh                 - shared utilities (YAML parsing, file ops, output)
│   ├── project-install.sh                  - install agent-os into a project
│   └── sync-to-profile.sh                  - sync project standards back to profiles
│
└── .github/
    ├── workflows/
    │   ├── pr-decline.yml                  - automated PR decline workflow
    │   └── stale.yml                       - stale issue/PR cleanup
    ├── CONTRIBUTING.md                     - contribution guidelines
    ├── PULL_REQUEST_TEMPLATE.md            - PR template
    ├── CODE_OF_CONDUCT.md                  - community guidelines
    ├── SUPPORT.md                          - support channels
    ├── SECURITY.yml                        - security disclosure policy
    └── ISSUE_TEMPLATE/
        └── config.yml                      - issue template config
```

## Entry Points

Three primary interaction methods:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        User Entry Points                            │
├──────────────────────┬──────────────────────┬───────────────────────┤
│   Bash Scripts       │   Claude Commands    │   File System         │
├──────────────────────┼──────────────────────┼───────────────────────┤
│ project-install.sh   │ /discover-standards  │ agent-os/standards/   │
│ sync-to-profile.sh   │ /index-standards     │ agent-os/product/     │
│                      │ /inject-standards    │ agent-os/specs/       │
│                      │ /plan-product        │ .claude/commands/     │
│                      │ /shape-spec          │                       │
└──────────────────────┴──────────────────────┴───────────────────────┘
```

## High-Level Component Diagram

```
┌───────────────┐   ┌───────────────┐   ┌───────────────────────┐
│ Commands      │   │ Profiles      │   │      Scripts          │
│ (markdown)    │   │ (standards)   │   │      (bash)           │
│               │   │               │   │                       │
│ discover      │   │ default/      │   │ project-install.sh    │
│ index         │   │ profile-a/    │   │ sync-to-profile.sh    │
│ inject        │   │ profile-b/    │   │ common-functions.sh   │
│ plan-product  │   │               │   │                       │
│ shape-spec    │   │               │   │                       │
└───────┬───────┘   └───────┬───────┘   └───────────┬───────────┘
        │                   │                       │ 
        v                   v                       v 
┌─────────────────────────────────────────────────────────────────┐
│                        config.yml                               │
│                (version, profiles, inheritance)                 │
└─────────────────────────────────────────────────────────────────┘
```

## Profile Inheritance Model

```
┌──────────────┐
│   default    │
└──────┬───────┘
       │ inherits_from
       v
┌──────────────┐
│  profile-a   │
└──────┬───────┘
       │ inherits_from
       v
┌──────────────┐
│  profile-b   │
└──────────────┘
```

- default    - base profile (always exists)
- profile-a  - extends default, overrides matching files
- profile-b  - extends profile-a (gets default + profile-a + own)

Resolution order: default ---> profile-a ---> profile-b.
Later profiles override earlier ones. Circular dependencies detected and rejected.

## Standards Discovery Flow

```
┌──────────┐     ┌──────────────────┐     ┌──────────────────┐
│ Codebase │---->│ /discover-       │---->│ Interactive Q&A  │
│  files   │     │  standards       │     │ (why? context?)  │
└──────────┘     └──────────────────┘     └────────┬─────────┘
                                                   │
                                                   v
                 ┌──────────────────┐     ┌──────────────────┐
                 │  Update          │<----│ Create .md file  │
                 │  index.yml       │     │ in standards/    │
                 └──────────────────┘     └──────────────────┘
```

## Standards Injection Flow

```
┌───────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ User invokes      │---->│ Detect scenario  │---->│ Read index.yml   │
│ /inject-standards │     │ (convo/skill/    │     │ Match against    │
│                   │     │ plan)            │     │ current context  │
└───────────────────┘     └──────────────────┘     └────────┬─────────┘
                                                            │
                                                            v
                         ┌──────────────────┐     ┌──────────────────┐
                         │ Format output    │<----│ User confirms    │
                         │ per scenario     │     │ selection        │
                         └────────┬─────────┘     └──────────────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    v             v             v 
             ┌───────────┐ ┌────────────┐ ┌────────────┐
             │ Convo:    │ │ Skill:     │ │ Plan:      │
             │ full text │ │ file refs  │ │ file refs  │
             │ in chat   │ │ or content │ │ or content │
             └───────────┘ └────────────┘ └────────────┘
```

## Installation Flow

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ User runs        │---->│ Load config.yml  │---->│ Resolve profile  │
│ project-install  │     │ Validate base    │     │ inheritance      │
│ .sh              │     │ installation     │     │ chain            │
└──────────────────┘     └──────────────────┘     └────────┬─────────┘
                                                           │
                                                           v
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ Install commands │<----│ Generate         │<----│ Copy standards   │
│ to .claude/      │     │ index.yml        │     │ (base first,     │
│ commands/        │     │                  │     │ overrides next)  │
└──────────────────┘     └──────────────────┘     └──────────────────┘
```

## Sync-Back Flow

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ Project          │---->│ sync-to-         │---->│ Interactive file │
│ standards/       │     │ profile.sh       │     │ & profile select │
└──────────────────┘     └──────────────────┘     └────────┬─────────┘
                                                           │
                                                           v
                         ┌──────────────────┐     ┌──────────────────┐
                         │ Copy to base     │<----│ Conflict detect  │
                         │ profile          │     │ Backup existing  │
                         └──────────────────┘     └──────────────────┘
```

## Shape Spec Flow

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ User enters      │---->│ /shape-spec      │---->│ Clarify scope    │
│ plan mode        │     │ (validates plan  │     │ Gather visuals   │
│                  │     │ mode active)     │     │ Find references  │
└──────────────────┘     └──────────────────┘     └────────┬─────────┘
                                                           │
                                                           v
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ Task 1: save     │<----│ Structure plan   │<----│ Check product/   │
│ spec docs        │     │ with tasks       │     │ Inject standards │
└────────┬─────────┘     └──────────────────┘     └──────────────────┘
         │
         v
┌──────────────────────────────────────────┐
│ agent-os/specs/YYYY-MM-DD-HHMM-slug/     │
│ ├── plan.md                              │
│ ├── shape.md                             │
│ ├── standards.md                         │
│ ├── references.md                        │
│ └── visuals/                             │
└──────────────────────────────────────────┘
```

## Module Dependency Graph

```
                     ┌──────────────────┐
                     │   config.yml     │
                     └────────┬─────────┘
                              │
              ┌───────────────┼───────────────┐
              v               v               v
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │  project-    │ │  sync-to-    │ │  profiles/   │
    │  install.sh  │ │  profile.sh  │ │              │
    └──────┬───────┘ └──────┬───────┘ └──────────────┘
           │                │
           v                v
    ┌─────────────────────────────┐
    │     common-functions.sh     │
    │  (YAML parse, file ops,     │
    │   output formatting)        │
    └─────────────────────────────┘

    ┌─────────────────────────────────────────────────┐
    │              Claude Code Commands               │
    │                                                 │
    │  discover  index  inject  plan-product  shape   │
    │     │        │      │         │           │     │
    │     v        v      v         v           v     │
    │  ┌─────────────────────────────────────────┐    │
    │  │         agent-os/standards/             │    │
    │  │         agent-os/product/               │    │
    │  │         agent-os/specs/                 │    │
    │  └─────────────────────────────────────────┘    │
    └─────────────────────────────────────────────────┘
```

## Design Patterns

1. Command Pattern        - commands are declarative markdown files executed by Claude Code; each defines a step-by-step interactive workflow
2. Profile Inheritance    - layered profiles where children override parents; circular dependency detection built in
3. Index-Based Discovery  - YAML index maps standards to descriptions enabling fast AI matching without reading all files
4. Scenario-Aware Output  - inject-standards detects context (conversation, skill, plan) and formats output differently
5. Interactive Loops      - commands process one item at a time through a full cycle (ask -> confirm -> act) before next
6. Stateless Execution    - commands read all state from files; no persistent agent memory between invocations
7. Documentation-as-Code  - standards, specs, and product docs live in the codebase alongside source code
