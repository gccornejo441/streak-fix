#!/bin/bash

TARGET_DIR="${1:-.}"
OUTPUT_FILE="tree.txt"

# Define patterns to exclude
EXCLUDES=(".git" "node_modules" "__pycache__")

echo "Generating project layout of: $TARGET_DIR" > "$OUTPUT_FILE"
echo "Excluding: ${EXCLUDES[*]}" >> "$OUTPUT_FILE"
echo "----------------------------------------" >> "$OUTPUT_FILE"

generate_tree() {
  local dir="$1"
  local prefix="$2"

  local entries=()
  while IFS= read -r -d '' entry; do
    entries+=("$entry")
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 | sort -z)

  local count=${#entries[@]}
  local i=0

  for entry in "${entries[@]}"; do
    ((i++))
    local name=$(basename "$entry")

    # Skip excluded entries
    for exclude in "${EXCLUDES[@]}"; do
      [[ "$name" == "$exclude" ]] && continue 2
    done

    local connector="├──"
    [[ $i -eq $count ]] && connector="└──"

    echo "${prefix}${connector} ${name}" >> "$OUTPUT_FILE"

    if [[ -d "$entry" ]]; then
      local new_prefix="${prefix}"
      [[ $i -eq $count ]] && new_prefix+="    " || new_prefix+="│   "
      generate_tree "$entry" "$new_prefix"
    fi
  done
}

generate_tree "$TARGET_DIR" ""

echo "Project layout saved to: $OUTPUT_FILE"
