# Anchor Examples

This file shows three worked examples of filled anchor files on projects of very different shapes. The goal is not to copy them — it is to see what "populated" looks like across a team product, a non-code operation, and a solo learning project.

Skim the example whose shape matches your own. Read the "What to notice" bullets at the end of each; they call out the non-obvious choices.

Loaded on demand, not per session. Depth is fine here.

---

## Example 1: SvelteKit learning platform — kursy.odkrywaj.ai

### Context

Polish-language AI education platform inside the Odkrywaj.AI ecosystem. Gamified courses with XP and badges, Stripe payments, Supabase auth, Bunny.net video. Built by a non-technical founder pairing with Claude in Claude Code. Public-facing product with paying users.

### What the anchors look like

#### STARTWORK.md
```markdown
# kursy.odkrywaj.ai

Polish-language AI education platform with gamified courses, XP, badges, and Stripe payments.

## Where to look

Read this file first. Pull the other anchors on demand, not up front.

- **What we're building, for whom, what we're NOT doing** → `./CONTEXT.md`
- **Where things live in this repo** → `./FILEMAP.md`
- **Languages, frameworks, dependencies** → `./TECHSTACK.md`
- **How to run, test, deploy** → `./WORKFLOW.md`
- **What's done, in progress, next** → `./PROGRESS.md`
- **Decisions and why** (read before proposing approaches) → `./DECISIONS.md`
- **Session wrap-up checklist** → `./ENDWORK.md`

## How to work here

When in doubt about an approach, check `./DECISIONS.md` before proposing — odds are the question has been answered.

When closing a session, run the `./ENDWORK.md` checklist.

---

_Anchors scaffolded by [odkrywaj-anchors](https://github.com/odkrywaj-ai/odkrywaj-anchors) on 2026-04-20._
```

#### CONTEXT.md
```markdown
# Context

## What this is

A Polish-language platform that teaches AI and prompt engineering through short, gamified courses. Users progress through lessons, earn XP and badges, and receive a certificate on course completion.

## Who it's for

Polish-speaking professionals, beginner to intermediate. Marketers, teachers, and small-business owners who want practical AI skills without a CS background. Not for developers building their own models.

## What we're building

- First full paid course: "AI w codziennej pracy" (12 lessons, ~3 hours)
- Companies training aggregator — a B2B flow where a company buys seats and invites employees
- Certificate generation on course completion (PDF with QR code linking to a public verification page)

## What we're NOT building

This list stops Claude from re-proposing rejected directions. Keep it updated.

- Mobile-native app — web-responsive only
- In-product AI tutor — maybe in v2, not now
- Social features — no comments, forums, or DMs in v1
- English-language content — Polish only until product-market fit here is clear

## Current focus

Get the first course live with a working Stripe checkout and certificate flow for the first 50 beta users.

## Constraints

- Solo founder budget, no external funding
- Content in Polish only
- GDPR / EU data residency (Supabase EU region)
- Self-serve only — no sales calls in v1

## Success looks like

500 paid users by end of quarter, course completion rate above 70%, NPS above 40.
```

#### FILEMAP.md
```markdown
# File Map

One-line purpose per top-level folder and key file. Update when structure changes — otherwise Claude wastes tokens re-discovering layout every session.

## Top-level layout

```
.
├── src/
│   ├── routes/           # SvelteKit pages + API endpoints
│   ├── lib/              # shared code (components, server utils, types)
│   └── app.html          # root HTML shell
├── static/               # fonts, favicons, images served as-is
├── supabase/
│   └── migrations/       # timestamped SQL migrations
├── scripts/              # one-off admin scripts (seed, upsert-lesson)
├── svelte.config.js
├── package.json
└── wrangler.toml         # Cloudflare Pages config
```

## What lives where

- `src/routes/` — file-based routing; `(auth)/`, `(public)/`, `api/` groups
- `src/lib/components/` — Svelte 5 components, PascalCase filenames
- `src/lib/server/` — server-only code (Supabase admin client, Stripe webhooks, never imported from `.svelte` files)
- `src/lib/types/` — TypeScript types including Supabase-generated `database.types.ts`
- `supabase/migrations/` — append-only SQL, never edit merged migrations

## Entry points

- Main file: `src/routes/+page.svelte` (landing)
- Config: `svelte.config.js`, `wrangler.toml`
- Tests live in: `tests/` (Playwright e2e) and colocated `*.test.ts` (unit)

## Conventions

- Svelte 5 runes only (`$state`, `$props`, `$derived`) — no legacy `export let` or `$:`
- Routes kebab-case, components PascalCase
- Server-only logic stays under `src/lib/server/`
- One Supabase migration per PR; never edit existing migration files

## Ignore for most tasks

- `.svelte-kit/` — build cache
- `node_modules/`
- `.wrangler/` — Cloudflare local emulator cache
- `static/videos-preview/` — large local test assets, not shipped
```

#### TECHSTACK.md
```markdown
# Tech Stack

## Core

- **Language**: TypeScript 5.8
- **Framework**: SvelteKit 2 with Svelte 5 (runes)
- **Runtime**: Cloudflare Pages + Pages Functions
- **Package manager**: npm

## Key dependencies

Things worth knowing when proposing changes.

- `@supabase/supabase-js` — auth, DB, RLS-guarded queries
- `stripe` (server-side) — checkout sessions, webhook handling
- `@bunnycdn/stream-sdk` — video player for course lessons
- `@playwright/test` — e2e tests
- `zod` — API payload validation

## Deployment

- **Target**: Cloudflare Pages (static + Functions for webhooks and signed URLs)
- **CI/CD**: Git push to `main` auto-deploys; PR previews on branches
- **Secrets location**: Cloudflare dashboard (Pages env vars); `.env.local` for dev only, never committed

## Versions that matter

If upgrading these breaks things, note why here.

- Svelte 5 — uses runes API; do not revert to Svelte 4 idioms
- SvelteKit 2 — adapter-cloudflare v4+; older adapters don't support Functions properly
- Node 20 — required by `@bunnycdn/stream-sdk` (uses modern fetch)

## Not using

Things Claude might assume but shouldn't — prevents wrong-library suggestions.

- Next.js, React — this is a Svelte project
- Tailwind — vanilla CSS only (Terminal Brutalism design system)
- Prisma — Supabase generates types directly via `supabase gen types`
- shadcn or any component library — all components are custom
- YouTube embeds — we use Bunny.net, see DECISIONS
```

#### WORKFLOW.md
```markdown
# Workflow

How work actually happens here. Update when commands or process change.

## Run locally

```bash
npm run dev
```

## Test

```bash
npm run check       # svelte-check + tsc
npm run test        # vitest unit tests
npm run test:e2e    # playwright (requires local server)
```

## Build

```bash
npm run build
```

## Deploy

Push to `main`. Cloudflare Pages picks it up, runs `npm run build`, deploys to kursy.odkrywaj.ai. Preview builds on all PR branches.

## Common tasks

### Add a new lesson

1. Create migration in `supabase/migrations/` with lesson row.
2. Run `scripts/upsert-lesson.ts` to push content (uses service role key from `.env.local`).
3. Regenerate types: `npx supabase gen types typescript --project-id <id> > src/lib/types/database.types.ts`.
4. Verify locally before pushing.

## Code style

- Svelte 5 runes only — never `export let` or `$:`
- Always `addEventListener`, never `onclick=""`
- Server-only code under `src/lib/server/` — never imported from `.svelte`
- Tabs for indentation, no semicolons at end of lines

## Git conventions

- **Commit message format**: English, imperative — `feat: add certificate generation endpoint`
- **Branch naming**: `feat/`, `fix/`, `docs/` prefix
- **PR / push policy**: No auto-push. Push only on explicit user confirmation.
```

#### PROGRESS.md
```markdown
# Progress

_Last updated: 2026-04-22_

State of the project. Updated at session end via the `./ENDWORK.md` checklist. Don't rewrite history — scroll to the session log for older status.

## Done

- Supabase auth with email + Google OAuth
- Stripe checkout for single-course purchase
- XP accrual on lesson completion
- Badge schema + first 5 badge definitions
- First 3 lessons of "AI w codziennej pracy" published
- Terminal Brutalism design system locked in

## In progress

- Badge notification UI (toast on earn, badge wall on profile)

## Next

In priority order.

1. Certificate generation (PDF + public verification page)
2. Email confirmation flow (Resend; welcome, purchase receipt, course completion)
3. Companies training aggregator — B2B seat purchase + invite flow
4. Lessons 4–12 of "AI w codziennej pracy"

## Blocked

Things waiting on external input before moving.

- Aggregator pricing — waiting on first training partner to sign LOI before finalizing tiers

---

## Session log

Dated notes from recent sessions, newest on top.

### 2026-04-22 — Badge notification spike

Prototyped toast component with Svelte 5 `$state` + `$effect`. Decided to delay the badge wall until completion flow is done.

### 2026-04-18 — Stripe webhook refactor

Moved webhook handling from a SvelteKit endpoint to a Pages Function for better cold-start behavior. Added replay protection via `event.id` dedup in Supabase.

### 2026-04-15 — Initial scaffold

Anchors generated via odkrywaj-anchors. Baseline captured.
```

#### DECISIONS.md
```markdown
# Decisions

**Append-only log.** Every non-trivial choice that shaped this project lives here. Claude reads this before proposing approaches — it stops the "we already decided not to do that" loop.

## Rules

- One entry per decision, newest on top.
- Never delete. If a decision is reversed, add a new entry that supersedes the old one.
- Keep entries short. Link out to a design doc if the reasoning is long.

---

## Entries

<!-- Add new decisions above this line. Oldest below. -->

### 2026-04-10 — Host video on Bunny.net, not YouTube

**Decision**: All course video goes through Bunny Stream.
**Why**: No pre-roll ads, GDPR-compliant EU CDN, per-viewer signed URLs for paid content, materially cheaper than Vimeo at our volume.
**Alternatives considered**: YouTube unlisted (ad overlay ruins UX, no DRM, scraping risk), Vimeo Pro (2x Bunny's cost), self-hosted on R2 (no HLS out of the box).

### 2026-04-08 — Supabase over Firebase for backend

**Decision**: Supabase for auth, Postgres, and storage.
**Why**: Real Postgres (row-level security, proper joins), EU region for GDPR, open source so not locked into Google, generated TypeScript types out of the box.
**Alternatives considered**: Firebase (NoSQL modeling pain for course/lesson/enrollment joins, no EU region guarantees), raw Postgres on Fly.io (too much ops for a solo founder).

### 2026-04-05 — SvelteKit over Next.js

**Decision**: Build the platform on SvelteKit 2 / Svelte 5.
**Why**: Smaller bundle for content-heavy pages, simpler mental model (runes + file-based routing), Cloudflare Pages adapter works cleanly. Personal fit: one person maintaining this — Svelte reduces ceremony.
**Alternatives considered**: Next.js (larger bundle, React re-renders fight the gamified UI), Astro (great for content but weaker for interactive lesson players), Remix (fewer Polish community resources).

### 2026-04-05 — Adopt odkrywaj-anchors for project memory

**Decision**: Use the 8-anchor system plus optional Claude Code hooks.
**Why**: Cut per-session re-explanation. Give Claude a router into project context instead of one giant CLAUDE.md.
**Alternatives considered**: Single CLAUDE.md (too large, always loads), no anchors (wastes time every session).
```

#### ENDWORK.md
```markdown
# Endwork

Session wrap-up checklist. Run when the user says "kończymy", "endwork", "wrapping up", "gg", or equivalent.

## Checklist

1. **Update `./PROGRESS.md`**
   - Move finished items from "In progress" to "Done".
   - Add new items to "Next" if they surfaced this session.
   - Add a dated entry to the session log at the bottom (newest on top).

2. **Log new decisions in `./DECISIONS.md`** (if any)
   - Any non-trivial choice made this session gets an entry at the top.
   - Append only. Never rewrite older entries.

3. **Update `./CONTEXT.md`** (only if scope or audience changed)
   - If the "NOT building" list grew — add it. This is the highest-signal update.

4. **Update `./TECHSTACK.md`** (only if stack changed)
   - New dependency? Framework swapped? Version pinned? Supabase types regenerated after a migration?

5. **Update `./FILEMAP.md`** (only if structure changed)
   - New route group? New `src/lib/` subfolder? File moved?

6. **Commit**
   - English imperative: `feat: …`, `fix: …`, `docs: …`, `refactor: …`
   - Include anchor updates in the same commit if they relate to the session's work.

7. **Push** — only on explicit user confirmation. No auto-push.

## Don't

- Don't rewrite PROGRESS history — append only.
- Don't edit DECISIONS entries — supersede with a new entry if reversed.
- Don't push without explicit user OK.
- Don't forget to regenerate Supabase types after a migration — stale types bite in the next session.
```

### What to notice

- **"What we're NOT building" is the densest signal.** Four bullets kill four whole conversation threads future-Claude would otherwise reopen (mobile app, AI tutor, social, English content).
- **DECISIONS are dated and ordered newest-first**, with explicit "Alternatives considered". That's the line that prevents the "why not Firebase?" re-debate.
- **PROGRESS "Blocked" section names an external dependency**, not an internal todo. Blocked items shouldn't be things the team can unblock — those go under "In progress".
- **ENDWORK has one project-specific item** grafted onto the template: "regenerate Supabase types after migration". That's the kind of per-project footgun ENDWORK exists to remember.
- **TECHSTACK "Not using"** is the anti-hallucination field. Without it, Claude will happily suggest Tailwind or Prisma. With it, those suggestions never start.

---

## Example 2: Content marketing agency — "Baker & Wolfe Agency" (fictional)

### Context

Fictional 5-person content marketing agency running campaigns for SaaS clients. The founder, Alex, uses Claude for brief-writing, draft copy, and campaign retros. Anchors exist so Claude remembers which client has which voice, what's been pitched, and what's out of scope. Not a code project.

### What the anchors look like

#### STARTWORK.md
```markdown
# Baker & Wolfe Agency

Five-person content marketing agency serving B2B SaaS clients. Claude is used for briefs, drafts, and retros.

## Where to look

Read this file first. Pull the other anchors on demand, not up front.

- **Who we serve, what we do and don't do** → `./CONTEXT.md`
- **Where the artefacts live (Notion, Figma, Airtable)** → `./FILEMAP.md`
- **Tools and systems we use** → `./TECHSTACK.md`
- **How work moves through the agency** → `./WORKFLOW.md`
- **What campaigns are where** → `./PROGRESS.md`
- **Why we work the way we do** → `./DECISIONS.md`
- **End-of-session checklist** → `./ENDWORK.md`

## How to work here

Before drafting copy for a client, read their voice guideline note linked from `./FILEMAP.md`.

When closing a session, run the `./ENDWORK.md` checklist.

---

_Anchors scaffolded by [odkrywaj-anchors](https://github.com/odkrywaj-ai/odkrywaj-anchors) on 2026-03-12._
```

#### CONTEXT.md
```markdown
# Context

## What this is

A five-person content marketing agency. We plan, write, and run campaigns for B2B SaaS clients on retainer. Deliverables: briefs, blog series, email sequences, lead magnets, campaign retros.

## Who it's for

B2B SaaS companies with 20–200 employees that have a product story to tell and no in-house content team. Our clients pay us to be the content team, not to advise on strategy from the side.

## What we're building

- Three campaigns per quarter per client
- A standing voice guideline doc per client, updated quarterly
- Internal library of reusable brief templates, hook formulas, and retro templates

## What we're NOT doing

This list stops Claude and the team from creeping into work we don't do. Keep it updated.

- Paid ads — we refer out to two trusted partners
- SEO audits — we refer out; we write content but don't do technical SEO
- Video production — subcontracted to a freelance studio
- Client-facing dashboards — too much ops overhead, no client has asked

## Current focus

Onboarding Ledger (fintech) — new retainer, voice guideline in draft. Running Q2 campaigns for three existing clients: Acme SaaS (blog series on integrations), Northwind (lifecycle emails), Harborline (launch campaign for their v3 release).

## Constraints

- Five people total: Alex (founder/strategy), two writers, one designer, one PM
- No offshore team, no freelance rotation — quality control matters more than velocity
- 48-hour turnaround SLA on first drafts; any slower and clients get nervous

## Success looks like

90% retainer retention year-over-year, client NPS above 50, three published case studies per year.
```

#### FILEMAP.md
```markdown
# File Map

Where the artefacts live. This is not a code repo — it's a Notion + Airtable + Figma setup. Update when a client onboards or a tool changes.

## Top-level layout (Notion workspace)

```
Notion dashboard: https://notion.so/<workspace>/dashboard
├── Clients/
│   ├── Ledger/              # fintech, onboarding
│   ├── Acme SaaS/           # retainer since 2025-09
│   ├── Northwind/           # retainer since 2025-11
│   └── Harborline/          # retainer since 2026-01
├── Campaigns/
│   ├── Active/              # currently running, one sub-page per campaign
│   └── Archive/             # finished, linked from client pages
├── Voice-Guidelines/        # one per client, updated quarterly
├── Templates/               # brief, retro, email sequence, lead magnet
├── Retros/                  # campaign retros, newest-first
└── Admin/                   # contracts, invoicing, capacity planning
```

## What lives where

- `Clients/<name>/` — master client page with contract terms, primary contact, current retainer scope
- `Campaigns/Active/` — one page per running campaign; status in Airtable
- `Voice-Guidelines/<name>/` — tone, banned words, audience notes, example do/don't pairs
- `Retros/` — dated retro docs, link back to the campaign page

## Entry points

- Main dashboard: `https://notion.so/<workspace>/dashboard`
- Airtable campaign calendar: `https://airtable.com/<base-id>/campaigns`
- Shared Figma: `https://figma.com/files/<team>`

## Conventions

- One sub-page per campaign in `Campaigns/Active/`, moved to `Archive/` on close
- Voice guideline updates get a changelog entry at the top of the doc
- Retros are dated `YYYY-MM-DD — Client — Campaign name`

## Ignore for most tasks

- `Admin/` — unless the task is about contracts, billing, or capacity
- `Archive/` — only read when a current draft references a past campaign
```

#### TECHSTACK.md
```markdown
# Tools & systems

The "stack" for an agency is the set of tools we run work through. Update when a tool is added or retired.

## Core

- **Notion** — briefs, voice guidelines, campaign pages, retros
- **Airtable** — campaign calendar with status, owner, due date, client
- **Figma** — visual assets for campaigns, shared with clients for review
- **Slack** — internal team comms; one channel per retainer client
- **Claude.ai** — primary drafting surface for copy and briefs

## Supporting

- **Grammarly Premium** — style and tone check on final drafts
- **Loom** — async client walkthroughs when a written update won't do
- **Calendly** — kickoff call scheduling

## Integration

- Airtable → Slack via Zapier: status changes to "Ready for review" post to the client's internal channel

## Not using

Tools we've evaluated and rejected.

- Google Docs — moved off in 2025; Notion DB properties matter for cross-client comparison
- Asana — overkill for a 5-person team, Airtable + Slack covers it
- Canva — Figma gives the designer better control, Canva outputs look templated
- ChatGPT as primary — we use Claude, see DECISIONS

## Access and secrets

- Client logins stored in 1Password shared vault "Baker & Wolfe"
- Never share client credentials in Slack or docs
```

#### WORKFLOW.md
```markdown
# Workflow

How work actually moves through the agency. Update when the process changes.

## Client retainer cycle

```
Brief ──► Kickoff call ──► Outline ──► First draft ──► Client review ──► Revision ──► Publish ──► Retro
```

## SLAs

- Brief turnaround: 3 business days from kickoff call
- First draft: 48 hours from brief approval
- Revisions: 24 hours
- Retro: within 5 business days of campaign close

## Common tasks

### Kickoff a new campaign

1. Schedule kickoff call via Calendly
2. Create campaign page in `Campaigns/Active/<client>/<campaign name>`
3. Fill brief using template from `Templates/brief.md`
4. Share brief in client channel, tag stakeholder

### Draft campaign copy with Claude

1. Load the client's voice guideline doc into the conversation
2. Reference 2–3 past examples from `Campaigns/Archive/`
3. Draft, then senior writer reviews before sending to client
4. Never send Claude output directly to client without human review

## Style rules

- Claude drafts always reviewed by a senior writer (Alex or lead writer)
- Voice guidelines are the source of truth; if they disagree with a brief, flag it
- Every campaign gets a retro — non-negotiable

## Client-facing policy

- Email and Slack only; no texting, no WhatsApp
- Revisions in one round per draft; further revisions are scoped as new work
- No spec work, no free trials, no unpaid pitches
```

#### PROGRESS.md
```markdown
# Progress

_Last updated: 2026-04-23_

State of the agency's current work. Updated at week close via the `./ENDWORK.md` checklist.

## Done (this month)

- Harborline v3 launch campaign — shipped, metrics tracked
- Northwind welcome sequence (8 emails) — delivered, client approved
- Acme integrations blog series (3 of 5 posts) — published
- New retainer signed: Ledger (fintech)

## In progress

- Ledger voice guideline (first draft with client for feedback)
- Acme integrations blog series posts 4 and 5 (post 4 in review)
- Q2 campaign planning for Northwind (draft calendar shared)

## Next

In priority order.

1. Finalize Ledger voice guideline and kickoff first campaign
2. Close Harborline retro with CMO (call scheduled 2026-04-26)
3. Refresh Acme voice guideline (quarterly update due)
4. Case study writeup: Harborline v3 launch results

## Blocked

- Ledger kickoff campaign — waiting on CMO feedback on voice guideline draft

---

## Session log

### 2026-04-23 — Ledger voice guideline v1

Draft shared with CMO. Called out uncertainty on "how much fintech jargon" — waiting on their steer.

### 2026-04-20 — Harborline retro

Team retro went well. One surface: we mis-timed the pre-launch teaser by a week. Logged in retro doc for future reference.

### 2026-04-15 — Initial anchor scaffold

Anchors generated via odkrywaj-anchors. Baseline captured.
```

#### DECISIONS.md
```markdown
# Decisions

**Append-only log.** Every non-trivial choice that shaped how we work lives here.

## Rules

- One entry per decision, newest on top.
- Never delete. If reversed, add a new entry that supersedes the old one.

---

## Entries

### 2026-03-20 — No client-facing portal

**Decision**: We will not build or license a client dashboard / portal in 2026.
**Why**: No client has asked for one; it adds ops overhead (access management, status syncing, training); Notion share-view covers 80% of the need. Revisit if a client demands it contractually.
**Alternatives considered**: Basecamp (another tool to maintain), custom portal (engineering cost for a 5-person ops team), Notion guest access (already using this).

### 2026-03-05 — Claude over ChatGPT as primary drafting surface

**Decision**: Writers use Claude as the primary drafting AI; ChatGPT used only when a client has a specific OpenAI requirement.
**Why**: Better Polish-English code-switching for our mixed-market clients, longer context window for loading full voice guidelines + examples, more consistent tone adherence in our tests.
**Alternatives considered**: ChatGPT (loses voice adherence in longer drafts), Gemini (weaker on tone), multiple tools per writer (inconsistent outputs across team).

### 2026-02-18 — Notion over Google Docs for briefs

**Decision**: All client briefs live in Notion, not Google Docs.
**Why**: Notion DB properties let us filter across clients ("show all briefs for fintech", "show all briefs with email as primary channel"). Google Docs is unstructured. The cross-client lookup turned out to be the daily workflow, not the edge case.
**Alternatives considered**: Google Docs (no structured query across briefs), Coda (smaller ecosystem, harder for clients to view), Airtable alone (better for calendar than long-form writing).

### 2026-02-15 — Adopt odkrywaj-anchors for project memory

**Decision**: Use the 8-anchor system so Claude remembers agency context across sessions.
**Why**: Cuts 10 minutes of re-briefing at the start of every draft session. Also forces us to write down decisions we were making implicitly.
```

#### ENDWORK.md
```markdown
# Endwork

Session wrap-up checklist. Run when the user says "kończymy", "endwork", "wrapping up", "gg", or equivalent.

## Checklist

1. **Update `./PROGRESS.md`**
   - Move finished campaigns from "In progress" to "Done".
   - Add new items to "Next" if they surfaced this session.
   - Add a dated entry to the session log.

2. **Log new decisions in `./DECISIONS.md`** (if any)
   - Any non-trivial agency-process or tool decision made this session.

3. **Update `./CONTEXT.md`** (only if scope changed)
   - New client onboarded? A service added to or removed from "What we're NOT doing"?

4. **Update `./TECHSTACK.md`** (only if tools changed)
   - New tool added? Tool retired? Integration changed?

5. **Update `./FILEMAP.md`** (only if the Notion / Airtable layout changed)
   - New client folder? Template reorganized?

6. **Sync Airtable campaign statuses** — this is the one non-anchor step; stale Airtable burns team trust more than anything.

7. **Post week-close summary in #team Slack** on Fridays only.

## Don't

- Don't rewrite PROGRESS history — append only.
- Don't edit DECISIONS entries — supersede with a new entry.
- Don't forget to move campaigns to `Archive/` once retro is closed.
```

### What to notice

- **The 8 files are the same, the content is wildly different.** Anchors work for non-code projects. The structure is about "what Claude needs to know", not "what the programming language is".
- **FILEMAP describes a Notion workspace, not a code tree.** A filesystem tree is one way to use it; a workspace layout is another. What matters is that Claude can find things.
- **TECHSTACK is "Tools & systems", not "Languages and frameworks".** The file header in the filename stays `TECHSTACK.md` (do not rename) but the internal H1 adapts to the domain.
- **ENDWORK has a domain-specific step grafted on** ("Sync Airtable campaign statuses") — these non-anchor housekeeping items are exactly what ENDWORK should absorb so Claude nags the user to do them.
- **DECISIONS are about process and tooling**, not tech choices. The file format works for both.

---

## Example 3: Solo developer learning Rust — "rusty" (fictional)

### Context

An individual developer with a decade of Java experience is learning Rust by building a small CLI password manager. No team, no users yet beyond self + two friends. Anchors exist so Claude tracks what the user has learned, what they've rejected, and the specific bugs they're stuck on. Small project — anchors stay small to match.

### What the anchors look like

#### STARTWORK.md
```markdown
# rusty

A CLI password manager. Learning project — Rust stable, minimal deps, local-first.

## Where to look

- **Goals, scope, what this is NOT** → `./CONTEXT.md`
- **Folder layout** → `./FILEMAP.md`
- **Rust version and crates** → `./TECHSTACK.md`
- **Build, test, lint commands** → `./WORKFLOW.md`
- **What works, what doesn't** → `./PROGRESS.md`
- **Rust design decisions** → `./DECISIONS.md`
- **Wrap-up checklist** → `./ENDWORK.md`

## How to work here

I'm learning Rust — when proposing patterns, prefer "idiomatic beginner" over "clever". Explain lifetime / borrow issues when they come up.

---

_Anchors scaffolded by [odkrywaj-anchors](https://github.com/odkrywaj-ai/odkrywaj-anchors) on 2026-04-01._
```

#### CONTEXT.md
```markdown
# Context

## What this is

A command-line password manager I'm building to learn Rust. Local-first, file-based vault, no sync. Usable on Linux and macOS.

## Who it's for

Me. Two friends asked to try it once it works. Not a public release.

## What we're building

- Vault create / open with master password
- Add / list / get / delete entries
- Encrypted file storage, decrypt only in memory

## What we're NOT building

- Cross-device sync — scope creep
- GUI — terminal only
- Browser extension — a v2 fantasy, not v1
- TUI with ratatui — too much Rust learning surface at once

## Current focus

Get the first working `vault encrypt → vault decrypt` round-trip with argon2-derived key.

## Constraints

- Solo, evenings / weekends
- Learning project — clarity over cleverness
- Must run offline, no network calls of any kind

## Success looks like

I use it as my actual password manager for a month without losing data, and I can explain why each line of it exists.
```

#### FILEMAP.md
```markdown
# File Map

## Top-level layout

```
.
├── src/
│   ├── main.rs        # CLI entry, arg parsing (clap)
│   ├── vault.rs       # encrypt / decrypt, file I/O
│   ├── crypto.rs      # argon2 + ring wrapping
│   └── entry.rs       # Entry struct, serde
├── tests/             # integration tests
├── examples/          # small usage examples
└── Cargo.toml
```

## What lives where

- `src/main.rs` — argument parsing only, delegates to modules
- `src/vault.rs` — everything about the vault file format
- `src/crypto.rs` — all key derivation and AEAD lives here, isolated for review
- `tests/` — integration tests that spin up a temp vault

## Conventions

- No unwrap in non-test code — `Result` everywhere
- Crypto touches stay in `src/crypto.rs` — easier to audit
- Errors use `anyhow::Result` in main, typed errors in library code

## Ignore for most tasks

- `target/` — build output
- `Cargo.lock` — committed, not edited by hand
```

#### TECHSTACK.md
```markdown
# Tech Stack

## Core

- **Language**: Rust 1.78 (stable)
- **Runtime**: native binary, Linux + macOS
- **Package manager**: cargo

## Key dependencies

Kept minimal on purpose.

- `clap` 4.x — CLI arg parsing
- `argon2` — password-based key derivation (argon2id)
- `ring` — AEAD (ChaCha20-Poly1305) for vault encryption
- `serde` + `serde_json` — entry serialization
- `anyhow` — ergonomic error handling in `main.rs`

## Not using

- `async` / `tokio` — blocking is fine for a CLI; async is extra learning surface
- `sqlx` / `diesel` — vault is a file, not a DB
- `bcrypt` — see DECISIONS, argon2 is the modern default
- `ratatui` — TUI is scope creep for v1

## Versions that matter

- Rust 1.78+ for `.is_some_and()` usage in `vault.rs`
- `ring` 0.17 — API changed between 0.16 and 0.17
```

#### WORKFLOW.md
```markdown
# Workflow

Solo project, local only, no CI.

## Build

```bash
cargo build
cargo build --release
```

## Test

```bash
cargo test
cargo test -- --nocapture    # see println! output
```

## Lint / quality gate before commit

```bash
cargo fmt --all -- --check
cargo clippy -- -D warnings
cargo test
```

All three must pass before I commit. No CI yet — solo.

## Run

```bash
cargo run -- vault init ~/Vaults/personal
cargo run -- vault add github
cargo run -- vault get github
```

## Git conventions

- Commits in English, imperative: `feat: add vault init`, `fix: handle empty vault`
- One logical change per commit
- Push to GitHub on feature completion only, not every commit
```

#### PROGRESS.md
```markdown
# Progress

_Last updated: 2026-04-21_

## Done

- Cargo project scaffolded with clap arg parsing
- `vault init` creates an empty encrypted file
- Argon2id key derivation working, parameters picked
- Unit tests for crypto roundtrip passing

## In progress

- `vault add` — serializing Entry into the vault

## Next

1. `vault get <name>` with decrypt → print → zeroize
2. `vault list` (just names, not secrets)
3. Integration tests that spin up a temp vault
4. `vault delete <name>`

## Blocked

- Hit a lifetime error on Entry when iterating borrowed vault contents; don't fully understand yet. Parked with a comment in `src/vault.rs:47`. Want to understand, not just `.clone()` past it.

---

## Session log

### 2026-04-21 — Lifetime wall

Got stuck on `Iterator::find` returning a reference that outlives the borrow. Parked. Will revisit after reading the lifetime chapter of the book again.

### 2026-04-18 — Crypto roundtrip working

Encrypt then decrypt a known plaintext, assertion passes. First real Rust milestone.

### 2026-04-01 — Initial scaffold

Anchors generated via odkrywaj-anchors. Baseline captured.
```

#### DECISIONS.md
```markdown
# Decisions

**Append-only log.**

---

## Entries

### 2026-04-05 — No async runtime

**Decision**: No tokio, no async-std. Blocking I/O only.
**Why**: CLI with a single user does one thing at a time. Async is extra learning surface I don't need. Adds compile-time and runtime complexity for zero benefit here.
**Alternatives considered**: tokio (overkill), async-std (same).

### 2026-04-03 — File-based vault, not SQLite

**Decision**: Store the vault as a single encrypted JSON file.
**Why**: Simpler to encrypt (whole file in / out), easier to back up, easier to reason about. SQLite would let me encrypt per-row with SQLCipher but adds a C dep and I don't need the query surface.
**Alternatives considered**: SQLite + SQLCipher (extra C dep, unneeded), sled (cool but a big chunk of learning for not much gain).

### 2026-04-02 — Argon2id, not bcrypt

**Decision**: Use argon2id for password-based key derivation.
**Why**: Modern OWASP recommendation, built-in resistance to GPU and side-channel attacks, mature Rust crate. Bcrypt is fine but not what I'd pick starting in 2026.
**Alternatives considered**: bcrypt (legacy default), scrypt (fine, less current momentum than argon2), PBKDF2 (weakest of the options).

### 2026-04-01 — Adopt odkrywaj-anchors

**Decision**: Use the 8-anchor system even for a solo learning project.
**Why**: Track what I've tried, what I've rejected, what I don't understand yet. Saves re-explaining the project to Claude every evening.
```

#### ENDWORK.md
```markdown
# Endwork

Session wrap-up.

## Checklist

1. **Update `./PROGRESS.md`**
   - Move finished items to "Done". Add new items to "Next".
   - Add a dated entry to the session log with what I actually learned today.

2. **Log new decisions in `./DECISIONS.md`**
   - Any Rust-design choice worth remembering next session.

3. **Update `./TECHSTACK.md`** — only if I added / removed a crate.

4. **Update `./FILEMAP.md`** — only if I added a new module.

5. **Quality gate before commit**
   - `cargo fmt --all -- --check`
   - `cargo clippy -- -D warnings`
   - `cargo test`

6. **Commit** — English imperative. One logical change.

## Don't

- Don't push half-working code just to save progress — commit locally, don't push.
- Don't `.clone()` through a lifetime error I don't understand; park it with a comment and move on.
- Don't add a dep without logging why in DECISIONS.
```

### What to notice

- **Anchors on a tiny solo project look different from anchors on a team production app.** Both are correct. The template fits the project, not the other way around.
- **PROGRESS "Blocked" is a learning blocker, not an external one** — "hit a lifetime error I don't understand yet". That is a valid entry; blocking on understanding is real.
- **STARTWORK "How to work here" carries a collaboration preference** ("prefer idiomatic beginner over clever") — this is where per-project tuning instructions live.
- **ENDWORK includes a project-specific "Don't"** — the `.clone()` anti-pattern. That nudge is exactly what ENDWORK should encode so the user-plus-Claude pair avoids a known trap.
- **The whole file set is short.** A one-person learning project does not need 150-line anchors. Shrinking them is not a failure — it is a correct fit.

---

These examples are starting points, not templates. Your anchors will look different from all three, and that is the point. Populate with what your project actually needs, prune what is not earning its place, and treat the files as living documents that change as the project does.
