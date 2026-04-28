---
name: odkrywaj-anchors
description: Scaffold 8 project anchor markdown files (STARTWORK, CONTEXT, FILEMAP, TECHSTACK, WORKFLOW, PROGRESS, DECISIONS, ENDWORK) plus optional Claude Code hooks so Claude keeps full project memory across sessions and stops re-asking resolved questions. Trigger on magic words "Odkrywaj potencjał", "Kotwica!", "Accio anchors", "ustaw anchory", "bootstrap anchors", "set up anchor files". Also trigger WITHOUT magic words when the user describes the underlying problem — "Claude forgets between sessions", "persistent memory for my codebase", "stop Claude re-proposing rejected ideas", or any equivalent complaint about losing project context across Claude Code sessions. Run before serious multi-session work on a growing repo.
---

# Project Anchors

## Why this exists

Claude Code sessions forget. On any project bigger than a weekend hack, users waste the first 10 minutes of every session re-explaining what the code does, what was tried, and what was rejected. This skill drops 8 small markdown files in the project root that Claude reads on demand.

Key insight: **STARTWORK.md is a router, not a document.** It points Claude at the right anchor for the current task (CONTEXT for big picture, FILEMAP for navigation, DECISIONS for rejected approaches). Loading STARTWORK first, then pulling one relevant anchor, beats stuffing one giant CLAUDE.md.

## Modes (auto-detected from project state)

Before doing anything, check the project root for any of: `STARTWORK.md`, `CONTEXT.md`, `FILEMAP.md`, `TECHSTACK.md`, `WORKFLOW.md`, `PROGRESS.md`, `DECISIONS.md`, `ENDWORK.md`.

- **Init mode** — no anchor files exist. Run the full flow: scan → ask gaps → write 8 files → offer hooks.
- **Update mode** — at least one anchor exists. Stop and offer three choices: refresh from scan (per-file diff, preserve hand-edited prose), fill missing only, or cancel. Never silently clobber a hand-edited anchor.
- **Hooks-only mode** — all 8 anchors exist and the user asks to install hooks. Skip scan + questions, jump to Step 4.

## Workflow

### Step 1 — Scan

Run `scripts/scan_project.sh` from this skill's directory against the project root. It returns: top-level tree (depth 2), detected stack from manifests, last 10 commits, README/CLAUDE.md excerpts, folder file counts. Treat this as ground truth for TECHSTACK and FILEMAP — most of what the anchors need is already here. If the scan returns nothing (fresh repo, missing tools), fall back to manual Q&A; never abort on scan failure.

### Step 2 — Ask only the gaps

At most **four** questions, one at a time, and only for things the scan couldn't determine:

1. **One-sentence project description** — only if README is missing or uninformative.
2. **Target audience / user** — who is this for?
3. **What we're explicitly NOT doing** — highest-value field. A clear "not-doing" list stops Claude from re-proposing rejected directions. Push gently; vague answers fine, empty answers not.
4. **Current sprint goal** — what is the user focused on right now?

Asking less is better than asking thoroughly. If the scan answered everything, ask nothing.

### Step 3 — Generate anchors

Read templates from `assets/anchors/`. Replace `{{PLACEHOLDERS}}` with scan data and answers. Write all 8 files to the **project root** — not `.claude/`, not a subfolder. Anchors are living documents the user edits daily. Use **relative paths** (`./CONTEXT.md`) in cross-references.

### Step 4 — Offer hooks

Ask: "Install Claude Code hooks so STARTWORK.md auto-loads on every session start and ENDWORK triggers on 'kończymy' / 'endwork'? (Y/n)"

- **Y:** copy `assets/hooks/` contents into the project's `.claude/`. If `.claude/settings.json` already exists, **merge** new hooks into the existing config, dedupe by command, preserve every other key. If merge is ambiguous (malformed JSON, schema conflict), stop and show the user both files.
- **N:** skip. Tell the user they can re-run the skill later in hooks-only mode.

### Step 5 — Hand off

Print: files created, hooks status, next step ("Start a fresh session and say 'pracujemy nad projektem' or 'let's work on the project' — STARTWORK loads, Claude knows where to look"). Do not edit further in the same turn. Fresh session, clean context, anchor-driven is the whole point.

## The 8 files

| File | Loaded when | Purpose |
|------|-------------|---------|
| `STARTWORK.md` | Every session start (router) | One-page map pointing to the other 7. ≤50 lines. |
| `CONTEXT.md` | Task touches product goals or audience | Why, who for, what success looks like, what we're NOT building. |
| `FILEMAP.md` | Claude needs to find code | Top-level folder layout + one-line purpose per folder. |
| `TECHSTACK.md` | Task is technical | Languages, frameworks, key deps, runtime, deploy target, versions that matter. |
| `WORKFLOW.md` | Task touches dev process | Run / test / deploy commands. Git conventions. |
| `PROGRESS.md` | Planning next steps | Done, in-progress, next, blocked. Updated at session end. |
| `DECISIONS.md` | Evaluating approaches | Decisions and **why**, append-only. Stops re-proposing rejected paths. |
| `ENDWORK.md` | Session close ("kończymy" / "endwork") | Wrap-up checklist: update PROGRESS, log new DECISIONS, commit, push. |

STARTWORK is the entry, ENDWORK is the exit, the middle six load on demand. Middle anchors stay under ~150 lines each. Past that they become noise — move overflow into `docs/` or a real spec.

## Merge strategy (re-runs)

- **Never silently overwrite user content.** If a file's shape doesn't match the original template, treat it as user-edited and ask before writing.
- **Per-file diff and confirm** in update mode. No bulk overwrite.
- **`.claude/settings.json` merges, never clobbers.** Parse, merge, dedupe by command, preserve other keys. On failure, stop and hand the user both files.
- **DECISIONS.md is append-only.** Never rewrite existing entries. Only add new ones, only on explicit request.

## Principles (use when rules above don't cover an edge case)

1. **Anchors are user property.** A non-empty anchor on re-run is assumed user-edited; protect it.
2. **User input beats scan.** If the user says "we're a Go shop" and scan found a stray `package.json`, believe the user.
3. **TBD beats invented content.** Empty template fields get `TBD`, never a guessed framework. A `TBD` invites the user to fill it in; a hallucination misleads every future session.
4. **Less context per session > more files.** Every anchor earns its place by saving a bigger reload. If an anchor stops doing that, it shrinks or merges.

For worked examples on three contrasting projects, see `references/examples.md`.
