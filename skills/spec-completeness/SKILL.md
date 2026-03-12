---
name: spec-completeness
description: "Score a subject spec against the ontology and readiness gates. Use this when you need blocker-aware completeness scoring, evidence-confidence scoring, decision-risk scoring, contradiction penalties, next-action selection, or the Ouroboros-style 80/80 planning gate."
---

Use this whenever canon changes materially.

## Ontology

Track these dimensions:
- purpose and success criteria
- actors
- boundaries
- core flows
- entities
- state transitions
- interfaces
- constraints
- failure modes
- non-goals
- assumptions
- acceptance criteria

For each dimension track:
- `coverage`
- `confidence`
- `evidence_count`
- `independent_evidence_count`
- `weighted_support`
- `contradiction_count`
- `planning_blocker`

## Scores

Compute:
- `completeness_score`
- `evidence_confidence_score`
- `decision_risk_score`

Rules:
- blocker dimensions weigh more
- duplicate evidence should not inflate support
- unresolved assumptions cap the affected dimension
- contradictions reduce confidence and readiness

## Gates

`Not Ready` if:
- `completeness_score < 80`
- or `evidence_confidence_score < 80`
- or any blocker dimension below `3`
- or contradictions remain unresolved

`Conditionally Ready` if:
- completeness and evidence confidence are `>= 80`
- blocker dimensions are `>= 3`
- assumptions are explicit

`Ready` if:
- completeness and evidence confidence are `>= 90`
- blocker dimensions are `>= 4`
- contradictions are closed
- acceptance criteria are implementation-usable
- decision risk is below cap

Every scoring pass must emit:
- `why_not_ready[]`
- `blocker_dimensions[]`
- `minimum_next_actions[]`

## Output

Update:
- `completeness-matrix.md`
- `manifest.json`
- `specs/<subject>.md` under `Completeness Status` and `Planning Readiness`
