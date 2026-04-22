#!/usr/bin/env bash
# inject-context.sh
# SessionStart hook (matcher: "" — fires on startup, resume, compact,
# clear).
#
# Gives Claude the minimum repository awareness it needs — branch,
# recent activity, active ADRs, open debt — without bloating CLAUDE.md.
# Anything written to stdout becomes part of Claude's context for the
# session, so keep it terse.
#
# Ch. 13 "Feeding the AI Context: Getting Repository Awareness Right":
# give the model the *current state* pointers; let it fetch details on
# demand.
set -euo pipefail

# Read and ignore stdin JSON — we don't need the event payload, but we
# must consume it to be a well-behaved hook.
cat >/dev/null

# Only print anything when we're in a git repo.
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  exit 0
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
SHORT_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo '?')"

# Last 3 commits, one-line form.
LAST_COMMITS="$(git log --oneline -3 2>/dev/null || true)"

# Status of working tree: count of modified and untracked.
STAT_COUNTS="$(git status --porcelain 2>/dev/null | awk '
  /^[ MARCD]/   { mod++ }
  /^\?\?/       { unt++ }
  END {
    printf "%d modified, %d untracked", (mod+0), (unt+0)
  }')"

# Count of accepted ADRs (files numbered NNNN- excluding the template).
ADR_COUNT=0
if [[ -d docs/adrs ]]; then
  ADR_COUNT="$(find docs/adrs -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' \
    ! -name '0000-template.md' 2>/dev/null | wc -l | tr -d ' ')"
fi

# Count of active tech-debt rows (crude: count table rows in the Active
# section).
DEBT_COUNT=0
if [[ -f docs/TECH_DEBT.md ]]; then
  DEBT_COUNT="$(awk '
    /^## Active debt/ { in_section=1; next }
    /^## /             { in_section=0 }
    in_section && /^\| TD-[0-9]+/ { n++ }
    END                { print n+0 }
  ' docs/TECH_DEBT.md)"
fi

cat <<EOF
[repo-context] Branch: ${BRANCH} @ ${SHORT_SHA} | working tree: ${STAT_COUNTS}
[repo-context] ADRs on file: ${ADR_COUNT} | active tech-debt items: ${DEBT_COUNT}
[repo-context] Last 3 commits:
${LAST_COMMITS}
[repo-context] Reminder: invoke /outcomes-first for any non-trivial new task, /adr for design decisions, /debt add for shortcuts, /brag for shipped wins.
EOF

exit 0
