---
name: review
description: Run a structured code review over the current diff (or a named commit/branch) and produce a review report organized by severity. Invoke before asking a human reviewer, after finishing an implementation, or when the user pastes a PR URL/diff. Critiques only — does not rewrite code without a separate request. Forks an isolated reviewer subagent so the review cannot be biased by the current conversation.
when_to_use: User says "review", "look over", "critique", "what could go wrong", "am I missing anything" in the context of code changes, a PR, or a diff. Also on your own initiative right after closing a TDD loop.
argument-hint: "[optional: branch name, commit SHA, or path glob]"
context: fork
agent: reviewer
allowed-tools: Read Grep Glob Bash(git diff:*) Bash(git log:*) Bash(git show:*) Bash(git status:*)
---

# Code review amplifier

Per Ch. 13: *"AI as an amplifier, not a gatekeeper."* Your output is a
**report**, not a merge gate. The human is still the approver.

## What to review

Scope, in priority order:

1. If `$ARGUMENTS` names a branch, commit, or path → review that.
2. Otherwise: the uncommitted working-tree diff (`git diff HEAD`).
3. If the working tree is clean: the last commit on the current branch
   (`git show HEAD`).

If none of those yields a diff, stop and say so — don't invent a review.

## The seven passes

Walk the diff seven times, each with a single lens. A finding is one of:
`blocker`, `major`, `minor`, `nit`. Be sparing with `blocker`.

1. **Correctness.** Does each changed function do what its name promises?
   Are off-by-ones, null-checks, type coercions, and boundary cases
   covered? Does every new branch have a test?
2. **Security.** User input parsed? SQL/shell/HTML rendered? Secrets
   logged? Authz checked? Rate-limit or timeout absent where needed?
   (Ch. 13 "Security First.")
3. **Error handling & resilience.** What happens when the network is
   flaky, the DB is read-only, the third-party API is down? Are retries
   bounded? Are errors observable?
4. **Readability.** Name tells you what, shape tells you why, comments
   explain the surprising. Any function > ~30 lines without a reason? Any
   name that made you pause > 2 seconds?
5. **Test quality.** Do the tests fail if you delete one line of the
   implementation? Are they fast and hermetic? Any snapshot tests hiding
   lack of thought?
6. **API & contract.** Did a public signature change without a
   migration note? Did an error-shape change silently? A logged event
   renamed (breaks dashboards)?
7. **Scope discipline.** Does the diff do one thing? If not, propose the
   split. (Ch. 5 "Scope Creep Enablement.")

## Output format

Two blocks — a one-line verdict, then findings.

```text
### Verdict
<one sentence: "Ship it after <N> blockers fixed" | "Looks good, <N> minor
comments" | "Split this PR before reviewing further">

### Findings

**Blockers** (must fix before merge)
- [path/to/file.ts:42] <one-line finding>. <one-line why it matters>.
  Suggested fix: <one line>.

**Major** (strongly recommend)
- [path/to/file.ts:88] …

**Minor**
- [path/to/file.ts:12] …

**Nits** (taste-level)
- [path/to/file.ts:5] …
```

## Guardrails

- **Ground every finding in a file path and line number.** No hand-wavy
  "some functions could be cleaner."
- **Do not rewrite code inside the review.** If the user wants a fix, they
  will ask — then leave review mode.
- **Flag, don't forbid.** A finding is a suggestion. Use "Consider…",
  "This risks…", not "You must…".
- **Call out what's good.** If the diff is genuinely tidy, say so in one
  line. Reviews that are only negative train people to fear reviews.
  (Ch. 10 "Rubber Stamping" — the opposite failure mode is critiquing for
  the sake of critiquing.)
