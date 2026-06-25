forge_cmd_remove() {
  local module="$1"
  local removed=0
  local module_config_path="$OPS_CONFIG_DIR/$module"

  if [[ -f "$OPS_SERVICES_DIR/$module.yml" ]]; then
    rm -f "$OPS_SERVICES_DIR/$module.yml"
    removed=1
  fi

  if [[ -d "$module_config_path" ]]; then
    rm -rf "$module_config_path"
    removed=1
  elif [[ -f "$module_config_path" ]]; then
    rm -f "$module_config_path"
    removed=1
  fi

  if [[ "$removed" -eq 0 ]]; then
    echo "Module not present in project: $module" >&2
    exit 1
  fi

  echo "Removed $module"
}
