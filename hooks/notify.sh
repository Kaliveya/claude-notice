#!/usr/bin/env bash
# Creates an iCloud Reminder when Claude Code is about to use a tool.
# Description is written to a temp file to avoid AppleScript string-escaping bugs.

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

LOGFILE="/tmp/claude_hook.log"
DESC_FILE="/tmp/claude_hook_desc.txt"
TITLE_FILE="/tmp/claude_hook_title.txt"

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')

case "$TOOL" in
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
    DESC="${CMD:0:80}"
    ;;
  Write)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
    DESC="Write: $(basename "$FILE")"
    ;;
  Edit)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
    DESC="Edit: $(basename "$FILE")"
    ;;
  *)
    DESC="Tool: $TOOL"
    ;;
esac

# Write strings to files — avoids all AppleScript encoding/escaping issues
printf '%s' "$DESC" > "$DESC_FILE"
printf 'Claude Code 待审批' > "$TITLE_FILE"

# Create iCloud Reminder; all strings read from files (no Chinese in script body)
osascript <<'APPLESCRIPT' 2>>"$LOGFILE"
set descFile to "/tmp/claude_hook_desc.txt"
set titleFile to "/tmp/claude_hook_title.txt"

set fRef to open for access POSIX file descFile
set descText to read fRef as «class utf8»
close access fRef

set fRef to open for access POSIX file titleFile
set titleText to read fRef as «class utf8»
close access fRef

tell application "Reminders"
  set theList to first list
  set alertTime to current date
  set r to make new reminder at end of reminders of theList
  set name of r to titleText
  set body of r to descText
  set due date of r to alertTime
  set remind me date of r to alertTime
end tell
APPLESCRIPT

RESULT=$?
echo "[$(date '+%H:%M:%S')] tool=$TOOL result=$RESULT desc=$DESC" >> "$LOGFILE"

# macOS banner notification — also reads from files
osascript <<'APPLESCRIPT' 2>>"$LOGFILE"
set descFile to "/tmp/claude_hook_desc.txt"
set titleFile to "/tmp/claude_hook_title.txt"

set fRef to open for access POSIX file descFile
set descText to read fRef as «class utf8»
close access fRef

set fRef to open for access POSIX file titleFile
set titleText to read fRef as «class utf8»
close access fRef

display notification descText with title titleText sound name "Glass"
APPLESCRIPT

exit 0
