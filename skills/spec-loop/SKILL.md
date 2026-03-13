---
name: spec-loop
description: "Run the evidence-first Trace loop for a subject spec. Use this when you need to process evidence one unit at a time, produce unit summaries, rewrite the rolling summary, branch out to sub-agents for bounded exploration, choose adaptive clarification profiles, and emit speculative variants when blockers remain."
---

Use this after intake and whenever more evidence work is needed.

## Core loop

For each evidence unit:
1. write a one-sentence `unit summary`
2. rewrite the one-sentence `rolling summary`
3. update claims and provenance links
4. update critical decision coverage and blocker state
5. choose the next action:
   - `Read More`
   - `Ask`
   - `Mark Assumption`

## Hard rules

- Never append to the rolling summary mechanically. Rewrite it.
- Every canonical claim must be traceable through sidecar claim ids and
  evidence unit ids.
- If the evidence source is large, spawn sub-agents per independent area.
- Sub-agents return typed patch proposals only.
- No major canon claim may exist without `evidence_refs` or an explicit
  assumption id.
- Analogy prompts are ambiguity-heavy by default.
- `question_rounds_completed = 0` on a `sparse` `analogy_feature` or
  `parity_clone` run means required clarification buckets are still open unless
  the user explicitly approved a recommended default pack.

## Clarification policy

First classify or reuse `request_archetype`.

Use these clarification profiles:

- `feature`, `analogy_feature`, `parity_clone`
  - `core_outcome`
  - `scope_boundary`
  - `implementation_constraints`
  - `acceptance_signal`
- `bugfix`
  - reproduction
  - expected behavior
  - environment/version boundary
- `integration`
  - external system boundary
  - auth/data ownership
  - failure/retry expectations
- `migration`
  - source/target boundary
  - compatibility window
  - rollback expectation

Ask only if:
- passive evidence is exhausted, ambiguous, or lower value
- the ambiguity blocks critical decision coverage or blocker closure

Use the runtime's native question tool whenever available.
Ask one batch at a time, max `3`, with recommended options first.
Allow a recommended default pack when the user can approve defaults in one
reply.
Record answers as new `evidence_unit` records.

For `sparse` `analogy_feature` or `parity_clone` runs:
- seed required clarification ids before drafting:
  - `rq-core-outcome`
  - `rq-scope-boundary`
  - `rq-implementation-constraints`
  - `rq-acceptance-signal`
- do not mark those buckets `covered` from analogy alone
- if the user does not answer, keep the run in
  `AWAITING_CLARIFICATION` or `SPECULATIVE_DRAFT`

## Speculative mode

If required clarifications remain unresolved:
- do not collapse uncertainty into one canonized solution shape
- emit `2-3` bounded variants instead of one settled handoff path
- each variant must list:
  - included scope
  - excluded scope
  - unresolved decisions
  - tradeoffs
  - risk notes
- set `planning_status=SPECULATIVE_DRAFT`
- keep `handoff_status=WITHHELD`
- do not emit one canonized “best guess” subject spec as if it were final

## Required outputs

Update:
- `spec-ledger.md`
- `question-backlog.md`
- `evidence-ledger.jsonl`
- `claim-ledger.jsonl`
- the `Core Model`, `Behavior and Flows`, and `Open Questions` sections

`question-backlog.md` must always split:
- `Required Clarifications`
- `Deferred Questions`
- `Non-blocking Assumptions`

`No open planning-critical questions` is illegal for a `sparse`
`analogy_feature` or `parity_clone` run unless:
- each required clarification id is closed by evidence
- or answered by the user
- or explicitly approved through a recommended default pack

## Branching guidance

Good fanout targets:
- separate docs sections
- separate subsystems
- UI vs API behavior
- contradiction investigations

Bad fanout targets:
- tightly coupled edits to the same section
- final readiness decisions
- user interaction policy
