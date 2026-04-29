#!/bin/bash
# on_pre_compact.sh — snapshot organizator files before context compaction.
# Runs via Claude Code PreCompact hook.
# Creates timestamped copies of PROGRESS/DECISIONS/CONTEXT in .claude/organizator-backups/
# so nothing important is lost if compaction drops recent context.

set -u

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"

# Guard: refuse to run without a known project root — never let $BACKUP_DIR resolve to
# something like "/organizator-backups" or the cwd if CLAUDE_PROJECT_DIR is unset.
if [ -z "$PROJECT_DIR" ] || [ ! -d "$PROJECT_DIR" ]; then
  echo "on_pre_compact: CLAUDE_PROJECT_DIR unset or invalid; skipping snapshot." >&2
  exit 0
fi

BACKUP_DIR="$PROJECT_DIR/.claude/organizator-backups"
mkdir -p "$BACKUP_DIR" || exit 0

TIMESTAMP=$(date -u +%Y%m%d-%H%M%S 2>/dev/null || date +%s)

for entry in PROGRESS.md DECISIONS.md CONTEXT.md; do
  if [ -f "$PROJECT_DIR/$entry" ]; then
    base="${entry%.md}"
    cp "$PROJECT_DIR/$entry" "$BACKUP_DIR/${base}-${TIMESTAMP}.md" 2>/dev/null || true
  fi
done

# Rolling window: keep only the 10 newest backups per organizator file base name.
# Use find over `ls | tail | rm` so empty matches and odd filenames are safe.
for base in PROGRESS DECISIONS CONTEXT; do
  # Sort newest-first by mtime, drop first 10 (kept), delete the rest.
  find "$BACKUP_DIR" -maxdepth 1 -type f -name "${base}-*.md" -print0 2>/dev/null \
    | xargs -0 -r ls -1t 2>/dev/null \
    | tail -n +11 \
    | while IFS= read -r old; do
        # Final safety: only delete files inside $BACKUP_DIR.
        case "$old" in
          "$BACKUP_DIR"/*) rm -f -- "$old" 2>/dev/null || true ;;
        esac
      done
done

echo "Organizator snapshots saved to .claude/organizator-backups/ before compaction." >&2

exit 0
