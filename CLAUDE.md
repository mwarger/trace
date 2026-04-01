# Forge — Project Instructions

## Version bumping

Every commit that changes skills, orchestrator behavior, or plugin metadata
**must** bump the version in `.claude-plugin/plugin.json` before pushing. This
ensures `/plugin update forge` picks up the latest changes.

Use semver:
- **patch** (1.2.0 → 1.2.1): bug fixes, wording clarifications, doc-only changes
- **minor** (1.2.0 → 1.3.0): new skills, behavioral changes, new fields in contracts
- **major** (1.2.0 → 2.0.0): breaking changes to skill interfaces or artifact schema
