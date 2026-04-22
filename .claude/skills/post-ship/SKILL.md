---
name: post-ship
description: Produce the three artifacts that should exist AFTER code ships but are routinely skipped — a README/changelog update, an observability plan (metrics, logs, alerts), and a communication note (announcement draft for Slack/email/changelog). Use when a feature has been merged or is about to deploy, when the user says "we shipped it" or "announce this", or on your own initiative right after a /commit that closes a notable outcome. Explicitly refuses to treat the code-merge as "done".
when_to_use: A feature or change just shipped, is about to ship, or has been asked to be announced. Skip for internal refactors with no user-visible change.
argument-hint: "[optional: what shipped, e.g. 'email verification gate']"
allowed-tools: Read Write Edit Grep Glob Bash(git log:*) Bash(git diff:*)
---

# Post-ship: the work after the merge

From Ch. 13 "After the Code: Docs, Observability, and Communication":
*"Code in main is not value delivered. Value is delivered when users
can find it, the team can operate it, and the stakeholders know it
exists."*

This skill produces three lightweight artifacts. They are meant to be
copy-paste-to-where-they-go, not perfect.

## The three artifacts

### 1. Docs update

- Identify the user-facing surface that changed (endpoint, config key,
  UI flow, SDK method).
- Update the **first** of these that exists and is relevant:
  `README.md`, `docs/`, `CHANGELOG.md`, API reference, Storybook, or the
  in-code docstring/JSDoc of the changed symbol.
- Keep the change small and local. If the feature needs a new doc page,
  say so — do not write a full doc page unless asked.

### 2. Observability plan

Answer these five questions in one line each:

1. **What signal tells us this is working?** (a metric, a log line)
2. **What signal tells us it's broken?** (an error, a ratio, a timeout)
3. **Who sees the signal?** (a dashboard, an alert, a log query)
4. **What's the first thing on-call should do** when the broken signal
   fires? (runbook in one paragraph — link to it from the code)
5. **What's the rollback?** (feature flag off, revert SHA, manual step)

If the answers are sparse, flag it. Shipping without observability is a
tech-debt entry — suggest `/debt add`.

### 3. Communication note

A 3-section template:

```markdown
**What:** <one line, user-facing>
**Why:** <one line, outcome in user language>
**How to use / what to do:** <one line, the new thing to do, or "nothing
— it just works">
**Where to learn more:** <link to docs / ADR>
**Who to ping:** <@you or the owner>
```

Tone is **factual, short, no hype**. Readers are busy.

## Procedure

1. **Identify what shipped.** If `$ARGUMENTS` names it, use that.
   Otherwise: read the last commit (`git log -1 --stat`) and summarize.
   If the last commit is trivial (chore, typo), stop and say so.

2. **Classify the change.**
   - **User-visible** — new feature, changed UX, new endpoint.
   - **Operator-visible** — new config, new env var, new dependency.
   - **Internal-only** — refactor, test-only, build change.

   Internal-only gets artifact #1 at most; no comms, no obs plan.

3. **Write all three artifacts** (for user- or operator-visible). Write
   them inline in the response first; offer to persist to files if the
   user confirms.

4. **Surface gaps.** If the observability answers are empty, list them
   as a checklist so the human can decide to add them or log debt.

## Output format

```text
### What shipped
<one line> — <SHA or PR link>

### Docs update
<file path> ← <proposed diff or one-line note>

### Observability plan
1. Working signal: …
2. Broken signal: …
3. Who sees it: …
4. First on-call action: …
5. Rollback: …

### Announcement draft
**What:** …
**Why:** …
**How to use:** …
**Where:** …
**Ping:** …

### Gaps
- <gap> — suggest /debt add "<title>"
```

## Guardrails

- **Don't manufacture metrics that don't exist.** If there is no
  dashboard, say so; don't pretend the signal is already being measured.
- **Don't announce internal refactors.** Be honest about what the user
  will notice (nothing).
- **Keep the announcement one screen long.** If it needs more, it's a
  blog post, not an announcement — route the user there.
