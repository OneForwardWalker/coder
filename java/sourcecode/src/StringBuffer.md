# StringBuffer
[reference](https://blog.csdn.net/wqqqianqian/article/details/80001256)
## 构造函数
### public StringBuffer()
> 实际上调用到AbstractStringBuilder里面，初始化一个长度为16的char数组
### public StringBuffer(int capacity)
> 构造一个不带字符，但具有指定初始容量的字符串缓冲区
### public StringBuffer(String str)
> 先调用父类的构造方法构造长度为str.lenth+16的长度，再append(append 是用 synchronized 修饰的,所以是线程安全的),执行父类的append(str)  

略...
# 保证线程安全
# 方法通过synchronized保证线程安全，集成了抽象类AbstractStringBuilder，实现的方法**不完全**是线程安全的。

