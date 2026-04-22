---
name: tdd
description: Drive a feature or bug-fix through a tests-first loop (red → green → refactor). Use whenever the task is to add new behavior, fix a reproducible bug, or harden an existing function. Writes failing tests first, runs them to confirm they fail for the right reason, then implements the minimum code to turn them green, then refactors. Do NOT use for exploratory spikes, UI tweaks with no logic, or pure documentation changes.
when_to_use: New behavior with clear acceptance criteria, reproducible bugs, or any change that adds conditional logic. Skip for docs-only, config-only, or dependency-bump changes.
argument-hint: "[feature or bug description]"
---

# Tests-first, then code

From Ch. 13: *"AI excels at translating a tight specification into
implementation. The tightest specification you can give it is a failing
test."*

## The loop

This skill drives three sub-loops. Announce which loop you are in at each
step so the human can follow.

### Loop 1 — **Specify** (one pass)

1. Restate the behavior in one sentence: *"Given \<state\>, when
   \<action\>, then \<observable result\>."* If you cannot, run
   `/outcomes-first` first and come back.
2. List the **test cases** as bullet points. Cover: the happy path, at
   least one edge case (empty, zero, max), and at least one failure mode
   (bad input, unavailable dependency). Do not write test code yet.
3. Confirm the list with the user. Wait.

### Loop 2 — **Red → Green** (one sub-loop per test case, smallest first)

1. Write **one** failing test. Run it.
2. Confirm it fails for the **right reason** (the assertion, not a missing
   import). If it fails for the wrong reason, fix the test first.
3. Implement the **minimum** code to turn it green. No speculative
   generality. No extra parameters for "future use". No helper functions
   you don't call.
4. Run the whole test file, not just the new test, to catch regressions.
5. Commit if the user has enabled per-test commits; otherwise, note the
   green and move to the next test case.

### Loop 3 — **Refactor** (once all test cases are green)

1. Ask: *"Is any block duplicated, any function > ~25 lines, any name
   unclear?"* Fix only what you can justify in one sentence.
2. Run the full test suite (not just the file). All green → stop.
3. If you changed the public shape, update the ADR if one exists, else
   suggest `/adr`.

## Guardrails

- **Never disable, skip, or weaken a failing test to make it pass.** If a
  test seems wrong, say so out loud and ask the human.
- **Never mark a task complete with tests that were not actually run.** Run
  them. Paste the command and the last line of output.
- **Stop at green.** Ch. 5 "Gold-Plating": the definition of done is
  "tests green + refactor pass". Not "also add three nice-to-haves".

## Output format

```text
### Spec (Loop 1)
Given <state>, when <action>, then <result>.

Test cases:
- [ ] happy path: …
- [ ] edge: …
- [ ] failure: …

### Progress (Loop 2)
- [x] happy path — red (line 42 assertion) → green (3 lines in foo.ts)
- [ ] edge: empty list
- [ ] failure: network timeout

### Refactor pass (Loop 3)
<what changed, what stayed>

### Final
<command used to run all tests>
<last line of output: e.g. "Tests: 14 passed, 14 total">
```

## What this skill does not do

- It does not generate tests with no assertions ("smoke tests") and call it
  done.
- It does not write tests after the code and call that TDD. Order matters:
  red before green. Every time.
