public class Solution {
    public int RemoveElement(int[] nums, int val) {
        int k = 0;
        for(int idx = nums.Length-1; idx >= 0; idx--)
        {
            if(nums[idx] == val)
                nums[idx] = nums[nums.Length - ++k];
        }
        return nums.Length-k;
    }
}