public class Solution {
    int[] _resutls;

    private int stepDown(int step){
        if(_resutls[step] != 0)
            return _resutls[step];
        _resutls[step] = stepDown(step-1) + stepDown(step-2);
        return _resutls[step];
    }
    public int ClimbStairs(int n) {
        _resutls = new int[n+2];
        _resutls[0]=1;
        _resutls[1]=2;
        return stepDown(n-1);
    }
}