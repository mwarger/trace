# Post-Handoff Beads Generation & Adversarial Review

## Problem

After Trace emits an implementation plan, there is no mechanism to decompose that plan into tracked, dependency-wired work units — or to verify that those work units faithfully and completely capture the spec. Engineers receive a plan document but must manually create tickets, figure out ordering, and hope nothing was missed.

## Goals

- Optionally decompose the implementation plan into beads (issues) using `br` and `bv`
- Wire dependencies, epics, and provenance labels so beads trace back to spec claims
- Stress-test the bead set with an adversarial agent team until convergence on coverage, granularity, dependency correctness, and actionability
- Include TDD-ready test sketches with test type annotations per bead
- Treat the Trace spec as the PRD — no separate PRD artifact needed
- Beads live in a shared workspace at the project root, not scoped to a single Trace run

## Non-Goals

- Replacing or modifying the existing spec adversarial review
- Generating a separate PRD artifact (the spec serves this role)
- A beads handoff skill (developers use `bv` directly for execution planning and triage)

## Design

### 1. Orchestrator Phase Changes

Rename phase 10 from `PUBLISH` to `PLAN_HANDOFF`. Add two new optional phases:

```
1.  INTAKE
2.  EVIDENCE_FANOUT
3.  REDUCE_AND_MERGE
4.  GAP_ANALYSIS
5.  USER_INPUT
6.  DRAFT
7.  VERIFY
8.  READINESS_GATE
9.  ADVERSARIAL_REVIEW
10. PLAN_HANDOFF (renamed from PUBLISH)
11. BEADS_GENERATION (optional)
12. BEADS_REVIEW (optional)
```

#### Entry to BEADS_GENERATION

After `PLAN_HANDOFF` completes, the orchestrator prompts:

> "Implementation plan emitted. Would you like to generate a beads workspace from this plan?"

If the user declines, the run ends at `PLAN_HANDOFF`. If they accept, the orchestrator routes to `spec-beads-generate`.

#### Opt-in Semantics

These phases are post-handoff and do not affect the canonical readiness contract. No new `planning_status` values are added. The readiness contract (`PLANNING_READY` + `ELIGIBLE` + `adversarial_status = converged`) remains the gate for emitting the implementation plan. Beads phases are downstream of that gate.

#### New Manifest Fields

- `beads_generated` (boolean)
- `beads_epic_id` (string — the `br` epic ID)
- `beads_review_rounds_completed` (integer)
- `beads_review_status` (`converged` | `decomposition_required`) — absent until the review phase exits, consistent with `adversarial_status` semantics
- `beads_total` (integer)
- `beads_coverage_score` (integer — % of spec claims traced to beads)
- `beads_workspace_path` (string — path to the `.beads` directory)

### 2. New Skill: `spec-beads-generate`

#### Purpose

Decompose `implementation-plan.md` into a set of beads with full provenance back to the spec.

#### Behavior

1. Initialize a beads workspace if one doesn't exist (`br init`). If `.beads` already exists at the project root, use it.
2. Create an epic for the spec subject: `br create --type epic --title "<subject>" --labels "trace:<subject-slug>"`
3. Read each workstream from the implementation plan and create beads:
   - One bead per discrete work unit within a workstream
   - `br create --title "..." --type task --parent <epic-id> --labels "trace:<subject-slug>" --description "..."`
   - Description includes: what to do, acceptance criteria, which spec claims this bead covers
4. Wire dependencies from the implementation plan's dependency graph: `br dep add`
5. Emit `beads-manifest.json` — a mapping of bead IDs to spec claims, acceptance criteria, and workstream origin

#### `beads-manifest.json` Schema

```json
{
  "subject": "feature-flags-system",
  "epic_id": "FEAT-001",
  "workspace_path": "/path/to/project/.beads",
  "beads": [
    {
      "bead_id": "FEAT-002",
      "title": "Add flag evaluation engine",
      "workstream": "core-engine",
      "spec_claims": ["claim-003", "claim-007"],
      "acceptance_criteria": ["ac-001", "ac-002"],
      "dependencies": ["FEAT-005"],
      "test_first": "yes",
      "test_sketches": [
        {
          "type": "unit",
          "description": "flag evaluates to default when no rules match"
        },
        {
          "type": "property",
          "description": "for any rule set, evaluation is deterministic given same context"
        }
      ]
    }
  ],
  "unmapped_claims": [],
  "unmapped_acceptance_criteria": []
}
```

`unmapped_claims` and `unmapped_acceptance_criteria` start populated after generation and must be empty after review converges. The coverage agent uses these arrays as its primary attack surface.

#### Provenance Contract

Every spec claim and acceptance criterion must appear in at least one bead's description. The manifest tracks this mapping explicitly so the review phase can verify coverage.

#### What This Skill Does NOT Do

It does not evaluate quality. That is the review phase's job. This skill is the advocate — it makes the best decomposition it can and hands it to the adversarial team.

### 3. New Skill: `spec-beads-review`

#### Purpose

Stress-test the beads for coverage, granularity, dependencies, and actionability until convergence.

#### Agent Team Allocation

Same pattern as `spec-adversarial-review` — dynamic teams via `TeamCreate`. Team persists across all rounds.

**Coverage agent** — checks every spec claim and acceptance criterion against `beads-manifest.json`. Flags anything not traced to a bead, or traced to a bead that doesn't actually address it.

**Granularity agent** — evaluates each bead: too coarse (multiple unrelated concerns, would need decomposition during implementation)? Too fine (trivially small, noise)? Proposes splits or merges.

**Dependency agent** — runs `bv --robot-suggest` for cycle detection, `bv --robot-graph` for structure analysis, `bv --robot-insights` for graph health. Checks for missing edges (bead A clearly depends on bead B but no dep exists) and false edges.

**Actionability agent** — plays literal implementer for each bead. Evaluates:
- Could I implement this without asking questions?
- Does it have clear acceptance criteria?
- Can I write a failing test first? If the bead doesn't describe observable behavior or a verifiable outcome, it's not TDD-ready — flag it.
- Are test boundaries clear? Does the bead specify enough about inputs, outputs, and side effects to know what to assert against?
- Beads that are inherently non-testable-first (pure refactors with no behavior change, infrastructure setup) get annotated as `test-first: n/a` with rationale.

#### TDD Test Sketches

The actionability agent produces pseudocode test sketches per bead, specifying both the scenario and the test type. The agent chooses the most appropriate type per bead from: **unit**, **property**, **integration**, **contract**, **e2e**.

Example:

```
Bead: FEAT-003 "Add rate limiter to API gateway"
test-first: yes
test-sketches:
  - type: unit
    "rate limiter returns 429 when count exceeds threshold"
  - type: property
    "for any sequence of N requests where N > limit, exactly N-limit get 429"
  - type: integration
    "rate limiter reads config from Redis, updates survive restart"
```

A pure data transformation gets property tests. A boundary interaction gets contract/integration tests. A user-facing flow gets e2e. If the agent can't write meaningful test sketches for a bead, that is itself a finding — the bead's acceptance criteria are too vague.

Test sketches are embedded in the bead description by default. Use `br comments add` only when the description would exceed a reasonable length (e.g., beads with many test scenarios). When an engineer starts the bead, the red-green cycle is already scoped.

#### Round Structure

Each round:

1. All agents evaluate the current bead set independently
2. Agents use `br` queries and `bv --robot-*` commands as evidence sources
3. Findings collected, deduplicated, and classified:
   - **Critical** — missing spec claim coverage, dependency cycle, bead with multiple valid interpretations → escalate to user
   - **High** — granularity problem, missing dependency edge, vague acceptance criteria → escalate to user
   - **Resolvable** — answer is unambiguous from spec, codebase, or bv analysis → auto-resolve, log decision, flag for user visibility
4. Resolutions applied: `br create` (new beads), `br update` (fix descriptions), `br dep add/remove` (rewire), `br delete` (merge/remove)
5. `beads-manifest.json` updated with any changes
6. Next round begins on the updated bead set

#### Convergence

- **Minimum**: 2 rounds if round 1 produces findings. If round 1 produces zero material findings from all agents, 1 round is sufficient.
- **Maximum**: 5 rounds (safety cap)
- **Exit**: a round where ALL agents independently report zero material findings
- **Bias**: toward running another round if any agent is uncertain. The cap is a safety valve, not a target.
- **"Material" defined broadly**: anything that could cause an engineer to make a judgment call the beads should have made for them

#### Cap Behavior

Hitting the cap (5 rounds without convergence) is NOT an acceptable exit. It triggers a decomposition signal:

- `beads_review_status = decomposition_required`
- Emit `beads-decomposition-proposal.md` explaining what's tangled and why

Decomposition can mean one of two things:

1. **The implementation plan's workstreams are too tangled** — the beads can't be cleanly separated because the plan itself has unclear boundaries. Escalate back to the user with a proposal to revise the implementation plan.
2. **The spec has gaps the beads review exposed** — the act of decomposing into concrete work units revealed ambiguity that the spec adversarial review missed. This is a back-transition signal — loop back to `spec-loop` with a `beads-escalation.json` artifact listing finding IDs, affected spec sections, and reopened blockers. The orchestrator passes this to `spec-loop` so the re-entry round is targeted to the specific findings, same pattern as `adversarial-escalation.json`. `spec-loop` treats both escalation artifact types identically — scope the round to the listed findings.

The user decides next steps based on the decomposition proposal.

#### Outputs

- `beads-review-log.md` — all findings across all rounds with resolutions and provenance
- `beads-review-round-N.json` — structured findings per round
- Updated `beads-manifest.json`
- On decomposition: `beads-decomposition-proposal.md`
- On back-transition: `beads-escalation.json`

### 4. Beads Workspace Location

Beads live at the git repository root (as determined by `git rev-parse --show-toplevel`), not inside Trace artifacts. Multiple Trace runs can feed beads into the same shared workspace.

- If a `.beads` directory already exists at the git root, use it — don't re-init
- If not, run `br init` at the git root before creating any beads
- The orchestrator records the workspace path in `manifest.json` as `beads_workspace_path`

Provenance is maintained via:

- **Epic** per spec run (`--parent`) — structural grouping
- **Label** per spec (`--labels "trace:<subject-slug>"`) — cross-cutting queryability
- **`beads-manifest.json`** stored in `specs/_artifacts/<subject>/` — Trace-side artifact mapping bead IDs to spec claims

A developer can query by spec origin (`br list --label trace:feature-flags-system`) or see all work across specs (`br list`).

### 5. Affected Files

| File | Change |
|------|--------|
| `skills/spec-beads-generate/SKILL.md` | **new** — beads generation skill |
| `skills/spec-beads-review/SKILL.md` | **new** — beads adversarial review skill |
| `skills/trace-orchestrator/SKILL.md` | **modify** — rename PUBLISH to PLAN_HANDOFF, add phases 11-12, add manifest fields, add user prompt after handoff, register new artifacts in catalog |
| `README.md` | **modify** — update phase list, add new skills, update skill count |
| `scripts/smoke-test.sh` | **modify** — add new skill dirs to check |
| `docs/superpowers/specs/2026-03-19-adversarial-review-design.md` | **modify** — update PUBLISH reference to PLAN_HANDOFF for consistency |
| `skills/spec-loop/SKILL.md` | **modify** — accept `beads-escalation.json` as re-entry input (same handling as `adversarial-escalation.json`) |
