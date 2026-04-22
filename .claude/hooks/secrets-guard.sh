#!/usr/bin/env bash
# secrets-guard.sh
# PreToolUse hook (matcher: Edit|Write|MultiEdit)
#
# Scans the CONTENT Claude is about to write for anything that looks like
# a secret being inlined into source. Enforces Ch. 13: "Don't feed the AI
# sensitive data" — and, symmetrically, don't let the AI bake secrets
# into the repo.
#
# Patterns are intentionally high-signal (small number, low false-positive
# rate). This is a safety net, not a DLP product. A human should still
# grep before pushing.
#
# Exit codes:
#   0  -> allow
#   2  -> block with feedback
set -euo pipefail

INPUT="$(cat)"

# Pull the content being written. Edit uses `new_string`; Write uses
# `content`; MultiEdit has an `edits` array of { new_string }. We
# concatenate all of them.
if command -v jq >/dev/null 2>&1; then
  CONTENT="$(echo "$INPUT" | jq -r '
    [
      (.tool_input.new_string // empty),
      (.tool_input.content // empty),
      ((.tool_input.edits // []) | map(.new_string // empty) | join("\n"))
    ] | join("\n")
  ')"
else
  # No jq -> we can't reliably inspect. Fail open with a warning.
  echo "secrets-guard.sh: jq not available; skipping content scan." >&2
  exit 0
fi

[[ -z "$CONTENT" ]] && exit 0

# Regexes. Each entry: description | pattern (extended regex).
# Keep this list focused. The goal is to catch accidents, not to be a
# secret scanner.
declare -a CHECKS=(
  'AWS access key ID|AKIA[0-9A-Z]{16}'
  'AWS secret access key (40-char)|(^|[^A-Za-z0-9/+=])[A-Za-z0-9/+=]{40}([^A-Za-z0-9/+=]|$)'
  'GitHub personal access token|ghp_[A-Za-z0-9]{36}'
  'GitHub fine-grained token|github_pat_[A-Za-z0-9_]{82}'
  'Slack bot/user token|xox[baprs]-[A-Za-z0-9-]{10,}'
  'Google API key|AIza[0-9A-Za-z_-]{35}'
  'Stripe secret key|sk_live_[0-9A-Za-z]{24,}'
  'OpenAI/Anthropic-style API key|sk-[A-Za-z0-9]{20,}'
  'Generic private key block|-----BEGIN (RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY-----'
  'JWT (header.payload.signature)|eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
)

HITS=()
for check in "${CHECKS[@]}"; do
  DESC="${check%%|*}"
  PAT="${check#*|}"
  # `grep -e PATTERN` prevents a leading dash in PATTERN (e.g. the
  # -----BEGIN PRIVATE KEY line) from being read as an option flag.
  if echo "$CONTENT" | grep -Eq -e "$PAT"; then
    HITS+=("$DESC")
  fi
done

if ((${#HITS[@]} > 0)); then
  echo "Blocked: the write contains one or more patterns that look like secrets." >&2
  echo "Matched pattern(s):" >&2
  for h in "${HITS[@]}"; do echo "  - $h" >&2; done
  echo "" >&2
  echo "If this is a false positive (e.g. a documented example in a README):" >&2
  echo "  - Add a comment tagging the match as an example, e.g. '# fake-key-for-docs'" >&2
  echo "  - Or relax the pattern in .claude/hooks/secrets-guard.sh" >&2
  echo "If this is a real secret, rotate it IMMEDIATELY, then re-ask without the secret." >&2
  exit 2
fi

exit 0
