---
name: spec-synthesis-review
description: "Reduce typed sub-agent outputs into canon and verify the subject spec before readiness promotion. Use this when you need deterministic merges, provenance review, contradiction handling, verification loops, section drafting, or final review passes across the spec."
---

Use this after a scoring pass or when draft sections need promotion into canon.

## Reducer rules

- The lead agent is the only reducer.
- Apply sub-agent results only when `parent_revision` matches canon.
- If the result is stale, rebase, revalidate, or discard.

Merge order:
1. evidence / claims
2. contradictions
3. ontology rescore
4. section patch
5. readiness gate

## Required review passes

1. completeness review
2. contradiction review
3. provenance review
4. implementability review

## Verification loop

Before readiness promotion, run:
- completeness check against requested deliverables
- grounding check from canonical text to claim ids
- empty-result recovery for suspiciously thin evidence
- section/schema format check
- missing-context gate
- action-safety gate for mutation or publication steps

If any check fails, return to:
- evidence gathering
- targeted questions
- contradiction review
- or redrafting

## Output

Update:
- `specs/<subject>.md`
- `review-report.md`
- `claim-ledger.jsonl`
- `contradiction-log.md`
- `decision-log.md`
- `branch-registry.json`
