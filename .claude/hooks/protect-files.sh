#!/usr/bin/env bash
# protect-files.sh
# PreToolUse hook (matcher: Edit|Write|MultiEdit)
#
# Blocks edits to files that should never be touched by Claude without
# an explicit human step. Enforces Ch. 13 "Don't feed the AI sensitive
# data" and the CLAUDE.md policy "What I will not do without explicit
# human confirmation".
#
# Input (stdin, JSON): Claude Code hook event with tool_input.file_path
# Exit codes:
#   0  -> allow
#   2  -> block (stderr becomes Claude's feedback)
set -euo pipefail

INPUT="$(cat)"

# Extract file_path (Edit/Write use `file_path`; MultiEdit uses the same
# shape per edit). jq returns "null" for missing keys — guard against
# that.
if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')"
else
  # Fallback without jq: crude regex. Keep only for environments that
  # truly can't install jq.
  FILE_PATH="$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed 's/.*:"\(.*\)"/\1/')"
fi

# Nothing to check.
[[ -z "$FILE_PATH" ]] && exit 0

# Patterns that must never be written. First match wins.
# - Dotenv files (any variant)
# - Private keys and certificates
# - Conventional secrets directories
# - Lockfiles (they belong to the package manager, not to Claude)
# - Git internals
PROTECTED_PATTERNS=(
  '\.env$'
  '\.env\.'
  '/\.env$'
  '/\.env\.'
  '\.pem$'
  '\.key$'
  '\.p12$'
  '\.pfx$'
  '/secrets/'
  '/credentials/'
  'id_rsa$'
  'id_ed25519$'
  'package-lock\.json$'
  'pnpm-lock\.yaml$'
  'yarn\.lock$'
  'poetry\.lock$'
  'Cargo\.lock$'
  'Gemfile\.lock$'
  '/\.git/'
)

for pat in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" =~ $pat ]]; then
    echo "Blocked: \"$FILE_PATH\" is on the protected list (pattern: $pat)." >&2
    echo "This file must be edited by a human, not by Claude. If you genuinely need to update it:" >&2
    echo "  1. Explain to the user why, and" >&2
    echo "  2. Have them make the edit themselves, or" >&2
    echo "  3. Ask them to relax the rule in .claude/hooks/protect-files.sh." >&2
    echo "See CLAUDE.md section: 'What I will not do without explicit human confirmation'." >&2
    exit 2
  fi
done

exit 0
