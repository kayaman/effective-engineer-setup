---
name: outcomes-first
description: Reframe a task around its outcome before any code is written. Use at the start of any new feature, bug-fix, refactor, or when the user's request reads like an output ("add a button", "write a script", "build an endpoint") without a stated "so that…". Also use when the user asks "what should I work on?" or when scope feels fuzzy. The goal is a one-sentence outcome that names the user, the action, and the measurable result.
when_to_use: At task kickoff, before planning or coding. Skip if the outcome is already explicit and measurable in the user's message.
argument-hint: "[task description]"
---

# Outcomes over outputs

> *"Efficiency is doing things right; effectiveness is doing the right things."* — Peter Drucker, quoted in Ch. 1 of *The Effective Software Engineer*.

Most requests arrive as **outputs** ("add an endpoint", "fix the bug on the
checkout page"). Your job before doing anything is to restate the request as
an **outcome** — then confirm with the user.

## Procedure

1. **Capture the raw request.** If arguments were passed, that's it:
   `$ARGUMENTS`. Otherwise, paraphrase the last user message.

2. **Write the outcome in exactly one sentence**, using this template:

   > *"This change lets **\<who\>** do **\<what\>** so that **\<measurable
   > result or avoided cost\>**."*

   Do not produce more than one sentence. If you need two, the outcome is
   still fuzzy.

3. **Classify the impact** using the Ch. 1 spectrum:
   - **Local** — affects one file or one engineer's workflow
   - **Team** — affects teammates, shared tooling, or the build
   - **Product** — visible to end-users or changes a user-facing contract
   - **Strategic** — shifts a platform choice, a boundary, or a long-term cost

4. **Name the riskiest assumption.** One sentence: the assumption that, if
   wrong, would make the whole outcome worthless.

5. **Surface the smaller shape** (Ch. 5 "Over-Engineering"). Ask: *"What is
   the smallest change that would meaningfully deliver this outcome?"* Write
   the one-paragraph sketch.

6. **Present & stop.** Output the block below and wait for confirmation
   before touching code. Do not proceed on implicit agreement.

## Output format (verbatim)

```text
### Outcome
<one sentence using the template>

### Impact
<Local | Team | Product | Strategic> — <one-line why>

### Riskiest assumption
<one sentence>

### Smallest meaningful change
<one paragraph, 3–5 sentences>

### Waiting on
Confirm the outcome, or tell me which part is off, before I start.
```

## Anti-patterns this skill exists to prevent

- **Analysis Paralysis** (Ch. 5): the outcome block has a hard ceiling of
  ~5 short bullets. If the user asks for more planning, route to
  `/prioritize`, not more outcomes.
- **Scope Creep Enablement** (Ch. 5): once the outcome is agreed, later
  "while you're at it…" additions must either (a) fit the same outcome
  sentence, or (b) spawn a separate outcome block.
- **Hero Complex** (Ch. 5): if the smallest meaningful change is "rewrite
  the module", stop and ask for a human check — don't just do it.
