---
name: trace-orchestrator
description: "Create a subject-named specification from any evidence source using a reducer-based Trace workflow. Use this when the user wants a planning-ready spec, a clean-room reverse spec, or an evidence-first feature spec with sub-agent fanout, provenance tracking, contradiction handling, and 80/80 readiness gates."
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
5. Use the runtime's native question tool whenever user input is needed.
6. No spec is planning-ready unless:
   - `completeness_score >= 80`
   - `evidence_confidence_score >= 80`
   - blocker dimensions are at least `3`
   - contradictions are resolved

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

Ask the user only when the gap is planning-relevant and passive evidence is
exhausted or lower value.

Every question must map to:
- one ontology dimension
- one ambiguity
- one reason it matters

Use the runtime's native question tool whenever available.
Batch the smallest independent unblocker set, default max `3`.

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
