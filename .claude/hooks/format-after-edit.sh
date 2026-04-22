#!/usr/bin/env bash
# format-after-edit.sh
# PostToolUse hook (matcher: Edit|Write|MultiEdit)
#
# Auto-format the file Claude just edited, so "Clean, maintainable, and
# readable code" (Ch. 2) is deterministic, not advisory. Picks a
# formatter based on the file extension. If no matching formatter is
# available, exits quietly — this hook must never fail the turn.
#
# Add or swap formatters to match your stack.
set -euo pipefail

INPUT="$(cat)"

if command -v jq >/dev/null 2>&1; then
  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')"
else
  exit 0
fi

[[ -z "$FILE_PATH" ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && exit 0

# Skip files we already protect from edits (shouldn't reach here, but
# belt and braces).
case "$FILE_PATH" in
  *.env|*.env.*|*secrets/*|*.pem|*.key) exit 0 ;;
esac

EXT="${FILE_PATH##*.}"

# Format dispatcher. First available tool wins per language.
format_with() {
  local tool="$1" ; shift
  if command -v "$tool" >/dev/null 2>&1; then
    "$tool" "$@" "$FILE_PATH" >/dev/null 2>&1 || true
    return 0
  fi
  return 1
}

case "$EXT" in
  # JS / TS / JSON / CSS / HTML / Markdown — Biome first (fast), then
  # Prettier.
  ts|tsx|js|jsx|json|jsonc|css|html|md|mdx|yaml|yml)
    format_with biome format --write \
      || format_with prettier --write --log-level=error \
      || format_with npx prettier --write --log-level=error \
      || true
    ;;

  # Python — Ruff first (fast), then Black.
  py)
    format_with ruff format \
      || format_with black --quiet \
      || true
    ;;

  # Go — gofmt is always present when Go is installed.
  go)
    format_with gofmt -w \
      || true
    ;;

  # Rust — rustfmt.
  rs)
    format_with rustfmt --edition 2021 \
      || true
    ;;

  # Ruby — rubocop.
  rb)
    format_with rubocop -A --format quiet \
      || true
    ;;

  # Shell — shfmt.
  sh|bash)
    format_with shfmt -w -i 2 \
      || true
    ;;

  # Nothing else triggers formatting.
  *) : ;;
esac

# Always succeed — formatting failures are never blockers.
exit 0
