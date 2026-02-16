#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -qi "co-authored-by"; then
  echo "BLOCKED: commits with Co-Authored-By are not allowed" >&2
  exit 2
fi

exit 0
