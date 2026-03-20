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

#### Entry to ADVERSARIAL_REVIEW

All conditions that currently gate `PLANNING_READY` now gate entry to `ADVERSARIAL_REVIEW` instead:

- `blocker_reasons = []`
- All 5 critical decision buckets closed (not `open`)
- `completeness_score >= 80` and `evidence_confidence_score >= 80`
- Synthesis-review verification passes

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
7. Spec is updated with all resolutions
8. Next round begins on the updated spec

#### Convergence

- **Minimum**: 2 rounds (first pass always finds things; second validates answers didn't expose new gaps)
- **Maximum**: 5 rounds (safety cap)
- **Exit**: a round where ALL agents — section and cross-cutting — independently report zero material findings
- **Bias**: toward running another round if any agent is uncertain. The cap is a safety valve, not a target.
- **"Material" defined broadly**: anything that could cause an engineer to make a judgment call the spec should have made for them

#### Cap Behavior

Hitting the cap (5 rounds without convergence) is NOT an acceptable exit. It triggers a **decomposition signal**:

- `adversarial_status = decomposition_required`
- `planning_status` reverts to `AWAITING_CLARIFICATION`
- The review emits a decomposition proposal: natural seams in the spec, what's tangling, and 2-3 suggested sub-specs that would each be tractable
- User decides how to split
- Each sub-spec enters the pipeline at `spec-intake` independently

`adversarial_status` has exactly two values:

- `converged` — passed, proceed to `PLANNING_READY`
- `decomposition_required` — too complex, must split

No middle ground. No "close enough."

#### Outputs

- `adversarial-review-log.md` — all findings across all rounds, with resolutions and provenance
- `adversarial-round-N.json` — structured findings per round (for machine consumption)
- Updated `specs/<subject>.md` — spec revised with resolutions
- Updated `manifest.json` — new adversarial fields

### 3. Spec-Loop Clarification Hardening

No architectural changes to spec-loop — same skill, same clarification machinery. Changes are to the question profiles and gating.

#### Expanded Question Categories

Currently questions target the 5 critical decision buckets (core outcome, scope boundary, implementation constraints, dependencies, acceptance signal). Add mandatory categories:

- **Failure modes** — "What happens when X fails? What's the degraded behavior? Is data loss acceptable?"
- **Security boundaries** — "Who can access this? What's the trust model? What input do you not control?"
- **Edge cases** — "What happens at zero? At max scale? When two of these happen simultaneously?"
- **Scalability assumptions** — "What volume are you designing for? What's the growth expectation?"
- **Operational concerns** — "How do you know it's working? How do you debug it? What gets logged?"
- **Ordering and concurrency** — "Can these happen in parallel? What if they arrive out of order?"

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
- `decomposition_required` → user splits → each sub-spec enters at `spec-intake`

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

Added to the canonical readiness fields:

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
| `skills/spec-loop/SKILL.md` | **modify** — expanded clarification, research-first, raised drafting gate |
| `skills/trace-orchestrator/SKILL.md` | **modify** — new state, routing, team creation, manifest fields, phase list |
| `skills/spec-completeness/SKILL.md` | **modify** — score expanded categories |
| `skills/spec-plan-handoff/SKILL.md` | **modify** — require `adversarial_status = converged` |
| `README.md` | **modify** — update readiness model, skill count to 7, repo layout |
| `scripts/smoke-test.sh` | **modify** — check for new skill dir |
