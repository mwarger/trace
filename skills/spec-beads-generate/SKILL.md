---
name: spec-beads-generate
description: "Decompose an implementation plan into br beads with dependency wiring, epic grouping, and provenance labels. Use this after spec-plan-handoff when the user accepts the beads generation prompt."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Use this only after `spec-plan-handoff` has emitted `implementation-plan.md`
and the user has accepted the beads generation prompt.

## Purpose

Decompose `implementation-plan.md` into a set of beads with full provenance
back to the spec. This skill is the advocate — it makes the best decomposition
it can and hands it to the adversarial team (`spec-beads-review`).

## Preconditions

- `planning_status = PLANNING_READY`
- `handoff_status = ELIGIBLE`
- `adversarial_status = converged`
- `implementation-plan.md` exists in `specs/_artifacts/<subject>/`
- user accepted the beads generation prompt

## Behavior

1. locate the git repository root via `git rev-parse --show-toplevel`
2. if `.beads` exists at the git root, use it — do not re-init
3. if `.beads` does not exist, run `br init` at the git root
4. create an epic for the spec subject:
   `br create --type epic --title "<subject>" --labels "trace:<subject-slug>"`
5. read each workstream from `implementation-plan.md` and create beads:
   - one bead per discrete work unit within a workstream
   - `br create --title "..." --type task --parent <epic-id> --labels "trace:<subject-slug>" --description "..."`
   - description includes: what to do, acceptance criteria, which spec claims
     this bead covers
6. wire dependencies from the implementation plan's dependency graph:
   `br dep add <bead-id> <depends-on-id>`
7. emit `beads-manifest.json` to `specs/_artifacts/<subject>/`

## Provenance contract

Every spec claim and acceptance criterion must appear in at least one bead's
description. The manifest tracks this mapping explicitly so the review phase
can verify coverage.

## `beads-manifest.json` schema

```json
{
  "subject": "<subject-slug>",
  "epic_id": "<br epic ID>",
  "workspace_path": "<git root>/.beads",
  "beads": [
    {
      "bead_id": "<br issue ID>",
      "title": "<bead title>",
      "workstream": "<workstream name from implementation plan>",
      "spec_claims": ["<claim IDs from claim-ledger.jsonl>"],
      "acceptance_criteria": ["<AC IDs from spec>"],
      "dependencies": ["<bead IDs this depends on>"],
      "test_first": "yes | no | n/a",
      "test_sketches": [
        {
          "type": "unit | property | integration | contract | e2e",
          "description": "<pseudocode test scenario>"
        }
      ]
    }
  ],
  "unmapped_claims": ["<claim IDs not yet traced to any bead>"],
  "unmapped_acceptance_criteria": ["<AC IDs not yet traced to any bead>"]
}
```

`unmapped_claims` and `unmapped_acceptance_criteria` start populated after
generation and must be empty after `spec-beads-review` converges. The coverage
agent uses these arrays as its primary attack surface.

## Outputs

Emit as structured input to the orchestrator:
- `beads-manifest.json`
- structured beads fields for `manifest.json`:
  - `beads_generated = true`
  - `beads_epic_id`
  - `beads_total`
  - `beads_workspace_path`

## Quality gates and cross-cutting concerns

Do not create standalone beads for cross-cutting concerns like quality gates,
CI configuration, env var documentation, or linting setup. These are not
discrete work units — they apply across the entire epic.

Instead:
- embed quality gate criteria in the epic description
- distribute cross-cutting acceptance criteria across the beads they apply to
  (e.g., "all public functions have typespecs" goes on every bead that creates
  public functions)
- if a spec claim is purely cross-cutting (e.g., "all endpoints require auth"),
  map it to every bead whose work it constrains rather than creating a
  catch-all bead

The review phase's granularity agent will flag any bead that is just a
collection of unrelated cross-cutting checks.

## Hard rules

1. This skill does not evaluate quality. That is the review phase's job.
2. Every spec claim must map to at least one bead. If a claim cannot be
   decomposed into a discrete work unit, flag it and include it anyway — the
   review phase will address granularity.
3. Use `br` CLI commands for all bead operations. Do not write to the `.beads`
   directory directly.
4. Do not re-init an existing `.beads` workspace.
5. Epic and label provenance are required for every bead.
6. Do not create standalone beads for cross-cutting concerns — see
   "Quality gates and cross-cutting concerns" above.
