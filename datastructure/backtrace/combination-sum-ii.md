# 组合总数
[题目](https://leetcode.cn/problems/combination-sum-ii/)
> 回溯的元素有重复的，需要剪枝否组会重复
```java

public class Solution {

    private final List<List<Integer>> result = new LinkedList<>();
    private final HashSet<String> hashSet = new HashSet<>();

    public static void main(String[] args) {
        new Solution().combinationSum2(new int[] {10,1,2,7,6,1,5}, 8);
    }

    public List<List<Integer>> combinationSum2(int[] candidates, int target) {
        if (candidates == null || candidates.length == 0) {
            return result;
        }


        List<Integer> nums = Arrays.stream(candidates).boxed().sorted(Integer::compare).collect(Collectors.toList());

        if (nums.parallelStream().reduce(Integer::sum).get() < target) {
            return result;
        }

        LinkedList<Integer> trace = new LinkedList<>();
        backtrace(nums, trace, target,0);

        return result;
    }

    private void backtrace(List<Integer> nums, LinkedList<Integer> trace, int target, int begin) {
        int sum = sum(nums, trace);

        if (sum == target) {
            String key = genKey(nums, trace);
            if (hashSet.contains(key)) {
                return;
            }
            result.add(genOneResult(nums, trace));
            hashSet.add(key);
            return;
        }
        if (sum > target) {
            return;
        }
        if (trace.size() == nums.size()) {
            return;
        }
        for (int i = begin; i < nums.size(); i++) {
            if (trace.contains(i)) {
                continue;
            }
            if (i > begin && nums.get(i).equals(nums.get(begin))) {
                continue;
            }
            trace.add(i);
            backtrace(nums, trace, target, begin + 1);
            trace.removeLast();
        }
    }

    private int sum(List<Integer> list, LinkedList<Integer> trace) {
        int sum = 0;
        for (int i = 0; i < trace.size(); i++) {
            sum += list.get(trace.get(i));
        }
        return sum;
    }

    private String genKey(List<Integer> list, LinkedList<Integer> trace) {
        StringBuilder key = new StringBuilder();
        List<Integer> list1 = new ArrayList<>();
        for (Integer value : trace) {
            list1.add(list.get(value));
        }
        list1 = list1.stream().sorted(Integer::compare).collect(Collectors.toList());
        for (Integer integer : list1) {
            key.append(integer);
            key.append(",");
        }
        return key.toString();
    }

    private List<Integer> genOneResult(List<Integer> nums, LinkedList<Integer> trace) {
        LinkedList<Integer> linkedList = new LinkedList<>();

        for (Integer integer : trace) {
            linkedList.add(nums.get(integer));
        }
        return linkedList;
    }
}

```
