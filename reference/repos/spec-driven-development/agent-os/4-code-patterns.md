# Agent OS - Code Patterns

## Shell Scripting Style

### File Structure

Every script follows this pattern:

```bash
#!/bin/bash
# =============================================================================
# Script Name
# Brief description
# =============================================================================
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/common-functions.sh"
```

### Naming Conventions

| Element            | Convention         | Example                          |
|--------------------|--------------------|----------------------------------|
| Global variables   | SCREAMING_SNAKE    | SCRIPT_DIR, BASE_DIR, VERBOSE    |
| Functions          | snake_case         | print_section, get_yaml_value    |
| Local variables    | lowercase          | local dir=$1                     |
| Script files       | kebab-case         | project-install.sh               |
| Command files      | kebab-case         | discover-standards.md            |

### Color Output System

RGB color codes defined as constants:

```bash
RED='\033[38;2;255;32;86m'
GREEN='\033[38;2;0;234;179m'
YELLOW='\033[38;2;255;185;0m'
BLUE='\033[38;2;0;208;255m'
PURPLE='\033[38;2;142;81;255m'
NC='\033[0m'
```

Output functions hierarchy:

| Function        | Purpose                                   |
|-----------------|-------------------------------------------|
| print_color     | Base: print text in a given color         |
| print_section   | Section headers with decorative separator |
| print_status    | Status line with color                    |
| print_success   | Green checkmark with message              |
| print_warning   | Yellow warning with message               |
| print_error     | Red X with message                        |
| print_verbose   | Only prints when VERBOSE is enabled       |

### Function Organization

Functions are grouped into sections:

```bash
# -----------------------------------------------
# Output Functions
# -----------------------------------------------
print_color() { ... }
print_section() { ... }

# -----------------------------------------------
# YAML Parsing (Simple)
# -----------------------------------------------
get_yaml_value() { ... }

# -----------------------------------------------
# File Operations
# -----------------------------------------------
ensure_dir() { ... }
```

### Argument Parsing

Consistent pattern across scripts:

```bash
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile) PROFILE="$2"; shift 2 ;;
    --verbose) VERBOSE=true; shift ;;
    -h|--help) show_help; exit 0 ;;
    *) print_error "Unknown option: $1"; exit 1 ;;
  esac
done
```

Long-form flags only (no single-letter shortcuts except `-h`).

## Command Definition Conventions

All commands are markdown files with a consistent structure:

1. H1 title with short description
2. Brief description paragraph
3. `## Important Guidelines` (if needed)
4. `## Process` with numbered H3 steps: `### Step N: Action`
5. Each step describes what to do and how to interact with user

Interaction rules within commands:

- Ask one question at a time via `AskUserQuestion` tool
- Present suggestions rather than open-ended prompts
- Complete full loop (ask -> confirm -> act) before next item
- Never batch multiple questions upfront
- Draft output, get approval, then create files

## Error Handling

### Validation Strategy

Early validation before main work:

```
validate_base_installation()  - check base dir exists
validate_not_in_base()        - prevent running in base directory
validate_project_standards()  - check project has standards/
```

All validation functions exit with code 1 and call `print_error` on failure.

### Circular Dependency Detection

Profile inheritance chains are validated:

```
Track visited profiles in chain
If profile seen twice: return "CIRCULAR:profile-a -> profile-b -> profile-a"
If profile not found: return "NOTFOUND:profile-name"
```

### File Operation Safety

- Check directory existence before operations
- Use `ensure_dir` to create parent directories
- Exclude `.backups/` from find operations: `! -path "*/.backups/*"`
- Temporary file cleanup via trap: `trap "rm -f $sources_file" EXIT`

### Backup Strategy

- Timestamp-based backup folders: `YYYY-MM-DD-HHMM`
- Backups stored in `.backups/` subdirectory at target location
- Backup before overwrite, report count of backed-up files

### Exit Codes

| Code | Meaning                          |
|------|----------------------------------|
| 0    | Success or user cancellation     |
| 1    | Error (validation, missing file) |

## CI/CD

### pr-decline.yml

- Trigger: `pull_request_target` (labeled) or `workflow_dispatch` (manual)
- Uses `actions/github-script@v7` for JavaScript logic
- Four decline reasons: Out of scope, Low info, Duplicate, Spam
- Canned response messages per reason
- Comments on PR, then closes it via `gh` CLI

### stale.yml

- Trigger: daily cron at 09:00 UTC
- Uses `actions/stale@v9`
- 30 days before marking stale, 7 days before closing
- Exempts issues labeled `bug`

### Common CI Patterns

- Minimal permissions (principle of least privilege)
- Environment variables for reusable constants
- Official GitHub actions preferred
- Manual dispatch options for maintainer control

## Contributing Guidelines

### Workflow

1. Discussions first - required for features, encouraged for bugs
2. Three discussion categories: Bugs, Ideas, Q&A
3. Maintainers promote confirmed bugs from Discussions to Issues
4. Features need `approved` label before PR

### PR Requirements

| Type     | Requirements                                           |
|----------|--------------------------------------------------------|
| Bug fix  | Include `[bug fix]` in title, reproduction steps, tests|
| Feature  | Start with Discussion in Ideas, need approved label    |
| Docs     | Always welcome for typos, clarifications               |

### PR Template Checklist

- Link to related Issue/Discussion
- Documented test steps (numbered list)
- Draft "how to use" docs for new features
- Backwards compatibility considerations

### Security

- Private disclosure required (no public issues)
- Email: brian@buildermethods.com
- Prompt response promised

### Issue Configuration

- Blank issues disabled (forces templates)
- Five contact links redirect to appropriate channels:
  1. Bug reports    ---> Bugs discussion
  2. Features       ---> Ideas discussion
  3. Questions      ---> Q&A discussion
  4. Paid support   ---> Builder Methods Pro
  5. Documentation  ---> buildermethods.com/agent-os

## Key Architectural Decisions

1. Standards as markdown  - every word costs tokens; standards are kept concise and scannable
2. Index for matching     - AI reads descriptions not full files; reduces token consumption
3. Profile inheritance    - enables cross-project reuse without duplication
4. Timestamped specs      - every feature gets a dated folder for historical record
5. Interactive CLI        - commands guide users with suggestions, not open-ended prompts
6. v3.0 simplification   - defers spec writing, task breakdown, and orchestration to modern AI tools
