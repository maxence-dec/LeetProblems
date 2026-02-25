#!/usr/bin/env bash
set -euo pipefail

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
