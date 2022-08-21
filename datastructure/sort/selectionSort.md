# 选择排序
> 每次找到最小的，放到第一个元素,循环n-1次
> 
```java

class Solution {
    public static void main(String[] args) {
        new Solution().selectionSort(new int[]{3, 2, 4, 5, 9, 7, 8, 0});
    }

    public void selectionSort(int[] nums) {
        for (int i = 0; i < nums.length - 1; i++) {
            int min = i;
            for (int j = i + 1; j < nums.length; j++) {
                if (nums[j] < nums[min]) {
                    min = j;
                }
            }

            // 交换
            if (i != min) {
                int temp = nums[i];
                nums[i] = nums[min];
                nums[min] = temp;
            }

        }
    }
}


```