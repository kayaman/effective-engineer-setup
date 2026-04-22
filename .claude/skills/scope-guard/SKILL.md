---
name: scope-guard
description: Detect scope creep in the current task and propose a split. Use when the user adds "while you're at it…", "also can you…", or "one more thing…" to an in-flight task; when a diff grows past ~400 changed lines; when a PR description lists more than one outcome; or when Claude finds itself about to touch unrelated files. Output is a short assessment: stay the course, or split into N follow-up tasks with suggested titles.
when_to_use: An in-flight task where the user adds new requests OR when the current diff spans more than one concern. Do not run at task kickoff — that's /outcomes-first.
argument-hint: "[optional: the new request being added]"
allowed-tools: Bash(git diff --stat*) Bash(git diff --name-only*) Read Grep
---

# Scope guard

From Ch. 5, "Scope Creep Enablement": the mid-senior failure mode is
accommodating every addition silently. Each addition feels small; the sum
doubles the review burden and drags the timeline. This skill names the
growth out loud and offers a clean split.

## Procedure

1. **Capture the original outcome.** Look back in the conversation for
   the most recent `/outcomes-first` block, the starting user message, or
   the branch name. State it in one sentence.

2. **Capture the new request** (`$ARGUMENTS` if passed, else the most
   recent user message).

3. **Check the diff.** If we're mid-implementation:
   ```bash
   git diff --stat HEAD
   git diff --name-only HEAD
   ```
   Note the total changed files and lines.

4. **Classify the new request** against the original outcome:
   - **Inside scope** — the new request is a *necessary* consequence of
     the outcome; stay the course, implement it.
   - **Adjacent** — related, but the outcome sentence can be delivered
     without it; propose a split.
   - **Unrelated** — a new outcome entirely; absolutely split.

5. **Threshold check** (independent of classification):
   - Diff spans > 10 files → warn.
   - Diff > 400 changed lines → warn.
   - Diff touches two unrelated top-level directories (e.g.
     `services/billing/` **and** `services/search/`) → warn.

6. **Decide and present.**

### If inside scope
One line: *"Inside scope — proceeding."* No further action.

### If adjacent or unrelated, or any threshold tripped
Produce:

```text
### Original outcome
<one sentence>

### What's growing
- Added: <new request>
- Diff currently: <N> files, <M> lines

### Recommendation
Split into <K> tasks:

1. **<title>** (current) — <one-line outcome>.
   Stop when: <acceptance>.
2. **<title>** (follow-up) — <one-line outcome>.
3. ...

### Why split
<one sentence: review cost, bus factor, risk of bundled rollback>
```

7. **Stop and wait.** Do not start the new work or stop the current work
   until the user picks a path. Offer three options explicitly:
   - *"Finish current, spin up follow-ups as separate tasks"* (default)
   - *"Add it in — I accept the larger diff and review cost"*
   - *"Drop current, switch to the new request"* (rare; log a debt item)

## Why this skill refuses to just "do it all"

From Ch. 10 "Low Bus Factor" and Ch. 13 "PR Hygiene": large PRs get
rubber-stamped because no reviewer has time to read 800 lines. Small PRs
get real review. Protecting reviewability is protecting quality.
