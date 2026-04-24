#!/bin/bash
# on_pre_compact.sh — snapshot anchors before context compaction.
# Runs via Claude Code PreCompact hook.
# Creates timestamped copies of PROGRESS/DECISIONS/CONTEXT in .claude/anchors-backups/
# so nothing important is lost if compaction drops recent context.

set -u

PROJECT_DIR="$CLAUDE_PROJECT_DIR"
BACKUP_DIR="$PROJECT_DIR/.claude/anchors-backups"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)

for anchor in PROGRESS.md DECISIONS.md CONTEXT.md; do
  if [ -f "$PROJECT_DIR/$anchor" ]; then
    BASE="${anchor%.md}"
    cp "$PROJECT_DIR/$anchor" "$BACKUP_DIR/${BASE}-${TIMESTAMP}.md" 2>/dev/null || true
  fi
done

# Keep only the last 10 backups per anchor (rolling window)
for base in PROGRESS DECISIONS CONTEXT; do
  ls -1t "$BACKUP_DIR/${base}-"*.md 2>/dev/null | tail -n +11 | while read -r old; do
    rm -f "$old" 2>/dev/null || true
  done
done

echo "Anchor snapshots saved to .claude/anchors-backups/ before compaction." >&2

exit 0
