# Effective Engineer — Claude Code Template

A reusable, opinionated **Claude Code** template that operationalizes the
principles from *The Effective Software Engineer* (Addy Osmani, O'Reilly, 2026)
as skills, subagents, and hooks.

> **"Efficiency is doing things right; effectiveness is doing the right things."**
> Drop this template into any project and Claude Code will nudge you — and
> itself — toward the right things: outcomes over outputs, tests-first,
> ADR-driven design, anti-pattern awareness, and a compounding paper trail
> (ADRs, tech-debt ledger, brag doc, retros).

---

## What's inside

```
.
├── CLAUDE.md                       # Project memory: principles + guardrails Claude reads every session
├── .claude/
│   ├── settings.json               # Shared hooks, permission rules, MCP defaults
│   ├── settings.local.json.example # Per-developer overrides (copy, don't commit)
│   ├── skills/                     # 13 skills mapped to book chapters
│   │   ├── outcomes-first/         #  Ch.1  Outcomes vs outputs (auto-triggered on planning)
│   │   ├── prioritize/             #  Ch.1  Strategic prioritization
│   │   ├── adr/                    #  Ch.13 Architecture Decision Records
│   │   ├── tdd/                    #  Ch.13 Tests-first, then code
│   │   ├── review/                 #  Ch.13 AI as review amplifier (forks subagent)
│   │   ├── commit/                 #  Ch.2  Conventional commits, small PRs
│   │   ├── debug/                  #  Ch.2  Disciplined debugging loop
│   │   ├── debt/                   #  Ch.3  Tech-debt ledger
│   │   ├── scope-guard/            #  Ch.5  Anti scope-creep
│   │   ├── anti-patterns/          #  Ch.5  & Ch.10 — 20-anti-pattern scanner
│   │   ├── brag/                   #  Ch.6  Auto-maintained brag document
│   │   ├── retro/                  #  Ch.10 Retrospectives that drive action
│   │   └── post-ship/              #  Ch.13 Docs, observability, comms
│   ├── agents/
│   │   ├── reviewer.md             # Subagent used by /review
│   │   └── anti-pattern-scanner.md # Subagent used by /anti-patterns
│   └── hooks/                      # Deterministic guardrails
│       ├── secrets-guard.sh        #  Ch.13 Don't feed AI sensitive data
│       ├── licensing-check.sh      #  Ch.13 Licensing & attribution guard
│       ├── protect-files.sh        # Block edits to .env, locks, secrets
│       ├── format-after-edit.sh    #  Ch.2  Auto-format after every edit
│       ├── inject-context.sh       #  Ch.13 Repository awareness on SessionStart
│       └── brag-log.sh             #  Ch.6  Log accomplishments on Stop
└── docs/
    ├── USAGE.md                    # **Day-to-day usage guide — scenarios, recipes, troubleshooting**
    ├── PRINCIPLES.md               # Book → daily workflow mapping (short, high-signal)
    ├── adrs/                       # Architecture Decision Records live here
    │   ├── README.md
    │   ├── 0000-template.md
    │   └── 0001-record-architectural-decisions.md
    ├── TECH_DEBT.md                # Running technical-debt ledger
    └── BRAG.md                     # Brag document (updated automatically)
```

> **New to the template?** Read `docs/USAGE.md` after installing. It's the
> hands-on guide — a realistic day, indexed scenarios, a skills cheat sheet,
> hook reference, and troubleshooting.

---

## Install

```bash
# From the root of your project
git clone --depth 1 <this-repo-url> /tmp/ee-template
cp -R /tmp/ee-template/.claude ./
cp /tmp/ee-template/CLAUDE.md ./
cp -R /tmp/ee-template/docs ./
chmod +x .claude/hooks/*.sh

# Restart Claude Code so it picks up the new .claude/ directory
```

Then open Claude Code and try:

```text
/outcomes-first         Kick off any new task by clarifying the outcome
/adr "use Postgres"     Draft a new Architecture Decision Record
/tdd "password reset"   Start a tests-first implementation loop
/review                 Run the code-review amplifier on your changes
/anti-patterns          Scan the codebase for the 20 IC/team anti-patterns
/debt add "hot-fix regex"  Log a debt item to docs/TECH_DEBT.md
/brag                   Append an accomplishment to docs/BRAG.md
```

---

## Why these specific helpers?

Every helper maps to a named chapter, principle, or workflow in the book.
`docs/PRINCIPLES.md` is the one-page cheat sheet for that mapping, and
`docs/USAGE.md` is the day-to-day operator's guide.

Two design rules kept the surface area small:

1. **One principle, one helper.** No kitchen-sink skills. A skill that "does
   everything" triggers on everything, which means it triggers on nothing.
2. **Deterministic where possible, LLM where needed.** Hooks enforce the rules
   that are boring and mechanical (format on save, block `.env` writes, scan
   for secrets). Skills hold the parts that need judgement (drafting an ADR,
   scoping a PR, reviewing code).

---

## Customize

- Edit `CLAUDE.md` to add your stack, commands, and domain vocabulary.
  Keep it under ~200 lines; long memory is a tax on every turn.
- Toggle hooks on/off in `.claude/settings.json` (or your personal
  `~/.claude/settings.json` to apply everywhere).
- Add project-specific skills alongside the included ones — they live
  happily next to each other under `.claude/skills/`.

---

## Reference

- Book: Addy Osmani, *The Effective Software Engineer*, O'Reilly, 2026
  (ISBN 9798341638167)
- Claude Code skills: <https://code.claude.com/docs/en/skills>
- Claude Code hooks: <https://code.claude.com/docs/en/hooks-guide>
