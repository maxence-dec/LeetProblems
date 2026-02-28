#!/usr/bin/env bash
# shellcheck source=./scripts/constants.sh

set -euo pipefail
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/scripts" && pwd)"
source "$SCRIPTS_DIR/constants.sh"

usage_intro(){
    local exit_after="${1:-0}"
    echo "leet-problem - custom CLI tool for LeetCode file management"
    echo "Usage: leet-problem [--help]"
    echo "                    <command> [<arguments>]"
    echo "  new     Add a problem, generate files and update readme/metadata"
    echo "  status  Update a problem status in readme/metadata"
    [[ $1 -eq 1 ]] && echo "leet-problem <command> --help"
    [[ $1 -eq 1 ]] && echo "  Get details for a specific command use"
    [[ $exit_after -eq 1 ]] && exit 1
    echo ""
}

usage_new() {
    [[ $1 -eq 1 ]] && echo "leet-problem - custom CLI tool for LeetCode file management"
    echo ""
    echo "Command new"
    echo "Add a problem, generate files and update readme/metadata"
    echo "Usage:    leet-problem new <leetcode-url> [lang...]"
    echo "Languages: c  cpp  python  csharp  mysql"
    echo "Example: leet-problem new https://leetcode.com/problems/two-sum/ c cpp"
}

usage_status() {
    [[ $1 -eq 1 ]] && echo "leet-problem - custom CLI tool for LeetCode file management"
    echo ""
    echo "Command status"
    echo "Update a problem status in readme/metadata"
    echo "Usage:    leet-problem status <slug> <value>"
    echo "Values:"
    for code in $(echo "${!STATUS[@]}" | tr ' ' '\n' | sort -n); do
        echo "  $code — ${STATUS[$code]}"
    done
    echo "Example: leet-problem status insert-delete-getrandom-o1 2"
}

usage_all(){
    usage_intro 0
    usage_new 0
    usage_status 0
}

[[ $# -eq 0 ]] && usage_intro 1
FUNCTION_ARG="$1"
shift

case "$FUNCTION_ARG" in
        new)
            if [[ $# -lt 2 || $1 == "--help" ]]; then
                usage_new 1
            else
                echo "[leet-problem] Adding new problem"
                "$SCRIPT_DIR/new_problem.sh" "$@"
            fi
            ;;
        status)
            if [[ $# -lt 2 ||  $1 == "--help" ]]; then
                usage_status 1
            else
                echo "[leet-problem] Updating status"
                "$SCRIPT_DIR/status_update.sh" "$@"
            fi
            ;;
        --help)
            usage_all
            ;;
        *)
            echo "[leet-problem] Unknown argument, refer to --help"
            exit 1
            ;;
    esac
exit 0