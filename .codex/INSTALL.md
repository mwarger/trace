# Trace for Codex

## Quick local install

If you already have a checkout of this repo:

```bash
cd /path/to/trace
./install.sh
```

That installs the skills into:
- `${CODEX_HOME:-$HOME/.codex}/skills`

and installs a helper command:
- `trace-pack`

## Isolated local test install

If you want to test without touching your normal Codex setup:

```bash
cd /path/to/trace
./scripts/test-local.sh
export CODEX_HOME="$(pwd)/.local-test/codex-home"
```

Then start Codex from that same shell.

Trace should produce subject specs that can be handed to implementation work
directly when `planning_status=PLANNING_READY` and
`handoff_status=ELIGIBLE`, plus a root `specs/README.md` index for lookup.

Sparse prompts may still yield a bounded speculative draft, but that should
keep handoff withheld until clarifications close the critical decision buckets.

## Remote install

Tell your agent to install Trace from:
- <https://github.com/mwarger/trace>

The Codex install doc is:

```text
Fetch and follow instructions from https://raw.githubusercontent.com/mwarger/trace/main/.codex/INSTALL.md
```

If you prefer a shell install:

```bash
curl -fsSL "https://raw.githubusercontent.com/mwarger/trace/main/install.sh?$(date +%s)" | bash
```

## Verify

Run:

```bash
trace-pack doctor
trace-pack list-skills
```

Then start a new Codex session and ask for a Trace-style spec.
