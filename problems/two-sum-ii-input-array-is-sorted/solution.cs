public class Solution {
    public int[] TwoSum(int[] numbers, int target) {
        int lower = 0;
        int upper = numbers.Length - 1; //.Length >>>> .Count()
        int sum = numbers[lower] + numbers[upper];
        while(sum != target){
            if(sum > target)
                upper--;
            else
                lower++;
            sum = numbers[lower] + numbers[upper];
        }
        return new int[] {lower+1, upper+1};
    }
}