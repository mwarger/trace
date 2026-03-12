# Marginalia Spec Pack

Standalone skill pack for building subject-named specs from evidence.

The pack is built around 5 ideas:
- everything starts as evidence
- the lead agent is the only reducer of canon
- sub-agents do most bounded exploration and review work
- provenance is required before text becomes canonical
- no spec is planning-ready below the 80/80 gate

## Layout

```text
skills/
  marginalia-spec-orchestrator/
  spec-intake/
  spec-loop/
  spec-completeness/
  spec-synthesis-review/
  spec-plan-handoff/
specs/
  README.md
  analytics-module.md
  feature-flags-system.md
  auth-session-system.md
  _artifacts/
```

## Skills

- `marginalia-spec-orchestrator`
  Top-level reducer workflow. Routes work to sub-skills, enforces merge rules,
  user-question rules, and readiness gates.
- `spec-intake`
  Normalizes evidence, creates subject slug, seeds canon and ledgers.
- `spec-loop`
  Runs the paragraph-style evidence loop: unit summary, rolling summary, next
  action.
- `spec-completeness`
  Scores ontology coverage, contradictions, and readiness.
- `spec-synthesis-review`
  Merges typed patches into canon, runs provenance and verification passes.
- `spec-plan-handoff`
  Emits implementation plan only from a ready spec.

## Example corpus

The `specs/` tree shows 3 worked examples:
- `analytics-module.md`
- `feature-flags-system.md`
- `auth-session-system.md`

Each subject spec has a sidecar folder under `specs/_artifacts/<subject>/`
containing run state, evidence ledgers, contradiction logs, decision logs,
claim ledgers, reviews, and plan handoff artifacts.

## Usage

Use the orchestrator skill when the user wants to:
- reverse engineer an existing system into a clean spec
- turn sparse evidence into a planning-ready spec
- produce a reducer-safe, provenance-backed subject spec

The workflow is:
1. intake evidence
2. fan out bounded sub-agent exploration
3. reduce typed patches into canon
4. rescore ontology and readiness
5. ask targeted user questions only when passive evidence is weaker
6. verify grounding before promoting readiness
7. emit planning artifacts only after the 80/80 gate passes
