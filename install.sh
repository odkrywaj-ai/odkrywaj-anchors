#!/bin/bash
# install.sh — fallback installer for odkrywaj-anchors (when /plugin is unavailable)
# Recommended: use `/plugin marketplace add odkrywaj-ai/odkrywaj-anchors` inside Claude Code.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/odkrywaj-ai/odkrywaj-anchors/main/install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/odkrywaj-ai/odkrywaj-anchors.git"
SOURCE_DIR="$HOME/.claude/skills/.odkrywaj-anchors-source"
SKILL_DIR="$HOME/.claude/skills/odkrywaj-anchors"

# Sanity: never let SKILL_DIR collapse to a dangerous path (empty / root / $HOME).
case "$SKILL_DIR" in
  ""|"/"|"$HOME"|"$HOME/") echo "Refusing to operate on $SKILL_DIR" >&2; exit 1 ;;
esac

# Colors (tty only)
if [ -t 1 ]; then
  C_ORANGE='\033[0;33m'
  C_GREEN='\033[0;32m'
  C_RED='\033[0;31m'
  C_DIM='\033[2m'
  C_RESET='\033[0m'
else
  C_ORANGE=''; C_GREEN=''; C_RED=''; C_DIM=''; C_RESET=''
fi

say()  { printf "%b\n" "${C_ORANGE}▸${C_RESET} $*"; }
ok()   { printf "%b\n" "${C_GREEN}✓${C_RESET} $*"; }
die()  { printf "%b\n" "${C_RED}✗${C_RESET} $*" >&2; exit 1; }

# --- Pre-flight ---
command -v git >/dev/null 2>&1 || die "git is required but not installed."
command -v bash >/dev/null 2>&1 || die "bash is required but not installed."

printf "\n"
printf "%b\n" "${C_ORANGE}odkrywaj-anchors${C_RESET} ${C_DIM}· Claude Code skill installer${C_RESET}"
printf "%b\n" "${C_DIM}https://github.com/odkrywaj-ai/odkrywaj-anchors${C_RESET}"
printf "\n"

# --- Clone or update repo source ---
if [ -d "$SOURCE_DIR/.git" ]; then
  say "Updating existing source at $SOURCE_DIR"
  # Surface git's real error to the user — auth/DNS/network issues are otherwise opaque.
  git -C "$SOURCE_DIR" pull --ff-only || die "git pull failed (see error above)."
elif [ -d "$SOURCE_DIR" ]; then
  die "$SOURCE_DIR exists but is not a git checkout. Remove it first: rm -rf \"$SOURCE_DIR\""
else
  say "Cloning into $SOURCE_DIR..."
  mkdir -p "$(dirname "$SOURCE_DIR")"
  git clone --depth 1 "$REPO_URL" "$SOURCE_DIR" || die "git clone failed (see error above)."
fi

# --- Migrate v0.1.0 layout (if user previously cloned the repo over $SKILL_DIR) ---
if [ -d "$SKILL_DIR/.git" ]; then
  say "Removing legacy v0.1.x layout at $SKILL_DIR (migrated to plugin layout)"
  rm -rf -- "$SKILL_DIR"
fi

# --- Mirror the skill directory ---
PLUGIN_SKILL_DIR="$SOURCE_DIR/skills/odkrywaj-anchors"
[ -d "$PLUGIN_SKILL_DIR" ] || die "Source layout missing $PLUGIN_SKILL_DIR — install is broken."

# Replace SKILL_DIR contents only after we have verified source. If users have
# hand-edited content we don't ship (custom hooks etc.), back it up rather than nuke.
if [ -d "$SKILL_DIR" ]; then
  STRAYS=$(find "$SKILL_DIR" -maxdepth 1 -mindepth 1 \
    ! -name 'SKILL.md' ! -name 'assets' ! -name 'scripts' ! -name 'references' \
    -print 2>/dev/null | head -1)
  if [ -n "$STRAYS" ]; then
    BACKUP="${SKILL_DIR}.bak-$(date +%s)"
    say "Backing up unexpected files in $SKILL_DIR to $BACKUP"
    mv -- "$SKILL_DIR" "$BACKUP" || die "Failed to back up existing $SKILL_DIR."
  else
    rm -rf -- "$SKILL_DIR"
  fi
fi

cp -R -- "$PLUGIN_SKILL_DIR" "$SKILL_DIR" || die "Failed to copy skill files."

# --- Verify ---
[ -f "$SKILL_DIR/SKILL.md" ] || die "SKILL.md missing after install — something went wrong."
[ -d "$SKILL_DIR/assets/anchors" ] || die "assets/anchors missing — install is broken."
[ -d "$SKILL_DIR/scripts" ] || die "scripts missing — install is broken."

ok "Installed at $SKILL_DIR"

# --- Soft dependency checks ---
MISSING=""
command -v jq >/dev/null 2>&1 || MISSING="${MISSING}jq "
command -v tree >/dev/null 2>&1 || MISSING="${MISSING}tree "

printf "\n"
ok "odkrywaj-anchors is ready."
printf "\n"
printf "   %bNext:%b start a Claude Code session in any project and type:\n" "${C_DIM}" "${C_RESET}"
printf "         ${C_ORANGE}Kotwica!${C_RESET}   (or: ${C_DIM}ustaw anchory${C_RESET}, ${C_DIM}Accio anchors${C_RESET})\n"
printf "\n"

if [ -n "$MISSING" ]; then
  printf "   %bOptional:%b install \`${MISSING% }\` for full feature support.\n" "${C_DIM}" "${C_RESET}"
  printf "             The skill degrades gracefully without them.\n"
  printf "\n"
fi

printf "   %bTip:%b for one-command install/update, use the plugin route:\n" "${C_DIM}" "${C_RESET}"
printf "         ${C_DIM}/plugin marketplace add odkrywaj-ai/odkrywaj-anchors${C_RESET}\n"
printf "         ${C_DIM}/plugin install odkrywaj-anchors${C_RESET}\n"
printf "\n"
