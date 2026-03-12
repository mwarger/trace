#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="${MARGINALIA_TEST_ROOT:-$ROOT_DIR/.local-test}"
TEST_CODEX_HOME="$TEST_ROOT/codex-home"
TEST_SKILLS_DIR="$TEST_CODEX_HOME/skills"
MANIFEST_PATH="$TEST_ROOT/README.md"

log() {
  printf '[marginalia-test-local] %s\n' "$1"
}

mkdir -p "$TEST_SKILLS_DIR"

log "installing isolated skill set into $TEST_SKILLS_DIR"
MARGINALIA_SKILLS_DIR="$TEST_SKILLS_DIR" \
MARGINALIA_INSTALL_MODE="${MARGINALIA_INSTALL_MODE:-link}" \
"$ROOT_DIR/scripts/cli.sh" install-skills

cat > "$MANIFEST_PATH" <<EOF
# Local Test Environment

This directory is an isolated test install for the marginalia spec pack.

Use it like this:

\`\`\`bash
cd "$ROOT_DIR"
export CODEX_HOME="$TEST_CODEX_HOME"
codex
\`\`\`

Suggested prompts:

- Create a subject-named spec for this feature request using the marginalia pack.
- Reverse engineer this repo into a marginalia spec with sidecar artifacts.
- Use the marginalia-spec-orchestrator skill on this codebase.
EOF

log "wrote $MANIFEST_PATH"
log "next:"
printf '  export CODEX_HOME="%s"\n' "$TEST_CODEX_HOME"
printf '  codex\n'
