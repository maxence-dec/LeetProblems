/**
 * Definition for a binary tree node.
 * public class TreeNode {
 *     public int val;
 *     public TreeNode left;
 *     public TreeNode right;
 *     public TreeNode(int val=0, TreeNode left=null, TreeNode right=null) {
 *         this.val = val;
 *         this.left = left;
 *         this.right = right;
 *     }
 * }
 */
public class Solution {
    public int SumNumbers(TreeNode root) {
        int tt = 0;
        runSum(root, 0, ref tt);
        return tt;
    }

    private void runSum(TreeNode node, int valBranch, ref int tt){
        int nodeValue = valBranch*10 + node.val;
        if(node.left != null)
            runSum(node.left, nodeValue, ref tt);
        if(node.right != null)
            runSum(node.right, nodeValue, ref tt);
        if(node.left == null && node.right == null)
            tt += nodeValue;
    }
}