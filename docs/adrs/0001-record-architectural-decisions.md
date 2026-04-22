# 0001. Record architectural decisions as ADRs

- **Status:** Accepted
- **Date:** 2026-04-22
- **Deciders:** project team
- **Tags:** process, documentation

## Context

Decisions about architecture, dependencies, and boundaries have long tails.
Six months after a choice is made, the engineer who made it has moved on to
other work — or out of the company entirely — and the remaining team
inherits an artifact without the context that shaped it.

Ch. 5 of *The Effective Software Engineer* calls the failure mode out by
name: **Knowledge Silos**. The information exists in someone's head; the
codebase has the result but not the reasoning. When the next incident,
migration, or library upgrade arrives, the team re-does the thinking —
badly, because the constraints that were obvious last year are no longer
obvious.

Ch. 13 proposes Architecture Decision Records (ADRs) as the specific
remedy: a small, standardized file that captures context, decision,
alternatives, and consequences, numbered sequentially and append-only.

## Decision

We will record significant architectural decisions as ADRs in
`docs/adrs/`, using the Nygard-style template documented in
`docs/adrs/0000-template.md`. A "significant" decision is anything that
changes what Ch. 3 calls **depth or breadth investments**: introducing a
new library/framework, defining or moving a service boundary, choosing a
data model or protocol, or reversing any prior decision on the same
topics.

ADRs are created via the `/adr` Claude Code skill (`.claude/skills/adr/`),
which numbers the file and pre-fills the template. Manual creation is
also fine.

ADRs are append-only. We update an ADR's `Status` when it is superseded,
but we do not delete or rewrite the body.

## Alternatives considered

1. **Wiki pages (Confluence, Notion, etc.)** — rejected because external
   wikis drift from the code, require separate permissions, and are
   invisible to `grep` / `git log`.
2. **Long-form RFC documents** — rejected as the default because the
   effort of writing one discourages recording small-but-real decisions.
   We still use RFCs for large, upstream-facing proposals, but an ADR is
   the default and can cite an RFC.
3. **Inline comments in code** — rejected for anything that spans more
   than one file or has alternatives worth naming. Comments survive code
   churn poorly.
4. **Nothing (status quo)** — rejected because the status quo was the
   problem.

## Consequences

### Positive

- New contributors can answer "why did we do it this way?" in one file.
- Reviewers of future PRs can cite the ADR that constrains the change.
- The `/anti-patterns` scanner gains a new signal: rate of ADRs per
  quarter of active work, as a proxy for Knowledge-Silos risk.

### Negative

- Adds a small friction to design decisions — the author must write
  ~200–400 words.
- If the team neglects the process (stops writing them), the tool
  provides false comfort. Retros should include "did we record the
  decisions we should have?"

### Neutral (monitor)

- Number of ADRs produced per quarter. A sudden drop is a signal, not a
  goal.
- ADR status distribution: many `Proposed` ADRs with no follow-up may
  indicate Analysis Paralysis (Ch. 5).

## References

- *The Effective Software Engineer* (Addy Osmani, O'Reilly 2026), Ch. 13.
- Michael Nygard, "Documenting Architecture Decisions" (2011) —
  <https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions>
- `.claude/skills/adr/SKILL.md` — the Claude Code skill that drives this
  process.
