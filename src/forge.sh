#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${FORGE_ROOT_DIR:-}" ]]; then
  FORGE_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

source "$FORGE_ROOT_DIR/src/lib/common.sh"
source "$FORGE_ROOT_DIR/src/commands/add.sh"
source "$FORGE_ROOT_DIR/src/commands/list.sh"
source "$FORGE_ROOT_DIR/src/commands/compose.sh"
source "$FORGE_ROOT_DIR/src/commands/env.sh"

forge_main() {
  local command="${1:-}"
  local module="${2:-}"

  if [[ -z "$command" ]]; then
    usage
    exit 1
  fi

  case "$command" in
    add)
      if [[ -z "$module" ]]; then
        usage
        exit 1
      fi

      forge_cmd_add "$module"
      ;;
    list)
      forge_cmd_list
      ;;
    compose)
      forge_cmd_compose
      ;;
    env)
      forge_cmd_env
      ;;
    bootstrap)
      forge_cmd_compose
      forge_cmd_env
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}