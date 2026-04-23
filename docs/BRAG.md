# Brag Document

One-line records of shipped work. See `.claude/skills/brag/SKILL.md` for the
format and rules.

From Ch. 6 of _The Effective Software Engineer_: nobody else is tracking your
wins for you, and by review time the details have evaporated. This file is
for a future you, a manager, or a promo committee — keep it credible, keep
it specific, keep it up to date.

**Rules of thumb**

- Prefer outcomes to outputs: _"dropped p95 from 900ms to 180ms on checkout"_
  beats _"optimized the checkout service"_.
- Include partial work. A spike that proved an approach wrong is a win
  (_"avoided ~3 weeks on the wrong path"_).
- No ego-writing. _"Heroically shipped"_ → rewrite as a factual outcome.
- Cite numbers when you have them (users, latency, cost, cycle time).

**How entries get here**

1. You, explicitly, via `/brag add <what you did>`.
2. Automatically, as a dated stub at the end of substantive turns — see
   `.claude/hooks/brag-log.sh`. You're expected to flesh the stub out with
   `/brag add` within a day or two, while the details are still fresh.

---

<!--
Monthly headings are added as work happens. Template:

## 2026-03

### <Short title> — <Task | Project | Initiative>
- **Date / Ref:** 2026-03-14 · <SHA or PR/issue link>
- **What:** <one line, the visible outcome>
- **Impact:** <one line, who benefited and how — use numbers when you have them>
- **My role:** <one line: lead, contributor, reviewer, mentor, designer>
-->

_No entries yet. Ship something, then run `/brag add <summary>`._

## 2026-04

### 2026-04-23 — Stow-based split install for the Effective-Engineer template

- **Date / Ref:** 2026-04-23 · 057b72f · ADR 0002
- **Situation:** Template's `cp -R` install vendored 13 skills, 2 agents,
  and 6 hooks into every project, so fixes had to be re-copied everywhere
  and project diffs carried noise that wasn't project-specific.
- **Task:** Separate what's truly per-project (CLAUDE.md, ADRs, debt/brag
  ledgers) from what's personal-and-stable (skills, agents, hooks), and
  make the install one command per half.
- **Action:** Added `scripts/sync-to-dotfiles.sh` to populate a Stow
  package under `~/Projects/dotfiles/claude/` with a user-scope
  `settings.json` whose hooks resolve under `$HOME`; added
  `bootstrap.sh` for the per-project scaffolding; recorded the decision
  in ADR 0002; updated README with both install paths.
- **Result:** Updating a skill once now fans out to every project via
  `git pull && stow -R`. New-project setup dropped from ~7 commands to
  1 (`bootstrap.sh <dir>`). Smoke-tested both scripts end-to-end.
- **My role:** Designer + implementer (pair with Claude).
