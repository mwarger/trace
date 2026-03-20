---
name: trace-orchestrator
description: "Create a subject-named specification from any evidence source using a reducer-based Trace workflow. Use this when the user wants a planning-ready spec, a clean-room reverse spec, or an evidence-first feature spec with sub-agent fanout, provenance tracking, adaptive clarification, speculative variants, and a canonical readiness contract."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---

Use this as the top-level skill for the pack.

The main session is the only reducer of canon.
Sub-agents may read canon and return typed patch proposals, but they may not
write `specs/<subject>.md` directly.

## When to use

Trigger when the user wants to:
- create a spec from code, docs, transcripts, screenshots, or a repo
- create a spec from a sparse feature description
- reconcile multiple evidence sources into one planning-ready subject doc
- keep implementation from inventing missing decisions

## Hard rules

1. Everything begins as evidence. A one-line feature request is evidence.
2. Nothing becomes canon without provenance.
3. The lead agent is the only reducer.
4. Use sub-agents by default for bounded read-heavy work.
5. Ask the user directly when user input is needed.
6. `trace-orchestrator` owns the canonical readiness verdict.
7. No run is planning-ready if blocker reasons remain open.
8. Scores matter only after blocker reasons are cleared.
9. A `sparse` `analogy_feature` or `parity_clone` run with
   `question_rounds_completed = 0` may never end in `PLANNING_READY`.
10. In that case, `handoff_status` must remain `WITHHELD` even if the draft is
    coherent.

## Canonical readiness contract

Every run must carry these canonical fields in `manifest.json` and
`run-state.json`:
- `policy_version`
- `request_archetype`
- `starting_evidence_density`
- `source_origin_keys`
- `planning_status`
- `handoff_status`
- `blocker_reasons`
- `critical_decision_coverage`
- `question_rounds_completed`
- `required_clarifications_remaining`
- `assumption_load`
- `assumption_risk_score`
- `unconfirmed_product_decisions`
- `acceptance_scenarios_present`
- `corroboration_score`

`trace-orchestrator` is the only skill allowed to finalize:
- `planning_status`
- `handoff_status`
- `blocker_reasons`

Other skills emit structured inputs to that verdict.

## Planning state machine

Use these states:
- `planning_status`
  - `DISCOVERY`
  - `AWAITING_CLARIFICATION`
  - `SPECULATIVE_DRAFT`
  - `ADVERSARIAL_REVIEW`
  - `PLANNING_READY`
- `handoff_status`
  - `WITHHELD`
  - `ELIGIBLE`

Transitions:
- unresolved blocker reasons prevent `PLANNING_READY`
- unanswered required clarifications force `AWAITING_CLARIFICATION`
- bounded speculative variants while blockers remain force
  `SPECULATIVE_DRAFT`
- `handoff_status=ELIGIBLE` only when `planning_status=PLANNING_READY`
- do not emit a real implementation handoff while `handoff_status=WITHHELD`
- `sparse` `analogy_feature` or `parity_clone` plus zero question rounds must
  resolve to `AWAITING_CLARIFICATION` or `SPECULATIVE_DRAFT`, never
  `PLANNING_READY`
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

## Canonical merge protocol

Every sub-agent result must include:
- `branch_id`
- `parent_revision`
- `touched_sections[]`
- `proposed_changes[]`
- `confidence_notes`

Apply results only if `parent_revision` matches canon.
If canon advanced, rebase, revalidate, or discard.

Merge order:
1. evidence / claim ingestion
2. contradiction update
3. ontology rescore
4. section patch application
5. readiness gate

## Run phases

Treat the workflow as a persisted state machine:
1. `INTAKE`
2. `EVIDENCE_FANOUT`
3. `REDUCE_AND_MERGE`
4. `GAP_ANALYSIS`
5. `USER_INPUT`
6. `DRAFT`
7. `VERIFY`
8. `READINESS_GATE`
9. `PUBLISH`

Each phase needs entry criteria, exit criteria, and a checkpoint artifact in
`specs/_artifacts/<subject>/run-state.json`.

## Required sub-skill order

1. `spec-intake`
2. `spec-loop`
3. `spec-completeness`
4. `spec-synthesis-review`
5. `spec-plan-handoff`

Loop back to `spec-loop` or `spec-completeness` whenever verification fails or
blockers remain.

## Delegation policy

Default sub-agent roles:
- `evidence-explorer`
- `question-generator`
- `contradiction-reviewer`
- `completeness-reviewer`
- `provenance-reviewer`
- `spec-section-drafter`
- `implementability-reviewer`
- `artifact-curator`

Use the runtime's agent or subprocess mechanism for delegation (Agent tool in
Claude Code, sub-agents in Codex).

Delegate when work is:
- parallelizable
- read-heavy
- review-oriented
- locally scoped
- compressible to a short typed result

Keep work local when it changes canon, readiness, or user interaction policy.

## Tool policy

- Give each role the minimum viable tool allowlist.
- Read-only reviewers do not get write tools.
- Normalize untrusted external text into validated fields before it influences
  canon.
- Destructive or publication-adjacent actions require approval when the runtime
  supports it.

## Question policy

Ask the user when critical decision coverage is incomplete and passive evidence
is exhausted or lower value.

Every question must map to:
- one critical decision bucket or blocker dimension
- one ambiguity
- one reason it matters

Ask the user directly when available.
Batch the smallest independent unblocker set, default max `3`.
Offer a recommended default pack when a full answer can be approved quickly.

## Request archetypes

Classify every run into one of:
- `feature`
- `analogy_feature`
- `parity_clone`
- `integration`
- `bugfix`
- `migration`
- `refactor`
- `reverse_spec`

Analogy-driven prompts such as "like X" or "replicate X" default to
`analogy_feature` unless strong contrary evidence exists.

## Critical decision buckets

These buckets drive readiness:
- `core_outcome`
- `scope_boundary`
- `implementation_constraints`
- `dependencies_and_integrations`
- `acceptance_signal`

Evidence density is a routing hint, not the sole readiness gate.
A single explicit prompt may be enough if it closes these buckets without
relying on unconfirmed assumptions.
Analogy-driven sparse prompts do not get that exception by default.

## Artifacts

Root index:
- `specs/README.md`

Canonical spec:
- `specs/<subject>.md`

Sidecars:
- `manifest.json`
- `run-state.json`
- `branch-registry.json`
- `evidence-ledger.jsonl`
- `claim-ledger.jsonl`
- `input-log.md`
- `spec-ledger.md`
- `question-backlog.md`
- `completeness-matrix.md`
- `contradiction-log.md`
- `decision-log.md`
- `review-report.md`
- `implementation-plan.md`

## Root specs index

Every successful Trace run must leave behind a root `specs/README.md`.

Rules:
- if `specs/README.md` is missing, create it before or alongside the subject spec
- if it exists, preserve human-written prose outside the managed block
- update only the managed block for subject rows
- do not duplicate rows for the same subject; update the existing row

Managed block markers:
- `<!-- trace:spec-index:start -->`
- `<!-- trace:spec-index:end -->`

The root index is for discovery and navigation.
The subject spec is the backing artifact to hand to an external implementation
loop or another agent.
