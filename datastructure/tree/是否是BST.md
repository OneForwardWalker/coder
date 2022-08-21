# 中序遍历有序
```java
class Solution {
    public class TreeNode {
        int val;
        TreeNode left;
        TreeNode right;

        TreeNode() {
        }

        TreeNode(int val) {
            this.val = val;
        }

        TreeNode(int val, TreeNode left, TreeNode right) {
            this.val = val;
            this.left = left;
            this.right = right;
        }
    }

    private List<Integer> list = new ArrayList<>();

    public boolean isValidBST(TreeNode root) {
        inOrder(root);
        for (int i = 0; i < list.size() - 1; i++) {
            if (list.get(i) > list.get(i + 1)) {
                return false;
            }
        }
        return true;
    }

    private void inOrder(TreeNode t) {
        if (t == null) {
            return;
        }
        inOrder(t.left);
        list.add(t.val);
        inOrder(t.right);
    }


}
```
# 递归
```java

```