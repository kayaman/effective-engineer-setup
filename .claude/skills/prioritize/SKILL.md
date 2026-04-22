---
name: prioritize
description: Rank a set of candidate tasks, bugs, or ideas by impact and effort so the user knows what to do next. Use when the user lists multiple things ("we need to do X, Y, Z, and also Q"), asks "what should I work on?", presents a full backlog or a sprint candidate list, or is weighing two directions. Produces a 2×2 impact/effort table plus a one-sentence recommendation with the reasoning. Does not invent new items.
when_to_use: The user presents 3+ candidate items OR explicitly asks for ranking OR asks "what should I focus on?" Do not trigger for a single task — use `/outcomes-first` for that.
argument-hint: "[items, one per line, or URL to a backlog]"
---

# Strategic prioritization

Effective engineers spend their leverage on the work that compounds. This skill
applies the Ch. 1 and Ch. 8 framing: impact × effort, discounted by the
riskiest assumption.

## Procedure

1. **Gather the candidate list.** Take it from `$ARGUMENTS` if provided, else
   from the most recent user message. Do **not** invent items.

2. **Score each item** on a 1–3 scale:

   | Score | Impact                                         | Effort                     |
   |:-----:|:-----------------------------------------------|:---------------------------|
   |   1   | Local — one person, one file                   | < half a day               |
   |   2   | Team — teammates, shared tooling, build        | 1–5 days                   |
   |   3   | Product/strategic — users, boundaries, revenue | > 1 week, multi-person     |

3. **Compute leverage = Impact − Effort.** Ties break by which item
   unblocks the others (dependency order).

4. **Render the table.** Columns: `Item`, `Impact`, `Effort`, `Leverage`,
   `Unblocks`, `Notes`. Sort by leverage descending.

5. **Pick one.** Write a single sentence: *"Do **\<item\>** next, because
   \<leverage reason + one dependency fact\>."* If two items tie on leverage,
   name both and ask the user to pick — do not flip a coin.

6. **Flag the anti-patterns you see.** From Ch. 5:
   - *Perfectionism / Gold-Plating*: any item whose description is "polish X"
     or "clean up Y" with no outcome — flag it.
   - *Tool Obsession*: any item that is a tool/framework change with no
     user-facing or team outcome — flag it.
   - *Analysis Paralysis*: any item whose next action is "investigate" with
     no time-box — recommend a 1-day spike instead.

7. **Present & stop.** Output the table, the recommendation, and any flags.
   Do not start working on the chosen item until the user confirms.

## Output format

```text
### Ranked candidates

| # | Item | Impact | Effort | Leverage | Unblocks | Notes |
|---|------|:------:|:------:|:--------:|----------|-------|
| 1 | …    | 3      | 1      | +2       | #2, #3   | …     |
| 2 | …    | 2      | 2      |  0       | —        | …     |

### Recommendation
Do **<item>** next, because <reason>.

### Flagged anti-patterns
- <item>: <anti-pattern name> — <remedy>

### Confirm or redirect
Want me to start #N, or is the ranking missing context?
```

## What this skill deliberately does not do

- It does not estimate in hours. Ch. 1 warns against false precision; the 1–3
  scale is on purpose.
- It does not commit the ranking to a file. If the user wants that, they can
  ask — the default is low-friction, in-chat thinking.
