#!/usr/bin/env bash
set -euo pipefail

SLUG="${1:?Usage: gen_readme_problem.sh <slug> [--force]}"
FORCE=0
[[ "${2:-}" == "--force" ]] && FORCE=1

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROB_DIR="$REPO_ROOT/problems/$SLUG"
README="$PROB_DIR/README.md"
SCRIPTS_DIR="$REPO_ROOT/scripts"

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
    "$SCRIPTS_DIR/fetch_problem.sh" "$SLUG" > /dev/null
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
LANGS="${LANGS%,}"

cat > "$README" <<EOF
# ${TITLE} — ${DIFFICULTY}

**Topics:** ${TOPICS}
**Languages:** ${LANGS}

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
        esac
    fi
done

echo "[gen_readme_problem] Written: $README"
