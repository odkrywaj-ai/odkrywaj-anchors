#!/bin/bash
# on_user_prompt.sh — detect session-close triggers and inject ENDWORK.md.
# Runs via Claude Code UserPromptSubmit hook.
# If user types "kończymy" / "endwork" / "gg" / "wrapping up" / etc.,
# injects ENDWORK.md content as additionalContext so Claude runs the checklist.

set -u

INPUT=$(cat)

# Extract prompt (jq required; if missing, silently pass through)
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || echo "")

if [ -z "$PROMPT" ]; then
  exit 0
fi

# Case-insensitive match on end-session triggers at start of prompt
# (word boundary via \b so "gg wp" matches, "ggplot2" does not)
TRIGGER_REGEX='^(kończymy|konczymy|endwork|end work|gg|wrapping up|wrap up|end of session|koniec sesji|kończ sesję|koncz sesje)\b'

if echo "$PROMPT" | grep -iE "$TRIGGER_REGEX" >/dev/null 2>&1; then
  ENDWORK="$CLAUDE_PROJECT_DIR/ENDWORK.md"
  if [ -f "$ENDWORK" ]; then
    CONTENT=$(cat "$ENDWORK")
    jq -n \
      --arg ctx "User is closing the session. Run this ENDWORK checklist before responding:

$CONTENT" \
      '{
        hookSpecificOutput: {
          hookEventName: "UserPromptSubmit",
          additionalContext: $ctx
        }
      }'
  fi
fi

exit 0
