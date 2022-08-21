# 全排列
> 元素互不相同，标准的回溯算法模板
[题目](https://leetcode.cn/problems/permutations/)
```java
public class Solution {

    private final List<List<Integer>> result = new LinkedList<>();

    public static void main(String[] args) {

    }

    public List<List<Integer>> permute(int[] nums) {
        if (nums == null || nums.length == 0) {
            return result;
        }
        LinkedList<Integer> trace = new LinkedList<>();
        backtrace(nums, trace);
        return result;
    }

    private void backtrace(int[] nums, LinkedList<Integer> trace) {
        if(trace.size() == nums.length) {
            result.add(new LinkedList<>(trace));
            return;
        }
        for (int i = 0; i < nums.length; i++) {
            if(trace.contains(nums[i])) {
                continue;
            }
            trace.add(nums[i]);
            backtrace(nums,trace);
            trace.removeLast();
        }
    }
}

```
