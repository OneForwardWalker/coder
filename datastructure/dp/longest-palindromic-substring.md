# [回文串](https://leetcode.cn/problems/longest-palindromic-substring/solution/zui-chang-hui-wen-zi-chuan-by-leetcode-solution/)

## 动态规划
> 边界条件要清晰！！
```java
public class Solution {
    public static void main(String[] args) {
        System.out.println(new Solution().longestPalindrome("ccc"));
    }

    public String longestPalindrome(String s) {
        // 字符串长度小于2，直接返回
        if (s.length() < 2) {
            return s;
        }
        char[] chars = s.toCharArray();
        // 长度为2,字符相等，直接返回
        if (s.length() == 2 && chars[0] == chars[1]) {
            return s;
        }
        int len = chars.length;
        // dp[i][j]表示，i-j这个子串是不是回文串
        boolean[][] dp = new boolean[len][len];
        // 长度为以一定是回文串
        for (int i = 0; i < len; i++) {
            dp[i][i] = true;
        }
        // 最长回文串长度
        int maxLenth = 1;
        // 回文串的下标，-1表示没有赋值
        int beginIndex = -1;

        // 从长度为2的子串开始遍历
        for (int l = 2; l <= len; l++) {
            // i就是左边界，i+l-1是右边界
            for (int i = 0; i + l - 1 < len; i++) {
                // 是否找到
                boolean find = false;
                // 长度为2的话，需要判断是否相等
                if (l == 2 && chars[i] == chars[i + 1]) {
                    dp[i][i + l - 1] = true;
                    find = true;
                } else if (l == 2) {
                    dp[i][i + l - 1] = false;
                } else {
                    // 大于2就要利用之前存储的结果
                    if (chars[i] == chars[i + l - 1]) {
                        dp[i][i + l - 1] = dp[i + 1][i + l - 2];
                        find = dp[i][i + l - 1];
                    } else {
                        dp[i][i + l - 1] = false;
                    }
                }
                if (find && l > maxLenth) {
                    maxLenth = l;
                    beginIndex = i;
                }
            }
        }
        if (beginIndex == -1) {
            return Character.toString(chars[0]);
        }
        return s.substring(beginIndex, beginIndex + maxLenth);
    }

}
```
## 中心扩展算法
```java
public class Solution {
    public static void main(String[] args) {
        System.out.println(new Solution().longestPalindrome("cbbd"));
    }

    public String longestPalindrome(String s) {
        // 空串或者长度为1，是回文串
        if (s == null) {
            return "";
        }
        if (s.length() <= 1) {
            return s;
        }
        
        // 设置初始最大长度
        int maxLen = 1;
        // 初始回文串索引，-1代表没有找到更大的
        int beginIndex = -1;
        char[] chars = s.toCharArray();
        // 长度至少是2，遍历中心点
        for (int i = 0; i < chars.length; i++) {
            // 中心点为单个元素或者相邻的相同元素
            // 单个元素
            int r = i;
            while (r < chars.length - 1 && chars[r] == chars[r + 1]) {
                r++;
            }
            // 找到中心点或或中心段 i-r,扩散
            int sreadOffset = spread(i, r, chars);
            // 求长度要注意下
            if (maxLen < (r - i + 1 + 2 * sreadOffset)) {
                maxLen = r - i + 1 + 2 * sreadOffset;
                beginIndex = i - sreadOffset;
            }
            i = r;
        }

        return beginIndex == -1 ? Character.toString(chars[0]) : s.substring(beginIndex, beginIndex + maxLen);
    }

    private int spread(int i, int j, char[] chars) {
        int offset = 0;
        // 注意边界条件
        while (i - offset - 1 >= 0 && j + offset + 1 < chars.length && chars[i - offset - 1] == chars[j + offset + 1]) {
            offset++;
        }
        return offset;
    }

}
```
