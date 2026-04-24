# Changelog

All notable changes to `odkrywaj-anchors` are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.1.0]: https://github.com/odkrywaj-ai/odkrywaj-anchors/releases/tag/v0.1.0
