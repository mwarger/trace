# Adversarial Review & Intake Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a convergence-based adversarial review gate with dynamic agent teams and harden spec-loop questioning, so specs leave near-zero ambiguity for implementation.

**Architecture:** New `spec-adversarial-review` skill inserted between synthesis-review and plan-handoff. `ADVERSARIAL_REVIEW` becomes a fifth `planning_status` value. Spec-loop gets expanded question categories with per-archetype applicability and a research-first directive. Completeness scoring uses new sub-signals mapped to existing dimensions.

**Tech Stack:** Markdown skill definitions (SKILL.md), bash (smoke test), JSON schema (manifest fields)

**Spec:** `docs/superpowers/specs/2026-03-19-adversarial-review-design.md`

---

### Task 1: Add `ADVERSARIAL_REVIEW` to Orchestrator State Machine

**Files:**
- Modify: `skills/trace-orchestrator/SKILL.md:63-84` (planning state machine)

- [ ] **Step 1: Add ADVERSARIAL_REVIEW to the planning_status enum**

In `skills/trace-orchestrator/SKILL.md`, update the planning state machine section. Change lines 66-70 from:

```markdown
- `planning_status`
  - `DISCOVERY`
  - `AWAITING_CLARIFICATION`
  - `SPECULATIVE_DRAFT`
  - `PLANNING_READY`
```

to:

```markdown
- `planning_status`
  - `DISCOVERY`
  - `AWAITING_CLARIFICATION`
  - `SPECULATIVE_DRAFT`
  - `ADVERSARIAL_REVIEW`
  - `PLANNING_READY`
```

- [ ] **Step 2: Add ADVERSARIAL_REVIEW transition rules**

After the existing transition rules (line 84), add:

```markdown
- `ADVERSARIAL_REVIEW` entry requires: `blocker_reasons` empty, all critical
  decision buckets closed, `completeness_score >= 80`,
  `evidence_confidence_score >= 80`, and synthesis-review verification passed
- `ADVERSARIAL_REVIEW` → `PLANNING_READY` only when adversarial rounds
  converge (zero material findings by agent consensus)
- `ADVERSARIAL_REVIEW` → `AWAITING_CLARIFICATION` if adversarial review
  surfaces ambiguity only the user can resolve, or if the round cap is hit
  (decomposition required)
- `ADVERSARIAL_REVIEW` → `SPECULATIVE_DRAFT` if adversarial review re-opens
  blocker reasons
```

- [ ] **Step 3: Verify the file reads correctly**

Run: `grep -c 'ADVERSARIAL_REVIEW' skills/trace-orchestrator/SKILL.md`
Expected: at least 5 matches

- [ ] **Step 4: Commit**

```bash
git add skills/trace-orchestrator/SKILL.md
git commit -m "feat: add ADVERSARIAL_REVIEW to orchestrator planning state machine"
```

---

### Task 2: Add Adversarial Manifest Fields to Orchestrator

**Files:**
- Modify: `skills/trace-orchestrator/SKILL.md:36-61` (canonical readiness contract)

- [ ] **Step 1: Add the 5 new fields to the canonical readiness contract**

In `skills/trace-orchestrator/SKILL.md`, after line 54 (`- corroboration_score`), add:

```markdown
- `adversarial_rounds_completed`
- `adversarial_status`
- `adversarial_findings_total`
- `adversarial_findings_resolved_by_research`
- `adversarial_findings_resolved_by_user`
```

- [ ] **Step 2: Verify field count**

The contract should now list 20 fields (was 15). Count the `- \`` lines in that section to confirm.

- [ ] **Step 3: Commit**

```bash
git add skills/trace-orchestrator/SKILL.md
git commit -m "feat: add adversarial manifest fields to canonical readiness contract"
```

---

### Task 3: Update Orchestrator Run Phases and Sub-Skill Order

**Files:**
- Modify: `skills/trace-orchestrator/SKILL.md:105-131` (run phases and sub-skill order)

- [ ] **Step 1: Insert ADVERSARIAL_REVIEW phase**

Change the run phases (lines 108-116) from:

```markdown
1. `INTAKE`
2. `EVIDENCE_FANOUT`
3. `REDUCE_AND_MERGE`
4. `GAP_ANALYSIS`
5. `USER_INPUT`
6. `DRAFT`
7. `VERIFY`
8. `READINESS_GATE`
9. `PUBLISH`
```

to:

```markdown
1. `INTAKE`
2. `EVIDENCE_FANOUT`
3. `REDUCE_AND_MERGE`
4. `GAP_ANALYSIS`
5. `USER_INPUT`
6. `DRAFT`
7. `VERIFY`
8. `READINESS_GATE`
9. `ADVERSARIAL_REVIEW`
10. `PUBLISH`
```

- [ ] **Step 2: Insert spec-adversarial-review in sub-skill order**

Change the required sub-skill order (lines 123-127) from:

```markdown
1. `spec-intake`
2. `spec-loop`
3. `spec-completeness`
4. `spec-synthesis-review`
5. `spec-plan-handoff`
```

to:

```markdown
1. `spec-intake`
2. `spec-loop`
3. `spec-completeness`
4. `spec-synthesis-review`
5. `spec-adversarial-review`
6. `spec-plan-handoff`
```

- [ ] **Step 3: Update the loop-back instruction**

Change lines 129-130 from:

```markdown
Loop back to `spec-loop` or `spec-completeness` whenever verification fails or
blockers remain.
```

to:

```markdown
Loop back to `spec-loop` or `spec-completeness` whenever verification fails or
blockers remain. If `spec-adversarial-review` escalates back, pass the
`adversarial-escalation.json` artifact as input to the targeted `spec-loop`
round so it addresses the specific findings rather than running a generic pass.
```

- [ ] **Step 4: Commit**

```bash
git add skills/trace-orchestrator/SKILL.md
git commit -m "feat: add adversarial review to orchestrator phases and sub-skill order"
```

---

### Task 4: Update Orchestrator Artifacts and Delegation

**Files:**
- Modify: `skills/trace-orchestrator/SKILL.md:208-230` (artifacts section)
- Modify: `skills/trace-orchestrator/SKILL.md:132-155` (delegation policy)

- [ ] **Step 1: Add adversarial artifacts to the catalog**

After line 229 (`- implementation-plan.md`), add:

```markdown
- `adversarial-review-log.md`
- `adversarial-round-N.json`
- `adversarial-escalation.json`
- `decomposition-proposal.md`
- `sub-spec-brief-<name>.md`
```

- [ ] **Step 2: Add team creation guidance to delegation policy**

After the existing delegation policy section (after line 154), add:

```markdown
For adversarial review, create agent teams via `TeamCreate`:
- section agents: one per substantive spec area, allocated by reading the
  completeness matrix
- cross-cutting agents: literal implementer, QA adversary, consistency checker
- team persists for all adversarial rounds
```

- [ ] **Step 3: Commit**

```bash
git add skills/trace-orchestrator/SKILL.md
git commit -m "feat: add adversarial artifacts and team creation to orchestrator"
```

---

### Task 5: Expand Spec-Loop Clarification Profiles

**Files:**
- Modify: `skills/spec-loop/SKILL.md:35-68` (clarification policy)

- [ ] **Step 1: Add the expanded question categories with archetype matrix**

After the existing clarification profiles (after line 57, the migration profile), add:

```markdown
Additional required categories by archetype:

| Category | feature | analogy_feature | parity_clone | integration | bugfix | migration | refactor | reverse_spec |
|----------|---------|----------------|-------------|-------------|--------|-----------|----------|-------------|
| Failure modes | required | required | required | required | required | required | optional | required |
| Security boundaries | required | required | required | required | optional | optional | optional | required |
| Edge cases | required | required | required | required | required | required | optional | required |
| Scalability assumptions | required | optional | optional | required | optional | required | optional | optional |
| Operational concerns | required | optional | optional | required | optional | required | optional | required |
| Ordering and concurrency | required | optional | optional | required | required | required | optional | optional |

Categories marked `required` must be addressed before the drafting gate opens.
Categories marked `optional` are skipped unless evidence suggests relevance.
```

- [ ] **Step 2: Add the research-first directive**

After the new archetype matrix, add:

```markdown
## Research-first directive

Before escalating any question to the user:
1. search the codebase for existing patterns, implementations, or conventions
   that answer it
2. check existing evidence and prior clarification answers for implicit answers
3. only escalate if genuinely unanswerable from available sources
```

- [ ] **Step 3: Add the raised drafting gate**

After the research-first directive, add:

```markdown
## Raised drafting gate

All required categories (per archetype matrix) must be addressed before
transitioning to drafting. "Addressed" means the loop has a concrete answer
from evidence, codebase research, or user answer — or has explicitly marked the
category as out-of-scope with user agreement. "We didn't think to ask" is not
addressed.
```

- [ ] **Step 4: Add adversarial-escalation.json re-entry support**

After the raised drafting gate section, add:

```markdown
## Adversarial re-entry

When `adversarial-escalation.json` is present as input, scope the round to the
escalated findings only. Do not run a full generic pass. Address the specific
findings, affected sections, and reopened blockers listed in the escalation
artifact.
```

- [ ] **Step 5: Commit**

```bash
git add skills/spec-loop/SKILL.md
git commit -m "feat: expand spec-loop clarification profiles and add research-first directive"
```

---

### Task 6: Add Sub-Signal Mapping to Spec-Completeness

**Files:**
- Modify: `skills/spec-completeness/SKILL.md:12-26` (ontology section)

- [ ] **Step 1: Add sub-signal mapping after the ontology dimensions**

After line 26 (`- acceptance criteria`), add:

```markdown
## Sub-signal requirements

The following sub-signals feed into existing dimensions as required coverage
inputs. A dimension cannot score above `partial` unless its mapped sub-signals
are addressed (per the archetype applicability matrix in `spec-loop`).

| Sub-signal | Feeds into dimensions |
|------------|----------------------|
| Security boundaries | `constraints`, `interfaces` |
| Edge cases | `failure modes`, `state transitions` |
| Scalability assumptions | `constraints`, `assumptions` |
| Operational concerns | `interfaces`, `constraints` |
| Ordering and concurrency | `state transitions`, `core flows` |

For archetypes where a sub-signal is marked `optional` in the spec-loop
matrix, that sub-signal does not block the parent dimension's coverage. It
only contributes if evidence is present.
```

- [ ] **Step 2: Commit**

```bash
git add skills/spec-completeness/SKILL.md
git commit -m "feat: add sub-signal dimension mapping to spec-completeness"
```

---

### Task 7: Add Adversarial Gate to Spec-Plan-Handoff

**Files:**
- Modify: `skills/spec-plan-handoff/SKILL.md:10-17` (preconditions)

- [ ] **Step 1: Add adversarial_status gate**

Change lines 12-16 from:

```markdown
Do not emit a real implementation plan if:
- `planning_status != PLANNING_READY`
- or `handoff_status != ELIGIBLE`
- or the run is a `sparse` `analogy_feature` or `parity_clone` with
  `question_rounds_completed = 0`
```

to:

```markdown
Do not emit a real implementation plan if:
- `planning_status != PLANNING_READY`
- or `handoff_status != ELIGIBLE`
- or `adversarial_status != converged`
- or the run is a `sparse` `analogy_feature` or `parity_clone` with
  `question_rounds_completed = 0`
```

- [ ] **Step 2: Add adversarial-review-log.md to inputs**

After line 24 (`- review-report.md`), add:

```markdown
- `adversarial-review-log.md`
```

- [ ] **Step 3: Commit**

```bash
git add skills/spec-plan-handoff/SKILL.md
git commit -m "feat: require adversarial_status=converged in plan-handoff gate"
```

---

### Task 8: Create the `spec-adversarial-review` Skill

**Files:**
- Create: `skills/spec-adversarial-review/SKILL.md`

- [ ] **Step 1: Write the full SKILL.md**

Create `skills/spec-adversarial-review/SKILL.md` with this content:

```markdown
---
name: spec-adversarial-review
description: "Stress-test a subject spec for ambiguity, gaps, contradictions, and untestable claims using dynamic agent teams. Use this when the spec has passed completeness and synthesis-review gates and needs adversarial validation before readiness promotion."
allowed-tools: Read, Write, Edit, Glob, Grep, Agent
---

Use this after `spec-synthesis-review` passes and the orchestrator's scoring
gates are met. Do not use this before `blocker_reasons` is empty and
`completeness_score >= 80` and `evidence_confidence_score >= 80`.

## Purpose

Find every remaining gap that could force an engineer to make a judgment call
the spec should have made for them. The full adversarial attack surface:
ambiguity, missing failure modes, contradictions between sections, unstated
dependencies, scalability gaps, security blind spots, untestable claims.

## Agent team allocation

Use agent teams (`TeamCreate`) as the primary organizing mechanism. The team
persists across all rounds for context continuity.

### Section agents (depth)

One per substantive spec area. Allocate dynamically by reading the completeness
matrix. A simple spec gets 3-4 agents, a complex one 8-10.

Candidate roles (allocate only those with substantive spec content):
- core flows agent
- entity and state transitions agent
- interfaces and integrations agent
- constraints and failure modes agent
- security boundaries agent
- acceptance criteria agent
- data model agent
- migration and rollback agent

### Cross-cutting agents (coherence)

Always allocate these regardless of spec size:
- **literal implementer** — "If I read this spec with zero context and built
  exactly what it says, what would go wrong?"
- **QA adversary** — "What claims are untestable? What edge cases have no
  defined behavior?"
- **consistency checker** — "Where does section X contradict or assume
  something incompatible with section Y?"

## Round structure

Each round:
1. all agents read the current spec independently
2. section agents probe their area for: ambiguous language, missing failure
   modes, unstated assumptions, vague constraints, gaps an engineer would have
   to fill with judgment
3. cross-cutting agents probe for: inter-section contradictions, untestable
   claims, unstated dependencies, things that work on paper but break in
   practice
4. each agent researches the codebase before filing a finding — if the answer
   is in the code, it is a resolution, not a finding
5. findings are collected, deduplicated, and classified:
   - **critical** — multiple valid interpretations of a core behavior, missing
     failure mode that changes architecture → escalate to user
   - **high** — ambiguous constraint, unclear boundary, missing edge case with
     non-obvious answer → escalate to user
   - **resolvable** — answer is unambiguous from codebase or context →
     auto-resolve, log decision, flag for user visibility
6. user answers escalated findings
7. the orchestrator (as lead agent and sole reducer) applies all resolutions to
   the spec — this skill emits structured resolution proposals, it does not
   write canon directly
8. next round begins on the updated spec

## Convergence

- **minimum**: 2 rounds if round 1 produces findings. If round 1 produces zero
  material findings from all agents, 1 round is sufficient.
- **maximum**: 5 rounds (safety cap)
- **exit**: a round where ALL agents — section and cross-cutting — independently
  report zero material findings
- **bias**: toward running another round if any agent is uncertain. The cap is a
  safety valve, not a target.
- **"material" defined broadly**: anything that could cause an engineer to make
  a judgment call the spec should have made for them

## Cap behavior

Hitting the cap (5 rounds without convergence) is NOT an acceptable exit. It
triggers a decomposition signal:
- emit `adversarial_status = decomposition_required` as structured input to
  the orchestrator
- emit `decomposition-proposal.md` identifying natural seams, tangled concerns,
  and 2-3 suggested sub-specs with boundaries
- emit `sub-spec-brief-<name>.md` per suggested sub-spec containing:
  - extracted evidence relevant to that sub-spec
  - scope and boundaries (in and out)
  - constraints inherited from the parent spec
  - dependencies on other sub-specs (if any)
  - enough context for a fresh session to run `spec-intake` without losing
    information
- the decomposition proposal must identify dependency edges between sub-specs
- the user decides per sub-spec: run now (sequential), run in parallel via
  agent teams (for independent sub-specs), or save for later (self-contained
  brief for a new session)

## Back-transitions

When escalating back to earlier pipeline stages:
- emit `adversarial-escalation.json` listing: finding IDs, affected sections,
  blocker reason if reopened
- the orchestrator passes this to `spec-loop` so the re-entry round is targeted
  to the specific findings, not a generic pass

## Finding structure

Each finding must include:
- `finding_id` — stable identifier
- `round` — which adversarial round
- `agent_role` — which agent filed it
- `severity` — critical, high, or resolvable
- `spec_section` — which section of the subject spec
- `description` — what the problem is
- `evidence` — what the agent observed (spec text, codebase evidence, or both)
- `resolution` — how it was resolved (user answer, codebase research, or
  pending)
- `resolution_source` — user, codebase, or auto

## Outputs

Emit as structured input to the orchestrator (do not write these directly):
- `adversarial-review-log.md` — all findings across all rounds with resolutions
  and provenance
- `adversarial-round-N.json` — structured findings per round
- resolution proposals for `specs/<subject>.md`
- structured adversarial fields for `manifest.json`:
  - `adversarial_rounds_completed`
  - `adversarial_status` (`converged` | `decomposition_required`)
  - `adversarial_findings_total`
  - `adversarial_findings_resolved_by_research`
  - `adversarial_findings_resolved_by_user`

On decomposition:
- `decomposition-proposal.md`
- `sub-spec-brief-<name>.md` (one per suggested sub-spec)
- `adversarial-escalation.json` (on back-transition)

## Hard rules

1. This skill does not write canon. It emits proposals. The orchestrator
   reduces.
2. Research the codebase before filing any finding. If the answer is there, it
   is a resolution, not a finding.
3. Zero material findings means zero. "Probably fine" is not zero.
4. The cap is a decomposition signal, not an acceptable exit.
5. `adversarial_status` has exactly two values: `converged` or
   `decomposition_required`. No middle ground.
6. Agent teams are the required organizing mechanism. Do not use ad-hoc agent
   spawning.
```

- [ ] **Step 2: Verify the file exists and parses**

Run: `head -5 skills/spec-adversarial-review/SKILL.md`
Expected: the YAML frontmatter with `name: spec-adversarial-review`

- [ ] **Step 3: Commit**

```bash
git add skills/spec-adversarial-review/SKILL.md
git commit -m "feat: create spec-adversarial-review skill"
```

---

### Task 9: Update README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add ADVERSARIAL_REVIEW to the planning states**

In the canonical readiness model section, add `ADVERSARIAL_REVIEW` between `SPECULATIVE_DRAFT` and `PLANNING_READY`.

- [ ] **Step 2: Update the repo layout**

Add `spec-adversarial-review/` to the skills list in the repo layout code block.

- [ ] **Step 3: Update skill count and list**

Change "6 skills" to "7 skills" and add `spec-adversarial-review` to the bullet list.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add adversarial review to README"
```

---

### Task 10: Update Smoke Test

**Files:**
- Modify: `scripts/smoke-test.sh`

- [ ] **Step 1: Add spec-adversarial-review to the skill loop**

In `scripts/smoke-test.sh`, add `spec-adversarial-review` to the skill list in the `for` loop (after `spec-synthesis-review`):

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

- [ ] **Step 2: Run the smoke test**

Run: `./scripts/smoke-test.sh`
Expected: `[trace-smoke] smoke test ok`

- [ ] **Step 3: Commit**

```bash
git add scripts/smoke-test.sh
git commit -m "test: add spec-adversarial-review to smoke test"
```

---

### Task 11: Validation Pass

**Files:** None (read-only verification)

- [ ] **Step 1: Run the full smoke test**

Run: `./scripts/smoke-test.sh`
Expected: `[trace-smoke] smoke test ok`

- [ ] **Step 2: Verify all 7 skills exist**

Run: `ls skills/*/SKILL.md | wc -l`
Expected: `7`

- [ ] **Step 3: Verify ADVERSARIAL_REVIEW appears in all required files**

Run: `grep -rl 'ADVERSARIAL_REVIEW' skills/`
Expected: at least `trace-orchestrator/SKILL.md`

Run: `grep -l 'adversarial_status' skills/`
Expected: `spec-adversarial-review/SKILL.md`, `spec-plan-handoff/SKILL.md`

Run: `grep -l 'adversarial-escalation' skills/`
Expected: `trace-orchestrator/SKILL.md`, `spec-loop/SKILL.md`, `spec-adversarial-review/SKILL.md`

- [ ] **Step 4: Verify sub-signal mapping is in spec-completeness**

Run: `grep 'Sub-signal' skills/spec-completeness/SKILL.md`
Expected: match on the sub-signal requirements header

- [ ] **Step 5: Verify the design spec matches implementation**

Cross-check:
- State machine has 5 planning states ✓
- Manifest has 20 fields ✓
- Sub-skill order has 6 entries ✓
- Run phases has 10 entries ✓
- Smoke test checks 7 skills ✓
