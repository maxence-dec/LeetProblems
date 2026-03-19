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