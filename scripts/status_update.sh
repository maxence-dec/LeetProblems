#!/usr/bin/env bash
# shellcheck source=./constants.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"

NEW_STATUS="${STATUS[$2]:-}"
[[ -z "$NEW_STATUS" ]] && { echo "Unknown status code: $2"; exit 1; }


INPUT="$1"
if [[ "$INPUT" == *"://"* ]]; then
    SLUG=$(echo "$INPUT" | sed -E 's|https?://leetcode\.com/problems/([^/]+)/?.*|\1|')
    if [[ "$SLUG" == "$INPUT" ]]; then
        echo "[status-update] Could not extract slug from URL: $INPUT" >&2
        exit 1
    fi
else
    SLUG="$INPUT"
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
META="$REPO_ROOT/.meta/problems.json"

JSON_CONTENT=$(cat "$META")
MATCH_COUNT=$(echo "$JSON_CONTENT" | jq --arg slug "$SLUG" 'map(select(.slug == $slug)) | length')

if [[ "$MATCH_COUNT" -ne 0 ]]; then
    OLD_STATUS=$(echo "$JSON_CONTENT" | jq -r --arg slug "$SLUG" 'first(.[] | select(.slug == $slug) | .status)')
    echo "$JSON_CONTENT" | jq \
        --arg slug "$SLUG" \
        --arg status "$NEW_STATUS" \
        '(.[] | select(.slug == $slug) | .status) |= $status' \
        > "$META.tmp" && mv "$META.tmp" "$META"
    echo "[status_update]  problems.json: '$SLUG' status: '$OLD_STATUS' -> '$NEW_STATUS'"

    # --- regenerate root README ---
    "$SCRIPT_DIR/gen_readme_root.sh"
else
    echo "[status_update] Slug $SLUG not found in problems.json — skipping JSON update"
fi