use std::collections::HashMap;
impl Solution {
    pub fn three_sum(nums: Vec<i32>) -> Vec<Vec<i32>> {
        let mut targets:HashMap<i32,(usize,bool)> = HashMap::new();
        let mut result:Vec<Vec<i32>> = Vec::new();

        for i in (0..nums.len()) {
            targets.insert(nums[i], (i, false));
        }

        for x in (0..nums.len()) {
            for y in (0..nums.len()) {
                if x != y {
                    let sum = -(nums[x] + nums[y]);
                    if targets.contains_key(&sum) && targets[&sum].1 == false && targets[&sum].0 != x && targets[&sum].0 != y {
                        targets.insert(sum, (200,true));
                        targets.insert(nums[x], (200,true));
                        targets.insert(nums[y], (200,true));
                        result.push(vec![sum, nums[x], nums[y]])
                    }
                }
            }
        }
        result
    }
}