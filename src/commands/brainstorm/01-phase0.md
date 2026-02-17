
## Phase 0 - Route

Determine entry point based on existing file.

### Step 0.1 - Check for existing file

Search for `brainstorm-*.md` files matching the topic in project root.

If file exists:
- Read the file content
- Check `## Meta` section for current phase:
  - `phase: capture` → jump to `## Phase 1` Step 1.3
  - `phase: clarification` → jump to `## Phase 2` Step 2.1
  - `phase: loop` → jump to `## Phase 3` Step 3.1

### Step 0.2 - New topic

If no matching file exists:
- Proceed to `## Phase 1`
