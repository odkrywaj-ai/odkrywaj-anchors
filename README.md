# odkrywaj-anchors

> A Claude Code skill that gives any project persistent memory across sessions.
> Scaffold 8 anchor markdown files + optional hooks in one command.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-EA580C)](https://code.claude.com)

---

## The problem

Claude Code forgets. Every new session starts with ten minutes of re-explaining the project: what you're building, what's already done, what you tried and rejected, why the architecture is the way it is. On a growing codebase this gets worse, not better.

## The fix

One magic word drops 8 small markdown files in your project root. Claude reads them on demand — `STARTWORK.md` first as a router, then pulls only what the current task needs. Optional hooks auto-load context on every session start and trigger a wrap-up checklist when you close out.

```
You: Kotwica!
Claude: [scans project] [asks 3 questions] [writes 8 anchors]
        Done. Start a fresh session and say "pracujemy nad projektem".
```

## How it works

```
┌─────────────────────────────────────────────────────────────┐
│  SESSION START                                              │
│     │                                                       │
│     ▼                                                       │
│  Hook reads STARTWORK.md  ──►  Claude knows the project     │
│     │                                                       │
│     ▼                                                       │
│  Task needs specifics?                                      │
│     │                                                       │
│     ├──► architecture    ──►  reads DECISIONS.md            │
│     ├──► find a file     ──►  reads FILEMAP.md              │
│     ├──► propose a dep   ──►  reads TECHSTACK.md            │
│     └──► where we are    ──►  reads PROGRESS.md             │
│                                                             │
│  SESSION END — you type "kończymy" / "endwork" / "gg"       │
│     │                                                       │
│     ▼                                                       │
│  Hook injects ENDWORK.md  ──►  Claude updates anchors       │
└─────────────────────────────────────────────────────────────┘
```

## The 8 anchors

| File | Role |
|------|------|
| `STARTWORK.md` | Router. Read first. Points to the other seven. |
| `CONTEXT.md` | What you're building, for whom, what you're explicitly NOT building. |
| `FILEMAP.md` | Where things live. Prevents Claude from re-discovering layout. |
| `TECHSTACK.md` | Stack, key deps, versions that matter, what you're *not* using. |
| `WORKFLOW.md` | Run / test / deploy commands. Git conventions. |
| `PROGRESS.md` | Done / in progress / next / blocked + dated session log. |
| `DECISIONS.md` | Append-only log of *why*. Stops "we already rejected that" loops. |
| `ENDWORK.md` | Wrap-up checklist. Auto-triggered on session close. |

See [`skills/odkrywaj-anchors/references/examples.md`](./skills/odkrywaj-anchors/references/examples.md) for fully populated examples on three contrasting projects: a SvelteKit learning platform, a content marketing agency, and a solo Rust learning project.

## Install

### Recommended — Claude Code plugin

In any Claude Code session:

```
/plugin marketplace add odkrywaj-ai/odkrywaj-anchors
/plugin install odkrywaj-anchors
```

Done. The skill is available globally in every project.

### Fallback — one-liner installer

For setups without plugin support:

```bash
curl -fsSL https://raw.githubusercontent.com/odkrywaj-ai/odkrywaj-anchors/main/install.sh | bash
```

The script clones the repo to `~/.claude/skills/odkrywaj-anchors` and verifies the install. No system-level changes, no sudo.

### Manual (if you prefer to read what you run)

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/odkrywaj-ai/odkrywaj-anchors.git ~/.claude/skills/odkrywaj-anchors-plugin
ln -s ~/.claude/skills/odkrywaj-anchors-plugin/skills/odkrywaj-anchors ~/.claude/skills/odkrywaj-anchors
```

### Verify

Start a new Claude Code session in any project and type one of the magic words:

- `Kotwica!`
- `Odkrywaj potencjał`
- `Accio anchors` (for fans of a certain wizard)
- `ustaw anchory`
- `bootstrap anchors`
- `set up anchor files`

Claude will scan your project, ask a few questions, and scaffold the 8 anchors.

## Requirements

- [Claude Code](https://code.claude.com) installed
- `bash`, `git`
- `jq` recommended (hooks use it; scanner degrades gracefully without it)
- `tree` optional (scanner falls back to `find`)

## Update

Plugin install: `/plugin update odkrywaj-anchors` in Claude Code.

Script install:

```bash
cd ~/.claude/skills/odkrywaj-anchors && git pull
```

## Uninstall

Plugin install: `/plugin uninstall odkrywaj-anchors`.

Script install:

```bash
rm -rf ~/.claude/skills/odkrywaj-anchors
```

No other system changes to undo. Hooks live inside each project's `.claude/` folder and are removed when you delete the project or clear `.claude/settings.json`.

## Project modes

The skill detects which mode to run from project state:

- **Init mode** — no anchors exist yet. Full flow: scan → ask the gaps → write 8 files → offer hooks.
- **Update mode** — anchors exist. You choose: refresh from scan (preserves your edits), fill only missing files, or cancel.
- **Hooks-only mode** — anchors exist, you just want to add hooks.

## What this is NOT

- Not a replacement for `CLAUDE.md`. Anchors and `CLAUDE.md` solve different problems.
- Not a memory system. Anchors are files you (and Claude) write and read. There is no cloud, no vector DB, no magic.
- Not opinionated about your stack. Works for code, content ops, solo hobby projects.

## License

MIT. See [LICENSE](./LICENSE).

---

## Built by Odkrywaj.AI

[Odkrywaj.AI](https://odkrywaj.ai) is a Polish-language AI education ecosystem — tutorials, tool catalog, gamified courses, daily news. We build public open-source tools that make working with AI easier for everyone, not just developers.

- 🌐 [odkrywaj.ai](https://odkrywaj.ai) — the main hub
- 📰 [news.odkrywaj.ai](https://news.odkrywaj.ai) — AI news four times a day
- 🛠️ [narzedzia.odkrywaj.ai](https://narzedzia.odkrywaj.ai) — 73+ AI tools catalog
- 🎓 [kursy.odkrywaj.ai](https://kursy.odkrywaj.ai) — gamified courses

If this skill saved you time, star the repo and share it. That's the whole ask.

---

## Po polsku

`odkrywaj-anchors` to skill do Claude Code, który rozwiązuje największy problem dużych projektów: Claude zapomina kontekst między sesjami. Magiczne słowo `Kotwica!` tworzy 8 plików-kotwic w twoim projekcie, które Claude czyta w miarę potrzeby. Dodatkowo opcjonalne hooki automatycznie wczytują kontekst na start każdej sesji i uruchamiają checklistę zamykającą gdy piszesz "kończymy".

Pełna dokumentacja po angielsku powyżej — skill jest pisany pod międzynarodowe community Claude Code, ale triggery magicznych słów działają też po polsku (`Kotwica!`, `Odkrywaj potencjał`, `ustaw anchory`).
