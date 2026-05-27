#!/usr/bin/env bash
# Deletes "Claude Code" reminders 60 seconds after tool use is confirmed.
# Runs deletion in background so Claude Code is not blocked.

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

cat > /dev/null  # consume stdin

printf 'Claude Code' > /tmp/claude_hook_title.txt

(
  sleep 60
  osascript <<'APPLESCRIPT' 2>/dev/null
set titleFile to "/tmp/claude_hook_title.txt"
set fRef to open for access POSIX file titleFile
set titleText to read fRef as «class utf8»
close access fRef

tell application "Reminders"
  set toDelete to (reminders of first list whose name is titleText)
  repeat with r in toDelete
    delete r
  end repeat
end tell
APPLESCRIPT
) &

exit 0
