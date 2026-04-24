#!/bin/bash
# on_session_start.sh — inject STARTWORK.md into Claude's context on every session start.
# Runs via Claude Code SessionStart hook. Stdout is added to context automatically.

STARTWORK="$CLAUDE_PROJECT_DIR/STARTWORK.md"

if [ -f "$STARTWORK" ]; then
  echo "--- Project anchors (auto-loaded from STARTWORK.md) ---"
  cat "$STARTWORK"
  echo ""
  echo "--- End STARTWORK.md ---"
fi

exit 0
