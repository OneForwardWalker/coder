# 二叉树层序遍历
[leetcode](https://leetcode.cn/problems/binary-tree-level-order-traversal-ii/)
```java
import java.util.*;

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

    public List<List<Integer>> levelOrderBottom(TreeNode root) {
        if (root == null) {
            return new ArrayList<>();
        }
        List<List<Integer>> ret = new ArrayList<>();
        Deque<TreeNode> deque = new LinkedList<>();
        deque.offer(root);
        while (!deque.isEmpty()) {
            // 这边就是一层的数量
            int size = deque.size();
            List<Integer> list = new ArrayList<>();
            for (int i = 0; i < size; i++) {
                TreeNode node = deque.poll();
                list.add(node.val);
                if (node.left != null) {
                    deque.offer(node.left);
                }
                if (node.right != null) {
                    deque.offer(node.right);
                }
            }
            ret.add(list);
        }
        Collections.reverse(ret);
        return ret;
    }

}
```
# 不同的二叉搜索树
[leetcode95](https://leetcode.cn/problems/unique-binary-search-trees-ii/)
> 采用递归，构造所有可能的左子树和右子树
```java
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class Solution {

    class TreeNode {
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

    public static void main(String[] args) {
        new Solution().generateTrees(3);
    }

    public List<TreeNode> generateTrees(int n) {
        if (n == 0) {
            return new ArrayList<>();
        }
        return generateTrees(1, n);
    }

    public List<TreeNode> generateTrees(int start, int end) {
        List<TreeNode> allTree = new ArrayList<>();
        if (start > end) {
            allTree.add(null);
            return allTree;
        }
        for (int i = start; i < end; i++) {
            List<TreeNode> leftTree = generateTrees(start, i - 1);
            List<TreeNode> rightTree = generateTrees(i + 1, end);
            for (int j = 0; j < leftTree.size(); j++) {
                for (int k = 0; k < rightTree.size(); k++) {
                    TreeNode cur = new TreeNode(i);
                    cur.left = leftTree.get(j);
                    cur.right = rightTree.get(k);
                    allTree.add(cur);
                }
            }
        }
        return allTree;
    }
}
```
# 不同的二叉搜索树
[leetcode](https://leetcode.cn/problems/unique-binary-search-trees/)
```java
/**
 * 给你一个整数 n ，求恰由 n 个节点组成且节点值从 1 到 n 互不相同的 二叉搜索树 有多少种？返回满足题意的二叉搜索树的种数。
 * dp[i] = 由i个不同的数组成的二叉搜索树的个数
 * dp[1] = 1;
 * dp[2] =dp[0] + dp[2] + dp[1] + dp[1] + dp[2] +dp[0] = 0 + dp[1] + dp[1]
 * dp[3] = (0,3),dp[1] + dp[2]  + dp[2] + (3,0)
 * dp[4] = dp[1] + dp[3] + 2 + 2  + 3 + 1
 */
class Solution {
    public static void main(String[] args) {
        new Solution().numTrees(5);
    }

    public int numTrees(int n) {
        // 全部初始化为0
        int[] dp = new int[n + 1];
        // 0表示边界，根节点为第一个元素
        dp[0] = 1;
        dp[1] = 1;
        // i穷举所有可能的情况
        for (int i = 2; i <= n; i++) {
            // j穷举所有可能的根节点
            for (int j = 1; j <= i; j++) {
                int l = dp[j - 1];
                int r = dp[i - j];
                dp[i] += l * r;
            }
        }
        return dp[n];
    }
}
```
# 从前序与中序遍历序列构造二叉树
[leetcode](https://leetcode.cn/problems/construct-binary-tree-from-preorder-and-inorder-traversal/)
```java
import java.util.HashMap;
import java.util.Map;

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

    private HashMap<Integer, Integer> rootIndexMap = new HashMap<>();

    public TreeNode buildTree(int[] preorder, int[] inorder) {
        for (int i = 0; i < inorder.length; i++) {
            rootIndexMap.put(inorder[i], i);
        }
        return buildTree(preorder, inorder, 0, preorder.length - 1, 0, inorder.length - 1);
    }

    private TreeNode buildTree(int[] preorder, int[] inorder, int preLeft, int preRight, int inLeft, int inRight) {
        if (preLeft > preRight) {
            return null;
        }
        int preRoot = preLeft;
        int inRoot = rootIndexMap.get(preorder[preRoot]);
        int sizeLeftTree = inRoot - inLeft;
        TreeNode root = new TreeNode(preorder[preRoot]);
        root.left = buildTree(preorder, inorder, preLeft + 1, preLeft + sizeLeftTree, inLeft, inRoot - 1);
        root.right = buildTree(preorder, inorder, preLeft + sizeLeftTree + 1, preRight, inRoot + 1, inRight);
        return root;
    }
}

```
# 二叉树遍历，前序后序和中序
```java
class Solution {

    static class TreeNode {
        int val;
        TreeNode left;
        TreeNode right;

        public TreeNode() {

        }

        public TreeNode(int val) {
            this.val = val;
        }

        public TreeNode(int val, TreeNode l, TreeNode r) {
            this.val = val;
            this.left = l;
            this.right = r;
        }
    }

    public static void main(String[] args) {
        TreeNode t = new TreeNode(1);
        TreeNode t1 = new TreeNode(2);
        TreeNode t3 = new TreeNode(3);
        t.left = t1;
        t.right = t3;
        new Solution().preSearch(t);
    }

    public void preSearch(TreeNode t) {
        if (t == null) {
            return;
        }
        System.out.println(t.val);
        preSearch(t.left);
        preSearch(t.right);

    }

}


```
# 二叉树的最大深度
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

    public int maxDepth(TreeNode root) {

        return dfs(root);
    }

    private int dfs(TreeNode root) {
        if (root == null) {
            return 0;
        }
        int left = dfs(root.left);
        int right = dfs(root.right);
        return Math.max(left, right) + 1;
    }

}
```
# 二叉树的最长路径

# 路径总和（深度优先遍历）
[leetcode](https://leetcode.cn/problems/path-sum-ii/)
> 1. 深度优先遍历是先序遍历
> 2. 判断是叶子节点的标准是，左孩子和右孩子都是null。
```java
import java.util.Deque;
import java.util.LinkedList;
import java.util.List;

class Solution {

    static class TreeNode {
        int val;
        TreeNode left;
        TreeNode right;

        public TreeNode() {

        }

        public TreeNode(int val) {
            this.val = val;
        }

        public TreeNode(int val, TreeNode l, TreeNode r) {
            this.val = val;
            this.left = l;
            this.right = r;
        }
    }

    private List<List<Integer>> ret = new LinkedList();
    private Deque<Integer> deque = new LinkedList<>();

    public List<List<Integer>> pathSum(TreeNode root, int targetSum) {
        dfs(root, targetSum);
        return ret;
    }

    public void dfs(TreeNode root, int targetSum) {
        if (root == null) {
            return;
        }
        targetSum -= root.val;
        deque.offer(root.val);
        if (root.left == null && root.right == null && targetSum == 0) {
            ret.add(new LinkedList<>(deque));
        }
        System.out.println(root.val);
        dfs(root.left, targetSum);
        dfs(root.right, targetSum);
        deque.pollLast();
    }
}

```
# 从后序和中序序列构造二叉树
[leetcode](https://leetcode.cn/problems/construct-binary-tree-from-inorder-and-postorder-traversal/)
```java
import java.util.Deque;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

class Solution {

    static class TreeNode {
        int val;
        TreeNode left;
        TreeNode right;

        public TreeNode() {

        }

        public TreeNode(int val) {
            this.val = val;
        }

        public TreeNode(int val, TreeNode l, TreeNode r) {
            this.val = val;
            this.left = l;
            this.right = r;
        }
    }

    private HashMap<Integer, Integer> hashMap = new HashMap<>();

    public TreeNode buildTree(int[] inorder, int[] postorder) {
        for (int i = 0; i < inorder.length; i++) {
            hashMap.put(inorder[i], i);
        }
        return buildTree(inorder, postorder, 0, inorder.length - 1, 0, postorder.length - 1);
    }

    public TreeNode buildTree(int[] inorder, int[] postorder, int inorder_left, int inorder_right, int postorder_left, int postorder_right) {
        if (inorder_left > inorder_right) {
            return null;
        }
        // 根节点在后序遍历中的下标
        int postorder_root = postorder_right;
        // 根节点在中序遍历中的根节点
        int inorder_root = hashMap.get(postorder[postorder_root]);
        // 左子树的长度
        int size_left_subtree = inorder_root - inorder_left;
        // 建立根节点
        TreeNode root = new TreeNode(postorder[postorder_root]);
        root.left = buildTree(inorder, postorder, inorder_left, inorder_root - 1, postorder_left, postorder_left + size_left_subtree - 1);
        root.right = buildTree(inorder, postorder, inorder_root + 1, inorder_right, postorder_left + size_left_subtree, postorder_right - 1);
        return root;
    }
}


```
# 有序链表转二叉搜索树
[leetcode](https://leetcode.cn/problems/convert-sorted-list-to-binary-search-tree/)
```java
import java.util.Deque;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

class Solution {
    public class ListNode {
        int val;
        ListNode next;

        ListNode() {
        }

        ListNode(int val) {
            this.val = val;
        }

        ListNode(int val, ListNode next) {
            this.val = val;
            this.next = next;
        }
    }

    static class TreeNode {
        int val;
        TreeNode left;
        TreeNode right;

        public TreeNode() {

        }

        public TreeNode(int val) {
            this.val = val;
        }

        public TreeNode(int val, TreeNode l, TreeNode r) {
            this.val = val;
            this.left = l;
            this.right = r;
        }
    }

    public TreeNode sortedListToBST(ListNode head) {
        // 右边界是null
        return buildTree(head, null);
    }

    public TreeNode buildTree(ListNode left, ListNode right) {
        if (left == right) {
            return null;
        }
        ListNode mid = getMid(left, right);
        TreeNode root = new TreeNode(mid.val);
        root.right = buildTree(mid.next, right);
        root.left = buildTree(left, mid);
        return root;
    }

    public ListNode getMid(ListNode left, ListNode right) {
        ListNode slow = left;
        ListNode fast = left;
        while (fast != right && fast.next != right) {
            fast = fast.next;
            fast = fast.next;
            slow = slow.next;
        }
        return slow;
    }
}


```
# N叉树的层序遍历
[leetcode](https://leetcode.cn/problems/n-ary-tree-level-order-traversal/)
```java

```
