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
- `ADVERSARIAL_REVIEW`
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
.claude-plugin/
  plugin.json
  marketplace.json
skills/
  trace-orchestrator/
  spec-intake/
  spec-loop/
  spec-completeness/
  spec-synthesis-review/
  spec-adversarial-review/
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
LICENSE
```

## What gets installed

This repo installs 7 skills:
- `trace-orchestrator`
- `spec-intake`
- `spec-loop`
- `spec-completeness`
- `spec-synthesis-review`
- `spec-adversarial-review`
- `spec-plan-handoff`

The installer auto-detects the target platform:
- If `~/.claude/` exists → installs to `~/.claude/skills/`
- If `~/.codex/` exists → installs to `~/.codex/skills/`
- Override with `TRACE_SKILLS_DIR`

By default the installer uses symlinks so local edits in this repo are visible
immediately in the installed skills.

## Install

### Claude Code (recommended)

```
/plugin marketplace add mwarger/trace
/plugin install trace@trace-dev
```

That's it. All 6 skills are available immediately. Update with `/plugin update trace`.

### Codex

```
Fetch and follow instructions from https://raw.githubusercontent.com/mwarger/trace/main/.codex/INSTALL.md
```

### Manual / shell

Prereqs: `bash`, `git`, `python3`

```bash
./install.sh
```

This installs the skills into your detected skills dir and a helper command `trace-pack`.

Useful env vars:

```bash
TRACE_INSTALL_MODE=copy ./install.sh
TRACE_SKILLS_DIR="$HOME/.claude/skills" ./install.sh
TRACE_SKILLS_DIR="$HOME/.codex/skills" ./install.sh
```

Remote install:

```bash
curl -fsSL "https://raw.githubusercontent.com/mwarger/trace/main/install.sh?$(date +%s)" | bash
```

Platform-specific install docs:
- Claude Code: [`.claude/INSTALL.md`](.claude/INSTALL.md)
- Codex: [`.codex/INSTALL.md`](.codex/INSTALL.md)

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

Start a new session after install and ask for one of these:

```text
Create a subject-named spec for this feature request using Trace.
Reverse engineer this repo into a Trace spec with sidecar artifacts.
Take this transcript and build a planning-ready subject spec.
Use the trace-orchestrator skill on this codebase.
```

Works in both Claude Code (`claude`) and Codex (`codex`). If the install
worked, the orchestrator skill should trigger and then route into the focused
sub-skills.

After changing the skill pack, restart the agent session before testing again.
Do not trust a run that still writes old policy markers such as `trace-v1`.

## Local isolated testing

If you want to test without touching your normal setup:

```bash
./scripts/test-local.sh
```

That creates:
- `.local-test/skills`

and installs the skills there instead of your normal skills directory.

Then launch your agent from the same shell with:

```bash
TRACE_SKILLS_DIR="$(pwd)/.local-test/skills" claude
# or
TRACE_SKILLS_DIR="$(pwd)/.local-test/skills" codex
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

The safest way to test locally is with `TRACE_SKILLS_DIR` pointed at an
isolated directory. That keeps this pack from mixing with other installed
skills, custom prompts, or other local automation.

Recommended workflow for isolated testing:

```bash
./scripts/test-local.sh
TRACE_SKILLS_DIR="$(pwd)/.local-test/skills" claude  # or codex
```

Then try a prompt that should trigger the orchestrator.
