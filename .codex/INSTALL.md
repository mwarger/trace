# Forge for Codex

## Quick local install

If you already have a checkout of this repo:

```bash
cd /path/to/forge
./install.sh
```

That installs the skills into:
- `${CODEX_HOME:-$HOME/.codex}/skills`

and installs a helper command:
- `forge-pack`

## Isolated local test install

If you want to test without touching your normal Codex setup:

```bash
cd /path/to/forge
./scripts/test-local.sh
export CODEX_HOME="$(pwd)/.local-test/codex-home"
```

Then start Codex from that same shell.

Forge should produce subject specs that can be handed to implementation work
directly when `planning_status=PLANNING_READY` and
`handoff_status=ELIGIBLE`, plus a root `specs/README.md` index for lookup.

Sparse prompts may still yield a bounded speculative draft, but that should
keep handoff withheld until clarifications close the critical decision buckets.

## Remote install

Tell your agent to install Forge from:
- <https://github.com/mwarger/forge>

The Codex install doc is:

```text
Fetch and follow instructions from https://raw.githubusercontent.com/mwarger/forge/main/.codex/INSTALL.md
```

If you prefer a shell install:

```bash
curl -fsSL "https://raw.githubusercontent.com/mwarger/forge/main/install.sh?$(date +%s)" | bash
```

## Verify

Run:

```bash
forge-pack doctor
forge-pack list-skills
```

Then start a new Codex session and ask for a Forge-style spec.

If you update the skill pack, restart the agent session before rerunning a
Forge prompt so the new policy is actually loaded.
