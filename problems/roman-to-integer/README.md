# Roman to Integer — Easy

**Topics:** Hash Table, Math, String
**Language.s:** Rust

## Problem

Given a roman numeral, convert it to an integer.

Example 1:
Input: s = "III"
Output: 3
Explanation: III = 3.

Example 2:
Input: s = "LVIII"
Output: 58
Explanation: L = 50, V= 5, III = 3.

Example 3:
Input: s = "MCMXCIV"
Output: 1994
Explanation: M = 1000, CM = 900, XC = 90 and IV = 4.

Constraints:
    1 <= s.length <= 15
    s contains only the characters ('I', 'V', 'X', 'L', 'C', 'D', 'M').
    It is guaranteed that s is a valid roman numeral in the range [1, 3999].

## First Intuition

Minus or plus the next symbol depends on the highest value yet seen when parsing string from right to left.

## Notable Issues

String in Rust don't have an implementation similare to IEnumerable in C#, had to use `.chars()` to iterate through.

## Complexity

Time: O(n)  — Space: O(1)

## Post-Exercise

## References

## Implementation Notes
