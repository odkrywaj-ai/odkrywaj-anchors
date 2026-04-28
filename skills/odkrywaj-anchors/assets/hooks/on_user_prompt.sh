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

# Match end-session triggers ONLY when they are the entire prompt (modulo whitespace/punctuation).
# Bare "gg" / "wrap up" are too common in normal prompts ("gg generate X", "wrap up this function")
# so we require the trigger to stand alone, optionally followed by !, ., ?, or "wp" (gg wp).
TRIGGER_REGEX='^[[:space:]]*(kończymy|konczymy|endwork|end work|wrapping up|wrap up|end of session|koniec sesji|kończ sesję|koncz sesje|gg wp|gg)[[:space:]]*[!.?]*[[:space:]]*$'

if printf '%s' "$PROMPT" | grep -iE "$TRIGGER_REGEX" >/dev/null 2>&1; then
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
