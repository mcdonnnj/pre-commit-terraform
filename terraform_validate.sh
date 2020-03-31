#!/usr/bin/env bash
set -e

declare -a paths
index=0
error=0

for file_with_path in "$@"; do
  file_with_path="${file_with_path// /__REPLACED__SPACE__}"

  paths[index]=$(dirname "$file_with_path")
  (("index+=1"))
done

for path_uniq in $(echo "${paths[*]}" | tr ' ' '\n' | sort -u); do
  path_uniq="${path_uniq//__REPLACED__SPACE__/ }"

  current_path="$(pwd)"

  if [[ -n "$(find . -maxdepth 1 -name '*.tf' -print -quit)" ]]; then
    cd "$path_uniq"
    if ! terraform validate; then
      error=1
      echo
      echo "Failed path: $path_uniq"
      echo "================================"
    fi
    cd "$current_path"
  fi
done

if [[ "${error}" -ne 0 ]]; then
  exit 1
fi
