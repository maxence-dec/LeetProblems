public class Solution {
    public int RemoveDuplicates(int[] nums) {
        bool[] intExists = new bool[201];
        int k = 0;
        for(int i = 0; i < nums.Length; i++)
        {
            if(!intExists[nums[i]+100])
            {
                intExists[nums[i]+100] = true;
                nums[k] = nums[i];
                k++;
            }
        }
        return k;
    }
}