---
name: spec-intake
description: "Normalize all starting evidence into a subject spec run. Use this when beginning a Trace spec from code, docs, transcripts, screenshots, URLs, or a sparse user request. Creates the subject slug, frontmatter, evidence ledger, and intake summary."
---

Use this skill first.

## Goal

Turn raw inputs into a normalized evidence run with:
- a subject slug
- a canonical spec path
- a root specs index path
- seeded frontmatter
- initial evidence records
- intake summary

## Steps

1. Derive the subject slug from the thing being studied or developed.
2. Ensure `specs/README.md` exists.
3. If `specs/README.md` is missing, create it with:
   - a short title
   - a one-line description of the specs tree
   - an optional notes section
   - a managed block delimited by:
     - `<!-- trace:spec-index:start -->`
     - `<!-- trace:spec-index:end -->`
4. If `specs/README.md` exists but the managed block is missing, add the
   managed block without deleting human prose outside it.
5. Create `specs/<subject>.md`.
6. Create `specs/_artifacts/<subject>/`.
7. Classify every input as:
   - `repo`
   - `doc`
   - `transcript`
   - `ui`
   - `user_statement`
   - `answer`
   - `observation`
8. For each input, create an `evidence_unit` record with:
   - `id`
   - `source_type`
   - `source_ref`
   - `directness`
   - `authority`
   - `freshness`
   - `independence_group`
   - `extraction_method`
9. Seed the spec with:
   - `Overview`
   - `Intake Summary`
   - `Evidence Model`
10. Seed sidecars:
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
- The root `specs/README.md` is navigational.
- The subject spec is the implementation handoff artifact.
