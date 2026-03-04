public class Solution {
    public bool CanJump(int[] nums) {
        int maxJumpRange = nums[0];
        for(int i = 0; i < nums.Length-1; i++){
            if(nums[i] == 0 && maxJumpRange <= i)
                return false;
            if(nums[i] + i> maxJumpRange)
                maxJumpRange = nums[i] + i;
        }
        return true;
    }
}