# Changelog

All notable changes to `odkrywaj-organizator` (formerly `odkrywaj-anchors`) are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] — 2026-04-28

**BREAKING — full rename from `odkrywaj-anchors` → `odkrywaj-organizator`.** The product, the concept, and the magic words all change. There is no auto-migration of existing user content; users on v0.2.x must reinstall and re-trigger the scaffold.

### Changed

- **Plugin name**: `odkrywaj-anchors` → `odkrywaj-organizator`. New install command:
  ```
  /plugin marketplace add odkrywaj-ai/odkrywaj-organizator
  /plugin install odkrywaj-organizator
  ```
- **GitHub repository**: renamed `odkrywaj-ai/odkrywaj-anchors` → `odkrywaj-ai/odkrywaj-organizator`. GitHub serves redirects from the old name for ~30 days, but update bookmarks and CI references.
- **Skill directory**: `skills/odkrywaj-anchors/` → `skills/odkrywaj-organizator/`.
- **Asset directory**: `skills/.../assets/anchors/` → `skills/.../assets/organizator/`.
- **Concept terminology**: "anchor file" → "organizator file"; "the anchors" → "the organizator" or "the organizator files" depending on context. The 8 file names themselves (`STARTWORK.md`, `CONTEXT.md`, …, `ENDWORK.md`) are unchanged.
- **Backup directory**: `.claude/anchors-backups/` → `.claude/organizator-backups/`. Existing user backups under the old path are NOT migrated — old files stay where they are; new snapshots write to the new path.
- **`displayName`** in plugin manifest: "Odkrywaj Anchors" → "Odkrywaj Organizator".

### Magic words (replaced — old triggers removed)

- `Organizuj!`
- `ustaw organizatora`
- `Accio organizator`
- `bootstrap organizator`
- `set up organizator files`

Removed (no longer trigger the skill): `Kotwica!`, `Odkrywaj potencjał`, `Odkrywaj projekt`, `Accio anchors`, `ustaw anchory`, `ustaw kotwice`, `bootstrap anchors`, `set up anchor files`.

### Migration

- **`/plugin install odkrywaj-anchors` users**: run `/plugin uninstall odkrywaj-anchors` then `/plugin marketplace add odkrywaj-ai/odkrywaj-organizator` + `/plugin install odkrywaj-organizator`.
- **`install.sh` users**: re-run the script. It auto-removes legacy `~/.claude/skills/odkrywaj-anchors` and `~/.claude/skills/.odkrywaj-anchors-source` paths and installs to the new `~/.claude/skills/odkrywaj-organizator` location.
- **Per-project files** (`STARTWORK.md`, `CONTEXT.md`, …, `ENDWORK.md`): unchanged. No user-project edits required.
- **Per-project hooks** (`.claude/settings.json` + `.claude/hooks/`): re-run the skill in hooks-only mode to pick up the new backup-dir name. Old `.claude/anchors-backups/` directories can be deleted manually if you want.

## [0.2.1] — 2026-04-28

Robustness and reviewer-flagged bugfixes. No breaking changes.

### Fixed

- **CRITICAL — `assets/hooks/on_user_prompt.sh`**: end-session trigger regex no longer false-positives on common prompts like "gg generate a graph", "wrap up this function", or "endwork is hard, please refactor". Triggers now require the keyword to stand alone (modulo whitespace + `!.?` punctuation). Verified with 12-case unit test.
- **HIGH — `assets/hooks/on_pre_compact.sh`**: refuses to run if `CLAUDE_PROJECT_DIR` is unset or invalid (prevented `$BACKUP_DIR` collapsing to `/anchors-backups`). Rolling-window cleanup rewritten with `find -print0` so empty matches and odd filenames are safe; final `rm` guarded with `case` check that path is inside `$BACKUP_DIR`.
- **HIGH — `install.sh`**: `set -euo pipefail` so partial failures don't ship a half-installed skill. `git clone`/`pull` errors now surface to the user instead of being swallowed by `2>&1`. Pre-check refuses to operate on `/`, `$HOME`, or empty `$SKILL_DIR`. Hand-edited content in `$SKILL_DIR` is moved to a `.bak-<timestamp>` directory rather than nuked.
- **HIGH — `.claude-plugin/plugin.json`**: added `engines.claude-code` constraint and `displayName` so the `/plugin` UI surfaces a friendly name and older clients fail clean.
- **MEDIUM — `.claude-plugin/marketplace.json`**: removed duplicate `version`/`author`/`license` fields (now resolved from `plugin.json`, no drift on bumps).
- **MEDIUM — `assets/hooks/on_session_start.sh`**: added `set -u` and a `CLAUDE_PROJECT_DIR` guard.
- **MEDIUM — `scripts/scan_project.sh`**: `date -u +...Z` now falls back to `date +%s` on busybox; folder-iteration uses `find -print0` so paths with spaces (common on Windows) work.

### Added

- **`scripts/scan_project.sh`** — `take N` helper replaces `head -N` calls and appends `_(truncated; X more line(s))_` markers when output is clipped, so Claude knows the data was truncated instead of silently working with a half-view.

### Changed

- **`SKILL.md` frontmatter `description`** — trimmed from 908 chars to ~700 by dropping redundant trigger paraphrases. Stays well under the 1024-char Anthropic recommendation while keeping every distinct trigger phrase.

## [0.2.0] — 2026-04-28

Repackaged as a Claude Code plugin with marketplace manifest. One-command install via `/plugin`.

### Added

- `.claude-plugin/plugin.json` — plugin manifest (name, version, author, repo, license, keywords).
- `.claude-plugin/marketplace.json` — self-marketplace so users can `/plugin marketplace add odkrywaj-ai/odkrywaj-anchors` then `/plugin install odkrywaj-anchors`.
- Plugin layout: skill content moved to `skills/odkrywaj-anchors/` (`SKILL.md`, `assets/`, `scripts/`, `references/`).

### Changed

- Tightened `SKILL.md` — removed duplication between "Modes" and intro existence-check, merged "Gotchas" and "What anchors are NOT" into "Merge strategy" + "Principles" sections, trimmed prose without losing rules.
- README install section now leads with `/plugin marketplace add` and keeps `install.sh` as a fallback for users without plugin support.

### Migration

- Users who installed v0.1.0 by cloning to `~/.claude/skills/odkrywaj-anchors/`: re-run `install.sh` (it now points at the new layout) or remove the old clone and install via the plugin command.

## [0.1.0] — 2026-04-24

First public release.

### Added

- `SKILL.md` with 8 magic-word triggers (`Kotwica!`, `Odkrywaj potencjał`, `Accio anchors`, `ustaw anchory`, `ustaw kotwice`, `bootstrap anchors`, `set up anchor files`, `Odkrywaj projekt`) and problem-description triggers.
- 8 anchor templates with `{{UPPERCASE_SNAKE_CASE}}` placeholders: `STARTWORK`, `CONTEXT`, `FILEMAP`, `TECHSTACK`, `WORKFLOW`, `PROGRESS`, `DECISIONS`, `ENDWORK`.
- `scripts/scan_project.sh` — deterministic project scanner. Detects Node, Python, Rust, Go, Ruby, PHP, JVM, and frontend frameworks (SvelteKit, Astro, Next.js, Nuxt, Vite). Graceful fallbacks for missing `jq`, `tree`, `git`.
- Three Claude Code hooks:
  - `SessionStart` — auto-loads `STARTWORK.md` into context on every new / resumed session.
  - `UserPromptSubmit` — detects session-close triggers and injects `ENDWORK.md` checklist.
  - `PreCompact` — snapshots `PROGRESS`, `DECISIONS`, `CONTEXT` into `.claude/anchors-backups/` before compaction. Rolling window of 10.
- Three operating modes: init, update, hooks-only — auto-detected from project state.
- Merge strategy protecting user-edited content on re-runs.
- `references/examples.md` with fully populated anchors on three contrasting projects (SvelteKit product, content agency, solo Rust project).
- `install.sh` one-liner installer with pre-flight checks and soft dependency warnings.

[0.3.0]: https://github.com/odkrywaj-ai/odkrywaj-organizator/releases/tag/v0.3.0
[0.2.1]: https://github.com/odkrywaj-ai/odkrywaj-organizator/releases/tag/v0.2.1
[0.2.0]: https://github.com/odkrywaj-ai/odkrywaj-organizator/releases/tag/v0.2.0
[0.1.0]: https://github.com/odkrywaj-ai/odkrywaj-organizator/releases/tag/v0.1.0
