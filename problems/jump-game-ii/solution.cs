public class Solution
{
    public int Jump(int[] nums)
    {
        return jumpFrom(nums, nums.Length - 1);
    }

    private int jumpFrom(int[] nums, int k)
    {
        if (k == 0)
            return 0;
        int jumps = nums.Length;
        for (int i = 0; i < k; i++)
        {
            if (i + nums[i] >= k)
            {
                jumps = jumpFrom(nums, i);
                break;
            }
        }
        return jumps + 1;
    }
}

// Non-recursive
public class Solution
{
    public int Jump(int[] nums)
    {
        int k = nums.Length - 1;
        int jumps = 0;
        while (k != 0)
        {
            for (int i = 0; i < k; i++)
            {
                if (i + nums[i] >= k)
                {
                    k = i;
                    jumps++;
                    break;
                }
            }
        }
        return jumps;
    }
}

// O(n) https://leetcode.com/u/r9n/
public class Solution {
    public int Jump(int[] nums) {
        int jumps = 0, farthest = 0, end = 0;

        for (int i = 0; i < nums.Length - 1; i++) {
            // Update the farthest point we can reach
            farthest = Math.Max(farthest, i + nums[i]);

            // If we've reached the current end, we need to jump
            if (i == end) {
                jumps++;
                end = farthest; // Update the range for the next jump
            }
        }

        return jumps;
    }
}