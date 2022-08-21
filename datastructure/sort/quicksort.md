# 快排算法
> 选择一个数字为基准，把基准放到最终的位置，将数组分为两个，分别比基准小和大  
> 采用分治的思想

```java
 private void quickSort(int[] src, int begin, int end) {
        if (begin < end) {
            int key = src[begin];
            int i = begin;
            int j = end;
            while (i < j) {
                while (i < j && src[j] > key) {
                    j--;
                }
                if (i < j) {
                    src[i++] = src[j];
                }
                while (i < j && src[i] <= key) {
                    i++;
                }
                if (i < j) {
                    src[j--] = src[i];
                }
            }
            src[i] = key;
            quickSort(src, begin, i - 1);
            quickSort(src, i + 1, end);
        }
    }
```
# 随机快排
```java
import java.util.Random;

class Solution {
    public static void main(String[] args) {
        new Solution().findKthLargest(new int[] {3, 2, 1, 5, 6, 4}, 2);
    }

    public int findKthLargest(int[] nums, int k) {
        quicksort(nums, 0, nums.length - 1, nums.length - k);
        return nums[nums.length - k];
    }

    public void quicksort(int[] nums, int begin, int end, int index) {
        if (begin < end) {
            int randomIndex = new Random().nextInt(end - begin + 1) + begin;
            int key = nums[randomIndex];
            nums[randomIndex] = nums[begin];
            int i = begin;
            int j = end;
            while (i < j) {
                while (i < j && nums[j] > key) {
                    j--;
                }
                if (i < j) {
                    nums[i++] = nums[j];
                }
                while (i < j && nums[i] < key) {
                    i++;
                }
                if (i < j) {
                    nums[j--] = nums[i];
                }
            }
            nums[i] = key;
            quicksort(nums, begin, i - 1, index);
            quicksort(nums, i + 1, end, index);

        }
    }
}
```
