CATALOG_DIR="$FORGE_ROOT_DIR/catalog"
COMPOSE_OUTPUT_FILE="docker-compose.yml"
ENV_OUTPUT_FILE=".env.example"
OPS_SERVICES_DIR="ops/services"
OPS_ENV_DIR="ops/env"
OPS_CONFIG_DIR="ops/config"
OPS_SCRIPTS_DIR="ops/scripts"
OPS_DOCKER_DIR="ops/docker"

usage() {
  cat <<'EOF'
Usage:
  forge add <module>
  forge list
  forge compose
  forge env
  forge bootstrap
EOF
}

find_module_dir() {
  local module_name="$1"
  local matches=()
  local path

  while IFS= read -r -d '' path; do
    if [[ -f "$path/service.yml" ]]; then
      matches+=("$path")
    fi
  done < <(find "$CATALOG_DIR" -type d -name "$module_name" -print0)

  if [[ ${#matches[@]} -eq 0 ]]; then
    echo "Module not found: $module_name" >&2
    exit 1
  fi

  if [[ ${#matches[@]} -gt 1 ]]; then
    echo "Module name is ambiguous: $module_name" >&2
    printf 'Matches:\n' >&2
    printf '  %s\n' "${matches[@]}" >&2
    exit 1
  fi

  printf '%s\n' "${matches[0]}"
}

find_project_service_files() {
  local service_files=()
  local path

  if [[ ! -d "$OPS_SERVICES_DIR" ]]; then
    echo "Project services directory not found: $OPS_SERVICES_DIR" >&2
    exit 1
  fi

  while IFS= read -r -d '' path; do
    service_files+=("$path")
  done < <(find "$OPS_SERVICES_DIR" -maxdepth 1 -type f -name '*.yml' -print0 | sort -z)

  if [[ ${#service_files[@]} -eq 0 ]]; then
    echo "No service manifests found under $OPS_SERVICES_DIR/*.yml" >&2
    exit 1
  fi

  printf '%s\n' "${service_files[@]}"
}

find_project_env_files() {
  local env_files=()
  local path

  if [[ ! -d "$OPS_ENV_DIR" ]]; then
    return 0
  fi

  while IFS= read -r -d '' path; do
    env_files+=("$path")
  done < <(find "$OPS_ENV_DIR" -maxdepth 1 -type f -name '*.env.example' -print0 | sort -z)

  if [[ ${#env_files[@]} -eq 0 ]]; then
    return 0
  fi

  printf '%s\n' "${env_files[@]}"
}

extract_service_name() {
  local service_file="$1"
  local service_name

  service_name="$(awk '
    $0 ~ /^services?:[[:space:]]*$/ { in_services = 1; next }
    in_services && $0 ~ /^  [^[:space:]][^:]*:[[:space:]]*$/ {
      line = $0
      sub(/^  /, "", line)
      sub(/:[[:space:]]*$/, "", line)
      print line
      exit
    }
  ' "$service_file")"

  if [[ -z "$service_name" ]]; then
    echo "Could not determine service name from $service_file" >&2
    exit 1
  fi

  printf '%s\n' "$service_name"
}

extract_named_volumes() {
  local service_file="$1"

  awk '
    $0 ~ /^volumes:[[:space:]]*$/ {
      in_volumes = 1
      next
    }

    in_volumes {
      if ($0 ~ /^  [^[:space:]][^:]*:[[:space:]]*$/) {
        line = $0
        sub(/^  /, "", line)
        sub(/:[[:space:]]*$/, "", line)
        print line
        next
      }

      if ($0 ~ /^[^[:space:]]/ && $0 !~ /^volumes:[[:space:]]*$/) {
        in_volumes = 0
      }
    }
  ' "$service_file"
}

array_contains() {
  local needle="$1"
  shift
  local item

  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done

  return 1
}

list_catalog_modules() {
  local service_file
  local module_dir
  local module_name
  local module_rel_path

  while IFS= read -r -d '' service_file; do
    module_dir="$(dirname "$service_file")"
    module_name="$(basename "$module_dir")"
    module_rel_path="${module_dir#"$CATALOG_DIR"/}"
    printf '%s\t%s\n' "$module_name" "$module_rel_path"
  done < <(find "$CATALOG_DIR" -type f -name 'service.yml' -print0 | sort -z)
}