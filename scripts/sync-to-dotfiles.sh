#!/usr/bin/env bash
# sync-to-dotfiles.sh
#
# Mirror this repo's user-scope assets (skills, agents, hooks, and a
# user-scope settings.json) into a GNU Stow package inside your personal
# dotfiles repo, so `stow -d <dotfiles> -t "$HOME" claude` symlinks them
# into ~/.claude/.
#
# Usage:
#   ./scripts/sync-to-dotfiles.sh                          # defaults to ~/Projects/dotfiles
#   ./scripts/sync-to-dotfiles.sh /path/to/dotfiles        # custom path
#   ./scripts/sync-to-dotfiles.sh /path/to/dotfiles claude # custom package name
#
# Layout produced:
#   <dotfiles>/claude/.claude/skills/...
#   <dotfiles>/claude/.claude/agents/...
#   <dotfiles>/claude/.claude/hooks/...
#   <dotfiles>/claude/.claude/settings.json    (user-scope; hooks reference $HOME)
#
# After syncing:
#   cd <dotfiles> && stow -t "$HOME" claude
#
# The project-scope pieces (CLAUDE.md, docs/PRINCIPLES.md, docs/adrs/,
# docs/TECH_DEBT.md, docs/BRAG.md) are *not* touched here. Use
# ./bootstrap.sh <project-dir> for those.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES="${1:-$HOME/Projects/dotfiles}"
PKG="${2:-claude}"
DEST="$DOTFILES/$PKG/.claude"

if [[ ! -d "$REPO_ROOT/.claude" ]]; then
  echo "error: $REPO_ROOT/.claude not found — run this from the effective-engineer-setup repo." >&2
  exit 1
fi

mkdir -p "$DEST"

echo "→ syncing skills, agents, hooks into $DEST"
# Prefer rsync --delete (keeps the package clean when skills are
# renamed/removed upstream). Fall back to cp -R if rsync isn't installed.
sync_dir() {
  local src="$1" dst="$2"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$src/" "$dst/"
  else
    rm -rf "$dst"
    mkdir -p "$dst"
    cp -R "$src/." "$dst/"
  fi
}
sync_dir "$REPO_ROOT/.claude/skills" "$DEST/skills"
sync_dir "$REPO_ROOT/.claude/agents" "$DEST/agents"
sync_dir "$REPO_ROOT/.claude/hooks"  "$DEST/hooks"
chmod +x "$DEST/hooks/"*.sh 2>/dev/null || true

echo "→ writing user-scope settings.json"
# Hook paths resolve under $HOME/.claude/hooks so they work in any project.
# Permissions stay conservative; per-project overrides live in
# <project>/.claude/settings.local.json.
cat > "$DEST/settings.json" <<'JSON'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "_comment": [
    "User-scope settings installed via stow from your dotfiles repo.",
    "Project-specific permission overrides belong in",
    "<project>/.claude/settings.local.json (gitignored) or",
    "<project>/.claude/settings.json (committed).",
    "Hooks are auto-discovering: each script cd's into the current git root",
    "before running, so these paths work from any project."
  ],

  "permissions": {
    "ask": [
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(git merge:*)",
      "Bash(git rebase:*)",
      "Bash(npm publish:*)",
      "Bash(pnpm publish:*)",
      "Bash(yarn publish:*)",
      "Bash(pip publish:*)",
      "Bash(uv publish:*)"
    ],
    "deny": [
      "Bash(git push --force*)",
      "Bash(git push -f*)",
      "Bash(rm -rf /*)",
      "Bash(rm -rf ~*)",
      "Bash(sudo *)",
      "Bash(chmod 777 *)",
      "Read(.env*)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Read(**/secrets/**)",
      "Read(**/credentials/**)",
      "Edit(.env*)",
      "Edit(**/*.pem)",
      "Edit(**/*.key)",
      "Edit(**/secrets/**)",
      "Write(.env*)",
      "Write(**/*.pem)",
      "Write(**/*.key)",
      "Write(**/secrets/**)"
    ]
  },

  "hooks": {
    "SessionStart": [
      { "matcher": "", "hooks": [
        { "type": "command", "command": "$HOME/.claude/hooks/inject-context.sh" }
      ]}
    ],
    "PreToolUse": [
      { "matcher": "Edit|Write|MultiEdit", "hooks": [
        { "type": "command", "command": "$HOME/.claude/hooks/protect-files.sh" },
        { "type": "command", "command": "$HOME/.claude/hooks/secrets-guard.sh" },
        { "type": "command", "command": "$HOME/.claude/hooks/licensing-check.sh" }
      ]}
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write|MultiEdit", "hooks": [
        { "type": "command", "command": "$HOME/.claude/hooks/format-after-edit.sh" }
      ]}
    ],
    "Stop": [
      { "matcher": "", "hooks": [
        { "type": "command", "command": "$HOME/.claude/hooks/brag-log.sh" }
      ]}
    ]
  },

  "includeCoAuthoredBy": true
}
JSON

echo
echo "✓ synced to $DEST"
echo
echo "Next steps:"
echo "  1. cd $DOTFILES && git add $PKG && git commit -m 'sync effective-engineer claude package'"
echo "  2. stow -t \"\$HOME\" $PKG        # from inside $DOTFILES"
echo "  3. Open Claude Code in any project — skills/hooks/agents resolve under ~/.claude/"
