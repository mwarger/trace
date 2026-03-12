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
- `marginalia-spec-pack`

## Isolated local test install

If you want to test without touching your normal Codex setup:

```bash
cd /path/to/trace
./scripts/test-local.sh
export CODEX_HOME="$(pwd)/.local-test/codex-home"
```

Then start Codex from that same shell.

## Once the repo is hosted

The intended Codex install flow is:

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
marginalia-spec-pack doctor
marginalia-spec-pack list-skills
```

Then start a new Codex session and ask for a marginalia-style spec.
