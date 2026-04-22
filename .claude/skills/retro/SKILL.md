---
name: retro
description: Facilitate a structured retrospective over a given period (sprint, project, incident). Use when the user says "let's do a retro", "look back on last week/sprint", "what did we learn from X incident", or when closing out a significant project. Produces a report with three sections (Kept, Changed, Action Items) where every action item has an owner, an acceptance test, and a due date. Explicitly refuses to produce action-less "it was fine" retros.
when_to_use: End of a sprint/project/incident, or when the user asks for a retrospective or post-mortem.
argument-hint: "[period, e.g. 'last-sprint', 'payment-migration', 'checkout-outage-2026-03-14']"
allowed-tools: Read Bash(git log --since:*) Bash(git log --oneline:*) Bash(git shortlog:*) Grep
---

# Retrospective that drives action

From Ch. 10 "Ineffective Sprint Retrospectives": the failure mode is
*"we noticed things but nothing changed"*. This skill fixes that by
refusing to end without action items whose completion is objectively
checkable.

## Procedure

1. **Frame the period.** Parse `$ARGUMENTS`:
   - `last-sprint` / `last-week` / `last-month` → use git log range
     (`--since="1 week ago"`, etc.).
   - A project or incident name → ask the user for the start/end dates
     or tags if not obvious from branch names.

2. **Gather factual inputs** from the period:
   - `git log --oneline --since="..."` for volume and concerns shipped.
   - `git shortlog -sne --since="..."` for author distribution.
   - Check `docs/adrs/` for ADRs accepted in the window.
   - Check `docs/TECH_DEBT.md` for items added vs repaid in the window.
   - Check `docs/BRAG.md` for entries.

3. **Prompt the user** for qualitative inputs, listed explicitly so they
   can answer in any order:
   - *"What went well enough that you want to keep doing it?"*
   - *"What felt heavy, slow, or wrong — even if we shipped?"*
   - *"Any near-misses? (Almost-incidents, close calls, lucky catches.)"*
   - *"Any surprises? (Things you didn't expect to matter, or that
     changed your mental model.)"*
   - *"What was noise vs signal?"*

4. **Synthesize** into three sections (Ch. 10's *Start/Stop/Continue*
   renamed to be less prescriptive):

   - **Kept** — practices worth keeping. 2–5 bullets.
   - **Changed** — practices to change. 2–5 bullets. Each bullet names
     the **root cause**, not the symptom. (*"Meetings ran long because
     we skipped the agenda"* — not *"meetings ran long"*.)
   - **Action Items** — 1–5 concrete changes. Each item has:
     - `owner:` — one name (not "the team")
     - `acceptance:` — observable outcome that proves done
     - `due:` — specific date, not "next sprint"

5. **Refuse action-less retros.** If the user has no action items, ask
   again with: *"Pick one thing from 'Changed' and turn it into an
   action. What's the smallest experiment you can run?"*

6. **Write or append to `docs/retros/YYYY-MM-DD-<name>.md`** only if the
   user asks to persist it; default is in-chat.

## Output format

```text
### Retrospective: <period / project name>
Dates: <start> → <end>

### Signals (from the codebase)
- Commits: <N> across <K> authors (top 3: …)
- ADRs accepted: <N>
- Tech-debt delta: +<added>, −<repaid>
- Incidents in window: <N>

### Kept
- <practice> — keep because <one-line reason>

### Changed
- <practice> — root cause: <one line>. What we'll try instead: <one line>.

### Action Items
1. **<title>** — owner: @<name>, due: YYYY-MM-DD
   - Acceptance: <observable outcome>
2. …

### Carry-over from last retro
- <item> — <done | in progress | dropped (reason)>
```

## Guardrails

- **No anonymous blame.** Root causes point at practices and systems, not
  at individuals. *"We reviewed PRs late"* — not *"Sam reviewed PRs
  late"*.
- **No "try harder" actions.** *"Be more focused"* isn't an action; it has
  no acceptance test. Push back until the user names a procedural change
  or a tool change.
- **Don't invent signals.** If git log yields nothing interesting, say
  "no notable pattern" — don't manufacture insight.
