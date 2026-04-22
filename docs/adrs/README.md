# Architecture Decision Records

This directory holds Architecture Decision Records (ADRs) for the project.
An ADR captures **one** significant architectural decision — the context
that forced it, the decision itself, the alternatives considered, and the
consequences we accept.

## How to create one

Use the Claude Code skill:

```text
/adr "use Postgres for the user service"
```

The skill will number the file (`NNNN-<slug>.md`), fill in the template,
and link to related ADRs. See `.claude/skills/adr/SKILL.md` for the rules.

You can also copy `0000-template.md` by hand if you prefer.

## Rules

- **One decision per ADR.** If you catch yourself writing "and we also…",
  split the ADR.
- **Status lifecycle:** `Proposed` → `Accepted` (or `Deprecated`).
  `Superseded by NNNN-<slug>.md` when a later ADR replaces this one.
  Never delete or rewrite accepted ADRs — append-only log.
- **Numbering is stable and sequential.** Don't renumber. If two people
  grabbed the same number, the second takes the next free one.
- **Title is a short imperative phrase.** "Use Postgres for users", not
  "Database choice".

## Index

See the file list in this directory. Filenames include the title for
grep-ability, so:

```bash
ls docs/adrs/ | sort
rg -l 'Status: Accepted' docs/adrs/
```

## Why ADRs at all?

From Ch. 13 of *The Effective Software Engineer*: an ADR is the cheapest
possible tool for fighting knowledge silos. A future engineer — human or
AI — who needs to know *why we chose X* gets the answer in one file,
without a Slack archaeology expedition.
