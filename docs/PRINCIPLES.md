# Principles (book → daily workflow)

This is the short cheat sheet. Every row pairs a principle from *The Effective
Software Engineer* (Osmani, O'Reilly 2026) with the concrete Claude Code
helper that operationalizes it.

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

## Chapter 10 — Team-Level Anti-Patterns

| Anti-pattern | How this template fights it |
|---|---|
| Rubber Stamping | `/review` gives reviewers a ready-to-paste report; reviewer subagent critiques seriously |
| Low Bus Factor | `/anti-patterns` scans `git shortlog` for single-author modules |
| Ineffective Retros | `/retro` refuses to close without owner+acceptance+due on every action item |

## Chapter 13 — Practical AI for Effective Engineers

| Principle from Ch. 13 | Helper |
|---|---|
| "Plan and design with AI; draft an ADR" | `/adr` skill with supporting template |
| "Tests-first, then code" | `/tdd` skill (three-loop structure) |
| "AI as code-review amplifier, not gatekeeper" | `/review` skill + reviewer subagent (isolated context) |
| "After the code: docs, observability, comms" | `/post-ship` skill (three artifacts) |
| "Feeding AI context: repo awareness" | `inject-context.sh` SessionStart hook |
| "Security first: build AI into the SDLC" | `protect-files.sh`, `secrets-guard.sh` PreToolUse hooks |
| "Don't feed the AI sensitive data" | `secrets-guard.sh` scans outbound writes |
| "Licensing and attribution guardrails" | `licensing-check.sh` PreToolUse hook |

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
