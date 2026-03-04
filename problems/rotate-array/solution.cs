public class Solution
{
    public void Rotate(int[] nums, int k)
    {
        if (nums.Length < 2 || k == nums.Length || k < 1)
            return;
        k %= nums.Length;
        int[] temps = new int[k];
        for (int i = 0; i < k; i++)
            temps[i] = nums[nums.Length - k + i];
        for (int i = 0; i < nums.Length; i++)
        {
            (temps[i % k], nums[i]) = (nums[i], temps[i % k]);
        }
    }
}

// refacto (+solutions help)
public class Solution {
    public void Rotate(int[] nums, int k) {
        int n = nums.Length;
        k %= n;
        Reverse(nums, 0, n - 1);
        Reverse(nums, 0, k - 1);
        Reverse(nums, k, n - 1);
    }
    private void Reverse(int[] nums, int s, int e) {
        while (e > s) {
            (nums[e], nums[s]) = (nums[s], nums[e]);
            s++;
            e--;
        }
    }
}
