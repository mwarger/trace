# Trace

Trace is a standalone skill pack for building subject-named specs from
evidence.

The primary output is a subject spec you can point another agent or an external
implementation loop at. The root `specs/README.md` is the navigational index
for those subject specs, not a replacement for them.

## Inspiration

Trace takes inspiration from marginalia as a reading and synthesis method, then
pushes that idea into evidence-led specification, reducer-based merges, and
sub-agent-assisted planning.

The pack is built around 5 ideas:
- everything starts as evidence
- the lead agent is the only reducer of canon
- sub-agents do most bounded exploration and review work
- provenance is required before text becomes canonical
- readiness is a canonical state machine, not just a score threshold

## Canonical readiness model

Trace separates planning state from handoff state.

Planning states:
- `DISCOVERY`
- `AWAITING_CLARIFICATION`
- `SPECULATIVE_DRAFT`
- `PLANNING_READY`

Handoff states:
- `WITHHELD`
- `ELIGIBLE`

Important rules:
- scores do not override blocker reasons
- sparse prompts may still draft, but blocked runs must keep handoff withheld
- analogy prompts should trigger clarifying questions unless the critical
  product decisions are already explicit
- speculative uncertainty should become bounded variants, not fake certainty
- sparse analogy prompts with zero question rounds must not become
  `PLANNING_READY`

## Repo layout

```text
skills/
  trace-orchestrator/
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
- `trace-orchestrator`
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
- install a helper command named `trace-pack`

Useful env vars:

```bash
TRACE_INSTALL_MODE=copy ./install.sh
TRACE_SKILLS_DIR="$HOME/.codex/skills" ./install.sh
CODEX_HOME="$HOME/.codex" ./install.sh
```

### Remote install

Tell your agent to install Trace from:
- <https://github.com/mwarger/trace>

```bash
curl -fsSL "https://raw.githubusercontent.com/mwarger/trace/main/install.sh?$(date +%s)" | bash
```

GitHub repo:
- `git@github.com:mwarger/trace.git`
- <https://github.com/mwarger/trace>

For Codex, the install doc is:
- [`.codex/INSTALL.md`](.codex/INSTALL.md)

## Helper command

After install, this command should be available:

```bash
trace-pack help
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
Create a subject-named spec for this feature request using Trace.
Reverse engineer this repo into a Trace spec with sidecar artifacts.
Take this transcript and build a planning-ready subject spec.
Use the trace-orchestrator skill on this codebase.
```

If the install worked, the orchestrator skill should trigger and then route into
the focused sub-skills.

After changing the skill pack, restart the agent session before testing again.
Do not trust a run that still writes old policy markers such as `trace-v1`.

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
trace-pack test-local
```

## Smoke test

To verify the repo structure and example artifacts:

```bash
./scripts/smoke-test.sh
```

or:

```bash
trace-pack smoke-test
```

The smoke test checks:
- expected skill folders exist
- expected spec files exist
- the root specs index uses the managed Trace block
- managed JSON files parse
- managed JSONL ledgers parse

## Root specs index contract

Every successful Trace run should leave behind:
- a subject spec at `specs/<subject>.md`
- a matching row in `specs/README.md`

Trace manages the subject rows inside:
- `<!-- trace:spec-index:start -->`
- `<!-- trace:spec-index:end -->`

Human notes outside that block should be preserved.

Rows should surface:
- planning status
- handoff status
- subject purpose

## Uninstall

To remove the installed wrapper and managed skills:

```bash
./uninstall.sh
```

or:

```bash
trace-pack uninstall-skills
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
