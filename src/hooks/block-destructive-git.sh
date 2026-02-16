#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -qE "git\s+push"; then
  echo "BLOCKED: git push not allowed without explicit permission" >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE "git\s+tag"; then
  echo "BLOCKED: git tag not allowed without explicit permission" >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE "git\s+branch\s+-(d|D)"; then
  echo "BLOCKED: git branch delete not allowed without explicit permission" >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE "git\s+reset\s+--hard"; then
  echo "BLOCKED: git reset --hard not allowed without explicit permission" >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE "git\s+clean\s+-f"; then
  echo "BLOCKED: git clean -f not allowed without explicit permission" >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE "git\s+checkout\s+\."; then
  echo "BLOCKED: git checkout . not allowed without explicit permission" >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE "git\s+restore\s+\."; then
  echo "BLOCKED: git restore . not allowed without explicit permission" >&2
  exit 2
fi

exit 0
