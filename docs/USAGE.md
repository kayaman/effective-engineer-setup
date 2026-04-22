# Day-to-day usage

A practical guide for using this template once it's installed. Pair with
`README.md` (install + overview) and `PRINCIPLES.md` (book → helper map).

This guide is indexed by situation, not by component. If you want the
"what is each thing," read `README.md` first.

---

## 1. The first 15 minutes

After you copy `.claude/`, `CLAUDE.md`, and `docs/` into your project:

1. **Open `CLAUDE.md`** and replace the `<PROJECT NAME>`, stack, and
   commands placeholders at the top. Claude reads this file every session,
   so wrong or stale entries cost you forever. Ten minutes here pays back
   for months.
2. **Start a Claude Code session** in the project root. The SessionStart
   hook runs `inject-context.sh` — you should see a short context block
   (branch, HEAD SHA, changed-file count, ADR count, debt count, last 3
   commits). If you don't, skip to *When things go wrong → SessionStart
   hook silent*.
3. **Test a hook.** Ask Claude to edit `.env`. It should refuse — that's
   `protect-files.sh` working. Ask Claude to paste a fake AWS key into a
   file (`AKIAIOSFODNN7EXAMPLE` is fine, it's the AWS doc example). It
   should refuse — that's `secrets-guard.sh` working.
4. **Invoke a skill.** Type `/debt list`. It should read
   `docs/TECH_DEBT.md` and print the (empty) active table. If Claude asks
   "which skill?" the skill loader isn't picking up the file — check
   `.claude/skills/debt/SKILL.md` exists and has the YAML frontmatter.
5. **Glance at `docs/PRINCIPLES.md`** so you know what helper to reach
   for in what situation. You don't need to memorize it — this guide and
   the CLAUDE.md reminders will pull you back.

If all five passed, you're running.

---

## 2. A day in the template

A realistic chronological walk through one feature-dev day. None of
these invocations are mandatory; they're the shape of a day when the
template is doing its job.

### 09:00 — Start the session
SessionStart hook prints repo state. Glance at it — if there's an ADR
added yesterday you didn't write, or a debt row you didn't add, that's
information.

### 09:05 — Pick work
Fuzzy: *"what should I look at today?"* → Claude may auto-trigger
`/prioritize`. If you have a concrete task already, just describe it.
If the task description reads like an output (*"add a button"*) rather
than an outcome (*"let users reset their own password without opening a
ticket"*), Claude should pull in `/outcomes-first` before planning.
**You can force it:** `/outcomes-first add self-serve password reset`.

### 09:20 — Decide the shape
If the task introduces anything architecturally new — a library, a
schema, a boundary, a protocol choice — write the ADR now, not after
coding. `/adr use Postgres for the password-reset token store`. The
skill drafts a Nygard-style ADR in `docs/adrs/` with Context, Decision,
Alternatives, Consequences. You edit, then move Status to Accepted.

### 09:45 — Red/green loop
`/tdd` drives a disciplined tests-first loop. *"Let's TDD the token
expiry logic."* Claude writes failing tests, runs them to confirm they
fail **for the right reason**, then implements the minimum code, then
refactors. Three things you'll notice:

- It stops when tests pass. That's intentional — no gold-plating
  (Ch. 5's *Perfectionism* anti-pattern).
- It may ask you to name the acceptance criteria before touching code.
  Don't skip this.
- Post-Tool-Use formatter runs after every edit. If your formatter
  command fails silently, that's by design — the hook never blocks.

### 11:00 — Shortcut taken
You hard-coded an admin email. *"Add that as debt and keep going."*
`/debt add hard-coded admin email in services/reset/handler.ts — should
come from config by end of sprint`. You get back `TD-003 logged`.
Whole process: ten seconds. Debt is now visible.

### 11:30 — Scope creep attempted
You say *"while you're at it, can you also add an audit log?"* Claude
should stop and invoke `/scope-guard`. You'll get back either *"related,
fold in"* or *"split — I'll open TD-004 and we'll do it next."* Resist
the urge to override — scope-guard exists to save you.

### 13:00 — Ready for human review
Before you ping a reviewer, `/review`. This forks an isolated reviewer
subagent (it can't see the optimistic framing from the current
conversation). You'll get a severity-ranked report: blockers, high, med,
low. Fix blockers and highs, at minimum. Log the lows as debt if they're
real and you won't fix them now.

### 14:00 — Commit
`/commit`. The skill inspects staged and unstaged diffs, groups by
concern, and proposes either one commit or a split. It never commits
without showing the message first. This is the one skill with
`disable-model-invocation: true` — Claude will **not** commit on its
own initiative; you have to ask.

### 15:00 — Merged
`/post-ship email verification`. Three artifacts: changelog/README
update, an observability plan (what metrics, logs, alerts should exist
now that this is live), and a comms note (Slack/email draft). You don't
need all three every time, but the skill surfaces what you're skipping.
Then `/brag add shipped self-serve password reset — Q1 OKR, removes
~40 tickets/week from support queue`.

### 17:30 — End of session
Stop hook runs `brag-log.sh`. If there were commits in the last five
minutes or an ADR/debt update, it appends a dated stub to `docs/BRAG.md`
for you to flesh out tomorrow morning. The rule of thumb from Ch. 6:
write the impact sentence within 24 hours, while the numbers are still
fresh.

---

## 3. Scenarios & recipes

Indexed by situation. Each is the shortest prompt that gets the helper
to do the right thing.

### "I don't know what to work on"
```
/prioritize
- finish password reset
- fix login flake (reported 3x this week)
- migrate auth tests to vitest
- investigate the 500ms p95 regression
```
You get back a 2×2 (impact × effort) and a one-sentence pick.

### "This task feels fuzzy"
```
/outcomes-first migrate auth tests to vitest
```
Output: a one-sentence outcome, a sharpened task list, a clear
*"done when"* definition.

### "We're about to choose between two libraries"
```
/adr choose between zod and valibot for request validation
```
ADR drafted with both as Alternatives Considered. You edit, Status =
Accepted, commit.

### "New behavior, clear acceptance criteria"
```
/tdd add rate limiting to /api/login: 5 attempts per IP per 15min, 429 response
```
Red → green → refactor. Stops when tests pass.

### "Something is broken"
```
/debug login returns 500 intermittently in staging, not reproducible locally
```
Forces a written hypothesis, records what's tried, converges by
bisection. Switch to `/tdd` once you have the fix.

### "I took a shortcut"
```
/debt add skipped CSRF check on /admin/impersonate because we're behind the VPN
```
`TD-NNN logged`. Later, when you do fix it:
```
/debt repay TD-042
```

### "Cleanup sprint starting"
```
/debt list
/debt audit
```
`list` shows tracked items sorted by severity × interest; `audit` scans
the codebase for untracked `TODO`/`FIXME`/`HACK` markers and suggests
which to promote into the ledger.

### "Scope is growing"
```
/scope-guard can you also add 2FA while you're in here?
```
You'll get stay-the-course or split-and-defer, with titles for the
follow-ups if it's a split.

### "Ready for human review"
```
/review
```
Uses the current diff. Or:
```
/review origin/main..HEAD
/review services/billing/**
```

### "Something smells"
```
/anti-patterns services/billing/**
```
Scans for the 20 anti-patterns from Ch. 5 and Ch. 10 with evidence.
Good before a retro, after onboarding, or when a PR *"feels off"*. Don't
run it every edit — it's a periodic scan, not a linter.

### "Sprint ending / project wrapped / post-incident"
```
/retro last-sprint
/retro payment-migration
/retro checkout-outage-2026-03-14
```
Three sections: Kept, Changed, Action Items. Every action item gets an
owner, acceptance test, and due date. The skill refuses to produce an
action-less "it was fine" retro.

### "Feature shipped"
```
/post-ship rate-limit on /api/login
```
Changelog/README note, observability plan, comms draft.

### "Logging an accomplishment"
```
/brag add shipped rate-limit; login abuse alerts dropped from ~20/day to 0
```

### "Prepping for 1:1 / self-review"
```
/brag summarize last-month
/brag summarize last-quarter
/brag summarize 2026-01-01..2026-03-31
```
Highlights, by-the-numbers, theme of the period.

### "Reviewing a stranger's PR"
```
/review https://github.com/org/repo/pull/123
```
(Requires Claude to have access to fetch the diff, or paste it.)

---

## 4. Skills cheat sheet

All skills are `.claude/skills/<name>/SKILL.md`. Two can be triggered by
Claude on its own initiative; the rest are usually user-invoked via `/`
slash command.

| Skill | Invoke | Subcommands | Writes to | Ch. |
|---|---|---|---|---|
| `outcomes-first` | `/outcomes-first <task>` | — | (in-chat) | 1 |
| `prioritize` | `/prioritize` + list | — | (in-chat) | 1 |
| `adr` | `/adr <decision title>` | — | `docs/adrs/NNNN-*.md` | 13 |
| `tdd` | `/tdd <feature\|bug>` | — | test + src files | 13 |
| `review` | `/review [ref\|glob]` | — | (in-chat, forked context) | 13 |
| `commit` | `/commit [scope]` | — | git | 2 |
| `debug` | `/debug <symptom>` | — | (in-chat) | 2 |
| `debt` | `/debt <sub>` | `add`, `list`, `repay`, `audit` | `docs/TECH_DEBT.md` | 3 |
| `scope-guard` | `/scope-guard [new req]` | — | (in-chat) | 5 |
| `anti-patterns` | `/anti-patterns [glob]` | — | (in-chat, forked context) | 5 & 10 |
| `brag` | `/brag <sub>` | `add` (default), `summarize` | `docs/BRAG.md` | 6 |
| `retro` | `/retro <period>` | — | (in-chat) | 10 |
| `post-ship` | `/post-ship [what shipped]` | — | `README.md`, `CHANGELOG.md`, (comms draft) | 13 |

**Auto-invocation notes.** `commit` has `disable-model-invocation: true`
— Claude won't commit on its own, ever. The others can be pulled in by
Claude when your prompt matches the skill's description. If a skill
auto-fires when you didn't want it, say *"don't use the X skill for
this"* and Claude will fall back to a plain response.

**Forked-context skills.** `review` and `anti-patterns` fork an isolated
subagent with its own window. That subagent cannot see the optimistic
framing from your main conversation. That's the whole point — don't
"help" it by pasting in your justification. Let it look at the code
cold.

---

## 5. Hook reference

Hooks are deterministic. They can't be argued out of blocking something.

| Hook | Event | Matcher | What it does | Can block? |
|---|---|---|---|---|
| `inject-context.sh` | SessionStart | — | Prints branch, SHA, changed files, ADR count, debt count, last 3 commits | No |
| `protect-files.sh` | PreToolUse | `Edit\|Write\|MultiEdit` | Blocks edits to `.env*`, `*.pem`, `*.key`, `secrets/`, `credentials/`, lockfiles, `.git/` | Yes (exit 2) |
| `secrets-guard.sh` | PreToolUse | `Edit\|Write\|MultiEdit` | Scans new content for AWS keys, GitHub PATs, Slack tokens, Google API keys, Stripe keys, OpenAI `sk-*` keys, private-key blocks, JWTs | Yes (exit 2) |
| `licensing-check.sh` | PreToolUse | `Edit\|Write\|MultiEdit` | Warns on license headers, SPDX tags, copyright lines, attribution markers | No (warn only) |
| `format-after-edit.sh` | PostToolUse | `Edit\|Write\|MultiEdit` | Runs the right formatter by extension (biome, prettier, ruff, black, gofmt, rustfmt, rubocop, shfmt) | No (silent fail) |
| `brag-log.sh` | Stop | — | If recent commits / ADR / debt changes in last 5 min, appends dated stub to `docs/BRAG.md` | No |

**How to tell a hook fired.** `inject-context.sh` is the only visible
one — look at the top of each session. The rest are silent unless they
block. When a PreToolUse hook blocks, you'll see Claude's response with
the blocker's stderr message ("refusing to write to `.env`…").

**When to disable a hook.** Put a per-developer override in
`.claude/settings.local.json` (gitignored). Example: disable the
formatter on a branch where the formatter is misconfigured.
```json
{
  "hooks": {
    "PostToolUse": []
  }
}
```
`settings.local.json` **overrides** `settings.json` for your machine;
it doesn't merge. If you disable one hook event, redeclare the ones you
still want.

**When to add a hook.** See *Customizing* below.

---

## 6. The paper trail

Four files compound over time. Treat them as first-class code.

### `docs/adrs/NNNN-*.md`
Written by `/adr`. Numbered, immutable once Accepted (reverse a
decision with a new ADR that supersedes the old one, don't edit the
old one). A healthy team has 10–30 ADRs per year per service.

### `docs/TECH_DEBT.md`
Written by `/debt`. Active debt at top (table + details), repaid debt
at bottom. Rule of thumb: if you can't point to a specific line in this
file when someone asks *"why is X so hard to change?"* then you haven't
been logging.

### `docs/BRAG.md`
Written by `/brag add` and the Stop hook. Monthly headings. Fill in
impact within 24 hours — by Thursday next week the numbers evaporate.
Review before every 1:1 and every performance cycle.

### `docs/PRINCIPLES.md`
Static. Shipped with this template. Don't modify unless you're
adapting the template itself — it's the map between the book and the
helpers.

---

## 7. When things go wrong

### SessionStart hook silent
Check `.claude/settings.json` has the SessionStart entry (it does by
default). Then check `.claude/hooks/inject-context.sh` is executable:
```
chmod +x .claude/hooks/*.sh
```
Then run it by hand to see if it errors:
```
.claude/hooks/inject-context.sh
```

### PreToolUse hook blocks a legitimate edit
You're editing a file that matches a deny pattern (`.env*`, `*.pem`,
etc.) for a real reason. Two options:
1. **Best:** rename the file. If it's a template, call it `.env.example`
   — it'll pass. If it's a test fixture, call it `example.key.txt`.
2. **Escape hatch:** in your `.claude/settings.local.json` (gitignored),
   add a per-developer `allow` rule for that specific path. Commit this
   to history if and only if the team agrees. Never add broad patterns
   like `Edit(**/*.env)`.

### secrets-guard.sh flagged something that isn't a secret
Look at the stderr — it'll name the pattern that matched (e.g.
`AKIA...` for AWS). If it's a fake in docs or a test fixture, move it
to a `.example` file or use a clearly-broken placeholder like
`AWS_ACCESS_KEY_ID=<your-key-here>`. Don't disable the hook — this is
exactly the kind of guardrail that pays back a hundred times.

### Formatter ran and made weird changes
`format-after-edit.sh` dispatches on file extension. If the wrong
formatter ran (e.g. `prettier` on a file that should use `biome`), the
fix is in your project config, not the hook. The hook calls whichever
formatter your project has installed — it's thin.

### Skill was auto-triggered when I didn't want it
Tell Claude *"don't use the `<name>` skill for this"* and it'll fall
back. If a skill keeps mis-triggering, tighten its `when_to_use` in the
skill's frontmatter (e.g., add explicit negative examples).

### Skill wasn't auto-triggered when I expected it
Either (a) you're phrasing the ask in a way that doesn't match the
skill's `description`, or (b) the skill has `disable-model-invocation:
true` (that's the `commit` skill). Just invoke it explicitly with `/`.

### `/brag summarize` shows nothing
The Stop hook only logs when a session had recent commits or ADR/debt
updates. On a read-only session (reviews, discussions), nothing lands.
Use `/brag add` explicitly for non-commit work.

### The anti-pattern scanner reports a false positive
The scanner is conservative but not perfect. It cites evidence for
every finding — if the evidence is wrong, the finding is wrong. Say so
and ask for the scan to be re-run excluding that pattern, or tighten
the pattern in the scanner subagent's prompt at
`.claude/agents/anti-pattern-scanner.md`.

---

## 8. Customizing

### Adding a skill
1. Create `.claude/skills/<name>/SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: your-skill
   description: <one paragraph — this is what Claude matches on when
     deciding whether to auto-trigger. Be specific. Use examples.>
   when_to_use: <one sentence, including negative cases>
   argument-hint: "[how the user should invoke it]"
   allowed-tools: Read Edit Write Bash(git log:*)
   ---

   # Skill body in Markdown — the actual instructions Claude follows.
   ```
2. Optional: add `disable-model-invocation: true` for user-only skills
   (like `commit`).
3. Optional: add `context: fork` and `agent: <agent-name>` for skills
   that should run in an isolated subagent context (like `review`).
4. Restart your Claude Code session for it to pick up the new skill.

### Adding a subagent
1. Create `.claude/agents/<name>.md` with YAML frontmatter:
   ```yaml
   ---
   name: your-agent
   description: <what this agent is for>
   tools: [Read, Grep, Glob, Bash]
   ---

   # The system prompt / instructions for the forked agent.
   ```
2. Reference it from a skill via `agent: your-agent` + `context: fork`.

### Adding a hook
1. Create `.claude/hooks/<name>.sh`. Keep it fast (< 200 ms). Use
   `set -euo pipefail`. Read input JSON from stdin.
2. Exit codes:
   - `0` = success
   - `2` = block with stderr as the reason (PreToolUse only)
   - anything else = non-blocking error
3. Register it in `.claude/settings.json` under the right event +
   matcher.
4. `chmod +x .claude/hooks/<name>.sh`.
5. Test it with synthetic JSON:
   ```bash
   echo '{"tool_name":"Edit","tool_input":{"file_path":"x.ts","new_string":"..."}}' \
     | .claude/hooks/<name>.sh
   echo "exit: $?"
   ```

### Disabling a helper you won't use
Delete the directory (`.claude/skills/<name>/` or
`.claude/agents/<name>.md`) or move it to `.claude/disabled/`. Remove
its mention from `CLAUDE.md` so Claude doesn't advertise a skill that
isn't loaded.

### Tightening `CLAUDE.md`
The file is read every session. Shorter and sharper is better. Two
rules:

- **If something is context-sensitive** (stack, commands, contact
  info, conventions), put it in `CLAUDE.md`.
- **If something is universal** (operating principles, anti-patterns
  from the book), it's already in `CLAUDE.md` — don't duplicate it into
  every skill.

Keep the file under ~200 lines.

---

## 9. Anti-patterns when using the template

Meta-warnings from Ch. 5 that apply to the template itself:

- **Tool obsession.** Don't invoke four skills for a one-line doc fix.
  The template's value is picking the one helper that fits.
- **Over-engineering.** If you find yourself writing an ADR for
  *"should this be a `let` or `const`"*, you're mis-matching the
  helper. ADRs are for decisions whose consequences outlive the PR.
- **Rubber stamping.** A passing review, a green hook, and a logged
  brag entry don't mean the work is good. The helpers automate
  bookkeeping, not judgment.
- **Hero complex.** If the `/brag` file is all you, the team has a
  bus-factor problem (Ch. 10). Log peers' wins in retros, and pair.
- **Knowledge silo.** If only you know why a decision was made, write
  the ADR. The template can only record what you tell it.

---

## 10. Upgrading the template

When you pull a newer version of this template into an existing project:

1. Diff the new `.claude/` against yours. Merge the new skills/hooks
   you want; keep your local customizations.
2. `CLAUDE.md` should mostly be yours at this point — diff only the
   "Operating principles" section against the new one.
3. `docs/PRINCIPLES.md` can be replaced wholesale unless you've been
   editing it.
4. Never replace `docs/adrs/`, `docs/TECH_DEBT.md`, or `docs/BRAG.md`
   — those are your content, not the template's.
5. Re-run the 15-minute smoke test from Section 1.

---

*For the book → helper mapping, see `docs/PRINCIPLES.md`. For install
and overview, see `README.md`. For bugs or gaps in the template itself,
open an ADR locally explaining what you changed and why.*
