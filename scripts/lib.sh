#!/usr/bin/env bash
set -euo pipefail

SLUG=""

lp_fetch_problem(){
    CACHE_DIR="/tmp/lc_cache"
    CACHE_FILE="$CACHE_DIR/${SLUG}.json"
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


lp_scaffold(){
    SLUG="${1:?Usage: scaffold.sh <slug> <lang...>}"
    shift
    LANGS=("$@")
    [[ ${#LANGS[@]} -eq 0 ]] && { echo "Usage: scaffold.sh <slug> <lang...>  (c cpp python csharp mysql)" >&2; exit 1; }

    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    SCRIPT_DIR="$REPO_ROOT/scripts"
    PROB_DIR="$REPO_ROOT/problems/$SLUG"

    if [[ -d "$PROB_DIR" ]]; then
        echo "[scaffold] Directory already exists: $PROB_DIR" >&2
        # echo "[scaffold] Use gen_makefile.sh or gen_readme_problem.sh --force to update individual files." >&2
        exit 1
    fi

    mkdir -p "$PROB_DIR"
    echo "[scaffold] Created: $PROB_DIR"

    "$SCRIPT_DIR/fetch_problem.sh" "$SLUG" > /dev/null

    for lang in "${LANGS[@]}"; do
        case "$lang" in
            c)
                printf '%s' "$STUB_C"    > "$PROB_DIR/solution.c"
                #printf '%s' "$TEST_C"    > "$PROB_DIR/test_solution.c"
                echo "[scaffold] Created solution.c" # + test_solution.c"
                ;;
            cpp)
                printf '%s' "$STUB_CPP"  > "$PROB_DIR/solution.cpp"
                #printf '%s' "$TEST_CPP"  > "$PROB_DIR/test_solution.cpp"
                echo "[scaffold] Created solution.cpp" # + test_solution.cpp"
                ;;
            python)
                printf '%s' "$STUB_PY"   > "$PROB_DIR/solution.py"
                #printf '%s' "$TEST_PY"   > "$PROB_DIR/solution_test.py"
                echo "[scaffold] Created solution.py" # + solution_test.py"
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

    # "$SCRIPT_DIR/gen_makefile.sh" "$SLUG"
    "$SCRIPT_DIR/gen_readme_problem.sh" "$SLUG"

}

lp_gen_readme_problem(){
    SLUG="${1:?Usage: gen_readme_problem.sh <slug> [--force]}"
    FORCE=0
    [[ "${2:-}" == "--force" ]] && FORCE=1

    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    PROB_DIR="$REPO_ROOT/problems/$SLUG"
    README="$PROB_DIR/README.md"
    SCRIPT_DIR="$REPO_ROOT/scripts"

    [[ -d "$PROB_DIR" ]] || { echo "[gen_readme_problem] Directory not found: $PROB_DIR" >&2; exit 1; }

    ANALYSIS_SECTIONS=("## First Intuition" "## Notable Issues" "## Post-Exercise" "## References" "## Implementation Notes")

    has_content() {
        local file="$1"
        [[ ! -f "$file" ]] && return 1
        for section in "${ANALYSIS_SECTIONS[@]}"; do
            if grep -qF "$section" "$file"; then
                local next_line
                next_line=$(grep -A1 -F "$section" "$file" | tail -1)
                if [[ -n "$next_line" && "$next_line" != "##"* ]]; then
                    return 0
                fi
            fi
        done
        return 1
    }

    if has_content "$README" && [[ $FORCE -eq 0 ]]; then
        echo "[gen_readme_problem] README has hand-written content. Use --force to overwrite." >&2
        echo "[gen_readme_problem] Diff preview:" >&2
        exit 1
    fi

    CACHE_FILE="/tmp/lc_cache/${SLUG}.json"
    if [[ ! -f "$CACHE_FILE" ]]; then
        "$SCRIPT_DIR/fetch_problem.sh" "$SLUG" > /dev/null
    fi

    TITLE=$(jq -r '.title' "$CACHE_FILE")
    DIFFICULTY=$(jq -r '.difficulty' "$CACHE_FILE")
    TOPICS=$(jq -r '[.topicTags[].name] | join(", ")' "$CACHE_FILE")

    LANGS=""
    [[ -f "$PROB_DIR/solution.c" ]]   && LANGS="$LANGS C,"
    [[ -f "$PROB_DIR/solution.cpp" ]] && LANGS="$LANGS C++,"
    [[ -f "$PROB_DIR/solution.py" ]]  && LANGS="$LANGS Python,"
    [[ -f "$PROB_DIR/solution.cs" ]]  && LANGS="$LANGS C#,"
    [[ -f "$PROB_DIR/solution.sql" ]] && LANGS="$LANGS MySQL,"
    [[ -f "$PROB_DIR/solution.rs" ]] && LANGS="$LANGS Rust,"
    LANGS="${LANGS%,}"

cat > "$README" <<EOF
# ${TITLE} — ${DIFFICULTY}

**Topics:** ${TOPICS}
**Language.s:**${LANGS}

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
                solution.c)   echo -e "\n### C\n"   >> "$README" ;;
                solution.cpp) echo -e "\n### C++\n" >> "$README" ;;
                solution.py)  echo -e "\n### Python\n" >> "$README" ;;
                solution.cs)  echo -e "\n### C#\n"  >> "$README" ;;
                solution.sql) echo -e "\n### MySQL\n" >> "$README" ;;
                solution.rs) echo -e "\n### Rust\n" >> "$README" ;;
            esac
        fi
    done

    echo "[gen_readme_problem] Written: $README"

}

lp_gen_readme_root(){
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    META="$REPO_ROOT/.meta/problems.json"
    README="$REPO_ROOT/README.md"

    [[ -f "$META" ]] || { echo "[gen_readme_root] .meta/problems.json not found" >&2; exit 1; }

    INTRO=""
    if [[ -f "$README" ]]; then
        INTRO=$(awk '/<!-- INTRO_START -->/{found=1} found{print} /<!-- INTRO_END -->/{exit}' "$README")
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

cat > "$README" <<EOF
${INTRO}

## Problems

${TABLE_HEADER}
${TABLE_SEP}
${TABLE_ROWS}
EOF

    echo "[gen_readme_root] Written: $README"
}

lp_new_problem(){
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
}

lp_status_update(){
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
}