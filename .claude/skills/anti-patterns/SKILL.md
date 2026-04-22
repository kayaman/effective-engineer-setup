---
name: anti-patterns
description: Scan the codebase, PR, or recent conversation for the 20 individual-contributor and team-level anti-patterns catalogued in The Effective Software Engineer (Ch. 5 & Ch. 10). Use when the user asks "what smells?", "code smells", "am I doing anything wrong?", before a retrospective, when onboarding to a new codebase, or when a PR feels off. Produces a report listing each detected anti-pattern with evidence (file:line, commit, or quoted conversation) and the remedy from the book. Deliberately conservative — reports only anti-patterns it can cite evidence for.
when_to_use: Codebase audit, pre-retro, PR smell-check, or onboarding review. Do NOT run after every edit — it's a periodic scan, not a linter.
argument-hint: "[optional: path glob to restrict scan, e.g. 'services/billing/**']"
context: fork
agent: anti-pattern-scanner
allowed-tools: Read Grep Glob Bash(git log:*) Bash(git diff:*) Bash(rg:*) Bash(find:*)
---

# Anti-pattern scanner

The 15 individual anti-patterns from Ch. 5 and the 5 team-level ones from
Ch. 10, reframed as detectable signals. For each, the report lists:
**evidence** (with file:line or quote), **why it hurts** (one line), and
**remedy** (from the book).

## The 20 anti-patterns and their detection signals

### Individual (Ch. 5)

1. **Knowledge Silos.** Signals: a module with a single recent `git log`
   author over 6+ months; undocumented internal APIs; a Slack-only runbook
   referenced in code comments.
2. **Hero Complex.** Signals: a single author on 80%+ of out-of-hours
   commits; `--no-verify` or force-pushes in history; commits titled
   "hotfix" with no linked issue.
3. **Over-Engineering.** Signals: abstract base classes with one concrete
   subclass; plugin/strategy machinery with one strategy; config knobs
   never changed; factory-of-factories.
4. **Inability to Delegate.** Signals (in conversation): "I'll just do
   it", "faster if I handle it", refusal to break a task into reviewable
   chunks.
5. **Lack of Visibility.** Signals: no README in a new service; merged
   PRs with empty descriptions; ADRs for the codebase total < 1 per
   quarter of active work.
6. **Analysis Paralysis.** Signals: spike branches with > 30 days no
   commits; design docs with > 3 revisions and no accepted decision;
   PRs in "draft" for > 2 weeks.
7. **Not-Invented-Here.** Signals: a hand-rolled implementation of
   something shipped by the stdlib or a widely-used library the codebase
   already depends on (e.g. a custom `deepEqual` with `lodash` present).
8. **Perfectionism / Gold-Plating.** Signals: commits late in a PR titled
   "polish", "cleanup", "final touches" after approval; inline bikeshedding
   on style in PR comments.
9. **Context-Switching Addiction.** Signals (conversation/commit log):
   interleaved unrelated commits on one branch; ≥ 3 in-flight branches per
   author.
10. **Scope Creep Enablement.** Signals: PR description lists > 2 distinct
    outcomes; commits on one PR touch > 2 unrelated top-level dirs.
11. **Technical Debt Denial.** Signals: `TODO|FIXME|HACK` markers
    outnumber entries in `docs/TECH_DEBT.md` by > 5×.
12. **Meeting Overload.** Out of scope for code scan. Report as "cannot
    detect from code" but list for completeness.
13. **Feedback Resistance.** Signals (conversation): "I disagree" with
    no reasoning; PR comments dismissed without a fix or a justified reply.
14. **Tool Obsession.** Signals: > 2 framework/runtime switches per year;
    dependencies with < 90 days of use before removal; ADRs titled
    "migrate to X" with no user-facing outcome.
15. **Imposter Syndrome Paralysis.** Not detectable from code. Skip.

### Team-level (Ch. 10)

16. **Knowledge Silos (team).** Signals: a whole service with a single
    author in `git shortlog -sne` for the last year.
17. **Rubber-Stamping.** Signals: PRs merged with 0 review comments and
    > 200 changed lines; reviews with only a ✅ emoji.
18. **Flaky Product Ownership.** Signals: requirements doc edited > 3×
    after implementation started; issues with repeated relabeling.
19. **Low Bus Factor.** Signals: any file with `git shortlog -sne` showing
    one author > 90% for > 500 lines.
20. **Ineffective Retros.** Not detectable from code. Report as process
    observation only.

## Procedure

1. Restrict scope to `$ARGUMENTS` if a glob is given; else the whole repo
   excluding `node_modules`, `dist`, `.venv`, `vendor`, `build`.
2. For each detectable anti-pattern, run the signal check. Use `rg` and
   `git log` for speed; never `cat` a huge file just to grep it.
3. Record an entry only if there is **concrete evidence** — a file:line,
   a commit SHA, or a quoted line from the conversation. No "vibes".
4. Deduplicate: the same file matching three patterns → one entry listing
   all three, not three entries.

## Output format

```text
### Summary
<N> findings across <M> categories. Highest-signal: <top 3 by severity>.

### Findings

**<Anti-pattern name>** — <Ch. reference>
- Evidence: <file:line> / <commit SHA> / "<quoted line>"
- Why it hurts: <one line>
- Remedy (from the book): <one line, paraphrased>

<...>

### Not checked (out of scope for static scan)
- Meeting Overload
- Imposter Paralysis
- Ineffective Retros
```

## Guardrails

- **Cite or don't report.** Every finding must have evidence the reader
  can verify in < 30 seconds.
- **Paraphrase the book's remedy; don't quote at length.** A sentence is
  plenty — the reader can look up the chapter.
- **Don't moralize.** The tone is *diagnosis*, not *judgement*.
