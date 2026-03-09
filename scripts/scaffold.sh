#!/usr/bin/env bash
set -euo pipefail

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

STUB_C='#include <stdio.h>
#include <stdlib.h>

/* TODO: replace with actual function signature from problem */
int solution(int* nums, int numsSize) {
    return 0;
}
'

STUB_CPP='#include <vector>
#include <string>
using namespace std;

/* TODO: replace with actual function signature from problem */
class Solution {
public:
    int solution(vector<int>& nums) {
        return 0;
    }
};
'

STUB_PY='# TODO: replace with actual function signature from problem
class Solution:
    def solution(self, nums: list[int]) -> int:
        return 0
'

STUB_CS='// TODO: replace with actual function signature from problem
public class Solution {
    public int Solution(int[] nums) {
        return 0;
    }
}
'

STUB_SQL='-- TODO: write SQL query below
-- Problem: '"$SLUG"'
'

STUB_RS='// TODO: replace with actual function signature from problem
use std::io;

fn main() {
    println!("Hello, world!");
}
'

TEST_C='#include <stdio.h>
#include <assert.h>

/* TODO: include solution.c or link against it */

int main(void) {
    /* assert(solution(...) == expected); */
    printf("All tests passed\n");
    return 0;
}
'

TEST_CPP='#include <cassert>
#include <iostream>
#include "solution.cpp"

int main() {
    Solution s;
    /* assert(s.solution(...) == expected); */
    std::cout << "All tests passed" << std::endl;
    return 0;
}
'

TEST_PY='import pytest
from solution import Solution

def test_placeholder():
    s = Solution()
    # assert s.solution(...) == expected
    pass
'

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
