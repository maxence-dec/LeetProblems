public class Solution {
    public int[] TwoSum(int[] nums, int target) {
        Dictionary<int, int> dict = new Dictionary<int, int>();
        int i = 0;
        while ( i < nums.Length) {
            if (dict.ContainsKey(target - nums[i]))
                break;
            dict[nums[i]] = i;
            i++;
        }
        return new int[] { dict[target - nums[i]], i };
    }
}