using System.Collections.Generic;

public class Solution
{
    private ReaderWriterLockSlim cacheLock = new ReaderWriterLockSlim();
    private const int MOD = 1_000_000_007;
    public int XorAfterQueries(int[] nums, int[][] queries)
    {
        ulong[] longNums = new ulong[nums.Length];
        for (int idx = 0; idx < longNums.Length; idx++)
            longNums[idx] = (ulong)nums[idx];

        int subQuerySize = nums.Length == 1 ? 1 : (int)Math.sqrt(nums.Length);
        Dictionary<int, List<int[]>> queriesByStep = new();

        foreach (int[] querie in queries)
        {
            if (querie[2] * querie[2] <= querie.Length)
            {
                if (queriesByStep.ContainsKey(querie[2]))
                    queriesByStep.ContainsKey(querie[2]) = new();
                queriesByStep.ContainsKey(querie[2]).Add(querie);
            }
            else
            {
                for (int idx = querie[0]; idx <= querie[1]; idx += querie[2])
                    longNums[idx] = longNums[idx] * (ulong)querie[3] % MOD;
            }
        }

        foreach (int step in queriesByStep.Keys)
        {

        }

        if (longNums.Length == 1)
            return (int)longNums[0];

        ulong result = longNums[0];
        for (int idx = 1; idx < longNums.Length; idx++)
            result ^= longNums[idx];
        return (int)result;
    }
}