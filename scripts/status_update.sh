#!/usr/bin/env bash
# shellcheck source=./constants.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"

NEW_STATUS="${STATUS[$2]:-}"
[[ -z "$NEW_STATUS" ]] && { echo "Unknown status code: $2"; exit 1; }

SLUG=$1

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META="$REPO_ROOT/.meta/problems.json"

JSON_CONTENT=$(cat "$META")
ALREADY=$(echo "$JSON_CONTENT" | jq --arg slug "$SLUG" 'map(select(.slug == $slug)) | length')

if [[ "$ALREADY" -ne 0 ]]; then
    OLD_STATUS=$(echo "$JSON_CONTENT" | jq -r --arg slug "$SLUG" 'first(.[] | select(.slug == $slug) | .status)')
    echo "$JSON_CONTENT" | jq \
        --arg slug "$SLUG" \
        --arg status "$NEW_STATUS" \
        '(.[] | select(.slug == $slug) | .status) |= $status' \
        > "$META.tmp" && mv "$META.tmp" "$META"
    echo "[status-problem]  problems.json: '$SLUG' status: '$OLD_STATUS' -> '$NEW_STATUS'"

    # --- regenerate root README ---
    "$SCRIPTS_DIR/gen_readme_root.sh"
else
    echo "[status-problem]  lug $SLUG no found in problems.json — skipping JSON update"
fi