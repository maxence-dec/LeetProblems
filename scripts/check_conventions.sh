#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
META="$REPO_ROOT/.meta/problems.json"
PROBLEMS_DIR="$REPO_ROOT/problems"

fail=0

slug_valid() {
    [[ "$1" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

for dir in "$PROBLEMS_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    slug=$(basename "$dir")

    if ! slug_valid "$slug"; then
        echo "[convention] Invalid slug format: $slug"
        fail=1
    fi

    has_solution=0
    for f in "$dir"solution.*; do
        [[ -f "$f" ]] && has_solution=1
    done
    if [[ $has_solution -eq 0 ]]; then
        echo "[convention] No solution file in: $slug"
        fail=1
    fi

    if [[ ! -f "$dir/README.md" ]]; then
        echo "[convention] Missing README.md in: $slug"
        fail=1
    fi
done

if [[ -f "$META" ]]; then
    while IFS= read -r json_slug; do
        if [[ ! -d "$PROBLEMS_DIR/$json_slug" ]]; then
            echo "[convention] problems.json references missing directory: $json_slug"
            fail=1
        fi
    done < <(jq -r '.[].slug' "$META")
fi

if [[ $fail -eq 0 ]]; then
    echo "[convention] All checks passed."
fi

exit $fail
