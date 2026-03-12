# Implementation Plan

## Workstreams

1. login/session-family creation
2. refresh rotation and reuse detection
3. revocation endpoints and session-state updates
4. browser/mobile transport adapters
5. device trust visibility and revocation UI/API

## Dependencies

- session-family schema before refresh rotation
- revocation model before device trust UI/API
- browser/mobile transport decisions before client adapters

## Acceptance Criteria

- family revocation on refresh reuse
- secure cookie behavior
- explicit session revocation
- device list and revoke support

## Test Scenarios

- reused refresh credential revokes entire family
- revoked session cannot refresh again
- browser session uses secure httpOnly cookies
- device revoke removes active session on next enforcement point

## Top Risks

- race conditions during concurrent refresh
- inconsistent session-family revocation propagation

## Explicit Excluded Work

- MFA enrollment
- IdP federation
