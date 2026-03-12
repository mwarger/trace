---
subject: analytics-module
canonical_version: v0.4
status: draft
readiness: not-ready
updated_at: 2026-03-12
keywords:
  - analytics
  - telemetry
  - events
  - funnels
  - reporting
  - ingestion
artifact_path: specs/_artifacts/analytics-module
---

# Analytics Module

## Overview

Subject spec for an internal analytics module that captures product events,
stores normalized telemetry, and exposes reporting views.

## Purpose

Give product and ops teams a consistent event stream and pre-aggregated
metrics without every consumer re-deriving business events from raw logs.

## Goals

- Accept client and server events through one ingestion contract.
- Normalize events before storage.
- Support funnel, trend, and retention reporting.

## Non-Goals

- Ad hoc BI query authoring.
- End-user dashboard theming.

## Scope and Boundaries

In scope:
- ingestion API
- normalization rules
- event identity and dedupe
- reporting views

Out of scope:
- warehouse export jobs
- billing-specific retention policy decisions

## Intake Summary

Started from medium-density evidence: architecture notes, event examples,
report mockups, and a short owner statement about reporting goals.

## Canonical Decisions

- Canon uses normalized event envelopes before persistence.
- Funnel reporting is derived from canonical event names, not raw client names.
- Client retries must be deduped by event id plus short replay window.

## Core Model

The module is an event pipeline with 3 stages: ingest, normalize, aggregate.
The current blind spot is retention policy, which affects long-window reports.

## Evidence Model

Accepted evidence types:
- owner statements
- API sketches
- UI/report screenshots
- architecture notes
- follow-up answers

Claims promoted into canon must map to claim ids in the sidecar claim ledger.

## Architecture or Structure

- ingestion endpoint receives event envelopes
- normalizer validates schema and canonical event naming
- storage layer persists normalized events
- aggregate jobs build report-friendly tables
- reporting layer serves funnel and trend views

## Core Entities / Types / Interfaces

- `EventEnvelope`
  `event_id`, `actor_id`, `event_name`, `occurred_at`, `properties`
- `NormalizedEvent`
  canonical event with validated dimensions
- `ReportQuery`
  time window, cohort filters, metric type

## Behavior and Flows

1. Client or backend emits event.
2. Ingestion validates the envelope.
3. Normalizer maps it to canonical naming.
4. Duplicate replays are collapsed.
5. Aggregates update reporting tables.
6. Reports read aggregates, not raw event streams.

## Failure Modes and Edge Cases

- invalid schema rejects event with structured error
- duplicate event ids collapse into one canonical event
- unknown event names are quarantined, not silently stored
- late-arriving events may miss near-real-time reports until recompute

## Acceptance Criteria

- canonical event names are enforced at ingest time
- duplicate retries do not inflate funnel counts
- report queries return consistent counts for the same window
- quarantine path exists for invalid or unknown events

## Open Questions

- exact retention window for raw and aggregated events
- whether cross-device identity stitching is v1 or later

## Assumptions

- retention policy will be set per workspace tier
- identity stitching is deferred from v1

## Completeness Status

- `completeness_score`: 83
- `evidence_confidence_score`: 82
- `decision_risk_score`: 31
- blocker dimensions at `3+`
- one blocker remains operationally open: retention policy

## Planning Readiness

Not Ready.
Core behavior and interfaces are stable enough to keep studying, but
long-window storage and recompute work would still be speculative until
retention is set.

## References

- [`_artifacts/analytics-module/input-log.md`](_artifacts/analytics-module/input-log.md)
- [`_artifacts/analytics-module/completeness-matrix.md`](_artifacts/analytics-module/completeness-matrix.md)
- [`_artifacts/analytics-module/claim-ledger.jsonl`](_artifacts/analytics-module/claim-ledger.jsonl)
- [`_artifacts/analytics-module/decision-log.md`](_artifacts/analytics-module/decision-log.md)
- [`_artifacts/analytics-module/review-report.md`](_artifacts/analytics-module/review-report.md)
