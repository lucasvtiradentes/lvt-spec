#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC="$SCRIPT_DIR/repo-naming.md"

TARGETS="claude codex gemini"

filter_for_agent() {
  local agent="$1"
  local in_block=false
  local block_visible=false
  local in_variant=false
  local variant_match=false

  while IFS= read -r line; do
    if [[ "$line" =~ ^'<!--@only '(.+)'-->'$ ]]; then
      local agents="${BASH_REMATCH[1]}"
      in_block=true
      block_visible=false
      IFS=',' read -ra arr <<< "$agents"
      for a in "${arr[@]}"; do
        if [[ "$a" == "$agent" ]]; then
          block_visible=true
          break
        fi
      done
      continue
    fi

    if [[ "$line" =~ ^'<!--@end-->'$ ]]; then
      in_block=false
      block_visible=false
      in_variant=false
      variant_match=false
      continue
    fi

    if [[ "$line" =~ ^'<!--@'(.+)'-->'$ ]]; then
      local agents="${BASH_REMATCH[1]}"
      in_variant=true
      variant_match=false
      IFS=',' read -ra arr <<< "$agents"
      for a in "${arr[@]}"; do
        if [[ "$a" == "$agent" ]]; then
          variant_match=true
          break
        fi
      done
      continue
    fi

    if $in_block; then
      if $block_visible; then
        echo "$line"
      fi
    elif $in_variant; then
      if $variant_match; then
        echo "$line"
      fi
    else
      echo "$line"
    fi
  done < "$SRC"
}

strip_empty_edges() {
  sed '/./,$!d' | sed -e :a -e '/^\n*$/{$d;N;ba;}'
}

for agent in $TARGETS; do
  case "$agent" in
    claude)
      out="$REPO_ROOT/.claude/commands/gh/repo-naming.md"
      ;;
    codex)
      out="$REPO_ROOT/.agents/skills/repo-naming/SKILL.md"
      ;;
    gemini)
      out="$REPO_ROOT/.gemini/commands/gh/repo-naming.toml"
      ;;
  esac

  mkdir -p "$(dirname "$out")"
  filter_for_agent "$agent" | strip_empty_edges > "$out"
  echo "  $agent -> $(realpath --relative-to="$REPO_ROOT" "$out") ($(wc -l < "$out") lines)"
done
