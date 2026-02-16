# Agent OS - Technical Details

## Tech Stack

| Technology       | Role                                              |
|------------------|---------------------------------------------------|
| Bash             | Primary implementation language (scripts)         |
| Markdown         | Command definitions, standards, documentation     |
| YAML             | Configuration (config.yml, index.yml)             |
| GitHub Actions   | CI/CD (PR management, stale issue cleanup)        |

No external package managers are used. The entire system runs on standard Unix utilities.

## System Requirements

| Requirement         | Details                                        |
|---------------------|------------------------------------------------|
| OS                  | Linux/macOS (Unix-based)                       |
| Shell               | Bash                                           |
| Git                 | Required for version control                   |
| Unix utilities      | grep, sed, awk, find, cp, mkdir, tput          |
| Terminal            | ANSI color support (optional, for colored CLI) |
| AI Tool             | Claude Code, Cursor, or Antigravity            |

## Dependencies

No third-party dependencies. The system uses only:

- Standard Unix/Linux utilities (grep, sed, awk, find, cp, mkdir)
- tput for terminal formatting
- Custom YAML parsing via grep/sed (no external YAML parser)
- Git for version control operations

## Installation

### Base Installation

1. Clone or install the Agent OS repository to a local directory
2. Customize standards in the base installation profiles
3. Documentation: https://buildermethods.com/agent-os

### Project Installation

Run from the target project directory:

```bash
/path/to/agent-os/scripts/project-install.sh [OPTIONS]
```

Options:

| Flag               | Description                                      |
|--------------------|--------------------------------------------------|
| --profile <name>   | Use specified profile (default from config.yml)  |
| --commands-only    | Only update commands, preserve existing standards|
| --verbose          | Show detailed output                             |
| -h, --help         | Show help message                                |

Installation process:

1. Validates base installation exists
2. Validates not running inside base directory
3. Loads config.yml, resolves profile inheritance chain
4. Confirms standards overwrite if needed
5. Creates `agent-os/` directory structure in project
6. Copies standards from profiles (base first, overrides applied)
7. Generates `agent-os/standards/index.yml`
8. Installs commands to `.claude/commands/agent-os/`

### Project Structure After Installation

```
project/
├── agent-os/
│   ├── standards/
│   │   ├── index.yml
│   │   └── [domain-folders]/
│   ├── product/          (optional, created by /plan-product)
│   └── specs/            (optional, created by /shape-spec)
└── .claude/
    └── commands/
        └── agent-os/
            ├── discover-standards.md
            ├── index-standards.md
            ├── inject-standards.md
            ├── plan-product.md
            └── shape-spec.md
```

## Configuration

### config.yml

```yaml
version: 3.0
default_profile: default

profiles:
  profile-a:
    inherits_from: default
  profile-b:
    inherits_from: profile-a
```

| Field             | Description                                        |
|-------------------|----------------------------------------------------|
| version           | Agent OS version                                   |
| default_profile   | Profile used when none is specified                |
| profiles          | Optional inheritance relationships between profiles|

### Profile Structure

```
profiles/
├── default/
│   └── standards/
│       ├── global/
│       │   └── tech-stack.md
│       └── [other-domain-folders]/
└── custom-profile/
    └── standards/
        └── [domain-folders]/
```

Profiles support inheritance: child profiles override matching files from parent profiles. The installation script resolves the full inheritance chain and applies them in order.

### Standards Index (index.yml)

Generated automatically. Format:

```yaml
folder:
  filename:
    description: brief description of the standard
```

The `root` keyword represents files directly in the `standards/` base directory (not an actual folder).
