# 二分查找
```java
public class Test {
    public static void main(String[] args) {
        System.out.println(new Test().binSearch(new int[] {1,2,3,4,5,6,7,8}, 8));

    }

    private int binSearch(int[] nums, int target) {
        int left = 0;
        int right = nums.length - 1; // 注意

        while (left <= right) { // 注意
            int mid = (right + left) / 2;
            if (nums[mid] == target)
                return mid;
            else if (nums[mid] < target)
                left = mid + 1; // 注意
            else if (nums[mid] > target)
                right = mid - 1; // 注意
        }
        return -1;
    }
}
```
