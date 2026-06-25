forge_cmd_compose() {
  local service_files=()
  local named_volumes=()
  local service_file
  local service_basename
  local service_name
  local volume_name

  while IFS= read -r service_file; do
    service_files+=("$service_file")
  done < <(find_project_service_files)

  {
    printf 'services:\n'
    printf '\n'

    for service_file in "${service_files[@]}"; do
      service_basename="$(basename "$service_file")"
      service_name="$(extract_service_name "$service_file")"

      while IFS= read -r volume_name; do
        if [[ ${#named_volumes[@]} -eq 0 ]]; then
          named_volumes+=("$volume_name")
          continue
        fi

        if ! array_contains "$volume_name" "${named_volumes[@]}"; then
          named_volumes+=("$volume_name")
        fi
      done < <(extract_named_volumes "$service_file")

      printf '  %s:\n' "$service_name"
      printf '    extends:\n'
      printf '      file: %s/%s\n' "$OPS_SERVICES_DIR" "$service_basename"
      printf '      service: %s\n' "$service_name"
      printf '\n'
    done

    if [[ ${#named_volumes[@]} -gt 0 ]]; then
      printf 'volumes:\n'

      for volume_name in "${named_volumes[@]}"; do
        printf '  %s:\n' "$volume_name"
      done
    fi
  } > "$COMPOSE_OUTPUT_FILE"

  echo "Wrote $COMPOSE_OUTPUT_FILE"
}