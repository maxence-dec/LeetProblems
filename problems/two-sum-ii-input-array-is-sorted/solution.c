/**
 * Note: The returned array must be malloced, assume caller calls free().
 */
int* twoSum(int* numbers, int numbersSize, int target, int* returnSize) {
    int* result = (int*)malloc(2*sizeof(int));
    *returnSize = 2;

    int lower = 0, upper = numbersSize - 1;
    int sum = numbers[lower] + numbers[upper];
    while(sum != target){
        if(sum > target)
            upper--;
        else
            lower++;
        sum = numbers[lower] + numbers[upper];
    }
    result[0] = lower+1;
    result[1] = upper+1;
    return result;
}