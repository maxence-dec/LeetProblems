#!/usr/bin/env bash
# shellcheck source=./constants.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"

URL="$1"
shift
LANGS=("$@")

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
META="$REPO_ROOT/.meta/problems.json"

 # --- extract slug from URL ---
SLUG=$(echo "$URL" | sed -E 's|https?://leetcode\.com/problems/([^/]+)/?.*|\1|')
if [[ "$SLUG" == "$URL" ]]; then
    echo "[new-problem] Could not extract slug from URL: $URL" >&2
    exit 1
fi

echo "[new-problem] Slug: $SLUG"
echo "[new-problem] Languages: ${LANGS[*]}"

 # --- environment check ---
"$SCRIPT_DIR/check_env.sh"

 # --- scaffold problem directory ---
"$SCRIPT_DIR/scaffold.sh" "$SLUG" "${LANGS[@]}"

 # --- update .meta/problems.json ---
CACHE_FILE="/tmp/lc_cache/${SLUG}.json"

TITLE=$(jq -r '.title' "$CACHE_FILE")
DIFFICULTY=$(jq -r '.difficulty' "$CACHE_FILE")
TOPICS=$(jq -r '[.topicTags[].name]' "$CACHE_FILE")

LANG_JSON=$(printf '%s\n' "${LANGS[@]}" | jq -R . | jq -s .)

JSON_CONTENT=$(cat "$META")
MATCH_COUNT=$(echo "$JSON_CONTENT" | jq --arg slug "$SLUG" 'map(select(.slug == $slug)) | length')

if [[ "$MATCH_COUNT" -eq 0 ]]; then
    echo "$JSON_CONTENT" | jq \
        --arg slug "$SLUG" \
        --arg title "$TITLE" \
        --arg difficulty "$DIFFICULTY" \
        --arg status "${STATUS[0]:-}"\
        --argjson topics "$TOPICS" \
        --argjson languages "$LANG_JSON" \
        '. + [{slug: $slug, title: $title, difficulty: $difficulty, topics: $topics, languages: $languages, status: $status}]' \
        > "$META.tmp" && mv "$META.tmp" "$META"
    echo "[new-problem] Added to problems.json"
else
    echo "[new-problem] Slug already in problems.json — skipping JSON update"
fi

 # --- regenerate root README ---
"$SCRIPT_DIR/gen_readme_root.sh"

echo ""
echo "[new-problem] Done."
echo "  Problem dir : $REPO_ROOT/problems/$SLUG/"
echo "  Next steps  : edit problems/$SLUG/README.md, write solution, run 'make test'"
echo ""