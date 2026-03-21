# Trace for Claude Code

## Plugin install (recommended)

```
/plugin marketplace add mwarger/trace
/plugin install trace@trace-dev
```

All 9 skills are available immediately. Update with `/plugin update trace`.

## Manual install

If you prefer a local checkout:

```bash
cd /path/to/trace
./install.sh
```

That installs the skills into `~/.claude/skills/` (auto-detected) and a
helper command `trace-pack`.

Override the target with:

```bash
TRACE_SKILLS_DIR="$HOME/.claude/skills" ./install.sh
```

Remote shell install:

```bash
curl -fsSL "https://raw.githubusercontent.com/mwarger/trace/main/install.sh?$(date +%s)" | bash
```

## Isolated local test install

If you want to test without touching your normal Claude Code setup:

```bash
cd /path/to/trace
./scripts/test-local.sh
TRACE_SKILLS_DIR="$(pwd)/.local-test/skills" claude
```

Then start Claude Code from that same shell.

Trace should produce subject specs that can be handed to implementation work
directly when `planning_status=PLANNING_READY` and
`handoff_status=ELIGIBLE`, plus a root `specs/README.md` index for lookup.

Sparse prompts may still yield a bounded speculative draft, but that should
keep handoff withheld until clarifications close the critical decision buckets.

## Verify

Run:

```bash
trace-pack doctor
trace-pack list-skills
```

Then start a new Claude Code session and ask for a Trace-style spec.
