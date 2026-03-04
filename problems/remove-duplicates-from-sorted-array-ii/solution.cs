public class Solution
{
    private static void Collapse(int[] nums, int idx)
    {
        for (int i = idx; i < nums.Length - 1; i++)
            nums[i] = nums[i + 1];
    }

    public int RemoveDuplicates(int[] nums)
    {
        if (nums.Length == 1)
            return 1;
        int k = 1;
        for (int i = nums.Length - 1; i > 1; i--)
        {
            if (nums[i] == nums[i - 1] && i >= 2 && nums[i] == nums[i - 2])
            {
                Collapse(nums, i);
                continue;
            }
            k++;
        }
        return k + 1;
    }
}

// refacto
public class Solution {
    private static void Collapse(int[] nums, int[] lstIdx, int nbI){
        int cpt = 0;
        int i = 0;
        while(i < nums.Length-cpt){
            if(cpt < nbI && i+cpt == lstIdx[(nbI-1-cpt)])
                cpt++;
            else
                nums[i] = nums[i+++cpt];
        }
    }

    public int RemoveDuplicates(int[] nums) {
        if(nums.Length == 1)
            return 1;
        int[] lstIdx = new int[nums.Length-2];
        int nbIncorrect = 0;
        for(int i = nums.Length-1; i > 1; i--)
            if(nums[i] == nums[i-1] && i >= 2 && nums[i] == nums[i-2])
                lstIdx[nbIncorrect++] = i;
        if(nbIncorrect != 0)
            Collapse(nums, lstIdx, nbIncorrect);
        return nums.Length - nbIncorrect;
    }
}