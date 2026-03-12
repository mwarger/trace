#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI_NAME="marginalia-spec-pack"
DEFAULT_CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DEFAULT_SKILLS_DIR="${MARGINALIA_SKILLS_DIR:-$DEFAULT_CODEX_HOME/skills}"
MANIFEST_NAME=".marginalia-spec-pack-install.json"
SKILL_NAMES=(
  marginalia-spec-orchestrator
  spec-intake
  spec-loop
  spec-completeness
  spec-synthesis-review
  spec-plan-handoff
)

log() {
  printf '[%s] %s\n' "$CLI_NAME" "$1"
}

fail() {
  printf '[%s] ERROR: %s\n' "$CLI_NAME" "$1" >&2
  exit 1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

skills_dir() {
  printf '%s\n' "${MARGINALIA_SKILLS_DIR:-$DEFAULT_SKILLS_DIR}"
}

install_mode() {
  printf '%s\n' "${MARGINALIA_INSTALL_MODE:-link}"
}

manifest_path() {
  printf '%s/%s\n' "$(skills_dir)" "$MANIFEST_NAME"
}

ensure_prereqs() {
  has_cmd python3 || fail "python3 is required"
}

write_manifest() {
  local target_dir="$1"
  local mode="$2"
  TARGET_DIR="$target_dir" ROOT="$ROOT_DIR" MODE="$mode" python3 - <<'PY'
import json, os
skills = [
  "marginalia-spec-orchestrator",
  "spec-intake",
  "spec-loop",
  "spec-completeness",
  "spec-synthesis-review",
  "spec-plan-handoff",
]
path = os.path.join(os.environ["TARGET_DIR"], ".marginalia-spec-pack-install.json")
data = {
  "root_dir": os.environ["ROOT"],
  "install_mode": os.environ["MODE"],
  "skills": skills,
}
with open(path, "w", encoding="utf-8") as f:
  json.dump(data, f, indent=2)
  f.write("\n")
PY
}

install_skills() {
  ensure_prereqs

  local target_dir
  target_dir="$(skills_dir)"
  local mode
  mode="$(install_mode)"

  mkdir -p "$target_dir"

  local skill
  for skill in "${SKILL_NAMES[@]}"; do
    local src="$ROOT_DIR/skills/$skill"
    local dest="$target_dir/$skill"

    [[ -d "$src" ]] || fail "missing skill dir: $src"
    rm -rf "$dest"

    case "$mode" in
      link)
        ln -s "$src" "$dest"
        ;;
      copy)
        cp -R "$src" "$dest"
        ;;
      *)
        fail "unsupported install mode: $mode"
        ;;
    esac
  done

  write_manifest "$target_dir" "$mode"
  log "installed skills into $target_dir using mode=$mode"
}

uninstall_skills() {
  ensure_prereqs

  local target_dir
  target_dir="$(skills_dir)"
  local manifest
  manifest="$(manifest_path)"

  if [[ -f "$manifest" ]]; then
    local skill
    for skill in "${SKILL_NAMES[@]}"; do
      rm -rf "$target_dir/$skill"
    done
    rm -f "$manifest"
    log "removed managed skills from $target_dir"
  else
    log "no managed install manifest found at $manifest"
  fi
}

doctor() {
  ensure_prereqs
  log "root: $ROOT_DIR"
  log "skills dir: $(skills_dir)"
  log "install mode: $(install_mode)"

  local skill
  for skill in "${SKILL_NAMES[@]}"; do
    [[ -f "$ROOT_DIR/skills/$skill/SKILL.md" ]] || fail "missing $skill/SKILL.md"
  done

  [[ -f "$ROOT_DIR/specs/README.md" ]] || fail "missing specs/README.md"
  [[ -f "$ROOT_DIR/scripts/smoke-test.sh" ]] || fail "missing smoke-test.sh"
  log "doctor ok"
}

list_skills() {
  local skill
  for skill in "${SKILL_NAMES[@]}"; do
    printf '%s\n' "$skill"
  done
}

where_cmd() {
  printf 'root=%s\n' "$ROOT_DIR"
  printf 'skills_dir=%s\n' "$(skills_dir)"
  printf 'manifest=%s\n' "$(manifest_path)"
}

smoke_test() {
  "$ROOT_DIR/scripts/smoke-test.sh"
}

test_local() {
  "$ROOT_DIR/scripts/test-local.sh"
}

help_cmd() {
  cat <<EOF
Usage: $CLI_NAME <command>

Commands:
  help
  where
  list-skills
  install-skills
  uninstall-skills
  doctor
  smoke-test
  test-local

Env vars:
  CODEX_HOME
  MARGINALIA_SKILLS_DIR
  MARGINALIA_INSTALL_MODE=link|copy
EOF
}

main() {
  local cmd="${1:-help}"

  case "$cmd" in
    help) help_cmd ;;
    where) where_cmd ;;
    list-skills) list_skills ;;
    install-skills) install_skills ;;
    uninstall-skills) uninstall_skills ;;
    doctor) doctor ;;
    smoke-test) smoke_test ;;
    test-local) test_local ;;
    *)
      fail "unknown command: $cmd"
      ;;
  esac
}

main "$@"
