#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO_ROOT/src/gen-docs"
OUT="$REPO_ROOT/.claude/commands/gen-docs.md"

cat \
  "$SRC/00-overview.md" \
  "$SRC/01-phase0.md" \
  "$SRC/02-phase1.md" \
  "$SRC/03-phase2.md" \
  "$SRC/04-phase3.md" \
  "$SRC/05-reference.md" \
  > "$OUT"

echo "Mounted gen-docs.md ($(wc -l < "$OUT") lines)"
