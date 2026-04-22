---
name: brag
description: Append a one-line accomplishment to docs/BRAG.md, or summarize entries from a time window. Use when the user says "log this", "add to my brag doc", "record this", after shipping something meaningful, or when prepping for a 1:1, self-review, or promo packet. Subcommands via first argument; `add` is default. Also invoked automatically by the Stop hook at the end of substantive turns (see .claude/hooks/brag-log.sh).
when_to_use: User explicitly logs an accomplishment OR asks to see what they've done recently OR is preparing for a performance review.
argument-hint: "add|summarize [description or time window like 'last-month']"
allowed-tools: Read Edit Write Bash(date:*) Bash(git log:*)
---

# Brag document

From Ch. 6: *"Keep a brag document. Nobody else is tracking your wins for
you, and by review time the details have evaporated."*

The file lives at `docs/BRAG.md`. Entries are dated, tagged by impact
level, and brief — aim for two lines each.

## Subcommands

### `add` (default)

1. Parse the description from `$ARGUMENTS`. If the first token is
   literally `add`, strip it.
2. Fetch today's date (`date +%Y-%m-%d`) and, if in a git repo, the short
   SHA of HEAD.
3. Classify the impact level (from Ch. 6, mapped to Ch. 1's spectrum):
   - **Task** — a shipped piece of work (one feature, one bugfix, one doc)
   - **Project** — a multi-week effort you drove
   - **Initiative** — cross-team or strategic, affects how others work
4. Write the entry using the template below. Prepend it under the
   current month's heading; create the heading if absent.
5. Print a one-line confirmation: *"Logged: \<summary\> (impact:
   \<level\>)"*. Do not dump the whole brag doc.

### `summarize [window]`

Valid windows: `last-week`, `last-month`, `last-quarter`, `this-year`, or
an explicit ISO date range like `2026-01-01..2026-03-31`.

1. Read `docs/BRAG.md`. Parse entries by date.
2. Produce a digest with three sections:
   - **Highlights** — up to 5 entries (prefer `Initiative` > `Project` >
     `Task`), paraphrased into 1-line impact statements (STAR-ish: what
     changed, for whom, with what result).
   - **By the numbers** — count of entries per impact level and any
     metric you can extract from entry bodies (perf %, cost saved, users
     onboarded).
   - **Theme** — one sentence naming the pattern across the period
     (*"Deepened expertise in billing"*, *"Unblocked platform team
     twice"*).
3. Print the digest. Do not modify the file.

## Entry template

```markdown
## 2026-03

### <Short title> — <Task | Project | Initiative>
- **Date / Ref:** 2026-03-14 · <SHA or PR/issue link>
- **What:** <one line, the visible outcome>
- **Impact:** <one line, who benefited and how — use numbers when you have
  them (users, latency, cost, cycle-time)>
- **My role:** <one line: lead, contributor, reviewer, mentor, designer>
```

## Guardrails (Ch. 6)

- **No ego-writing.** *"Heroically shipped"*, *"saved the team"* — rewrite
  to a factual outcome (*"shipped X; team's deploy time dropped from Y to
  Z"*). The audience for this doc is a future you, a manager, or a promo
  committee — it needs to be credible.
- **Include partial work.** A spike that proved an approach wrong is a
  win. Log it as a Task with impact *"avoided \<cost of wrong path\>"*.
- **Cite numbers when they exist.** "~20% faster" is fine; "faster"
  without a number is weak.
- **Don't auto-embellish.** When the Stop hook feeds an entry, it is the
  user's words + a commit reference. Do not invent impact statements that
  aren't supported by the diff or the conversation.
