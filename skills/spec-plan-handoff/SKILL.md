---
name: spec-plan-handoff
description: "Generate an implementation plan from a ready subject spec. Use this when the spec has passed verification and readiness gates and you need workstreams, dependencies, acceptance criteria, risks, and test scenarios without reopening raw intake."
---

Use this only after the spec is at least `Conditionally Ready`.

## Preconditions

Do not emit a real implementation plan if:
- `completeness_score < 80`
- `evidence_confidence_score < 80`
- blocker dimensions remain below `3`
- contradictions are unresolved

## Inputs

Read from canon and sidecars:
- `specs/<subject>.md`
- `decision-log.md`
- `completeness-matrix.md`
- `review-report.md`

Do not plan directly from raw intake chatter.

## Outputs

Create or update `implementation-plan.md` with:
- workstreams
- dependencies
- acceptance criteria
- test scenarios
- top risks
- explicit excluded work

If the spec is blocked, write a withheld handoff note instead of a real plan.
