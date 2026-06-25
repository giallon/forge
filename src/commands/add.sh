forge_cmd_add() {
  local module="$1"
  local module_dir

  module_dir="$(find_module_dir "$module")"

  mkdir -p "$OPS_SERVICES_DIR" "$OPS_ENV_DIR" "$OPS_CONFIG_DIR" "$OPS_SCRIPTS_DIR" "$OPS_DOCKER_DIR"

  if [[ -f "$module_dir/service.yml" ]]; then
    cp "$module_dir/service.yml" "$OPS_SERVICES_DIR/$module.yml"
  else
    echo "Missing service.yml in module: $module" >&2
    exit 1
  fi

  if [[ -f "$module_dir/env.example" ]]; then
    cp "$module_dir/env.example" "$OPS_ENV_DIR/$module.env.example"
  fi

  if [[ -d "$module_dir/files/config" ]]; then
    cp -R "$module_dir/files/config/." "$OPS_CONFIG_DIR/"
  fi

  if [[ -d "$module_dir/files/scripts" ]]; then
    cp -R "$module_dir/files/scripts/." "$OPS_SCRIPTS_DIR/"
  fi

  while IFS= read -r -d '' dockerfile_path; do
    local dockerfile_name
    local dockerfile_target_name

    dockerfile_name="$(basename "$dockerfile_path")"
    dockerfile_target_name="${dockerfile_name}.${module}"
    cp "$dockerfile_path" "$OPS_DOCKER_DIR/$dockerfile_target_name"
    sed -E -i '' "s|^([[:space:]]*dockerfile:[[:space:]]*)([\"']?)${dockerfile_name}([\"']?)[[:space:]]*$|\\1\\2../docker/$dockerfile_target_name\\3|" "$OPS_SERVICES_DIR/$module.yml"
  done < <(find "$module_dir" -mindepth 1 -maxdepth 1 -type f -name 'Dockerfile*' -print0)

  # Backward compatibility for legacy modules that keep extra project assets
  # (for example Dockerfile or init directories) at module root.
  while IFS= read -r -d '' module_asset; do
    cp -R "$module_asset" .
  done < <(
    find "$module_dir" -mindepth 1 -maxdepth 1 \
      ! -name 'service.yml' \
      ! -name 'env.example' \
      ! -name 'README.md' \
      ! -name 'files' \
      ! -name 'Dockerfile*' \
      -print0
  )

  echo "Added $module"
}