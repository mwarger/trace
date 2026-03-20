# Post-Handoff Beads Generation & Adversarial Review Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add optional post-handoff phases that decompose the implementation plan into `br` beads with dependency wiring and provenance, then stress-test them with an adversarial agent team until convergence on coverage, granularity, dependencies, and actionability.

**Architecture:** Two new skills (`spec-beads-generate`, `spec-beads-review`) appended after `spec-plan-handoff`. Two new optional orchestrator phases (`BEADS_GENERATION`, `BEADS_REVIEW`) added after the renamed `PLAN_HANDOFF` phase (formerly `PUBLISH`). Beads live at the git root in a shared `.beads` workspace. Adversarial review follows the same convergence model as `spec-adversarial-review`.

**Tech Stack:** Markdown skill definitions (SKILL.md), bash (smoke test), `br` CLI (issue tracker), `bv` CLI (TUI viewer/analysis)

**Spec:** `docs/superpowers/specs/2026-03-20-beads-generation-review-design.md`

---

### Task 1: Rename `PUBLISH` to `PLAN_HANDOFF` in Orchestrator

**Files:**
- Modify: `skills/trace-orchestrator/SKILL.md:133` (run phases)

- [ ] **Step 1: Rename the phase**

In `skills/trace-orchestrator/SKILL.md`, change line 133 from:

```markdown
10. `PUBLISH`
```

to:

```markdown
10. `PLAN_HANDOFF`
```

- [ ] **Step 2: Verify**

Run: `grep -c 'PLAN_HANDOFF' skills/trace-orchestrator/SKILL.md`
Expected: 1 match

Run: `grep -c 'PUBLISH' skills/trace-orchestrator/SKILL.md`
Expected: 0 matches

- [ ] **Step 3: Commit**

```bash
git add skills/trace-orchestrator/SKILL.md
git commit -m "refactor: rename PUBLISH phase to PLAN_HANDOFF in orchestrator"
```

---

### Task 2: Rename `PUBLISH` to `PLAN_HANDOFF` in Adversarial Review Design Spec

**Files:**
- Modify: `docs/superpowers/specs/2026-03-19-adversarial-review-design.md:224`

- [ ] **Step 1: Update the phase reference**

In `docs/superpowers/specs/2026-03-19-adversarial-review-design.md`, change:

```markdown
Phase 10: PUBLISH (was 9)
```

to:

```markdown
Phase 10: PLAN_HANDOFF (was PUBLISH, was 9)
```

- [ ] **Step 2: Verify**

Run: `grep -c 'PUBLISH' docs/superpowers/specs/2026-03-19-adversarial-review-design.md`
Expected: 0 matches

- [ ] **Step 3: Verify PUBLISH is absent from spec-plan-handoff**

Run: `grep -c 'PUBLISH' skills/spec-plan-handoff/SKILL.md`
Expected: 0 matches (file never referenced the phase name — the spec's Affected Files entry for this file is a no-op)

- [ ] **Step 4: Commit**

```bash
git add docs/superpowers/specs/2026-03-19-adversarial-review-design.md
git commit -m "docs: update PUBLISH to PLAN_HANDOFF in adversarial review spec"
```

---

### Task 3: Add Beads Phases to Orchestrator Run Phases

**Files:**
- Modify: `skills/trace-orchestrator/SKILL.md:121-136` (run phases section)

- [ ] **Step 1: Add the two new optional phases**

After the line `10. \`PLAN_HANDOFF\`` (from Task 1), add:

```markdown
11. `BEADS_GENERATION` (optional — user prompted after PLAN_HANDOFF)
12. `BEADS_REVIEW` (optional — runs if BEADS_GENERATION completed)
```

- [ ] **Step 2: Add phase contracts**

After the `ADVERSARIAL_REVIEW` phase contract block (after line 143), add:

```markdown
`BEADS_GENERATION` phase contract:
- entry: `PLAN_HANDOFF` complete, user accepts prompt ("Would you like to
  generate a beads workspace from this plan?")
- exit: `beads-manifest.json` emitted, all beads created via `br`
- checkpoint: `beads-manifest.json`
- if user declines, run ends at `PLAN_HANDOFF`

`BEADS_REVIEW` phase contract:
- entry: `BEADS_GENERATION` complete
- exit: convergence (zero material findings from all agents) or
  decomposition required (cap hit)
- checkpoint: `beads-review-log.md`
```

- [ ] **Step 3: Verify phase count**

Run: `grep -cE '^\d+\.' skills/trace-orchestrator/SKILL.md`
Expected: 12 (phases) + 6 (sub-skills, from Task 5) = at least 18 numbered lines

- [ ] **Step 4: Commit**

```bash
git add skills/trace-orchestrator/SKILL.md
git commit -m "feat: add BEADS_GENERATION and BEADS_REVIEW phases to orchestrator"
```

---

### Task 4: Add Beads Manifest Fields to Orchestrator

**Files:**
- Modify: `skills/trace-orchestrator/SKILL.md:36-59` (canonical readiness contract)

- [ ] **Step 1: Add the 7 new fields**

After line 59 (`- adversarial_findings_resolved_by_user`), add:

```markdown
- `beads_generated`
- `beads_epic_id`
- `beads_review_rounds_completed`
- `beads_review_status`
- `beads_total`
- `beads_coverage_score`
- `beads_workspace_path`
```

- [ ] **Step 2: Verify field count**

The contract should now list 26 fields (was 19). Count the `` - ` `` lines in the section to confirm.

- [ ] **Step 3: Commit**

```bash
git add skills/trace-orchestrator/SKILL.md
git commit -m "feat: add beads manifest fields to canonical readiness contract"
```

---

### Task 5: Add Beads Skills to Orchestrator Sub-Skill Order and Delegation

**Files:**
- Modify: `skills/trace-orchestrator/SKILL.md:145-157` (sub-skill order)
- Modify: `skills/trace-orchestrator/SKILL.md:183-187` (delegation policy)

- [ ] **Step 1: Add beads skills to sub-skill order**

Change the sub-skill list (lines 147-152) from:

```markdown
1. `spec-intake`
2. `spec-loop`
3. `spec-completeness`
4. `spec-synthesis-review`
5. `spec-adversarial-review`
6. `spec-plan-handoff`
```

to:

```markdown
1. `spec-intake`
2. `spec-loop`
3. `spec-completeness`
4. `spec-synthesis-review`
5. `spec-adversarial-review`
6. `spec-plan-handoff`
7. `spec-beads-generate` (optional — only if user accepts beads prompt)
8. `spec-beads-review` (optional — only if beads were generated)
```

- [ ] **Step 2: Add beads escalation to loop-back instruction**

After the existing loop-back text (lines 154-157), add:

```markdown
If `spec-beads-review` triggers a back-transition, pass the
`beads-escalation.json` artifact as input to the targeted `spec-loop` round.
`spec-loop` treats `beads-escalation.json` identically to
`adversarial-escalation.json` — scope the round to the listed findings.
```

- [ ] **Step 3: Add beads team creation to delegation policy**

After the adversarial team creation block (after line 187), add:

```markdown
For beads review, create agent teams via `TeamCreate`:
- coverage agent: spec claim traceability
- granularity agent: bead sizing
- dependency agent: graph correctness (uses `bv --robot-*` commands)
- actionability agent: implementability + TDD test sketches
- team persists for all beads review rounds
```

- [ ] **Step 4: Commit**

```bash
git add skills/trace-orchestrator/SKILL.md
git commit -m "feat: add beads skills to orchestrator sub-skill order and delegation"
```

---

### Task 6: Add Beads Artifacts to Orchestrator Catalog

**Files:**
- Modify: `skills/trace-orchestrator/SKILL.md:241-267` (artifacts section)

- [ ] **Step 1: Add beads artifacts**

After line 267 (`- sub-spec-brief-<name>.md`), add:

```markdown
- `beads-manifest.json`
- `beads-review-log.md`
- `beads-review-round-N.json`
- `beads-decomposition-proposal.md`
- `beads-escalation.json`
```

- [ ] **Step 2: Verify**

Run: `grep -c 'beads-' skills/trace-orchestrator/SKILL.md`
Expected: at least 7 matches (5 artifacts + references in phase contracts and delegation)

- [ ] **Step 3: Commit**

```bash
git add skills/trace-orchestrator/SKILL.md
git commit -m "feat: register beads artifacts in orchestrator catalog"
```

---

### Task 7: Add `beads-escalation.json` Re-Entry to Spec-Loop

**Files:**
- Modify: `skills/spec-loop/SKILL.md:109-114` (adversarial re-entry section)

- [ ] **Step 1: Expand re-entry to cover beads escalation**

Change lines 109-114 from:

```markdown
## Adversarial re-entry

When `adversarial-escalation.json` is present as input, scope the round to the
escalated findings only. Do not run a full generic pass. Address the specific
findings, affected sections, and reopened blockers listed in the escalation
artifact.
```

to:

```markdown
## Escalation re-entry

When `adversarial-escalation.json` or `beads-escalation.json` is present as
input, scope the round to the escalated findings only. Do not run a full
generic pass. Address the specific findings, affected sections, and reopened
blockers listed in the escalation artifact. Both artifact types use the same
schema and are handled identically.
```

- [ ] **Step 2: Verify**

Run: `grep 'beads-escalation' skills/spec-loop/SKILL.md`
Expected: 1 match

- [ ] **Step 3: Commit**

```bash
git add skills/spec-loop/SKILL.md
git commit -m "feat: accept beads-escalation.json as re-entry input in spec-loop"
```

---

### Task 8: Create `spec-beads-generate` Skill

**Files:**
- Create: `skills/spec-beads-generate/SKILL.md`

- [ ] **Step 1: Create the skill directory**

Run: `mkdir -p skills/spec-beads-generate`

- [ ] **Step 2: Write the full SKILL.md**

Create `skills/spec-beads-generate/SKILL.md` with this content:

```markdown
---
name: spec-beads-generate
description: "Decompose an implementation plan into br beads with dependency wiring, epic grouping, and provenance labels. Use this after spec-plan-handoff when the user accepts the beads generation prompt."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Use this only after `spec-plan-handoff` has emitted `implementation-plan.md`
and the user has accepted the beads generation prompt.

## Purpose

Decompose `implementation-plan.md` into a set of beads with full provenance
back to the spec. This skill is the advocate — it makes the best decomposition
it can and hands it to the adversarial team (`spec-beads-review`).

## Preconditions

- `planning_status = PLANNING_READY`
- `handoff_status = ELIGIBLE`
- `adversarial_status = converged`
- `implementation-plan.md` exists in `specs/_artifacts/<subject>/`
- user accepted the beads generation prompt

## Behavior

1. locate the git repository root via `git rev-parse --show-toplevel`
2. if `.beads` exists at the git root, use it — do not re-init
3. if `.beads` does not exist, run `br init` at the git root
4. create an epic for the spec subject:
   `br create --type epic --title "<subject>" --labels "trace:<subject-slug>"`
5. read each workstream from `implementation-plan.md` and create beads:
   - one bead per discrete work unit within a workstream
   - `br create --title "..." --type task --parent <epic-id> --labels "trace:<subject-slug>" --description "..."`
   - description includes: what to do, acceptance criteria, which spec claims
     this bead covers
6. wire dependencies from the implementation plan's dependency graph:
   `br dep add <bead-id> <depends-on-id>`
7. emit `beads-manifest.json` to `specs/_artifacts/<subject>/`

## Provenance contract

Every spec claim and acceptance criterion must appear in at least one bead's
description. The manifest tracks this mapping explicitly so the review phase
can verify coverage.

## `beads-manifest.json` schema

```json
{
  "subject": "<subject-slug>",
  "epic_id": "<br epic ID>",
  "workspace_path": "<git root>/.beads",
  "beads": [
    {
      "bead_id": "<br issue ID>",
      "title": "<bead title>",
      "workstream": "<workstream name from implementation plan>",
      "spec_claims": ["<claim IDs from claim-ledger.jsonl>"],
      "acceptance_criteria": ["<AC IDs from spec>"],
      "dependencies": ["<bead IDs this depends on>"],
      "test_first": "yes | no | n/a",
      "test_sketches": [
        {
          "type": "unit | property | integration | contract | e2e",
          "description": "<pseudocode test scenario>"
        }
      ]
    }
  ],
  "unmapped_claims": ["<claim IDs not yet traced to any bead>"],
  "unmapped_acceptance_criteria": ["<AC IDs not yet traced to any bead>"]
}
```

`unmapped_claims` and `unmapped_acceptance_criteria` start populated after
generation and must be empty after `spec-beads-review` converges. The coverage
agent uses these arrays as its primary attack surface.

## Outputs

Emit as structured input to the orchestrator:
- `beads-manifest.json`
- structured beads fields for `manifest.json`:
  - `beads_generated = true`
  - `beads_epic_id`
  - `beads_total`
  - `beads_workspace_path`

## Hard rules

1. This skill does not evaluate quality. That is the review phase's job.
2. Every spec claim must map to at least one bead. If a claim cannot be
   decomposed into a discrete work unit, flag it and include it anyway — the
   review phase will address granularity.
3. Use `br` CLI commands for all bead operations. Do not write to the `.beads`
   directory directly.
4. Do not re-init an existing `.beads` workspace.
5. Epic and label provenance are required for every bead.
```

- [ ] **Step 3: Verify the file exists**

Run: `head -3 skills/spec-beads-generate/SKILL.md`
Expected: YAML frontmatter with `name: spec-beads-generate`

- [ ] **Step 4: Commit**

```bash
git add skills/spec-beads-generate/SKILL.md
git commit -m "feat: create spec-beads-generate skill"
```

---

### Task 9: Create `spec-beads-review` Skill

**Files:**
- Create: `skills/spec-beads-review/SKILL.md`

- [ ] **Step 1: Create the skill directory**

Run: `mkdir -p skills/spec-beads-review`

- [ ] **Step 2: Write the full SKILL.md**

Create `skills/spec-beads-review/SKILL.md` with this content:

```markdown
---
name: spec-beads-review
description: "Stress-test beads for coverage, granularity, dependency correctness, and actionability using adversarial agent teams. Use this after spec-beads-generate when the beads workspace is populated."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---

Use this after `spec-beads-generate` has emitted `beads-manifest.json` and
created all beads via `br`.

## Purpose

Find every remaining gap in the bead decomposition that could cause an
engineer to make a judgment call the beads should have made for them. The full
attack surface: missing spec claim coverage, wrong granularity, dependency
errors, vague acceptance criteria, missing TDD test sketches.

## Agent team allocation

Use agent teams (`TeamCreate`) as the primary organizing mechanism. The team
persists across all rounds for context continuity.

### Required agents

**Coverage agent** — checks every spec claim and acceptance criterion against
`beads-manifest.json`. Flags anything not traced to a bead, or traced to a
bead that does not actually address it. Primary input:
`unmapped_claims` and `unmapped_acceptance_criteria` arrays.

**Granularity agent** — evaluates each bead: too coarse (multiple unrelated
concerns, would need decomposition during implementation)? Too fine (trivially
small, noise)? Proposes splits or merges.

**Dependency agent** — uses `bv --robot-suggest` for cycle detection,
`bv --robot-graph` for structure analysis, `bv --robot-insights` for graph
health. Checks for missing edges (bead A clearly depends on bead B but no dep
exists) and false edges.

**Actionability agent** — plays literal implementer for each bead. Evaluates:
- could I implement this without asking questions?
- does it have clear acceptance criteria?
- can I write a failing test first? If the bead does not describe observable
  behavior or a verifiable outcome, it is not TDD-ready — flag it
- are test boundaries clear? Does the bead specify enough about inputs,
  outputs, and side effects to know what to assert against?
- beads that are inherently non-testable-first (pure refactors with no
  behavior change, infrastructure setup) get annotated as `test-first: n/a`
  with rationale

### TDD test sketches

The actionability agent produces pseudocode test sketches per bead, specifying
both the scenario and the test type. Choose the most appropriate type per bead
from: **unit**, **property**, **integration**, **contract**, **e2e**.

A pure data transformation gets property tests. A boundary interaction gets
contract or integration tests. A user-facing flow gets e2e. If the agent
cannot write meaningful test sketches for a bead, that is itself a finding —
the bead's acceptance criteria are too vague.

Test sketches are embedded in the bead description by default. Use
`br comments add` only when the description would exceed a reasonable length.

### Evidence sources

Agents must use `br` and `bv --robot-*` commands as evidence sources:
- `br list --label trace:<subject>` — list beads for this spec
- `br show <id>` — read bead details
- `br dep list <id>` — check dependencies
- `br dep tree <id>` — visualize dependency tree
- `br dep cycles` — detect cycles
- `bv --robot-suggest` — duplicates, dependency issues, label problems, cycles
- `bv --robot-graph` — dependency graph structure
- `bv --robot-insights` — graph analysis and health metrics
- `bv --robot-plan` — dependency-respecting execution order

## Round structure

Each round:
1. all agents evaluate the current bead set independently
2. agents use `br` queries and `bv --robot-*` commands as evidence
3. findings collected, deduplicated, and classified:
   - **critical** — missing spec claim coverage, dependency cycle, bead with
     multiple valid interpretations → escalate to user
   - **high** — granularity problem, missing dependency edge, vague acceptance
     criteria → escalate to user
   - **resolvable** — answer is unambiguous from spec, codebase, or bv
     analysis → auto-resolve, log decision, flag for user visibility
4. resolutions applied:
   - `br create` (new beads)
   - `br update` (fix descriptions)
   - `br dep add` / `br dep remove` (rewire)
   - `br delete` (merge or remove)
5. `beads-manifest.json` updated with any changes
6. next round begins on the updated bead set

## Convergence

- **minimum**: 2 rounds if round 1 produces findings. If round 1 produces
  zero material findings from all agents, 1 round is sufficient.
- **maximum**: 5 rounds (safety cap)
- **exit**: a round where ALL agents — all four — independently report zero
  material findings
- **bias**: toward running another round if any agent is uncertain. The cap is
  a safety valve, not a target.
- **"material" defined broadly**: anything that could cause an engineer to
  make a judgment call the beads should have made for them

## Cap behavior

Hitting the cap (5 rounds without convergence) is NOT an acceptable exit. It
triggers a decomposition signal:

- emit `beads_review_status = decomposition_required` as structured input to
  the orchestrator
- emit `beads-decomposition-proposal.md` explaining what is tangled and why

Decomposition can mean one of two things:

1. **the implementation plan's workstreams are too tangled** — the beads
   cannot be cleanly separated because the plan itself has unclear boundaries.
   Escalate back to the user with a proposal to revise the implementation
   plan.
2. **the spec has gaps the beads review exposed** — the act of decomposing
   into concrete work units revealed ambiguity that the spec adversarial
   review missed. Emit `beads-escalation.json` listing finding IDs, affected
   spec sections, and reopened blockers. The orchestrator passes this to
   `spec-loop` for a targeted re-entry round.

The user decides next steps based on the decomposition proposal.

## Finding structure

Each finding must include:
- `finding_id` — stable identifier
- `round` — which review round
- `agent_role` — coverage, granularity, dependency, or actionability
- `severity` — critical, high, or resolvable
- `bead_id` — which bead (or null for cross-cutting findings)
- `description` — what the problem is
- `evidence` — what the agent observed (bv output, br query result, spec
  text, or codebase evidence)
- `resolution` — how it was resolved (user answer, auto-resolve, or pending)
- `resolution_source` — user, bv_analysis, codebase, or auto

## Outputs

Emit as structured input to the orchestrator (do not write these directly):
- `beads-review-log.md` — all findings across all rounds with resolutions and
  provenance
- `beads-review-round-N.json` — structured findings per round
- updated `beads-manifest.json`
- structured beads review fields for `manifest.json`:
  - `beads_review_rounds_completed`
  - `beads_review_status` (`converged` | `decomposition_required`)
  - `beads_coverage_score`

On decomposition:
- `beads-decomposition-proposal.md`
- `beads-escalation.json` (on back-transition to spec-loop)

## Hard rules

1. This skill does not write canon. It emits proposals. The orchestrator
   reduces.
2. Use `br` and `bv` CLI commands as evidence sources. Do not read `.beads`
   database files directly.
3. Zero material findings means zero. "Probably fine" is not zero.
4. The cap is a decomposition signal, not an acceptable exit.
5. `beads_review_status` has exactly two values: `converged` or
   `decomposition_required`. No middle ground. The field is absent until the
   review phase exits.
6. Agent teams are the required organizing mechanism. Do not use ad-hoc agent
   spawning.
7. Every bead must have a `test_first` annotation and test sketches (unless
   `test-first: n/a` with rationale). Missing test sketches is a finding.
```

- [ ] **Step 3: Verify the file exists**

Run: `head -3 skills/spec-beads-review/SKILL.md`
Expected: YAML frontmatter with `name: spec-beads-review`

- [ ] **Step 4: Commit**

```bash
git add skills/spec-beads-review/SKILL.md
git commit -m "feat: create spec-beads-review skill"
```

---

### Task 10: Update README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update the pipeline diagram**

Change the pipeline section (lines 51-55) from:

```markdown
evidence → intake → loop → completeness → synthesis-review → adversarial-review → handoff
                     ↑                                              │
                     └──────────── blockers or gaps ────────────────┘
```

to:

```markdown
evidence → intake → loop → completeness → synthesis-review → adversarial-review → handoff
                     ↑                                              │                  │
                     └──────────── blockers or gaps ────────────────┘                  │
                     │                                                                 ↓
                     │                                              beads-generate → beads-review
                     └──────────── beads escalation ──────────────────────────────────┘
```

- [ ] **Step 2: Add new skills to the skills table**

After the `spec-plan-handoff` row (line 66), add:

```markdown
| `spec-beads-generate` | Decompose implementation plan into `br` beads with dependency wiring, epic grouping, and provenance labels |
| `spec-beads-review` | Stress-test beads for coverage, granularity, dependencies, and actionability using adversarial agent teams |
```

- [ ] **Step 3: Add beads skills to repo layout**

After `spec-plan-handoff/` (line 110), add:

```text
  spec-beads-generate/
  spec-beads-review/
```

- [ ] **Step 4: Update skill count**

Change line 128 from:

```markdown
This repo installs 7 skills:
```

to:

```markdown
This repo installs 9 skills:
```

And add after `spec-plan-handoff` in the bullet list (line 135):

```markdown
- `spec-beads-generate`
- `spec-beads-review`
```

- [ ] **Step 5: Update install instructions skill count**

Change line 154 from:

```markdown
That's it. All 7 skills are available immediately. Update with `/plugin update trace`.
```

to:

```markdown
That's it. All 9 skills are available immediately. Update with `/plugin update trace`.
```

- [ ] **Step 6: Commit**

```bash
git add README.md
git commit -m "docs: add beads generation and review to README"
```

---

### Task 11: Update Smoke Test

**Files:**
- Modify: `scripts/smoke-test.sh:27-37` (skill loop)

- [ ] **Step 1: Add new skills to the check loop**

Change lines 27-37 from:

```bash
for skill in \
  trace-orchestrator \
  spec-intake \
  spec-loop \
  spec-completeness \
  spec-synthesis-review \
  spec-adversarial-review \
  spec-plan-handoff
do
  require_file "$ROOT_DIR/skills/$skill/SKILL.md"
done
```

to:

```bash
for skill in \
  trace-orchestrator \
  spec-intake \
  spec-loop \
  spec-completeness \
  spec-synthesis-review \
  spec-adversarial-review \
  spec-plan-handoff \
  spec-beads-generate \
  spec-beads-review
do
  require_file "$ROOT_DIR/skills/$skill/SKILL.md"
done
```

- [ ] **Step 2: Run the smoke test**

Run: `./scripts/smoke-test.sh`
Expected: `[trace-smoke] smoke test ok`

- [ ] **Step 3: Commit**

```bash
git add scripts/smoke-test.sh
git commit -m "test: add spec-beads-generate and spec-beads-review to smoke test"
```

---

### Task 12: Validation Pass

**Files:** None (read-only verification)

- [ ] **Step 1: Run the full smoke test**

Run: `./scripts/smoke-test.sh`
Expected: `[trace-smoke] smoke test ok`

- [ ] **Step 2: Verify all 9 skills exist**

Run: `ls skills/*/SKILL.md | wc -l`
Expected: `9`

- [ ] **Step 3: Verify PLAN_HANDOFF replaced PUBLISH**

Run: `grep -r 'PUBLISH' skills/`
Expected: 0 matches

Run: `grep -c 'PLAN_HANDOFF' skills/trace-orchestrator/SKILL.md`
Expected: at least 2 matches

- [ ] **Step 4: Verify beads artifacts are in orchestrator catalog**

Run: `grep -c 'beads-' skills/trace-orchestrator/SKILL.md`
Expected: at least 7 matches

- [ ] **Step 5: Verify beads manifest fields are in readiness contract**

Run: `grep -c 'beads_' skills/trace-orchestrator/SKILL.md`
Expected: at least 7 matches

- [ ] **Step 6: Verify beads-escalation is accepted by spec-loop**

Run: `grep 'beads-escalation' skills/spec-loop/SKILL.md`
Expected: 1 match

- [ ] **Step 7: Verify new skills have correct frontmatter**

Run: `head -3 skills/spec-beads-generate/SKILL.md`
Expected: `name: spec-beads-generate`

Run: `head -3 skills/spec-beads-review/SKILL.md`
Expected: `name: spec-beads-review`

- [ ] **Step 8: Cross-check the design spec against implementation**

Verify:
- Phase list has 12 entries (10 core + 2 optional)
- Sub-skill order has 8 entries (6 core + 2 optional)
- Manifest has 26 fields (19 existing + 7 beads)
- Artifact catalog includes 5 beads artifacts
- Smoke test checks 9 skills
- PUBLISH is fully replaced by PLAN_HANDOFF everywhere
