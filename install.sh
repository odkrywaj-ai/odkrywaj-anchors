#!/bin/bash
# install.sh — one-liner installer for odkrywaj-anchors
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/odkrywaj-ai/odkrywaj-anchors/main/install.sh | bash
# Or clone manually — see README.md.

set -eu

REPO_URL="https://github.com/odkrywaj-ai/odkrywaj-anchors.git"
SKILL_DIR="$HOME/.claude/skills/odkrywaj-anchors"

# Colors (tty only)
if [ -t 1 ]; then
  C_ORANGE='\033[0;33m'
  C_GREEN='\033[0;32m'
  C_RED='\033[0;31m'
  C_DIM='\033[2m'
  C_RESET='\033[0m'
else
  C_ORANGE=''
  C_GREEN=''
  C_RED=''
  C_DIM=''
  C_RESET=''
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

# --- Handle existing install ---
if [ -d "$SKILL_DIR" ]; then
  say "Found existing install at $SKILL_DIR"
  if [ -d "$SKILL_DIR/.git" ]; then
    say "Pulling latest changes..."
    git -C "$SKILL_DIR" pull --ff-only || die "git pull failed. Fix manually or reinstall."
    ok "Updated."
  else
    die "$SKILL_DIR exists but is not a git checkout. Remove it first: rm -rf $SKILL_DIR"
  fi
else
  say "Cloning into $SKILL_DIR..."
  mkdir -p "$(dirname "$SKILL_DIR")"
  git clone --depth 1 "$REPO_URL" "$SKILL_DIR" >/dev/null 2>&1 || die "git clone failed."
  ok "Installed."
fi

# --- Verify ---
[ -f "$SKILL_DIR/SKILL.md" ] || die "SKILL.md missing after install — something went wrong."
[ -d "$SKILL_DIR/assets/anchors" ] || die "assets/anchors missing — install is broken."
[ -d "$SKILL_DIR/scripts" ] || die "scripts missing — install is broken."

# --- Soft dependency checks ---
MISSING=""
command -v jq >/dev/null 2>&1 || MISSING="${MISSING}jq "
command -v tree >/dev/null 2>&1 || MISSING="${MISSING}tree "

printf "\n"
ok "odkrywaj-anchors is installed and ready."
printf "\n"
printf "   %bNext:%b start a Claude Code session in any project and type:\n" "${C_DIM}" "${C_RESET}"
printf "         ${C_ORANGE}Kotwica!${C_RESET}   (or: ${C_DIM}ustaw anchory${C_RESET}, ${C_DIM}Accio anchors${C_RESET})\n"
printf "\n"

if [ -n "$MISSING" ]; then
  printf "   %bOptional:%b install \`${MISSING% }\` for full feature support.\n" "${C_DIM}" "${C_RESET}"
  printf "             The skill degrades gracefully without them.\n"
  printf "\n"
fi
