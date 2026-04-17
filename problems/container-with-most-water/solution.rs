impl Solution {

    pub fn max_area(height: Vec<i32>) -> i32 {
        let mut lower_bound: usize = 0;
        let mut upper_bound: usize = height.len() - 1;

        let mut result = 0;

        while lower_bound < upper_bound {
            let current_area = (upper_bound - lower_bound) as i32 * cmp::min(height[lower_bound], height[upper_bound]);
            result = cmp::max(result, current_area);

            if height[lower_bound] > height[upper_bound] { upper_bound -= 1; }
            else { lower_bound += 1; }
        }
        result
    }
}
