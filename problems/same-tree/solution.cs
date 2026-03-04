public class Solution {
    public bool IsSameTree(TreeNode p, TreeNode q) {
        if(p == null && q == null)
            return true;
        else if (p == null || q == null)
            return false;
        if(p.val == q.val)
            return IsSameTree(p.left, q.left) && IsSameTree(p.right, q.right);
        return false;
    }
}