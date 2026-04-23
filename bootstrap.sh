#!/usr/bin/env bash
# bootstrap.sh
#
# Drop the per-project Effective-Engineer scaffolding into a target project:
# CLAUDE.md (starter template), docs/PRINCIPLES.md, docs/adrs/ scaffolding,
# an empty TECH_DEBT.md, and an empty BRAG.md.
#
# It does NOT copy .claude/skills, .claude/agents, or .claude/hooks — those
# live at user scope (~/.claude/) via your stow-managed dotfiles. Run
# scripts/sync-to-dotfiles.sh once to install those.
#
# Usage:
#   ./bootstrap.sh <target-project-dir>        # won't overwrite existing files
#   ./bootstrap.sh <target-project-dir> --force # overwrite existing files
#
# Safe to re-run: by default every file is copied with a "don't clobber"
# rule, so customised CLAUDE.md / TECH_DEBT.md / BRAG.md survive a resync.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET="${1:-}"
FORCE=0
if [[ "${2:-}" == "--force" ]]; then FORCE=1; fi
if [[ "${1:-}" == "--force" ]]; then
  echo "error: --force must come after the target path." >&2
  exit 2
fi

if [[ -z "$TARGET" ]]; then
  echo "usage: $(basename "$0") <target-project-dir> [--force]" >&2
  exit 2
fi

if [[ ! -d "$TARGET" ]]; then
  echo "error: target $TARGET does not exist." >&2
  exit 1
fi

if ! git -C "$TARGET" rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "warning: $TARGET is not a git repo — the inject-context hook will no-op until you 'git init'."
fi

TARGET="$(cd "$TARGET" && pwd)"

copy() {
  local src="$1" dest="$2"
  if [[ -e "$dest" && $FORCE -ne 1 ]]; then
    echo "  skip  $dest (exists; pass --force to overwrite)"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  wrote $dest"
}

echo "→ bootstrapping $TARGET"

copy "$REPO_ROOT/CLAUDE.md"                              "$TARGET/CLAUDE.md"
copy "$REPO_ROOT/docs/PRINCIPLES.md"                     "$TARGET/docs/PRINCIPLES.md"
copy "$REPO_ROOT/docs/adrs/README.md"                    "$TARGET/docs/adrs/README.md"
copy "$REPO_ROOT/docs/adrs/0000-template.md"             "$TARGET/docs/adrs/0000-template.md"
copy "$REPO_ROOT/docs/adrs/0001-record-architectural-decisions.md" \
     "$TARGET/docs/adrs/0001-record-architectural-decisions.md"

# TECH_DEBT.md and BRAG.md start fresh per project — don't inherit this
# repo's entries. If the target already has one, leave it alone.
if [[ ! -e "$TARGET/docs/TECH_DEBT.md" || $FORCE -eq 1 ]]; then
  mkdir -p "$TARGET/docs"
  cat > "$TARGET/docs/TECH_DEBT.md" <<'MD'
# Technical-debt ledger

The living record of deliberate shortcuts taken in this codebase.
Managed by the `/debt` skill.

## Active debt

| ID | Added | Type | Sev | Interest | Summary | Owner |
|----|-------|------|-----|----------|---------|-------|
| _none yet — add with `/debt add <description>`_ | | | | | | |

## Details

_No debt recorded yet._

## Repaid

| ID | Added | Repaid | SHA | Notes |
|----|-------|--------|-----|-------|
| _empty_ | | | | |
MD
  echo "  wrote $TARGET/docs/TECH_DEBT.md (fresh)"
else
  echo "  skip  $TARGET/docs/TECH_DEBT.md (exists)"
fi

if [[ ! -e "$TARGET/docs/BRAG.md" || $FORCE -eq 1 ]]; then
  mkdir -p "$TARGET/docs"
  cat > "$TARGET/docs/BRAG.md" <<'MD'
# Brag Document

One-line records of shipped work. See `.claude/skills/brag/SKILL.md` for the
format and rules.

_No entries yet. Ship something, then run `/brag add <summary>`._
MD
  echo "  wrote $TARGET/docs/BRAG.md (fresh)"
else
  echo "  skip  $TARGET/docs/BRAG.md (exists)"
fi

# Minimal project-scope settings.json: permissions live here so collaborators
# who don't use the dotfiles package still get the safe defaults. Hooks are
# intentionally absent — they come from ~/.claude/settings.json.
if [[ ! -e "$TARGET/.claude/settings.json" || $FORCE -eq 1 ]]; then
  mkdir -p "$TARGET/.claude"
  cat > "$TARGET/.claude/settings.json" <<'JSON'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "_comment": [
    "Project-scope settings. Hooks are inherited from ~/.claude/settings.json",
    "when the Effective-Engineer dotfiles package is stowed. Add per-project",
    "allow rules here; put personal overrides in .claude/settings.local.json."
  ],
  "permissions": {
    "allow": [
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git branch:*)",
      "Bash(git show:*)",
      "Bash(ls:*)",
      "Bash(rg:*)",
      "Bash(find:*)",
      "Bash(pwd)"
    ]
  }
}
JSON
  echo "  wrote $TARGET/.claude/settings.json"
else
  echo "  skip  $TARGET/.claude/settings.json (exists)"
fi

echo
echo "✓ $TARGET is bootstrapped."
echo
echo "If you haven't yet installed the user-scope skills/hooks/agents:"
echo "  $REPO_ROOT/scripts/sync-to-dotfiles.sh /Projects/dotfiles"
echo "  cd /Projects/dotfiles && stow -t \"\$HOME\" claude"
