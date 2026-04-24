#!/bin/bash
# scan_project.sh — gather project info for odkrywaj-anchors
# Usage: scan_project.sh [project_dir]  (defaults to current directory)
# Output: markdown-structured report to stdout, designed for Claude Code to parse.

set -u

PROJECT_DIR="${1:-$(pwd)}"
cd "$PROJECT_DIR" || { echo "ERROR: cannot cd into $PROJECT_DIR" >&2; exit 1; }

echo "# Project Scan"
echo ""
echo "**Path**: $PROJECT_DIR"
echo "**Scan date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# --- Top-level tree (depth 2) ---
echo "## Tree (depth 2)"
echo ""
echo '```'
if command -v tree >/dev/null 2>&1; then
  tree -L 2 -I 'node_modules|.git|dist|build|target|__pycache__|.next|.nuxt|venv|.venv|.svelte-kit' --dirsfirst 2>/dev/null | head -100 || true
else
  find . -maxdepth 2 \
    -not -path '*/node_modules*' \
    -not -path '*/.git*' \
    -not -path '*/dist*' \
    -not -path '*/build*' \
    -not -path '*/target*' \
    -not -path '*/__pycache__*' \
    -not -path '*/.next*' \
    -not -path '*/.venv*' \
    2>/dev/null | sort | head -100 || true
fi
echo '```'
echo ""

# --- Detected stack ---
echo "## Detected stack"
echo ""
STACK_FOUND=0

if [ -f "package.json" ]; then
  STACK_FOUND=1
  echo "### Node.js (package.json)"
  echo ""
  if command -v jq >/dev/null 2>&1; then
    NAME=$(jq -r '.name // "unknown"' package.json 2>/dev/null || echo "unknown")
    VERSION=$(jq -r '.version // "unknown"' package.json 2>/dev/null || echo "unknown")
    DESC=$(jq -r '.description // ""' package.json 2>/dev/null || echo "")
    echo "- **Name**: $NAME"
    echo "- **Version**: $VERSION"
    [ -n "$DESC" ] && echo "- **Description**: $DESC"
    echo "- **Dependencies** (top 20):"
    jq -r '.dependencies // {} | to_entries | .[] | "  - \(.key): \(.value)"' package.json 2>/dev/null | head -20 || true
    echo "- **Dev dependencies** (top 10):"
    jq -r '.devDependencies // {} | to_entries | .[] | "  - \(.key): \(.value)"' package.json 2>/dev/null | head -10 || true
    echo "- **Scripts**:"
    jq -r '.scripts // {} | to_entries | .[] | "  - \(.key): \(.value)"' package.json 2>/dev/null | head -10 || true
  else
    echo "_(install jq for dependency details — package.json exists)_"
  fi
  echo ""
fi

if [ -f "pyproject.toml" ]; then
  STACK_FOUND=1
  echo "### Python (pyproject.toml)"
  echo ""
  echo '```toml'
  head -40 pyproject.toml 2>/dev/null || true
  echo '```'
  echo ""
fi

if [ -f "requirements.txt" ]; then
  STACK_FOUND=1
  echo "### Python (requirements.txt)"
  echo ""
  echo '```'
  head -30 requirements.txt 2>/dev/null || true
  echo '```'
  echo ""
fi

if [ -f "Cargo.toml" ]; then
  STACK_FOUND=1
  echo "### Rust (Cargo.toml)"
  echo ""
  echo '```toml'
  head -40 Cargo.toml 2>/dev/null || true
  echo '```'
  echo ""
fi

if [ -f "go.mod" ]; then
  STACK_FOUND=1
  echo "### Go (go.mod)"
  echo ""
  echo '```'
  head -30 go.mod 2>/dev/null || true
  echo '```'
  echo ""
fi

if [ -f "Gemfile" ]; then
  STACK_FOUND=1
  echo "### Ruby (Gemfile)"
  echo ""
  echo '```ruby'
  head -30 Gemfile 2>/dev/null || true
  echo '```'
  echo ""
fi

if [ -f "composer.json" ]; then
  STACK_FOUND=1
  echo "### PHP (composer.json)"
  echo ""
  if command -v jq >/dev/null 2>&1; then
    jq -r '"- Name: \(.name // "unknown")"' composer.json 2>/dev/null || true
    echo "- Requires:"
    jq -r '.require // {} | to_entries | .[] | "  - \(.key): \(.value)"' composer.json 2>/dev/null | head -20 || true
  else
    head -30 composer.json 2>/dev/null || true
  fi
  echo ""
fi

if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  STACK_FOUND=1
  echo "### JVM"
  [ -f "pom.xml" ] && echo "- Maven project (pom.xml)"
  [ -f "build.gradle" ] && echo "- Gradle project (build.gradle)"
  [ -f "build.gradle.kts" ] && echo "- Gradle project (build.gradle.kts)"
  echo ""
fi

# Frontend framework detection (config files)
FRONTEND_FOUND=0
if [ -f "svelte.config.js" ] || [ -f "astro.config.mjs" ] || [ -f "astro.config.ts" ] || [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "nuxt.config.ts" ] || [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
  FRONTEND_FOUND=1
  STACK_FOUND=1
  echo "### Frontend framework"
  [ -f "svelte.config.js" ] && echo "- SvelteKit"
  { [ -f "astro.config.mjs" ] || [ -f "astro.config.ts" ]; } && echo "- Astro"
  { [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; } && echo "- Next.js"
  [ -f "nuxt.config.ts" ] && echo "- Nuxt"
  { [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; } && echo "- Vite"
  echo ""
fi

if [ "$STACK_FOUND" = "0" ]; then
  echo "_No standard manifest files detected. Ask the user about the stack._"
  echo ""
fi

# --- Recent commits ---
echo "## Recent commits"
echo ""
if [ -d ".git" ] && command -v git >/dev/null 2>&1; then
  echo '```'
  git log --oneline -n 10 2>/dev/null || echo "(git log failed or empty repo)"
  echo '```'
else
  echo "_Not a git repository, or git not installed._"
fi
echo ""

# --- README excerpt ---
echo "## Existing README"
echo ""
if [ -f "README.md" ]; then
  echo '```markdown'
  head -40 README.md 2>/dev/null || true
  echo '```'
else
  echo "_No README.md found._"
fi
echo ""

# --- CLAUDE.md ---
echo "## Existing CLAUDE.md"
echo ""
if [ -f "CLAUDE.md" ]; then
  echo '```markdown'
  head -50 CLAUDE.md 2>/dev/null || true
  echo '```'
elif [ -f ".claude/CLAUDE.md" ]; then
  echo '```markdown'
  head -50 .claude/CLAUDE.md 2>/dev/null || true
  echo '```'
else
  echo "_No CLAUDE.md found._"
fi
echo ""

# --- Existing anchors ---
echo "## Existing anchors"
echo ""
ANCHORS_FOUND=0
for anchor in STARTWORK.md CONTEXT.md FILEMAP.md TECHSTACK.md WORKFLOW.md PROGRESS.md DECISIONS.md ENDWORK.md; do
  if [ -f "$anchor" ]; then
    ANCHORS_FOUND=1
    LINES=$(wc -l < "$anchor" 2>/dev/null || echo "?")
    echo "- \`$anchor\` exists ($LINES lines)"
  fi
done
if [ "$ANCHORS_FOUND" = "0" ]; then
  echo "_No anchor files present. Skill runs in **init mode**._"
else
  echo ""
  echo "_Anchor files present — skill should run in **update mode**, check with the user before overwriting._"
fi
echo ""

# --- Folder file counts ---
echo "## Top-level folder file counts"
echo ""
find . -maxdepth 1 -type d \
  -not -name '.' \
  -not -name '.git' \
  -not -name 'node_modules' \
  -not -name '.next' \
  -not -name '.venv' \
  -not -name 'venv' \
  -not -name 'dist' \
  -not -name 'build' \
  -not -name 'target' \
  2>/dev/null | sort | while read -r dir; do
  COUNT=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo "- \`$dir\`: $COUNT files"
done
echo ""

echo "---"
echo "_Scan complete. Use this as ground truth — ask user only for gaps._"
