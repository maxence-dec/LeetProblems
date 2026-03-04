public class Solution {
    private int MaxDepthParkour(TreeNode node, int depth){
        if(node == null)
            return depth;
        return Math.Max(MaxDepthParkour(node.left, depth+1), MaxDepthParkour(node.right, depth+1));
    }

    public int MaxDepth(TreeNode root) {
        if(root == null)
            return 0;
        return Math.Max(MaxDepthParkour(root.left, 1), MaxDepthParkour(root.right, 1));
    }
}