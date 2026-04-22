#!/usr/bin/env bash
# licensing-check.sh
# PreToolUse hook (matcher: Edit|Write|MultiEdit)
#
# Heuristic check for likely copy-pasted code that carries licensing or
# attribution obligations. This is a nudge, not a lawyer. It surfaces
# three signals:
#
#   1. A license header block in the content being written
#      (Apache, MIT, GPL, BSD, MPL, etc.)
#   2. A "Copyright <year> <Holder>" line
#   3. An explicit "Source:" / "Adapted from:" / "SPDX-License-Identifier"
#
# If ANY of these appear, we don't block — we warn to stderr with exit 0,
# so Claude sees it (as non-blocking feedback via debug log) but the
# write proceeds. The human is the real judge.
#
# Per Ch. 13 "Watch out for licensing and attribution issues": the goal
# is that attribution happens deliberately, not by accident.
set -euo pipefail

INPUT="$(cat)"

if command -v jq >/dev/null 2>&1; then
  CONTENT="$(echo "$INPUT" | jq -r '
    [
      (.tool_input.new_string // empty),
      (.tool_input.content // empty),
      ((.tool_input.edits // []) | map(.new_string // empty) | join("\n"))
    ] | join("\n")
  ')"
  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')"
else
  exit 0
fi

[[ -z "$CONTENT" ]] && exit 0

SIGNALS=()

# Common OSS license header fingerprints (first line only; no full text).
if echo "$CONTENT" | grep -Eiq 'Licensed under the (Apache|MIT|BSD|GPL|LGPL|MPL|Mozilla|ISC)'; then
  SIGNALS+=("license-header")
fi
if echo "$CONTENT" | grep -Eiq 'SPDX-License-Identifier:'; then
  SIGNALS+=("spdx-identifier")
fi
if echo "$CONTENT" | grep -Eiq 'Copyright[[:space:]]+\(?c?\)?[[:space:]]+[0-9]{4}'; then
  SIGNALS+=("copyright-line")
fi
if echo "$CONTENT" | grep -Eiq '(^|\s)(Source|Adapted from|Based on|Ported from)[[:space:]]*[:=]'; then
  SIGNALS+=("attribution-marker")
fi

if ((${#SIGNALS[@]} > 0)); then
  echo "licensing-check: noticed license/attribution signals in write to '${FILE_PATH}':" >&2
  for s in "${SIGNALS[@]}"; do echo "  - $s" >&2; done
  echo "" >&2
  echo "If this code was copied or adapted from an external source, please:" >&2
  echo "  1. Keep the attribution block intact." >&2
  echo "  2. Confirm the license is compatible with this project's LICENSE." >&2
  echo "  3. Record the decision in an ADR (via /adr) if it's a new dependency." >&2
  echo "This is a warning, not a block. Proceeding." >&2
  # Exit 0 — non-blocking.
fi

exit 0
