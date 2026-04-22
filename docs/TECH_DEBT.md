# Technical-debt ledger

The living record of deliberate shortcuts taken in this codebase.
Managed by the `/debt` skill (see `.claude/skills/debt/SKILL.md`).

From Ch. 3 of *The Effective Software Engineer*: unwritten debt is invisible,
and invisible debt compounds silently. Every shortcut gets a row here so
that *"we'll fix it later"* has a later.

## Conventions

- **IDs** are stable (`TD-001`, `TD-002`, …). Never reused after repayment.
- **Type**: `design` · `code` · `test` · `docs` · `infra` · `process`
- **Severity**: `low` (cosmetic) · `med` (slows teammates) · `high` (blocks a
  near-term feature or causes incidents)
- **Interest**: `flat` (pain doesn't grow) · `linear` (grows with usage) ·
  `compounding` (grows with code around it) — pay down `compounding` × `high`
  first.
- **Owner**: team or individual accountable for the repayment.
- Every row in *Active debt* must have a matching paragraph under *Details*
  with enough context for a stranger to repay it.

---

## Active debt

| ID | Added | Type | Sev | Interest | Summary | Owner |
|----|-------|------|-----|----------|---------|-------|
| _none yet — add with `/debt add <description>`_ | | | | | | |

---

## Details

<!--
One paragraph per active row. Structure:

### TD-NNN — <Short title>

- **Added:** YYYY-MM-DD (<short SHA>)
- **Where:** <file paths or module>
- **Why it happened:** <the deadline, the unknown, the trade-off>
- **What the "right" version looks like:** <the fix we'd do with more time>
- **Cost of delay:** <what gets worse the longer this sits>
- **Linked ADR / issue:** <if any>
-->

_No debt recorded yet._

---

## Repaid

| ID | Added | Repaid | SHA | Notes |
|----|-------|--------|-----|-------|
| _empty_ | | | | |
