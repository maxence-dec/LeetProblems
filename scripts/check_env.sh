#!/usr/bin/env bash
set -euo pipefail

REQUIRED=(curl jq python3)
OPTIONAL=(gcc g++ pytest mysql rustc cargo)
OPTIONAL_CSHARP=(dotnet mcs)

fail=0
for tool in "${REQUIRED[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        echo "[MISSING required] $tool"
        fail=1
    fi
done

if ! python3 -c "import html" &>/dev/null; then
    echo "[MISSING required] python3 html stdlib (unexpected)"
    fail=1
fi

if [[ $fail -ne 0 ]]; then
    echo "Required tools missing. Aborting."
    exit 1
fi

csharp_found=0
for tool in "${OPTIONAL_CSHARP[@]}"; do
    command -v "$tool" &>/dev/null && csharp_found=1
done
if [[ $csharp_found -eq 0 ]]; then
    echo "[missing optional] dotnet or mcs (C# support)"
fi

for tool in "${OPTIONAL[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        echo "[missing optional] $tool"
    fi
done
