forge_cmd_add() {
  local module="$1"
  local module_dir

  module_dir="$(find_module_dir "$module")"

  mkdir -p "$OPS_SERVICES_DIR" "$OPS_CONFIG_DIR" "$OPS_SCRIPTS_DIR" "$OPS_TEMPLATES_DIR"

  if [[ -f "$module_dir/service.yml" ]]; then
    cp "$module_dir/service.yml" "$OPS_SERVICES_DIR/$module.yml"
  else
    echo "Missing service.yml in module: $module" >&2
    exit 1
  fi

  if [[ -d "$module_dir/files/config" ]]; then
    cp -R "$module_dir/files/config/." "$OPS_CONFIG_DIR/"
  fi

  if [[ -d "$module_dir/files/scripts" ]]; then
    cp -R "$module_dir/files/scripts/." "$OPS_SCRIPTS_DIR/"
  fi

  if [[ -d "$module_dir/files/templates" ]]; then
    cp -R "$module_dir/files/templates/." "$OPS_TEMPLATES_DIR/"
  fi

  echo "Added $module"
}