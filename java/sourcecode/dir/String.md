# String
## 实现接口
> Serializable,没有接口，声明可序列化的语义  
> Compareable,只有一个compareTo(T t)接口
> CharSequence,是一个只读的字符串序列，包括length(),charAt(int index),subSequence(int start, int end)。
## 主要变量
> private final char value[],字符串实际是用字符数组存储的  
> private int hash,String hash code实例化的一个缓存
> 忽略大小写比较字符串的一个内部类，用户代码复用
## 方法
### 初始化
> 给value赋值
### length、isEmpty、charAt
> 都是在调用数组的方法
### getChars
> 使用，System.arraycopy()实现字符串拷贝
### getBytes(int srcBegin, int srcEnd, byte dst[], int dstBegin)
> 遍历char数组，每个字符转换为byte,赋值带dst
### getBytes(String charsetName),指定字符集，转byte数组
> 调用StringCoding.encode方法
### equals(Object anObject)
> 比较内存地址，一样的话返回true  
> 是字符串类型的话，遍历比较
### public boolean contentEquals(CharSequence cs) 多个重载
> 比较内容是否相等，基本都是遍历比较；如果是StringBuffer，需要加synchronized锁，避免在比较的过程中StringBuffer被修改，然后循环遍历比较；如果是String或者CharSequence类型就可以循环遍历
### public int compareTo(String anotherString)
> 先找到字符串长度小的那个字符串（避免数组越界），核心就是那个while循环，通过从第一个开始比较每一个字符，当遇到第一个较小的字符时，判定该字符串小。但还有一种是在较小长度的字符粗每个字符都和另一个字符串的每个字符相等，那么字符串长度较大的较大。
### public int compareToIgnoreCase(String str)
> 调用的String的内部类
###  public boolean regionMatches(int toffset, String other, int ooffset, int len)
> 比较该字符串和其他一个字符串从分别指定地点开始的n个字符是否相等。看代码可知道，其原理还是通过一个while去循环对应的比较区域进行判断，但在比较之前会做判定，判定给定参数是否越界。
### public int indexOf(int ch, int fromIndex)
> 判断当前字符串是否以某一段其他字符串开始的，和其他字符串比较方法一样，其实就是通过一个while来循环比较
### public String substring(int beginIndex)
> 其实就是指定头尾，然后构造一个新的字符串,new String(value,beginIndex,subLen)
### replace(char oldChar, char newChar)
> 先找到第一个匹配的位置（应该是怕有多余的赋值操作），然后new新的char数组，逐个比较赋值
### public String trim()
> 原理是通过找出前后第一个不是空格的字符串，返回原字符串的该子串
### 还有一些用到正则的方法
