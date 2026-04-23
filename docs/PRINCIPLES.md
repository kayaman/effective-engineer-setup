# Principles (book → daily workflow)

This is the short cheat sheet. Every row pairs a principle from *The Effective
Software Engineer* (Addy Osmani, O'Reilly Media, 2026 — ISBN 9798341638167)
with the concrete Claude Code helper that operationalizes it.

## The four frameworks this template leans on

The book draws on established practices; these are the four that appear
repeatedly and that every skill here is built around. Remembering the
frameworks lets you improvise when a skill doesn't quite fit.

| Framework | Where it shows up | Helper |
|---|---|---|
| **Impact × Effort matrix** (Ch. 1, Ch. 8) | Deciding what to work on, what to defer, what to drop. Score 1–3 each, act on the highest leverage. | `/prioritize`, `/outcomes-first` |
| **Martin Fowler's debt quadrant** (Ch. 3) | Classifying every shortcut on two axes: *deliberate vs. inadvertent* × *prudent vs. reckless*. Reckless-inadvertent is the worst; prudent-deliberate is fine if logged. | `/debt add` |
| **Nygard ADR template** (Ch. 13) | Status · Context · Decision · Consequences. 1–2 pages; immutable once accepted; supersede rather than rewrite. | `/adr` |
| **STAR method** (Ch. 6) | Writing an accomplishment: Situation · Task · Action · Result — *with numbers when they exist*. | `/brag` |

## Chapter 1 — Foundations of Effectiveness

| Principle | Helper | Where it fires |
|---|---|---|
| Outcomes over outputs | `/outcomes-first` skill | At task kickoff, before any code |
| Strategic prioritization | `/prioritize` skill | When ≥3 candidate items exist |
| The compound effect of quality | `format-after-edit.sh` hook + `/review` | Every edit, every PR |
| Measuring effectiveness | `/brag` skill + `brag-log.sh` hook | End of every substantive turn |

## Chapter 2 — Fundamentals (junior → mid)

| Principle | Helper |
|---|---|
| Clean, maintainable, readable code | `format-after-edit.sh` (deterministic) + `/review` (judgmental) |
| Testing and quality mindset | `/tdd` skill |
| Version control discipline | `/commit` skill (Conventional Commits, one concern per commit) |
| Debugging discipline | `/debug` skill (hypothesis-driven, bisection) |
| Documentation & note-taking | `/adr`, `/post-ship`, `/debt` — every artifact has a home |

## Chapter 3 — Depth vs Breadth, Technical Debt

| Principle | Helper |
|---|---|
| Managing technical debt strategically | `/debt add`, `/debt list`, `/debt repay`, `/debt audit` |
| Fowler quadrant: deliberate×prudent is fine if logged; reckless-inadvertent is the killer | `Cause` column in `docs/TECH_DEBT.md` |
| Pay down interest, not just principal — compounding × high-severity first | Sort order in `/debt list` |

## Chapter 5 — IC Anti-Patterns

| Anti-pattern | How this template fights it |
|---|---|
| Knowledge Silos | ADRs + BRAG + TECH_DEBT are all append-only, searchable, in-repo |
| Hero Complex | `/review` forces a review step; protect-files blocks force-pushes and `.env` edits |
| Over-Engineering | `/outcomes-first` ceiling ("smallest meaningful change"); `/scope-guard` splits megadiffs |
| Lack of Visibility | `inject-context.sh` surfaces state; `brag-log.sh` logs automatically |
| Analysis Paralysis | `/outcomes-first` and `/prioritize` cap planning depth |
| Perfectionism / Gold-Plating | `/tdd` stops at green; `/scope-guard` splits post-approval polish |
| Scope Creep Enablement | `/scope-guard` skill |
| Technical Debt Denial | `/debt add` is low-friction; `/debt audit` catches orphan TODOs |
| All 15 individual anti-patterns | `/anti-patterns` scanner (detectable subset) |

## Chapter 6 — Career Growth

| Principle | Helper |
|---|---|
| Keep a brag document | `/brag add`, `/brag summarize`, and the Stop hook auto-log |
| STAR framing per entry — Situation, Task, Action, Result, with numbers | Entry template in `.claude/skills/brag/SKILL.md` |
| Include partial wins (a spike that killed a wrong path is a win) | `/brag add` accepts "avoided <cost>" entries |

## Chapter 10 — Team-Level Anti-Patterns

| Anti-pattern | How this template fights it |
|---|---|
| Rubber Stamping | `/review` gives reviewers a ready-to-paste severity-sorted report; reviewer subagent critiques seriously (findings with file:line evidence) |
| Low Bus Factor | `/anti-patterns` scans `git shortlog -sne` for single-author modules |
| Ineffective Retros | `/retro` refuses to close without owner+acceptance+due on every action item; carries over prior-retro actions to check they actually happened |
| Flaky Product Ownership | `/anti-patterns` flags requirements docs with > 3 post-implementation edits |
| Knowledge Silos (team) | ADRs + BRAG + TECH_DEBT are append-only, in-repo, and searchable by any engineer or AI |

## Chapter 13 — Practical AI for Effective Engineers

| Principle from Ch. 13 | Helper |
|---|---|
| "Plan and design with AI; draft an ADR" | `/adr` skill with Nygard template + Alternatives-Considered section |
| "Start small; iterate in batches; catch misunderstandings early" | `/tdd` three-loop structure; `/scope-guard` 400-line threshold |
| "Tests-first, then code" | `/tdd` — red → green → refactor, with explicit over-fitting guardrail |
| "AI as code-review amplifier, not gatekeeper" | `/review` skill + reviewer subagent (isolated context, severity-banded report) |
| "After the code: docs, observability, comms" | `/post-ship` skill (three artifacts, explicit rollback step) |
| "Feeding AI context: repo awareness" | `inject-context.sh` SessionStart hook surfaces branch, commits, ADRs, debt |
| "Security first: build AI into the SDLC" | `protect-files.sh`, `secrets-guard.sh` PreToolUse hooks |
| "Don't feed the AI sensitive data" | `secrets-guard.sh` scans outbound writes |
| "Licensing and attribution guardrails" | `licensing-check.sh` PreToolUse hook; `/adr` requires source+license note for borrowed code |

---

## Core mental model

Claude Code is cheapest when it is most **specific**. Generic prompts give
generic answers. Every helper in this template exists to replace a generic
prompt with a specific one:

- `"plan this"` → `/outcomes-first` → *outcome sentence + impact + riskiest
  assumption + smallest change*
- `"review this"` → `/review` → *seven-pass critique, severity-labeled,
  file:line-anchored*
- `"refactor later"` → `/debt add` → *classified ledger row with decay rate*
- `"fix the bug"` → `/debug` → *hypothesis, experiment, regression test*

The helpers are cheap to skip when a task is trivial. They pay for themselves
on anything that isn't.
