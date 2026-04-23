# 0002. Split install: user-scope skills via stow, per-project docs via bootstrap

- **Status:** Accepted
- **Date:** 2026-04-23
- **Deciders:** project team
- **Tags:** process, tooling, installation

## Context

The original install path for this template was a single `cp -R` into each
project:

```bash
cp -R /tmp/ee-template/.claude ./
cp /tmp/ee-template/CLAUDE.md ./
cp -R /tmp/ee-template/docs ./
```

That works, but it has two practical problems once you use the template on
more than two or three projects:

1. **Drift.** Each project gets its own frozen copy of `skills/`, `hooks/`,
   and `agents/`. A fix to a skill has to be re-copied into every project —
   or silently diverges.
2. **Noise in the project repo.** The 13 skills, 2 agents, and 6 hooks are
   identical across every project, yet they get committed into every
   project's history, inflating diffs and making it hard to tell what's
   project-specific.

Meanwhile a subset of the template _is_ inherently per-project and must be
committed: `CLAUDE.md` (stack, commands, domain vocabulary), `docs/adrs/`
(numbered, append-only), `docs/TECH_DEBT.md`, `docs/BRAG.md`.

This maps onto a classic dotfiles shape: stable personal assets managed in
a central repo and symlinked into `$HOME` via GNU Stow, versus
project-specific assets committed to the project.

## Decision

We split the installation into two paths:

**User-scope (via GNU Stow, one-time setup):**

- `.claude/skills/`, `.claude/agents/`, `.claude/hooks/`, and a user-scope
  `.claude/settings.json` are synced into the user's personal dotfiles
  repo (default `~/Projects/dotfiles/claude/`) by
  `scripts/sync-to-dotfiles.sh`, then symlinked into `~/.claude/` by
  `stow -t "$HOME" claude`.
- The user-scope `settings.json` references hooks as
  `$HOME/.claude/hooks/<name>.sh`. Every hook already `cd`s into the
  current project's git root before operating, so a single installation
  works from any project.

**Project-scope (via `bootstrap.sh`, per project):**

- `CLAUDE.md`, `docs/PRINCIPLES.md`, `docs/adrs/{README,0000-template,0001}.md`,
  empty `docs/TECH_DEBT.md` and `docs/BRAG.md`, and a minimal
  `.claude/settings.json` carrying project-scope `allow` permissions are
  copied (not symlinked) by `./bootstrap.sh <project>`.
- These files are expected to be edited and committed. They are
  specifically the files that should diverge between projects.

The canonical source of truth for both paths remains this repository.
Updating a skill means editing it here, pushing, and re-running
`sync-to-dotfiles.sh`; the stow symlinks pick up the change automatically.

## Alternatives considered

1. **Everything under stow, including CLAUDE.md and docs/.** Rejected:
   CLAUDE.md is inherently per-project (it names the stack, the commands,
   the domain), and `docs/adrs/` and `docs/BRAG.md` must live in the
   project's git history so they travel with the code.
2. **Everything copied per-project (the status quo).** Rejected for the
   drift and noise reasons in the Context section.
3. **Symlinks committed into each project repo, gitignored or not.**
   Rejected: symlinks pointing outside the worktree break on other
   machines and in CI, and gitignoring them means collaborators who don't
   use the dotfiles package get a silently-broken setup.
4. **Publish skills as an npm/pip package.** Rejected as premature — the
   template is a handful of markdown and shell files, and a package
   manager is a lot of ceremony for a personal dotfiles workflow. Worth
   revisiting if the set of skills becomes a shared team artifact.

## Consequences

### Positive

- One place to update a skill or hook; updates fan out to every project
  via `stow` + the existing symlinks.
- Project repos stay clean: no vendored copies of 20+ skill/agent/hook
  files.
- Collaborators who don't use the dotfiles workflow still get the
  project-scope pieces (CLAUDE.md, docs/, permissions) via `bootstrap.sh`
  and get reduced-but-functional behavior without the hooks.

### Negative

- Two install paths instead of one. The README has to document both, and
  new users have to decide which to use.
- Hooks no longer ship with the project. A collaborator who clones a
  bootstrapped project without running `sync-to-dotfiles.sh` sees the
  skills (as /commands) as not available, and the SessionStart
  repo-context line is missing. Mitigation: the README calls this out and
  `bootstrap.sh` prints the follow-up command.
- `sync-to-dotfiles.sh` uses `rsync --delete`. If a user hand-edits
  files inside `<dotfiles>/claude/.claude/`, the next sync overwrites
  them. Personal customization belongs in `~/.claude/settings.local.json`
  (user-scope) or in a separate stow package.

### Neutral (monitor)

- Whether the two-path install creates confusion in issues or onboarding.
  If it does, we can add an `install.sh` that does both in sequence.
- Whether users reach for per-project overrides often enough that we
  should publish a documented `.claude/settings.local.json.example` for
  the project scope as well as the user scope.

## References

- _The Effective Software Engineer_ (Addy Osmani, O'Reilly 2026),
  Ch. 5 "Knowledge Silos" (why drift across projects is the real cost)
  and Ch. 13 "Repository Awareness" (why per-project CLAUDE.md matters).
- GNU Stow manual — <https://www.gnu.org/software/stow/manual/stow.html>
- `scripts/sync-to-dotfiles.sh`, `bootstrap.sh` — the two install paths.
