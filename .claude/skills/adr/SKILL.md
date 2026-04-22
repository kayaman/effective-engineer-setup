---
name: adr
description: Draft or update an Architecture Decision Record (ADR) in docs/adrs/. Use whenever the user is choosing between design alternatives, introducing a new library/framework/database, defining a service boundary, reversing a past decision, or when a PR review surfaces "why did we do it this way?". Produces a numbered ADR file following the Nygard-style template (Context, Decision, Status, Consequences) plus an Alternatives Considered section.
when_to_use: Any design decision whose consequences outlive the PR — library choice, schema shape, protocol (REST vs gRPC), error-handling strategy, deploy target, migration path.
argument-hint: "[short decision title, e.g. 'use Postgres for user service']"
allowed-tools: Read Write Edit Glob Bash(ls docs/adrs*) Bash(git log -1*)
---

# Architecture Decision Records

Per Ch. 13 of *The Effective Software Engineer*: before writing code for a
non-trivial decision, brainstorm with AI, then freeze the outcome in an ADR.
The ADR is the primary artifact — code follows.

## Procedure

1. **Read the template.** `docs/adrs/0000-template.md` defines the structure.
   If it is missing, fall back to the structure at the bottom of this file.

2. **Pick the next number.** List `docs/adrs/` (excluding `README.md`,
   `0000-template.md`, and any file matching `^[0-9]+-`). Use the highest
   existing N and assign N+1, zero-padded to 4 digits: `0007`, `0023`, etc.

3. **Slug the title.** Take `$ARGUMENTS`, lowercase it, replace non-alnum
   with hyphens, trim. Filename: `NNNN-<slug>.md`.

4. **Draft the ADR using the template.** Populate every section. In
   particular:
   - **Status**: start as `Proposed`. The user flips it to `Accepted` after
     review.
   - **Context**: 2–4 short paragraphs. State the forces at play, the
     constraints, and the prior decisions this builds on or contradicts.
     No code blocks in Context.
   - **Decision**: one paragraph. Active voice ("We will use X because Y").
     If the decision has a code-level shape (a config value, an interface),
     sketch it in 5–15 lines max.
   - **Alternatives considered**: list at least two real alternatives with a
     one-sentence reason each was rejected. If you only considered one
     option, stop and say so — that is itself a finding (Ch. 5
     "Not-Invented-Here" cuts both ways).
   - **Consequences**: split into `Positive`, `Negative`, and `Neutral
     (monitor)`. Be honest about the negative. If there are no negatives,
     you haven't thought hard enough.

5. **Cross-reference.** If the decision supersedes an earlier ADR, update the
   earlier file: change its `Status` to `Superseded by NNNN-<slug>.md` and
   add a top note. Do not delete the old ADR.

6. **Write the file, then present a short summary.** Don't dump the whole
   ADR back into chat — link to the file and summarize the Decision and the
   two biggest Consequences.

## ADR template (inline fallback)

```markdown
# NNNN. <Title>

- **Status:** Proposed | Accepted | Deprecated | Superseded by NNNN-slug.md
- **Date:** YYYY-MM-DD
- **Deciders:** <names or @handles>
- **Tags:** <area>, <stack>

## Context

<2–4 paragraphs: what forces are at play, what constraints, what prior
decisions.>

## Decision

We will <verb> <thing> because <reason>.

<Optional: 5–15 line sketch of the concrete shape.>

## Alternatives considered

1. **<Alternative A>** — rejected because <reason>.
2. **<Alternative B>** — rejected because <reason>.

## Consequences

### Positive
- <effect>

### Negative
- <effect — be honest>

### Neutral (monitor)
- <thing we should watch>

## References

- <link to PR, issue, RFC, or external article>
```

## What this skill refuses to do

- It will not write an ADR for a trivial decision (renaming a variable,
  picking a color). If the user insists, say why it's trivial and suggest a
  code comment instead.
- It will not mark the status as `Accepted`. Only humans accept ADRs.
- It will not delete or rewrite past ADRs. They are an append-only log.
