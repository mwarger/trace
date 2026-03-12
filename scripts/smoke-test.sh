#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  printf '[marginalia-smoke] %s\n' "$1"
}

require_file() {
  [[ -f "$1" ]] || {
    printf '[marginalia-smoke] ERROR: missing file %s\n' "$1" >&2
    exit 1
  }
}

log "checking required files"
require_file "$ROOT_DIR/README.md"
require_file "$ROOT_DIR/.codex/INSTALL.md"
require_file "$ROOT_DIR/specs/README.md"
require_file "$ROOT_DIR/specs/analytics-module.md"
require_file "$ROOT_DIR/specs/feature-flags-system.md"
require_file "$ROOT_DIR/specs/auth-session-system.md"

for skill in \
  marginalia-spec-orchestrator \
  spec-intake \
  spec-loop \
  spec-completeness \
  spec-synthesis-review \
  spec-plan-handoff
do
  require_file "$ROOT_DIR/skills/$skill/SKILL.md"
done

log "validating json/jsonl artifacts"
ROOT="$ROOT_DIR" python3 - <<'PY'
import json
import os
from pathlib import Path

root = Path(os.environ["ROOT"])
for path in root.joinpath("specs", "_artifacts").rglob("*.json"):
    json.loads(path.read_text())

for path in root.joinpath("specs", "_artifacts").rglob("*.jsonl"):
    for line in path.read_text().splitlines():
        if line.strip():
            json.loads(line)
PY

log "smoke test ok"
