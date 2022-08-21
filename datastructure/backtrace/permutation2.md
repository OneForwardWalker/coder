# 全排列
[题目](https://leetcode.cn/problems/permutations-ii/)
> 带重复元素的全排列，需要去重，去重之前排序
```java
public class Solution {

    private final List<List<Integer>> result = new LinkedList<>();

    public static void main(String[] args) {
        new Solution().permuteUnique(new int[] {1, -1, 1, 2, -1, 2, 2, -1});
    }

    public List<List<Integer>> permuteUnique(int[] nums) {
        if (nums == null || nums.length == 0) {
            return result;
        }
        LinkedList<Integer> trace = new LinkedList<>();
        boolean[] visit = new boolean[nums.length];
        // 排序
        Arrays.sort(nums);
        backtrace(nums, trace, visit);
        return result;
    }

    private void backtrace(int[] nums, LinkedList<Integer> trace, boolean[] visit) {
        if (trace.size() == nums.length) {
            result.add(new LinkedList<>(trace));
            return;
        }
        for (int i = 0; i < nums.length; i++) {
            // 去重
            if (visit[i] || (i > 0 && nums[i] == nums[i - 1] && !visit[i - 1])) {
                continue;
            }
            trace.add(nums[i]);
            visit[i] = true;
            backtrace(nums, trace, visit);
            visit[i] = false;
            trace.removeLast();

        }
    }

}

```
