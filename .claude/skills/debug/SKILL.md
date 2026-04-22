---
name: debug
description: Drive a disciplined, hypothesis-based debugging loop for a bug, failing test, flaky test, or unexpected behavior. Use when the user reports "it's broken", pastes an error or stack trace, shows a failing test, or says "why is this happening?". Forces a written hypothesis before any code change, records what was tried, and converges by bisection rather than by guessing. Not for feature work — use /tdd for new behavior.
when_to_use: A bug, crash, regression, flake, or "this should work but doesn't". Stop using it once root cause is found and a fix is ready; hand off to /tdd or the normal edit flow.
argument-hint: "[symptom or failing test name]"
---

# Disciplined debugging

From Ch. 2: *"Debugging is a science. Form a hypothesis, run an experiment,
update your belief. Repeat."* The common failure mode is **guess-patching**:
changing something plausible, re-running, and calling the green a fix even
though the underlying model of the system is still wrong.

## The loop

Follow in order. Announce each step out loud so the human can audit.

### 1. Reproduce

- Write the **minimum reproducible command**. Ideally a single failing
  test. Save it. Run it. Confirm it fails consistently (3 runs).
- If the bug is flaky, increase the run count and record pass/fail ratio
  before moving on. Do not debug a flake with a sample size of one.

### 2. Characterize

Answer, in one sentence each:
- **What was expected?** (from a spec, a test, or the user's words)
- **What happened?** (exact output, exact error, exact stack frame)
- **Where does expected diverge from actual?** (line number or assertion)
- **When did it start?** (last known-good commit via `git log` /
  `git bisect` if unknown)

### 3. Hypothesize

Write **at least two** competing hypotheses in one sentence each. Each
hypothesis must be **falsifiable** — name the observation that would
refute it.

> Example:
> H1: *"The retry middleware is double-counting attempts."* Falsified by:
> a log line showing `attempt=1` exactly once per request.
> H2: *"The timeout is shorter than the dependency's p99."* Falsified by:
> `curl --max-time 5` to the dependency returns in < 5s consistently.

If you only have one hypothesis, you are guessing. Find a second.

### 4. Experiment (cheapest first)

Pick the hypothesis whose experiment is cheapest, not the one you
"feel" is right. Good experiments:
- Add one log line (or print) at the divergence point. Re-run.
- Run a smaller input through the failing code path.
- `git bisect` between last-good and first-bad commit.
- Read the upstream library source at the exact version you are using.

Bad experiments:
- Changing several things at once.
- Adding `try/except: pass` to "see if it helps".
- Upgrading a dependency to dodge the bug.

### 5. Converge

After each experiment, update the hypotheses list: mark falsified ones,
refine surviving ones, add new ones if the evidence forces it. Continue
until one hypothesis explains **every** observed symptom.

### 6. Fix with a regression test

- Write a test that fails against the current (buggy) code for the
  reason you just identified. Confirm it fails.
- Apply the minimum fix. Confirm the test passes.
- Run the full suite to catch anything you broke.

### 7. Document

Add a one-line comment at the fix site with the root cause and the
ticket/ADR link. If the bug was subtle (concurrency, ordering, floating
point, encoding), write a short note in the relevant file or
`docs/TECH_DEBT.md` — next time someone hits this pattern, they should
find it quickly. (Ch. 5 "Knowledge Silos".)

## Output format

```text
### Repro
<command> — <N runs, M fails>

### Characterized
- Expected: …
- Actual:   …
- Divergence: <file:line>
- First-bad commit: <sha> (if identified)

### Hypotheses
- H1: … (falsified by: …)  [status: ?]
- H2: … (falsified by: …)  [status: ?]

### Experiments run
1. <experiment> → <observation> → H1 falsified

### Root cause
<one sentence>

### Fix
<path:line> — <one line describing the change>
Regression test: <path>
```

## Anti-patterns to refuse

- **"Just add a retry."** Unless the hypothesis is "the call is transient",
  retries hide bugs.
- **"Catch the exception and continue."** Only after you've named what the
  exception means and decided the swallow is intentional.
- **"Upgrade the dependency."** Only if the changelog explicitly fixes
  your symptom.
