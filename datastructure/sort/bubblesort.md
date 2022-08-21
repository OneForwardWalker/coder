# 冒泡排序
[菜鸟教程](https://www.runoob.com/w3cnote/bubble-sort.html)
> 基于交换，遇到比当前位置大的就交换，每轮都把最大的交换到最后一个位置  
> 每轮需要交换的元素都会减一
> 
```java
class Solution {
    public static void main(String[] args) {
        new Solution().bubbleSort(new int[]{3, 2, 4, 5, 9, 7, 8, 0});
    }

    public void bubbleSort(int[] nums) {
        // 循环n - 1次
        for (int i = 1; i < nums.length; i++) {
            boolean flag = true;
            // 每次从 0 到 nums.length - 1
            for (int j = 0; j < nums.length - i; j++) {
                if (nums[j] > nums[j + 1]) {
                    int temp = nums[j];
                    nums[j] = nums[j + 1];
                    nums[j + 1] = temp;
                    flag = false;
                }
            }
            // 没有发生交换代表有序
            if (flag) {
                break;
            }
        }
    }
}
```