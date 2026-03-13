---
subject: auth-session-system
canonical_version: v0.6
status: draft
readiness: ready
updated_at: 2026-03-12
keywords:
  - auth
  - session
  - cookies
  - refresh
  - revocation
  - device trust
artifact_path: specs/_artifacts/auth-session-system
policy_version: trace-readiness-v2
planning_status: PLANNING_READY
handoff_status: ELIGIBLE
---

# Auth Session System

## Overview

Subject spec for a session-based auth system with short-lived access state,
refresh rotation, revocation, and device tracking.

## Purpose

Provide secure, revocable authenticated sessions while keeping login and
re-auth flows predictable across browser and mobile clients.

## Goals

- stable login and refresh flows
- explicit revocation
- device/session visibility
- safe cookie behavior in browsers

## Non-Goals

- passwordless magic links
- enterprise SSO federation

## Scope and Boundaries

In scope:
- login session creation
- refresh rotation
- session revocation
- device trust records

Out of scope:
- MFA enrollment UX
- identity-provider federation

## Intake Summary

Started from dense mixed evidence: code snippets, auth docs, cookie policy
notes, and user clarifications. One major contradiction around refresh reuse
was resolved before readiness promotion.

## Canonical Decisions

- access state is short-lived and derived from active session
- refresh tokens rotate on successful use
- reused refresh tokens revoke the session family
- browser sessions use secure httpOnly cookies
- device trust records are visible and revocable per user

## Core Model

The system models auth as session families with one active refresh token chain.
Any token reuse indicates compromise or race and triggers family revocation.

## Evidence Model

Primary sources were code and auth notes, cross-checked with user answers on
desired revocation behavior and client constraints.

## Architecture or Structure

- login service issues session family and initial credentials
- refresh service validates and rotates tokens
- revocation service closes single sessions or session families
- session store tracks expiry, device metadata, and status
- client adapters apply browser or mobile transport rules

## Core Entities / Types / Interfaces

- `SessionFamily`
  user id, family id, status, created at
- `RefreshCredential`
  family id, version, expiry, last used at
- `DeviceRecord`
  device id, label, last seen at, trust state

## Behavior and Flows

1. User logs in and receives session family state.
2. Client uses access state until refresh is needed.
3. Refresh rotates credential and invalidates prior version.
4. Reuse detection revokes the family.
5. User or system may revoke sessions explicitly.

## Failure Modes and Edge Cases

- expired refresh returns re-auth required
- reused refresh revokes family and logs security event
- concurrent refresh race resolves by version check
- device metadata may lag but cannot silently keep revoked sessions alive

## Acceptance Criteria

- reused refresh credentials cannot mint new active session state
- explicit session revocation blocks future refresh
- browser cookies are secure and not script-readable
- users can see and revoke active devices

## Open Questions

- none blocking

## Assumptions

- mobile clients store refresh credentials in platform-secure storage
- session family revocation is acceptable UX for refresh reuse

## Completeness Status

- `completeness_score`: 93
- `evidence_confidence_score`: 91
- `decision_risk_score`: 16
- `corroboration_score`: 92
- `assumption_risk_score`: 6
- prior blocker on refresh reuse is resolved
- no unresolved blocker reasons

## Planning Readiness

Status: `PLANNING_READY`
Handoff: `ELIGIBLE`

## References

- [`_artifacts/auth-session-system/contradiction-log.md`](_artifacts/auth-session-system/contradiction-log.md)
- [`_artifacts/auth-session-system/decision-log.md`](_artifacts/auth-session-system/decision-log.md)
- [`_artifacts/auth-session-system/claim-ledger.jsonl`](_artifacts/auth-session-system/claim-ledger.jsonl)
- [`_artifacts/auth-session-system/review-report.md`](_artifacts/auth-session-system/review-report.md)
- [`_artifacts/auth-session-system/implementation-plan.md`](_artifacts/auth-session-system/implementation-plan.md)
