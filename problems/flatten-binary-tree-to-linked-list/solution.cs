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
    private void SetLeaf(TreeNode FlatRoot, TreeNode newR){
        if(FlatRoot.right != null)
            SetLeaf(FlatRoot.right, newR);
        else
            FlatRoot.right = newR;
    }

    public void Flatten(TreeNode root) {
        if(root == null)
            return;

        if(root.left != null)
            Flatten(root.left );

        if(root.right != null){
            TreeNode r = root.right;
            Flatten(root.right);
            if(root.left != null){
                SetLeaf(root.left, r);
                root.right = root.left;
            }
        }
        else
            root.right = root.left;

        root.left = null;
        return;
    }
}