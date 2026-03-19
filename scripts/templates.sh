#!/usr/bin/env bash
[[ -n "${_TEMPLATES_LOADED:-}" ]] && return 0
_TEMPLATES_LOADED=1

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
