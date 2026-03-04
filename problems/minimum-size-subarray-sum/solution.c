int minSubArrayLen(int target, int* nums, int numsSize) {
    int result = numsSize + 1;
    int lower = 0, upper = 0;

    int sum = nums[lower];
    while(1){
        if(sum >= target && result > upper - lower + 1)
            result = upper - lower + 1;

        if(sum <= target || lower == upper){
            if(++upper == numsSize) break;
            sum += nums[upper];
        }
        else
            sum -= nums[lower++];
    }
    return result == numsSize + 1 ? 0 : result;
}