# Container With Most Water — Medium

**Topics:** Array, Two Pointers, Greedy
**Language.s:** Rust

## Problem

You are given an integer array height of length n. There are n vertical lines drawn such that the two endpoints of the ith line are (i, 0) and (i, height[i]).
Find two lines that together with the x-axis form a container, such that the container contains the most water.
Return the maximum amount of water a container can store.
Notice that you may not slant the container.

Constraints:
    n == height.length
    2 <= n <= 10^5
    0 <= height[i] <= 10^4

## First Intuition

Keep two index pointers (upper - lower) and the max value calculated.
(upper - lower) * min(height(upper), height(lower))

Move the lowest valued one, only change the result if the calculated value is higher.

## Notable Issues

I got carried away with adding a hashmap or another way of moving from a local maximum to the next and avoid already calculated height value for greater area, but it would not change time complexity regardless and probably isn't worth the instruction overhead of calculating next index vs calculating area with values <= 10^4.

## Complexity

Time: O(n) — Space: O(1)

## Post-Exercise

Compared result with community solution by leetcode.com/u/la_castille result in changing manual 'if' statements to std functions min and max for idiomatic Rust.

## References

## Implementation Notes

"use std::cmp;" not needed because Leet-code already import it.
Non-trivial need for conversion between usize and i32 to study further.
