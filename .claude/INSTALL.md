# Forge for Claude Code

## Plugin install (recommended)

```
/plugin marketplace add mwarger/forge
/plugin install forge@forge-dev
```

All 10 skills are available immediately. Update with `/plugin update forge`.

## Manual install

If you prefer a local checkout:

```bash
cd /path/to/forge
./install.sh
```

That installs the skills into `~/.claude/skills/` (auto-detected) and a
helper command `forge-pack`.

Override the target with:

```bash
FORGE_SKILLS_DIR="$HOME/.claude/skills" ./install.sh
```

Remote shell install:

```bash
curl -fsSL "https://raw.githubusercontent.com/mwarger/forge/main/install.sh?$(date +%s)" | bash
```

## Isolated local test install

If you want to test without touching your normal Claude Code setup:

```bash
cd /path/to/forge
./scripts/test-local.sh
FORGE_SKILLS_DIR="$(pwd)/.local-test/skills" claude
```

Then start Claude Code from that same shell.

Forge should produce subject specs that can be handed to implementation work
directly when `planning_status=PLANNING_READY` and
`handoff_status=ELIGIBLE`, plus a root `specs/README.md` index for lookup.

Sparse prompts may still yield a bounded speculative draft, but that should
keep handoff withheld until clarifications close the critical decision buckets.

## Verify

Run:

```bash
forge-pack doctor
forge-pack list-skills
```

Then start a new Claude Code session and ask for a Forge-style spec.
