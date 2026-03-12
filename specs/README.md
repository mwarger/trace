# Specs

Trace keeps one subject-named spec per thing being studied or designed.
Use the subject spec as the implementation handoff artifact. Use this index to
discover the right spec and its sidecar artifacts.

## Notes

- `Readiness` follows the 80/80 gate plus blocker and contradiction gates from
  the completeness model.
- `Target` points at the implementation path when Trace can infer one.
- `Artifacts` contains reducer state, evidence ledgers, contradiction logs,
  decision logs, reviews, and handoff material.
- `Keywords` stay explicit so specs are easier to find later by synonym or
  subsystem.

<!-- trace:spec-index:start -->
| Spec | Target | Purpose | Status | Readiness | Keywords | Artifacts |
|---|---|---|---|---|---|---|
| [analytics-module.md](analytics-module.md) | `—` | Define analytics event ingestion, reporting behavior, and unresolved retention decisions. | Draft | Not Ready | analytics, telemetry, events, funnels, reporting, ingestion | [`_artifacts/analytics-module/`](_artifacts/analytics-module/) |
| [feature-flags-system.md](feature-flags-system.md) | `—` | Define a rollout-capable feature flag system with targeting, kill switches, and config rules. | Draft | Ready | feature flags, rollout, targeting, kill switch, cohorts, config | [`_artifacts/feature-flags-system/`](_artifacts/feature-flags-system/) |
| [auth-session-system.md](auth-session-system.md) | `—` | Define session creation, refresh, revocation, and device trust flows for auth state. | Draft | Ready | auth, session, cookies, refresh, revocation, device trust | [`_artifacts/auth-session-system/`](_artifacts/auth-session-system/) |
<!-- trace:spec-index:end -->
