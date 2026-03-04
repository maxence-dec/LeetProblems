public class Solution
{
    public int MajorityElement(int[] nums)
    {
        Dictionary<int, int> valueCount = new();
        foreach (int i in nums)
        {
            if (valueCount.ContainsKey(i))
            {
                valueCount[i]++;
                if (valueCount[i] >= nums.Length / 2 + 1)
                    return i;
            }
            else
                valueCount[i] = 1;
        }
        return nums[0];
    }
}


//Boyer–Moore majority vote implementation by https://leetcode.com/u/5ldv/
public class Solution {
    public int MajorityElement(int[] nums) {
        int Majority = 0;
        int Count = 0;
        for(int i = 0; i < nums.Length; i++)
        {
            if(Count == 0)
                Majority = nums[i];

            if(nums[i] == Majority)
                Count++;
            else
                Count--;
        }
        return Majority;
    }
}