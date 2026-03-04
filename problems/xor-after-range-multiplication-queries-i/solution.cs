public class Solution {
    public int XorAfterQueries(int[] nums, int[][] queries)
    {
        ulong[] longNums = new ulong[nums.Length];
        for (int idx = 0; idx < longNums.Length; idx++)
            longNums[idx] = (ulong)nums[idx];

        foreach (int[] querie in queries)
        {
            for (int idx = querie[0]; idx <= querie[1]; idx += querie[2])
                longNums[idx] = longNums[idx] * (ulong)querie[3] % (1000000000 + 7);
        }
        if(longNums.Length == 1)
            return (int)longNums[0];
        ulong result = longNums[0];
        for (int idx = 1; idx < longNums.Length; idx++)
            result ^= longNums[idx];
        return (int)result;
    }
}