---
name: spec-intake
description: "Normalize all starting evidence into a subject spec run. Use this when beginning a Trace spec from code, docs, transcripts, screenshots, URLs, or a sparse user request. Creates the subject slug, frontmatter, evidence ledger, and intake summary."
---

Use this skill first.

## Goal

Turn raw inputs into a normalized evidence run with:
- a subject slug
- a canonical spec path
- seeded frontmatter
- initial evidence records
- intake summary

## Steps

1. Derive the subject slug from the thing being studied or developed.
2. Create `specs/<subject>.md`.
3. Create `specs/_artifacts/<subject>/`.
4. Classify every input as:
   - `repo`
   - `doc`
   - `transcript`
   - `ui`
   - `user_statement`
   - `answer`
   - `observation`
5. For each input, create an `evidence_unit` record with:
   - `id`
   - `source_type`
   - `source_ref`
   - `directness`
   - `authority`
   - `freshness`
   - `independence_group`
   - `extraction_method`
6. Seed the spec with:
   - `Overview`
   - `Intake Summary`
   - `Evidence Model`
7. Seed sidecars:
   - `manifest.json`
   - `run-state.json`
   - `branch-registry.json`
   - `input-log.md`
   - `evidence-ledger.jsonl`
   - `claim-ledger.jsonl`

## Output rules

- `Intake Summary` stays short.
- Detailed intake history stays in sidecars.
- A one-line feature request is still enough to start a run.
- If the source is large, spawn sub-agents to catalog source areas before the
  main loop starts.
