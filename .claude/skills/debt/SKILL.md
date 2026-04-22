---
name: debt
description: Record, list, or repay an item in the technical-debt ledger at docs/TECH_DEBT.md. Use whenever a shortcut is taken in the current change (hard-coded value, bypassed validation, skipped test, out-of-band config, copied-and-tweaked code), when the user says "let's come back to this" or "add a TODO", or when exploring the codebase reveals a debt item worth recording. Subcommands, selected via the first argument: `add`, `list`, `repay`, `audit`.
when_to_use: Any time a deliberate shortcut is taken OR the user asks "what tech debt do we have?" OR when starting a cleanup sprint.
argument-hint: "add|list|repay|audit [description or ID]"
allowed-tools: Read Edit Write Grep Glob Bash(date:*) Bash(git log -1 --format=%h:*)
---

# Technical-debt ledger

From Ch. 3 and Ch. 5: unwritten technical debt is invisible, and invisible
debt compounds silently. This skill makes every shortcut a ledger row so
that "we'll fix it later" has a later.

The ledger lives at `docs/TECH_DEBT.md`. Each row has a stable ID (`TD-NNN`)
and links bidirectionally with commits and ADRs.

## Subcommands

### `add`

1. Parse the description from `$ARGUMENTS` after the `add` keyword.
2. Read `docs/TECH_DEBT.md`. Find the highest existing ID. Next ID is +1,
   zero-padded to 3 digits (`TD-001`, `TD-042`).
3. Fetch today's date (`date +%Y-%m-%d`) and the short SHA of the current
   HEAD if a repo (`git log -1 --format=%h`).
4. Classify the debt on three axes (Ch. 3):
   - **Type**: `design` | `code` | `test` | `docs` | `infra` | `process`
   - **Severity**: `low` (cosmetic) | `med` (slows teammates) |
     `high` (blocks a near-term feature or causes incidents)
   - **Interest**: `flat` (pain doesn't grow) |
     `linear` (grows with usage) | `compounding` (grows with code around it)
5. Append a row to the `## Active debt` table and a one-paragraph entry to
   the `## Details` section (see template below).
6. Print the ID and the one-line summary. Do not dump the whole ledger.

### `list`

Print the `## Active debt` table sorted by severity desc, then interest
desc. Highlight rows where interest is `compounding` and severity ≥ `med`
— those are the ones to pay down first.

### `repay TD-NNN`

1. Find the row. If it doesn't exist, stop and say so.
2. Move the row to the `## Repaid` section with a `repaid:` date and the
   current commit SHA.
3. Add a one-line entry to the repaid row: *"Fixed in \<SHA\>
   (\<PR/issue link if available\>): \<what changed\>"*.
4. If the debt item referenced an ADR, note the repayment in the ADR's
   Consequences section.

### `audit`

Scan the codebase for potential debt not yet in the ledger:

```bash
rg -n --type-add 'src:*.{ts,tsx,js,py,go,rs,rb,java}' --type src \
   'TODO|FIXME|HACK|XXX|@debt|@deprecated'
```

For each match, cross-reference with the ledger (match by filename and a
fuzzy keyword search). Report:
- **Orphan markers**: in-code markers with no ledger entry → suggest
  `/debt add`.
- **Stale entries**: ledger entries whose referenced code no longer
  matches → suggest `/debt repay` or clarify.

Do not auto-create entries from markers — let the human decide which are
real debt vs "note to self".

## Ledger template (used when `docs/TECH_DEBT.md` is first created)

```markdown
# Technical Debt Ledger

Every deliberate shortcut gets a row. Severity and interest drive order of
repayment. See `.claude/skills/debt/SKILL.md` for the rules.

## Active debt

| ID     | Type | Severity | Interest    | Added      | Summary |
|--------|------|----------|-------------|------------|---------|
| TD-001 | …    | med      | compounding | 2026-01-15 | …       |

## Details

### TD-001 — <one-line summary>
- **Added:** 2026-01-15 in <SHA>
- **Why:** <why the shortcut was taken — the real reason>
- **Cost if we keep it:** <concrete: breaks X feature, slows Y workflow>
- **Shape of repayment:** <outline of the fix, no code>
- **Related:** <ADR or issue links>

## Repaid

| ID     | Summary | Repaid     | Commit  | Notes |
|--------|---------|------------|---------|-------|
| TD-000 | …       | 2026-01-10 | abc1234 | …     |
```

## Guardrails

- **Never silently ignore a shortcut.** If Claude is about to write a
  workaround, it must either (a) ask the user whether to log it, or (b)
  log it proactively with `add` and mention the new ID in chat.
- **Never delete repaid entries.** Closed ledger entries are history —
  they answer "when did we fix X?" years later.
- **Don't over-classify.** Severity `high` is for "causes pain right now",
  not "might one day cause pain".
