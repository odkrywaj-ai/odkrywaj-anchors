---
name: odkrywaj-anchors
description: Scaffold 8 project anchor markdown files (STARTWORK, CONTEXT, FILEMAP, TECHSTACK, WORKFLOW, PROGRESS, DECISIONS, ENDWORK) plus optional Claude Code hooks so Claude keeps full project memory across sessions and stops re-asking resolved questions. Trigger on magic words "Odkrywaj potencjał", "Odkrywaj projekt", "Kotwica!", "Accio anchors", "ustaw anchory", "ustaw kotwice", "bootstrap anchors", "set up anchor files". Also trigger WITHOUT magic words whenever the user describes the underlying problem — "Claude forgets between sessions", "AI loses track of my project", "my project is too big for Claude to hold", "I want Claude to remember past decisions", "persistent memory for my codebase", "how do I stop Claude re-proposing stuff we already rejected", or any equivalent complaint about losing project context across Claude Code sessions. Run before any serious multi-session work on a growing repo.
---

# Project Anchors

## Why this exists

Claude Code sessions forget. On any project bigger than a weekend hack, users waste the first 10 minutes of every session re-explaining what the code does, what was already tried, and what directions were rejected. This skill fixes that by dropping 8 small markdown files in the project root that Claude reads on every session start.

The key insight: **STARTWORK.md is a router, not a document.** It tells Claude which other anchor to read for the current task (CONTEXT for the big picture, FILEMAP for navigation, DECISIONS for "why not that approach"). Loading STARTWORK first, then pulling the relevant anchor on demand, is cheaper and sharper than stuffing one giant CLAUDE.md.

## When to run

Run this skill when **any** of the following is true:

- The user types a trigger phrase: "Odkrywaj potencjał", "Odkrywaj projekt", "Kotwica!", "Accio anchors", "ustaw anchory", "ustaw kotwice", "bootstrap anchors", "set up anchor files".
- The user describes the persistent-memory problem: Claude forgetting between sessions, re-proposing rejected ideas, losing track of architecture, asking the same questions repeatedly, or wanting "memory" / "context" / "continuity" for a codebase.
- The user explicitly asks to initialize, bootstrap, or scaffold a project for long-term Claude Code use.

**Before generating anything, check if anchor files already exist** in the project root (any of STARTWORK.md, CONTEXT.md, FILEMAP.md, TECHSTACK.md, WORKFLOW.md, PROGRESS.md, DECISIONS.md, ENDWORK.md). If at least one exists, stop and ask the user: overwrite everything, fill only what's missing, or cancel. Never silently clobber a user's hand-edited anchors — that's their project memory.

## Workflow

### Step 1 — Scan the project

Run `scripts/scan_project.sh` from this skill's directory against the project root. The scan returns:

- File tree, depth 2 (top-level layout)
- Detected stack from manifests (`package.json`, `Cargo.toml`, `go.mod`, `requirements.txt`, `pyproject.toml`, `Gemfile`, etc.)
- Last 10 git commits (so you know what's been happening)
- Excerpts from existing `README.md` and `CLAUDE.md` if present
- List of top-level folders with file counts

Parse this output and treat it as ground truth for TECHSTACK and FILEMAP. **Most of what the anchors need is already here** — don't interrogate the user for things the scan already surfaced. If the scan fails or returns nothing (e.g. freshly initialized repo), fall back to manual Q&A; never abort the workflow on scan failure.

### Step 2 — Ask only the gaps

Ask at most **four** questions, one at a time, and only for information the scan couldn't determine. Typical gaps:

1. **One-sentence project description** — only if README is missing or uninformative.
2. **Target audience / user** — who is this for?
3. **What we're explicitly NOT doing** — this is the highest-value field. A clear "not-doing" list stops Claude from re-proposing directions the user has already rejected. Push a little here; vague answers are fine, empty answers are not.
4. **Current sprint goal** — what is the user focused on right now?

Asking less is better than asking thoroughly. If the scan answered everything, ask nothing and move on.

### Step 3 — Generate the 8 anchor files

Read the templates from this skill's `assets/anchors/` directory. Replace `{{PLACEHOLDERS}}` with scan data and user answers. Write all 8 files to the **project root**, not to `.claude/` or any subfolder. The user needs to see and edit them directly — anchors are living documents, not hidden config.

Use **relative paths** (`./CONTEXT.md`, `./DECISIONS.md`, etc.) in every cross-reference inside STARTWORK. Absolute paths break the moment the repo is cloned elsewhere.

### Step 4 — Offer hooks installation

Ask the user: "Install Claude Code hooks so STARTWORK.md auto-loads on every session start and ENDWORK triggers on 'kończymy' / 'endwork'? (Y/n)"

- **If Y:** copy `.claude/settings.json` and any hook scripts from this skill's `assets/hooks/` into the project's `.claude/` directory. **Critical:** if `.claude/settings.json` already exists in the project, merge the new hooks into the existing config — do not overwrite. If merging is ambiguous (conflicting hook names, different schema), stop and show the user both files and ask how to proceed.
- **If N:** skip hooks entirely. Tell the user they can re-run the skill later and pick hooks only.

### Step 5 — Confirm and hand off

Print a short summary:

- Files created (list them)
- Hooks status (installed / skipped)
- Next step: "Start a fresh Claude Code session and say 'pracujemy nad projektem' or 'let's work on the project' — STARTWORK will load and Claude will know where to look."

Do not launch into editing or further work in the same turn. The handoff is the whole point: fresh session, clean context, anchor-driven.

## The 8 files at a glance

| File | Loaded when | Purpose |
|------|-------------|---------|
| `STARTWORK.md` | Every session start (router) | One-page map pointing to the other 7. Claude reads this first and pulls only what the current task needs. |
| `CONTEXT.md` | When the task touches product goals or audience | Why this project exists, who uses it, what success looks like, what we are NOT building. |
| `FILEMAP.md` | When Claude needs to find code | Top-level folder layout + one-line purpose per folder. Faster than re-running `tree` every session. |
| `TECHSTACK.md` | When the task is technical | Languages, frameworks, key deps, runtime, deploy target, versions that matter. |
| `WORKFLOW.md` | When the task touches dev process | How to run / test / deploy. Commands the user actually uses. |
| `PROGRESS.md` | When planning next steps | What is done, in-progress, and next. Updated at session end. |
| `DECISIONS.md` | When evaluating approaches | Decisions made and **why**, so Claude stops suggesting rejected paths. Append-only. |
| `ENDWORK.md` | On session close ("kończymy" / "endwork") | Checklist for wrapping up: update PROGRESS, log new DECISIONS, commit, push. |

STARTWORK is the entry; ENDWORK is the exit. The middle six are read on demand.

## Gotchas

- **Never regenerate existing anchors without asking.** If any anchor file already exists in the project root, stop and offer overwrite / fill-missing / cancel. A hand-edited DECISIONS.md is often the most valuable file in the repo.
- **Project root, not `.claude/anchors/`.** The user will edit these daily. Hiding them breaks the whole point.
- **Relative paths only in STARTWORK.** Use `./CONTEXT.md`, not `/home/user/project/CONTEXT.md`.
- **Merge, don't clobber, `.claude/settings.json`.** Many users already have hooks. Overwriting silently destroys their setup.
- **Scan failure is not fatal.** If `scripts/scan_project.sh` returns nothing (new repo, missing tools), fall back to asking the user. Don't abort.
- **Preserve DECISIONS.md on re-run.** When the user runs the skill again on an existing project, leave DECISIONS.md alone if it has entries. Only populate it if it's empty. Overwriting decision history destroys the project's most irreplaceable anchor.
- **Don't invent content to fill templates.** If TECHSTACK scan is empty and the user hasn't answered, write `TBD` rather than guessing. A `TBD` prompts the user to fill it in; a hallucinated framework choice quietly misleads future sessions.

For worked examples of filled anchor files on real projects, see `references/examples.md` (added in a later phase).
