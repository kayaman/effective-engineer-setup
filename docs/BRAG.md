# Brag Document

One-line records of shipped work. See `.claude/skills/brag/SKILL.md` for the
format and rules.

From Ch. 6 of *The Effective Software Engineer*: nobody else is tracking your
wins for you, and by review time the details have evaporated. This file is
for a future you, a manager, or a promo committee — keep it credible, keep
it specific, keep it up to date.

**Rules of thumb**

- Prefer outcomes to outputs: *"dropped p95 from 900ms to 180ms on checkout"*
  beats *"optimized the checkout service"*.
- Include partial work. A spike that proved an approach wrong is a win
  (*"avoided ~3 weeks on the wrong path"*).
- No ego-writing. *"Heroically shipped"* → rewrite as a factual outcome.
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
