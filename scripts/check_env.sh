#!/usr/bin/env bash
set -euo pipefail

#SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REQUIRED=(curl jq python3)
OPTIONAL_C=(gcc)
OPTIONAL_CPP=(g++)
OPTIONAL_CSHARP=(dotnet mcs)
#OPTIONAL_PYTHON=(pytest)
OPTIONAL_MYSQL=(mysql)

DNF_HINTS=(
    "curl:curl"
    "jq:jq"
    "python3:python3"
    "gcc:gcc"
    "g++:g++"
    "dotnet:dotnet-sdk-8.0"
    "mcs:mono-devel"
    "mysql:community-mysql"
)

hint() {
    local tool="$1"
    for entry in "${DNF_HINTS[@]}"; do
        if [[ "${entry%%:*}" == "$tool" ]]; then
            echo "  → sudo dnf install ${entry##*:}"
            return
        fi
    done
    echo "  → install manually"
}

fail=0

for tool in "${REQUIRED[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        echo "[MISSING required] $tool"
        hint "$tool"
        fail=1
    fi
done

for tool in "${OPTIONAL_C[@]}" "${OPTIONAL_CPP[@]}" "${OPTIONAL_MYSQL[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        echo "[missing optional] $tool"
        hint "$tool"
    fi
done

csharp_found=0
for tool in "${OPTIONAL_CSHARP[@]}"; do
    command -v "$tool" &>/dev/null && csharp_found=1
done
if [[ $csharp_found -eq 0 ]]; then
    echo "[missing optional] dotnet or mcs (C# support)"
    hint "dotnet"
fi

if ! command -v pytest &>/dev/null; then
    echo "[missing optional] pytest  →  pip install --user pytest"
fi

if ! python3 -c "import html" &>/dev/null; then
    echo "[MISSING required] python3 html stdlib (unexpected)"
    fail=1
fi

if [[ $fail -ne 0 ]]; then
    echo "Required tools missing. Aborting."
    exit 1
fi
