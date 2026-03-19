#!/usr/bin/env bash
set -euo pipefail

SLUG="${1:?Usage: fetch_problem.sh <slug>}"
CACHE_DIR="/tmp/lc_cache"
CACHE_FILE="$CACHE_DIR/${SLUG}.json"

lp_fetch_problem(){
    mkdir -p "$CACHE_DIR"
    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi

    QUERY=$(cat <<EOF
{
  "query": "query { question(titleSlug: \"${SLUG}\") { title difficulty topicTags { name } content } }"
}
EOF
)

    RESPONSE=$(curl -sf \
        -X POST "https://leetcode.com/graphql" \
        -H "Content-Type: application/json" \
        -H "User-Agent: Mozilla/5.0" \
        -d "$QUERY")

    if [[ -z "$RESPONSE" ]]; then
        echo "[fetch_problem] curl returned empty response" >&2
        exit 1
    fi

    ERROR=$(echo "$RESPONSE" | jq -r '.errors // empty' 2>/dev/null)
    if [[ -n "$ERROR" ]]; then
        echo "[fetch_problem] API error: $ERROR" >&2
        exit 1
    fi

    TITLE=$(echo "$RESPONSE" | jq -r '.data.question.title // empty')
    if [[ -z "$TITLE" ]]; then
        echo "[fetch_problem] Problem not found or API changed: $SLUG" >&2
        exit 1
    fi

    echo "$RESPONSE" | jq '.data.question' > "$CACHE_FILE"
    cat "$CACHE_FILE"
}