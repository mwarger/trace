# Skill Quality Rubric

Use this rubric for soft-judge evaluation of SKILL.md files.

Score each dimension 0-20. Total score is the sum (0-100).

## 1. Clarity (0-20)

Is the skill's purpose, scope, and behavior unambiguous?

- 0-5: Unclear what the skill does or when to use it. Description is vague.
- 6-10: Purpose is understandable but many behaviors are ambiguous. An
  agent would have to guess at intent.
- 11-15: Most behaviors are clear. A few edge cases or decision points
  are left ambiguous.
- 16-20: An agent could execute this skill without asking questions.
  Every decision point has explicit guidance.

## 2. Completeness (0-20)

Does the skill cover all aspects of its responsibility?

- 0-5: Major sections missing. Key behaviors undefined.
- 6-10: Core functionality covered but significant gaps in error handling,
  edge cases, or output contracts.
- 11-15: Most areas covered. A few gaps remain but the shape is clear.
- 16-20: Comprehensive. Hard to find missing areas. Error paths, edge
  cases, and output contracts are all addressed.

## 3. Internal consistency (0-20)

Are there contradictions within the skill or with cross-referenced skills?

- 0-5: Multiple contradictions. Rules conflict with each other.
- 6-10: A few contradictions or ambiguities between sections.
- 11-15: Mostly consistent. Minor terminology drift or rule overlap.
- 16-20: No contradictions found. Rules are coherent and non-overlapping.
  Cross-references to other skills are accurate.

## 4. Contract precision (0-20)

Are inputs, outputs, preconditions, and postconditions well-defined?

- 0-5: No clear contract. Inputs and outputs are implied, not stated.
- 6-10: Some contracts defined. Many outputs are vague ("update the
  manifest") without specifying structure or fields.
- 11-15: Most contracts are precise. A few outputs lack schema or
  field-level detail.
- 16-20: Every input has a source, every output has a schema or explicit
  format, preconditions are checkable, postconditions are verifiable.

## 5. Dependency wiring (0-20)

Are relationships to other skills correctly expressed?

- 0-5: References to other skills are missing or wrong. Execution order
  is unclear.
- 6-10: Some cross-references exist but are incomplete. Unclear what
  artifacts flow between skills.
- 11-15: Most dependencies are documented. A few artifact handoffs are
  implicit rather than explicit.
- 16-20: Every cross-skill reference is accurate. Artifact handoffs are
  explicit (file name, schema, direction). Execution order is clear.

## Scoring output

```json
{
  "score": <sum of all dimensions>,
  "dimensions": {
    "clarity": <0-20>,
    "completeness": <0-20>,
    "internal_consistency": <0-20>,
    "contract_precision": <0-20>,
    "dependency_wiring": <0-20>
  },
  "findings": [
    "<specific gap or issue — one per entry>"
  ],
  "strengths": [
    "<what the skill does well — one per entry>"
  ]
}
```
