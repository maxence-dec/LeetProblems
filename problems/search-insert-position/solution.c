int searchInsert(int* nums, int numsSize, int target) {
    if(nums[0] > target) return 0;
    if(nums[numsSize-1] < target) return numsSize;

    int iteration = 0;
    int pointer = numsSize/(++iteration*2);
    while(nums[pointer] != target){

        if(nums[pointer] < target && target < nums[pointer+1])
            return pointer + 1;

        int reduction = numsSize/(++iteration*2);
        if(reduction == 0) reduction = 1;

        pointer = nums[pointer] > target
            ? pointer - reduction : pointer + reduction;

    }
    return pointer;
}