#!/usr/bin/env bash
# Installs Claude Code approval notifications via iCloud Reminders.
# Requires: macOS, jq, iCloud account signed in, Reminders app enabled in iCloud.

set -e

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"

echo "Installing Claude Code approval notifications..."

# Check dependencies
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install with: brew install jq"
  exit 1
fi

# Create hooks directory
mkdir -p "$HOOKS_DIR"

# Copy hook scripts
cp hooks/notify.sh "$HOOKS_DIR/notify.sh"
cp hooks/cleanup.sh "$HOOKS_DIR/cleanup.sh"
chmod +x "$HOOKS_DIR/notify.sh" "$HOOKS_DIR/cleanup.sh"

# Detect default Reminders list name
LIST_NAME=$(osascript -e 'tell application "Reminders" to get name of first list' 2>/dev/null || echo "")
if [ -z "$LIST_NAME" ]; then
  echo "Warning: Could not detect Reminders list name. Make sure Reminders app is accessible."
fi

# Merge hooks config into settings.json
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

HOOKS_JSON='{
  "PreToolUse": [
    {
      "matcher": "Bash|Write|Edit",
      "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "Bash|Write|Edit",
      "hooks": [{ "type": "command", "command": "~/.claude/hooks/cleanup.sh" }]
    }
  ]
}'

MERGED=$(jq --argjson hooks "$HOOKS_JSON" '.hooks = ($hooks + (.hooks // {}))' "$SETTINGS")
echo "$MERGED" > "$SETTINGS"

echo ""
echo "Done! Hooks installed to $HOOKS_DIR"
echo ""
echo "Next steps on iPhone:"
echo "  1. Settings → Notifications → Reminders → Allow Notifications: ON"
echo "  2. Banner style: Persistent"
echo "  3. If using Focus mode: add Reminders to allowed apps"
