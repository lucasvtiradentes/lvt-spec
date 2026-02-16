#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_SRC="$REPO_ROOT/src/hooks"
HOOKS_DEST="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/_custom/repos/github_lucasvtiradentes/repo-configs/global/settings.json"

mkdir -p "$HOOKS_DEST"

for hook in "$HOOKS_SRC"/*.sh; do
  [[ -f "$hook" ]] || continue
  cp "$hook" "$HOOKS_DEST/"
  chmod +x "$HOOKS_DEST/$(basename "$hook")"
  echo "installed: $(basename "$hook")"
done

HOOKS_CONFIG='{
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
}'

if [[ -f "$SETTINGS_FILE" ]]; then
  if jq -e '.hooks' "$SETTINGS_FILE" > /dev/null 2>&1; then
    echo "hooks already configured in settings.json"
  else
    jq --argjson new "$HOOKS_CONFIG" '. + $new' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
    mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    echo "added hooks config to settings.json"
  fi
else
  echo "settings file not found: $SETTINGS_FILE"
  exit 1
fi
