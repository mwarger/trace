---
name: spec-loop
description: "Run the evidence-first marginalia loop for a subject spec. Use this when you need to process evidence one unit at a time, produce unit summaries, rewrite the rolling summary, branch out to sub-agents for bounded exploration, and decide whether to read more, ask, or mark an assumption."
---

Use this after intake and whenever more evidence work is needed.

## Core loop

For each evidence unit:
1. write a one-sentence `unit summary`
2. rewrite the one-sentence `rolling summary`
3. update claims and provenance links
4. choose the next action:
   - `Read More`
   - `Ask`
   - `Mark Assumption`

## Hard rules

- Never append to the rolling summary mechanically. Rewrite it.
- Every canonical claim must point back to claim ids and evidence unit ids.
- If the evidence source is large, spawn sub-agents per independent area.
- Sub-agents return typed patch proposals only.

## When to ask

Ask only if:
- passive evidence is exhausted, ambiguous, or lower value
- the ambiguity blocks planning or blocker coverage

Use the runtime's native question tool whenever available.
Record answers as new `evidence_unit` records.

## Required outputs

Update:
- `spec-ledger.md`
- `question-backlog.md`
- `evidence-ledger.jsonl`
- `claim-ledger.jsonl`
- the `Core Model`, `Behavior and Flows`, and `Open Questions` sections

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
