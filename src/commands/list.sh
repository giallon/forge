forge_cmd_list() {
  local has_modules=0
  local module_name
  local module_rel_path

  while IFS=$'\t' read -r module_name module_rel_path; do
    has_modules=1

    if [[ "$module_name" == "$module_rel_path" ]]; then
      printf '%s\n' "$module_name"
    else
      printf '%s (%s)\n' "$module_name" "$module_rel_path"
    fi
  done < <(list_catalog_modules)

  if [[ "$has_modules" -eq 0 ]]; then
    echo "No catalog modules found in $CATALOG_DIR" >&2
    exit 1
  fi
}
