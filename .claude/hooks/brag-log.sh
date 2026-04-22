#!/usr/bin/env bash
# brag-log.sh
# Stop hook (fires when Claude finishes a turn).
#
# Detects "substantive" turns — ones that produced a commit or non-trivial
# set of file changes — and appends a dated stub to docs/BRAG.md. Claude
# or the user can flesh the stub out later with `/brag add`.
#
# This keeps the brag document an honest, near-lossless record without
# requiring the user to remember to log wins (Ch. 6).
#
# Must-not:
# - Never run forever. Check stop_hook_active and exit early if set.
# - Never block. Exit 0 always.
# - Never log on trivial turns (no file changes, no commits).
set -euo pipefail

INPUT="$(cat)"

# Infinite-loop guard from the Claude Code docs.
if command -v jq >/dev/null 2>&1; then
  if [[ "$(echo "$INPUT" | jq -r '.stop_hook_active // false')" == "true" ]]; then
    exit 0
  fi
fi

# Only operate inside a git repo with a docs/ folder present.
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  exit 0
fi
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"
[[ -d docs ]] || exit 0

# Determine if this turn was substantive:
#   - at least one commit in the last ~5 minutes, OR
#   - an ADR or debt entry was added in the last ~5 minutes.
# If neither, don't write anything.
RECENT_COMMITS="$(git log --since='5 minutes ago' --format='%h %s' 2>/dev/null || true)"

RECENT_ADR=""
if [[ -d docs/adrs ]]; then
  RECENT_ADR="$(find docs/adrs -maxdepth 1 -type f -newermt '5 minutes ago' \
    -name '[0-9][0-9][0-9][0-9]-*.md' ! -name '0000-template.md' 2>/dev/null || true)"
fi

RECENT_DEBT=""
if [[ -f docs/TECH_DEBT.md ]]; then
  if find docs/TECH_DEBT.md -newermt '5 minutes ago' 2>/dev/null | grep -q .; then
    RECENT_DEBT="yes"
  fi
fi

if [[ -z "$RECENT_COMMITS" && -z "$RECENT_ADR" && -z "$RECENT_DEBT" ]]; then
  exit 0
fi

BRAG_FILE="docs/BRAG.md"
MONTH_HEADING="## $(date +%Y-%m)"
TODAY="$(date +%Y-%m-%d)"

# Ensure file + month heading exist.
if [[ ! -f "$BRAG_FILE" ]]; then
  cat > "$BRAG_FILE" <<'EOF'
# Brag Document

One-line records of shipped work. See `.claude/skills/brag/SKILL.md` for the
format and rules.

EOF
fi
if ! grep -Fq "$MONTH_HEADING" "$BRAG_FILE"; then
  printf '\n%s\n\n' "$MONTH_HEADING" >> "$BRAG_FILE"
fi

# Build the stub.
{
  echo ""
  echo "### $TODAY — auto-logged (flesh out with /brag add)"
  if [[ -n "$RECENT_COMMITS" ]]; then
    echo "- **Commits:**"
    echo "$RECENT_COMMITS" | while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      echo "  - $line"
    done
  fi
  if [[ -n "$RECENT_ADR" ]]; then
    echo "- **ADRs added:**"
    echo "$RECENT_ADR" | while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      title="$(sed -n '1s/^#[[:space:]]*//p' "$f" | head -n1)"
      echo "  - $f — $title"
    done
  fi
  if [[ -n "$RECENT_DEBT" ]]; then
    echo "- **Tech-debt ledger updated:** docs/TECH_DEBT.md"
  fi
  echo "- **Impact:** _TODO: fill in with /brag add_"
} >> "$BRAG_FILE"

exit 0
