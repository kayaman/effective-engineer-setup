---
name: commit
description: Stage and write a disciplined Conventional-Commit message for the current changes. Use when the user says "commit", "let's commit this", "make the commit", or when finishing a TDD loop. Inspects the staged and unstaged diffs, groups changes by concern, and either produces ONE commit if the diff is cohesive, or proposes a split into multiple commits if it is not. Never commits without showing the message first.
when_to_use: Explicit commit requests. Do NOT auto-commit at the end of a turn without being asked.
argument-hint: "[optional scope hint, e.g. 'auth' or 'billing']"
disable-model-invocation: true
allowed-tools: Bash(git status:*) Bash(git diff:*) Bash(git diff --cached:*) Bash(git add:*) Bash(git commit:*) Bash(git log -1:*) Bash(git restore --staged:*)
---

# Disciplined commits

From Ch. 2: version control is documentation. A commit message is a message
to the future — including the future you, six months from now, on-call at
02:00. Write accordingly.

## Procedure

1. **Inspect state.**
   ```bash
   git status --short
   git diff --stat
   git diff --cached --stat
   ```

2. **Group changes by concern.** A "concern" is one answer to "why does
   this change exist?". Refactoring `foo.ts` to enable a new feature in
   `bar.ts` is **one** concern. Fixing a typo in the README while
   implementing a feature is **two**.

3. **Decide: one commit or split?**
   - **One commit** if every changed file serves the same concern and a
     single one-line subject can honestly describe it.
   - **Split** otherwise. Show the proposed split — file-by-file — and
     ask the user to confirm before staging.

4. **Write the message** in Conventional-Commits format:

   ```text
   <type>(<scope>): <imperative subject, ≤72 chars, no period>

   <body: what changed and WHY, not how. Hard-wrap at 72 cols. Reference
   outcomes, ADRs, issue IDs. Explain the trade-off if any.>

   <trailers>
   ```

   Types (pick one): `feat` · `fix` · `refactor` · `perf` · `test` ·
   `docs` · `build` · `ci` · `chore` · `revert`.

   Scope is optional; prefer the module/package name (`auth`, `billing`).

5. **Body rules (Ch. 2):**
   - **Imperative, not past:** *"Add retry to token refresh"* — not
     *"Added…"*, *"Adds…"*
   - **Explain why, not what.** The diff shows what.
   - **Link work.** Reference ADRs (`See docs/adrs/0007-…`), tech-debt
     entries, or issue IDs.
   - **Note follow-ups** as trailers, not prose:
     `Follow-up: migrate old tokens (docs/TECH_DEBT.md#TD-042)`.

6. **Show, then commit.** Print the full message and the file list.
   Ask: *"Commit as-is?"* Only stage and run `git commit` after
   confirmation.

7. **Never amend a pushed commit.** If the user asks to fix a prior
   commit and you cannot verify it is local-only via
   `git branch -r --contains HEAD`, stop and ask.

## Good vs bad examples

```text
# ✓ Good
feat(auth): require verified email before password reset

Password reset currently succeeds for unverified emails, which lets an
attacker who guessed an address claim the account before the owner
verifies. Gate the reset on `users.email_verified_at IS NOT NULL` and
surface a 409 with the same shape we use for the sign-in path, so the
client can route both cases to the same re-verification flow.

Closes #1423
See docs/adrs/0012-email-verification-gates.md
```

```text
# ✗ Bad
fix: bug fix
update stuff
WIP
final final v2
```

## Guardrails

- **No `--amend` on shared commits.** See step 7.
- **No `--no-verify`** unless the user explicitly asks and names the check
  they're skipping.
- **No commits with failing tests** without a `WIP:` prefix and an
  explicit note that the branch is private.
