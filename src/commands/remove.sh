forge_cmd_remove() {
  local module="$1"
  local removed=0
  local docker_asset

  if [[ -f "$OPS_SERVICES_DIR/$module.yml" ]]; then
    rm -f "$OPS_SERVICES_DIR/$module.yml"
    removed=1
  fi

  if [[ -f "$OPS_ENV_DIR/$module.env.example" ]]; then
    rm -f "$OPS_ENV_DIR/$module.env.example"
    removed=1
  fi

  while IFS= read -r -d '' docker_asset; do
    rm -f "$docker_asset"
    removed=1
  done < <(find "$OPS_DOCKER_DIR" -maxdepth 1 -type f -name "Dockerfile*.${module}" -print0 2>/dev/null)

  if [[ "$removed" -eq 0 ]]; then
    echo "Module not present in project: $module" >&2
    exit 1
  fi

  echo "Removed $module"
}
