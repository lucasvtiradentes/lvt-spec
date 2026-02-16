#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$REPO_ROOT/src/config.json"

filter_for_agent() {
  local agent="$1"
  local src="$2"
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
        [[ "$a" == "$agent" ]] && block_visible=true && break
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
        [[ "$a" == "$agent" ]] && variant_match=true && break
      done
      continue
    fi

    if $in_block; then
      $block_visible && echo "$line"
    elif $in_variant; then
      $variant_match && echo "$line"
    else
      echo "$line"
    fi
  done < "$src"
}

strip_empty_edges() {
  sed '/./,$!d' | sed -e :a -e '/^\n*$/{$d;N;ba;}'
}

for name in $(jq -r 'keys[]' "$CONFIG"); do
  dir="$REPO_ROOT/src/$name"
  if [[ ! -d "$dir" ]]; then
    echo "  SKIP $name (dir not found)"
    continue
  fi

  namespace="$(jq -r --arg n "$name" '.[$n].namespace' "$CONFIG")"
  readarray -t agents < <(jq -r --arg n "$name" '.[$n].agents // ["claude","codex","gemini"] | .[]' "$CONFIG")

  md_files=()
  for f in "$dir"/*.md; do
    [[ "$(basename "$f")" == "_generated.md" ]] && continue
    [[ -f "$f" ]] && md_files+=("$f")
  done

  if [[ ${#md_files[@]} -gt 1 ]]; then
    src="$dir/_generated.md"
    cat "${md_files[@]}" > "$src"
  elif [[ ${#md_files[@]} -eq 1 ]]; then
    src="${md_files[0]}"
  else
    echo "  SKIP $name (no .md files)"
    continue
  fi

  echo "$name:"
  for agent in "${agents[@]}"; do
    case "$agent" in
      claude) out="$REPO_ROOT/.claude/commands/$namespace/$name.md" ;;
      codex)  out="$REPO_ROOT/.agents/skills/$name/SKILL.md" ;;
      gemini) out="$REPO_ROOT/.gemini/commands/$namespace/$name.toml" ;;
      *) continue ;;
    esac

    mkdir -p "$(dirname "$out")"
    filter_for_agent "$agent" "$src" | strip_empty_edges > "$out"
    rel="$(realpath --relative-to="$REPO_ROOT" "$out")"
    echo "  $agent -> $rel ($(wc -l < "$out") lines)"
  done
done
