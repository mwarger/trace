# Adversarial Review & Intake Hardening

## Problem

Trace specs can reach `PLANNING_READY` with residual ambiguity — vague constraints, missing failure modes, unstated assumptions, inter-section contradictions — that engineers must resolve during implementation. The intake questioning is too gentle (focused narrowly on product decisions), and there is no phase that stress-tests the spec from hostile perspectives before handoff.

## Goals

- Leave as little as possible to figure out during implementation
- Front-load exhaustive questioning in the spec-loop phase
- Add a convergence-based adversarial review gate that uses dynamic agent teams to find every remaining gap
- If a spec can't converge, treat it as a decomposition signal, not an acceptable exit

## Design

### 1. State Machine Changes

Current planning states:

```
DISCOVERY → AWAITING_CLARIFICATION → SPECULATIVE_DRAFT → PLANNING_READY
```

New planning states:

```
DISCOVERY → AWAITING_CLARIFICATION → SPECULATIVE_DRAFT → ADVERSARIAL_REVIEW → PLANNING_READY
```

`ADVERSARIAL_REVIEW` is a fifth legal value of the `planning_status` field in both `manifest.json` and `run-state.json`. The orchestrator's canonical readiness contract must be updated to include it in the enum.

#### Entry to ADVERSARIAL_REVIEW

All conditions that currently gate `PLANNING_READY` now gate entry to `ADVERSARIAL_REVIEW` instead:

- `blocker_reasons = []`
- All 5 critical decision buckets closed (not `open`)
- `completeness_score >= 80` and `evidence_confidence_score >= 80`
- Synthesis-review verification passes

When these conditions are met, the orchestrator sets `planning_status = ADVERSARIAL_REVIEW` and routes to `spec-adversarial-review`.

#### Exit from ADVERSARIAL_REVIEW

- **→ `PLANNING_READY`**: all adversarial rounds converged (zero material findings by agent consensus), all user-escalated issues resolved, spec updated with resolutions
- **→ `AWAITING_CLARIFICATION`**: adversarial review surfaces ambiguity only the user can resolve
- **→ `SPECULATIVE_DRAFT`**: adversarial review reveals a missed blocker (re-opens `blocker_reasons`)
- **→ `AWAITING_CLARIFICATION` (decomposition)**: round cap hit without convergence — spec is too complex, decomposition proposal emitted

`handoff_status = ELIGIBLE` still only pairs with `PLANNING_READY`. Nothing downstream changes.

### 2. New Skill: `spec-adversarial-review`

#### Agent Team Allocation

Uses agent teams (`TeamCreate`) as the primary organizing mechanism. Team persists across all rounds for context continuity.

**Section agents** (depth) — one per substantive spec area, dynamically allocated by reading the completeness matrix. A simple spec gets 3-4, a complex one 8-10. Examples:

- Core flows agent
- Entity/state transitions agent
- Interfaces/integrations agent
- Constraints/failure modes agent
- Security boundaries agent
- Acceptance criteria agent

Allocation is dynamic — sections without substantive content don't get agents.

**Cross-cutting agents** (coherence) — always 2-3 regardless of spec size:

- **Literal implementer** — "If I read this spec with zero context and built exactly what it says, what would go wrong?"
- **QA adversary** — "What claims are untestable? What edge cases have no defined behavior?"
- **Consistency checker** — "Where does section X contradict or assume something incompatible with section Y?"

#### Round Structure

Each round:

1. All agents read the current spec independently
2. Section agents probe their area for: ambiguous language, missing failure modes, unstated assumptions, vague constraints, gaps an engineer would have to fill with judgment
3. Cross-cutting agents probe for: inter-section contradictions, untestable claims, unstated dependencies, things that work on paper but break in practice
4. Each agent researches the codebase before filing a finding — if the answer is in the code, it's not a finding, it's a resolution
5. Findings are collected, deduplicated, and classified:
   - **Critical** — multiple valid interpretations of a core behavior, missing failure mode that changes architecture → escalate to user
   - **High** — ambiguous constraint, unclear boundary, missing edge case with non-obvious answer → escalate to user
   - **Resolvable** — answer is unambiguous from codebase or context → auto-resolve, log decision, flag for user visibility
6. User answers escalated findings
7. The orchestrator (as lead agent and sole reducer) applies all resolutions to the spec. This is an intra-phase canon write owned by the orchestrator, consistent with the reducer protocol. The adversarial review skill emits structured resolution proposals; the orchestrator applies them. No exception to the lead-agent-as-only-reducer rule is needed.
8. Next round begins on the updated spec

#### Convergence

- **Minimum**: 2 rounds if round 1 produces findings. If round 1 produces zero material findings from all agents, the minimum is 1 round — the spec entered adversarial review already clean, and a mechanical repeat of an identical spec adds no signal.
- **Maximum**: 5 rounds (safety cap)
- **Exit**: a round where ALL agents — section and cross-cutting — independently report zero material findings
- **Bias**: toward running another round if any agent is uncertain. The cap is a safety valve, not a target.
- **"Material" defined broadly**: anything that could cause an engineer to make a judgment call the spec should have made for them

#### Cap Behavior

Hitting the cap (5 rounds without convergence) is NOT an acceptable exit. It triggers a **decomposition signal**:

- `adversarial_status = decomposition_required`
- `planning_status` reverts to `AWAITING_CLARIFICATION`
- The review emits a decomposition proposal (see below)
- User decides how to split and when to run each sub-spec

`adversarial_status` has exactly two values:

- `converged` — passed, proceed to `PLANNING_READY`
- `decomposition_required` — too complex, must split

No middle ground. No "close enough."

#### Decomposition Handoff

When decomposition is required, the adversarial review emits:

1. **`decomposition-proposal.md`** — identifies natural seams in the spec, what's tangling, and 2-3 suggested sub-specs with boundaries
2. **`sub-spec-brief-<name>.md`** (one per suggested sub-spec) — standalone brief containing:
   - Extracted evidence relevant to that sub-spec
   - Scope and boundaries (what's in, what's out)
   - Constraints inherited from the parent spec
   - Dependencies on other sub-specs (if any)
   - Enough context that a fresh session can run `spec-intake` on it without losing information

The user reviews the decomposition and decides per sub-spec:

- **Run now in this session** — sequential, one at a time through the full pipeline
- **Run in parallel via agent teams** — for sub-specs that are independent (no dependency edges between them), the orchestrator can spawn teams to run them concurrently
- **Save for later** — the brief is self-contained; pick it up in a new session whenever

The decomposition proposal must identify dependency edges between sub-specs so the user can make an informed choice. Sub-specs with dependencies should be sequenced (either within a session or across sessions); independent sub-specs are candidates for parallel teams.

All decomposition artifacts are added to the orchestrator's artifact catalog.

#### Outputs

- `adversarial-review-log.md` — all findings across all rounds, with resolutions and provenance
- `adversarial-round-N.json` — structured findings per round (for machine consumption)
- Updated `specs/<subject>.md` — spec revised with resolutions (applied by the orchestrator, not the skill directly)
- Updated `manifest.json` — new adversarial fields (written by the orchestrator per the canonical readiness contract)

Both new artifact types (`adversarial-review-log.md` and `adversarial-round-N.json`) must be added to the orchestrator's artifact catalog so the `artifact-curator` delegation role knows to handle and preserve them.

### 3. Spec-Loop Clarification Hardening

No architectural changes to spec-loop — same skill, same clarification machinery. Changes are to the question profiles and gating.

#### Expanded Question Categories

Currently questions target the 5 critical decision buckets (core outcome, scope boundary, implementation constraints, dependencies, acceptance signal). Add new categories with per-archetype applicability:

| Category | feature | analogy_feature | parity_clone | integration | bugfix | migration | refactor | reverse_spec |
|----------|---------|----------------|-------------|-------------|--------|-----------|----------|-------------|
| **Failure modes** | required | required | required | required | required | required | optional | required |
| **Security boundaries** | required | required | required | required | optional | optional | optional | required |
| **Edge cases** | required | required | required | required | required | required | optional | required |
| **Scalability assumptions** | required | optional | optional | required | optional | required | optional | optional |
| **Operational concerns** | required | optional | optional | required | optional | required | optional | required |
| **Ordering and concurrency** | required | optional | optional | required | required | required | optional | optional |

- **Failure modes** — "What happens when X fails? What's the degraded behavior? Is data loss acceptable?"
- **Security boundaries** — "Who can access this? What's the trust model? What input do you not control?"
- **Edge cases** — "What happens at zero? At max scale? When two of these happen simultaneously?"
- **Scalability assumptions** — "What volume are you designing for? What's the growth expectation?"
- **Operational concerns** — "How do you know it's working? How do you debug it? What gets logged?"
- **Ordering and concurrency** — "Can these happen in parallel? What if they arrive out of order?"

Categories marked `optional` for an archetype are skipped by default unless evidence suggests they're relevant. Categories marked `required` must be addressed before the drafting gate opens. This preserves the existing per-archetype clarification profile contract while expanding coverage where it matters.

#### Research-First Directive

Before escalating any question to the user, the loop must:

1. Search the codebase for existing patterns, implementations, or conventions that answer it
2. Check existing evidence and prior clarification answers for implicit answers
3. Only escalate if genuinely unanswerable from available sources

#### Raised Drafting Gate

All expanded categories must be addressed (by evidence, codebase research, or user answer) before the loop transitions to drafting. "Addressed" means the loop has a concrete answer or has explicitly marked it as out-of-scope with user agreement — not just "we didn't think to ask."

### 4. Orchestrator Routing Changes

#### New Sub-Skill Sequence

```
1. spec-intake
2. spec-loop (hardened questioning)
3. spec-completeness
4. spec-synthesis-review
5. spec-adversarial-review  ← new
6. spec-plan-handoff
```

#### Team Creation

The orchestrator creates the adversarial agent team via `TeamCreate` before routing to the skill:

- Reads the completeness matrix to determine section agents
- Always adds the 3 cross-cutting agents
- Team persists for the full adversarial phase (all rounds)

#### Back-Transitions

If adversarial review escalates back, the spec re-enters the pipeline:

- `AWAITING_CLARIFICATION` → route to `spec-loop` (targeted round) → `spec-completeness` → `spec-synthesis-review` → `spec-adversarial-review`
- `SPECULATIVE_DRAFT` → same re-entry path
- `decomposition_required` → decomposition briefs emitted → user chooses per sub-spec: run now (sequential), run in parallel (agent teams for independent sub-specs), or save for later (self-contained brief for a new session)

**Handoff to spec-loop on re-entry**: when adversarial review triggers a back-transition, it emits an `adversarial-escalation.json` artifact listing the specific findings that caused the regression (finding IDs, affected sections, blocker reason if reopened). The orchestrator passes this as input to the targeted `spec-loop` round so the loop knows exactly what to address rather than running a generic pass. `spec-loop` must accept `adversarial-escalation.json` as an optional input that, when present, scopes the round to the escalated findings.

#### Run State Changes

`run-state.json` gains a new phase:

```
Phase 9:  ADVERSARIAL_REVIEW
  entry: synthesis-review passed, scoring gates met
  exit: convergence (zero findings by consensus) or decomposition required
  checkpoint: adversarial-review-log.md
Phase 10: PUBLISH (was 9)
```

#### New Manifest Fields

Added to the canonical readiness fields. **The orchestrator owns these fields** per the canonical readiness contract — `spec-adversarial-review` emits structured inputs, and the orchestrator writes the final values to `manifest.json`, consistent with the existing pattern where only the orchestrator finalizes readiness fields.

- `adversarial_rounds_completed` (integer)
- `adversarial_status` (`converged` | `decomposition_required`)
- `adversarial_findings_total` (integer — across all rounds)
- `adversarial_findings_resolved_by_research` (integer)
- `adversarial_findings_resolved_by_user` (integer)

### 5. Other Skill Changes

#### spec-completeness

Score the expanded question categories (failure modes, security, edge cases, scalability, operational, ordering/concurrency) alongside the existing 11 dimensions. These new categories feed into the completeness and confidence scores.

#### spec-plan-handoff

Gate requires `adversarial_status = converged`. No exceptions.

### 6. Affected Files

| File | Change |
|------|--------|
| `skills/spec-adversarial-review/SKILL.md` | **new** — adversarial review skill |
| `skills/spec-loop/SKILL.md` | **modify** — expanded clarification, research-first, raised drafting gate, accept `adversarial-escalation.json` on re-entry |
| `skills/trace-orchestrator/SKILL.md` | **modify** — new state in `planning_status` enum, routing, team creation, manifest fields, phase list, artifact catalog update |
| `skills/spec-completeness/SKILL.md` | **modify** — score expanded categories |
| `skills/spec-plan-handoff/SKILL.md` | **modify** — require `adversarial_status = converged` |
| `README.md` | **modify** — update readiness model, skill count to 7, repo layout |
| `scripts/smoke-test.sh` | **modify** — check for new skill dir |
