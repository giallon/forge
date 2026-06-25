forge_cmd_remove() {
  local module="$1"
  local removed=0

  if [[ -f "$OPS_SERVICES_DIR/$module.yml" ]]; then
    rm -f "$OPS_SERVICES_DIR/$module.yml"
    removed=1
  fi

  if [[ "$removed" -eq 0 ]]; then
    echo "Module not present in project: $module" >&2
    exit 1
  fi

  echo "Removed $module"
}
