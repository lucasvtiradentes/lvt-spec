#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$REPO_ROOT/src/config.json"

filter_for_agent() {
  local agent="$1"
  local src="$2"
  local in_variant=false
  local variant_match=false

  while IFS= read -r line; do
    if [[ "$line" =~ ^'<!--@end-->'$ ]]; then
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

    if $in_variant; then
      $variant_match && echo "$line"
    else
      echo "$line"
    fi
  done < "$src"
}

strip_empty_edges() {
  sed '/./,$!d' | sed -e :a -e '/^\n*$/{$d;N;ba;}'
}

header_for_claude() {
  local title="$1" description="$2"
  printf '# %s\n\n%s\n' "$title" "$description"
}

header_for_codex() {
  local name="$1" description="$2"
  printf -- '---\nname: %s\ndescription: %s\n---\n' "$name" "$description"
}

header_for_gemini() {
  local description="$1"
  printf 'description = "%s"\nprompt = """\n' "$description"
}

footer_for_gemini() {
  printf '"""'
}

resolve_source() {
  local dir="$1"
  local md_files=()

  for f in "$dir"/*.md; do
    [[ "$(basename "$f")" == "_generated.md" ]] && continue
    [[ -f "$f" ]] && md_files+=("$f")
  done

  if [[ ${#md_files[@]} -gt 1 ]]; then
    local out="$dir/_generated.md"
    cat "${md_files[@]}" > "$out"
    echo "$out"
  elif [[ ${#md_files[@]} -eq 1 ]]; then
    echo "${md_files[0]}"
  else
    return 1
  fi
}

build_agent() {
  local agent="$1"
  local src="$2"
  local out="$3"
  local header="$4"
  local footer="$5"

  mkdir -p "$(dirname "$out")"
  {
    [[ -n "$header" ]] && printf '%s\n\n' "$header"
    filter_for_agent "$agent" "$src" | strip_empty_edges
    [[ -n "$footer" ]] && printf '\n%s\n' "$footer"
  } > "$out"
  local rel
  rel="$(realpath --relative-to="$REPO_ROOT" "$out")"
  echo "  $agent -> $rel ($(wc -l < "$out") lines)"
}

build_for_claude() {
  local name="$1" namespace="$2" src="$3" title="$4" description="$5"
  local header
  header="$(header_for_claude "$title" "$description")"
  build_agent "claude" "$src" "$REPO_ROOT/.claude/commands/$namespace/$name.md" "$header" ""
}

build_for_codex() {
  local name="$1" namespace="$2" src="$3" title="$4" description="$5"
  local header
  header="$(header_for_codex "$name" "$description")"
  build_agent "codex" "$src" "$REPO_ROOT/.agents/skills/$name/SKILL.md" "$header" ""
}

build_for_gemini() {
  local name="$1" namespace="$2" src="$3" title="$4" description="$5"
  local header footer
  header="$(header_for_gemini "$description")"
  footer="$(footer_for_gemini)"
  build_agent "gemini" "$src" "$REPO_ROOT/.gemini/commands/$namespace/$name.toml" "$header" "$footer"
}

build_command() {
  local name="$1"
  local dir="$REPO_ROOT/src/$name"

  if [[ ! -d "$dir" ]]; then
    echo "  SKIP $name (dir not found)"
    return
  fi

  local namespace title description
  namespace="$(jq -r --arg n "$name" '.[$n].namespace' "$CONFIG")"
  title="$(jq -r --arg n "$name" '.[$n].title // ""' "$CONFIG")"
  description="$(jq -r --arg n "$name" '.[$n].description // ""' "$CONFIG")"

  local src
  src="$(resolve_source "$dir")" || { echo "  SKIP $name (no .md files)"; return; }

  readarray -t agents < <(jq -r --arg n "$name" '.[$n].agents // ["claude","codex","gemini"] | .[]' "$CONFIG")

  echo "$name:"
  for agent in "${agents[@]}"; do
    case "$agent" in
      claude) build_for_claude "$name" "$namespace" "$src" "$title" "$description" ;;
      codex)  build_for_codex  "$name" "$namespace" "$src" "$title" "$description" ;;
      gemini) build_for_gemini "$name" "$namespace" "$src" "$title" "$description" ;;
    esac
  done
}

for name in $(jq -r 'keys[]' "$CONFIG"); do
  build_command "$name"
done
