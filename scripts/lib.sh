#!/usr/bin/env bash
# shellcheck source=./scripts/constants.sh
# shellcheck source=./scripts/templates.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/templates.sh"

lp_fetch_problem(){
    CACHE_DIR="/tmp/lc_cache"
    CACHE_FILE="$CACHE_DIR/${SLUG}.json"
    mkdir -p "$CACHE_DIR"
    if [[ -f "$CACHE_FILE" ]]; then
        return
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
    #cat "$CACHE_FILE"
}


lp_scaffold(){
    LANGS=("$@")
    [[ ${#LANGS[@]} -eq 0 ]] && exit 1;

    if [[ -d "$PROB_DIR" ]]; then
        echo "[scaffold] Directory already exists: $PROB_DIR" >&2
        exit 1
    fi

    mkdir -p "$PROB_DIR"
    echo "[scaffold] Created: $PROB_DIR"

    lp_fetch_problem

    for lang in "${LANGS[@]}"; do
        case "$lang" in
            c)
                printf '%s' "$STUB_C"    > "$PROB_DIR/solution.c"
                echo "[scaffold] Created solution.c"
                ;;
            cpp)
                printf '%s' "$STUB_CPP"  > "$PROB_DIR/solution.cpp"
                echo "[scaffold] Created solution.cpp"
                ;;
            python)
                printf '%s' "$STUB_PY"   > "$PROB_DIR/solution.py"
                echo "[scaffold] Created solution.py"
                ;;
            csharp)
                printf '%s' "$STUB_CS"   > "$PROB_DIR/solution.cs"
                echo "[scaffold] Created solution.cs (no test stub — use dotnet test project manually)"
                ;;
            mysql)
                printf '%s' "$STUB_SQL"  > "$PROB_DIR/solution.sql"
                echo "[scaffold] Created solution.sql"
                ;;
            rust)
                printf '%s' "$STUB_RS"  > "$PROB_DIR/solution.rs"
                echo "[scaffold] Created solution.rs"
                ;;
            *)
                echo "[scaffold] Unknown language: $lang (supported: c cpp python csharp mysql)" >&2
                ;;
        esac
    done

    lp_gen_readme_problem

}

lp_gen_readme_problem(){
    [[ -d "$PROB_DIR" ]] || { echo "[gen_readme_problem] Directory not found: $PROB_DIR" >&2; exit 1; }

    if [[ ! -f "$CACHE_FILE" ]]; then
        lp_fetch_problem
    fi

    TITLE=$(jq -r '.title' "$CACHE_FILE")
    DIFFICULTY=$(jq -r '.difficulty' "$CACHE_FILE")
    TOPICS=$(jq -r '[.topicTags[].name] | join(", ")' "$CACHE_FILE")

    LANGS_README=""
    [[ -f "$PROB_DIR/solution.c" ]]   && LANGS_README="$LANGS_README C,"
    [[ -f "$PROB_DIR/solution.cpp" ]] && LANGS_README="$LANGS_README C++,"
    [[ -f "$PROB_DIR/solution.py" ]]  && LANGS_README="$LANGS_README Python,"
    [[ -f "$PROB_DIR/solution.cs" ]]  && LANGS_README="$LANGS_README C#,"
    [[ -f "$PROB_DIR/solution.sql" ]] && LANGS_README="$LANGS_README MySQL,"
    [[ -f "$PROB_DIR/solution.rs" ]] && LANGS_README="$LANGS_README Rust,"
    LANGS_README="${LANGS_README%,}"

cat > "$README_PROBLEM" <<EOF
# ${TITLE} — ${DIFFICULTY}

**Topics:** ${TOPICS}
**Language.s:**${LANGS_README}

## Problem

## First Intuition

## Notable Issues

## Complexity

Time: O(?)  — Space: O(?)

## Post-Exercise

## References

## Implementation Notes
EOF

    for lang_file in solution.c solution.cpp solution.py solution.cs solution.sql; do
        if [[ -f "$PROB_DIR/$lang_file" ]]; then
            case "$lang_file" in
                solution.c)   echo -e "\n### C\n"   >> "$README_PROBLEM" ;;
                solution.cpp) echo -e "\n### C++\n" >> "$README_PROBLEM" ;;
                solution.py)  echo -e "\n### Python\n" >> "$README_PROBLEM" ;;
                solution.cs)  echo -e "\n### C#\n"  >> "$README_PROBLEM" ;;
                solution.sql) echo -e "\n### MySQL\n" >> "$README_PROBLEM" ;;
                solution.rs) echo -e "\n### Rust\n" >> "$README_PROBLEM" ;;
            esac
        fi
    done

    echo "[gen_readme_problem] Written: $README_PROBLEM"

}

lp_gen_readme_root(){
    [[ -f "$META" ]] || { echo "[gen_readme_root] .meta/problems.json not found" >&2; exit 1; }

    INTRO=""
    if [[ -f "$README_ROOT" ]]; then
        INTRO=$(awk '/<!-- INTRO_START -->/{found=1} found{print} /<!-- INTRO_END -->/{exit}' "$README_ROOT")
    fi

    if [[ -z "$INTRO" ]]; then
    INTRO=$(cat <<'EOF'
<!-- INTRO_START -->
<!-- Write your portfolio introduction here. This block is preserved on regeneration. -->
<!-- INTRO_END -->
EOF
    )
    fi

    TABLE_HEADER="| Problem | Difficulty | Topics | Languages | Status |"
    TABLE_SEP="|---------|------------|--------|-----------|--------|"

    TABLE_ROWS=$(jq -r '.[] |
        "| [\(.title)](problems/\(.slug)/README.md) | \(.difficulty) | \(.topics | join(", ")) | \(.languages | join(", ")) | \(.status) |"
    ' "$META")

cat > "$README_ROOT" <<EOF
${INTRO}

## Problems

${TABLE_HEADER}
${TABLE_SEP}
${TABLE_ROWS}
EOF

    echo "[gen_readme_root] Written: $README_ROOT"
}

lp_new_problem(){
    URL="$1"
    shift
    LANGS=("$@")

    # --- extract slug from URL ---
    SLUG=$(echo "$URL" | sed -E 's|https?://leetcode\.com/problems/([^/]+)/?.*|\1|')
    if [[ "$SLUG" == "$URL" ]]; then
        echo "[new-problem] Could not extract slug from URL: $URL" >&2
        exit 1
    fi

    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    SCRIPT_DIR="$REPO_ROOT/scripts"
    PROB_DIR="$REPO_ROOT/problems/$SLUG"

    README_PROBLEM="$PROB_DIR/README.md"

    META="$REPO_ROOT/.meta/problems.json"
    README_ROOT="$REPO_ROOT/README.md"

    echo "[new-problem] Slug: $SLUG"
    echo "[new-problem] Languages: ${LANGS[*]}"

     # --- environment check ---
    "$SCRIPT_DIR/check_env.sh"

     # --- scaffold problem directory ---
    lp_scaffold "${LANGS[@]}"

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
    lp_gen_readme_root

    echo ""
    echo "[new-problem] Done."
    echo "  Problem dir : $REPO_ROOT/problems/$SLUG/"
    echo "  Next steps  : edit problems/$SLUG/README.md, write solution, run 'make test'"
    echo ""
}

lp_status_update(){
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    README_ROOT="$REPO_ROOT/README.md"

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
        lp_gen_readme_root
    else
        echo "[status_update] Slug $SLUG not found in problems.json — skipping JSON update"
    fi
}