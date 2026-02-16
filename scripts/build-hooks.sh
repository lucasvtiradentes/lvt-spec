#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_SRC="$REPO_ROOT/src/hooks"

CLAUDE_HOOKS_DEST="$HOME/.claude/hooks"
CLAUDE_SETTINGS="$HOME/_custom/repos/github_lucasvtiradentes/repo-configs/global/settings.json"

GEMINI_HOOKS_DEST="$HOME/.gemini/hooks"
GEMINI_SETTINGS="$HOME/.gemini/settings.json"

config_for_claude() {
  cat <<'EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "~/.claude/hooks/block-coauthor.sh"},
          {"type": "command", "command": "~/.claude/hooks/block-destructive-git.sh"}
        ]
      }
    ]
  }
}
EOF
}

config_for_gemini() {
  cat <<'EOF'
{
  "hooks": {
    "BeforeTool": [
      {
        "matcher": ".*",
        "hooks": [
          {"type": "command", "command": "~/.gemini/hooks/block-coauthor.sh"},
          {"type": "command", "command": "~/.gemini/hooks/block-destructive-git.sh"}
        ]
      }
    ]
  }
}
EOF
}

copy_hooks() {
  local dest="$1"
  mkdir -p "$dest"
  for hook in "$HOOKS_SRC"/*.sh; do
    [[ -f "$hook" ]] || continue
    cp "$hook" "$dest/"
    chmod +x "$dest/$(basename "$hook")"
  done
}

merge_settings() {
  local settings_file="$1"
  local config="$2"

  if [[ ! -f "$settings_file" ]]; then
    mkdir -p "$(dirname "$settings_file")"
    echo "$config" | jq '.' > "$settings_file"
    return 0
  fi

  if jq -e '.hooks' "$settings_file" > /dev/null 2>&1; then
    return 1
  fi

  jq --argjson new "$config" '. + $new' "$settings_file" > "$settings_file.tmp"
  mv "$settings_file.tmp" "$settings_file"
}

build_for_claude() {
  copy_hooks "$CLAUDE_HOOKS_DEST"
  if merge_settings "$CLAUDE_SETTINGS" "$(config_for_claude)"; then
    echo "claude: hooks installed + settings updated"
  else
    echo "claude: hooks installed (settings already configured)"
  fi
}

build_for_gemini() {
  copy_hooks "$GEMINI_HOOKS_DEST"
  if merge_settings "$GEMINI_SETTINGS" "$(config_for_gemini)"; then
    echo "gemini: hooks installed + settings updated"
  else
    echo "gemini: hooks installed (settings already configured)"
  fi
}

build_for_claude
build_for_gemini
echo "codex: skipped (no PreToolUse support)"
