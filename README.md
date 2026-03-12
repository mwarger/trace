# Marginalia Spec Pack

Standalone skill pack for building subject-named specs from evidence.

The pack is built around 5 ideas:
- everything starts as evidence
- the lead agent is the only reducer of canon
- sub-agents do most bounded exploration and review work
- provenance is required before text becomes canonical
- no spec is planning-ready below the 80/80 gate or with unresolved blocker gaps
  or contradictions

## Repo layout

```text
skills/
  marginalia-spec-orchestrator/
  spec-intake/
  spec-loop/
  spec-completeness/
  spec-synthesis-review/
  spec-plan-handoff/
specs/
  README.md
  analytics-module.md
  feature-flags-system.md
  auth-session-system.md
  _artifacts/
scripts/
  cli.sh
  smoke-test.sh
  test-local.sh
install.sh
uninstall.sh
```

## What gets installed

This repo installs 6 skills:
- `marginalia-spec-orchestrator`
- `spec-intake`
- `spec-loop`
- `spec-completeness`
- `spec-synthesis-review`
- `spec-plan-handoff`

The default install target is:
- `${CODEX_HOME:-$HOME/.codex}/skills`

By default the installer uses symlinks so local edits in this repo are visible
immediately in the installed skills.

## Prereqs

- `bash`
- `git`
- `python3`

`curl` is only needed if you install via a remote raw script URL.

## Install

### Local checkout

From this repo:

```bash
./install.sh
```

This will:
- install the skills into your Codex skills dir
- install a helper command named `marginalia-spec-pack`

Useful env vars:

```bash
MARGINALIA_INSTALL_MODE=copy ./install.sh
MARGINALIA_SKILLS_DIR="$HOME/.codex/skills" ./install.sh
CODEX_HOME="$HOME/.codex" ./install.sh
```

### Superpowers-style remote install

Once this repo is hosted, the intended install shape is:

```bash
curl -fsSL "https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh?$(date +%s)" | bash
```

For Codex, the install doc is:
- [`.codex/INSTALL.md`](.codex/INSTALL.md)

## Helper command

After install, this command should be available:

```bash
marginalia-spec-pack help
```

Supported commands:
- `help`
- `where`
- `list-skills`
- `install-skills`
- `uninstall-skills`
- `doctor`
- `smoke-test`
- `test-local`

## How to kick it off

Start a new Codex session after install and ask for one of these:

```text
Create a subject-named spec for this feature request using the marginalia pack.
Reverse engineer this repo into a marginalia spec with sidecar artifacts.
Take this transcript and build a planning-ready subject spec.
Use the marginalia-spec-orchestrator skill on this codebase.
```

If the install worked, the orchestrator skill should trigger and then route into
the focused sub-skills.

## Local isolated testing

If you want to test this without touching your normal Codex setup:

```bash
./scripts/test-local.sh
```

That creates:
- `.local-test/codex-home/skills`

and installs the skills there instead of your normal `~/.codex/skills`.

Then launch Codex from the same shell with:

```bash
export CODEX_HOME="$(pwd)/.local-test/codex-home"
codex
```

This isolates the test from your normal skills and other installed scripts.

You can also do it through the helper:

```bash
marginalia-spec-pack test-local
```

## Smoke test

To verify the repo structure and example artifacts:

```bash
./scripts/smoke-test.sh
```

or:

```bash
marginalia-spec-pack smoke-test
```

The smoke test checks:
- expected skill folders exist
- expected spec files exist
- managed JSON files parse
- managed JSONL ledgers parse

## Uninstall

To remove the installed wrapper and managed skills:

```bash
./uninstall.sh
```

or:

```bash
marginalia-spec-pack uninstall-skills
```

## Notes on interference

The safest way to test locally is with a separate `CODEX_HOME`.
That keeps this pack from mixing with other installed skills, custom prompts, or
other local automation.

Recommended workflow for isolated testing:

```bash
./scripts/test-local.sh
export CODEX_HOME="$(pwd)/.local-test/codex-home"
codex
```

Then try a prompt that should trigger the orchestrator.
