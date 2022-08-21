# ConcurrentHashMap
[参考](https://blog.csdn.net/sihai12345/article/details/79383766)
## `初始化`
1. 空的构造函数，啥都不干
2. 带初始容量的构造函数，会重新计算容量，sizeCtl=(1.5*initialCapacity + 1)然后向上找最近的2的n次方
## `put方法`
### `调用`：
1. put(key)->putVal(key,value)
### `流程`：
1. 得到hash值： 
    spread(hash)，这里避免计算出的hash值为负数，大概是为了避免与内置的MOVED/TREEBIN/RESERVED这三个hash函数冲突  
2. binCount记录相应链表的长度
3. 开始自旋
4. 如果数组为空，**初始化**  
   1. 考虑并发，CAS将sizeCtl设置为-1，加锁进行初始化，没有抢到锁的线程，结束循环，其他进入循环的线程判断sizeCtr是否为-1，是的话通过Thread.yeild(),让线程进入就绪状态
   2. 初始化完成后，自旋重新进入循环
5. 数组不为空的话，找到hash值对应的数组下标，得到第一个节点f（使用getObjectVolidate获取的）  
    1. 如果这个节点为空，通过cas赋值，成功的结束循环，失败的需要再次进入循环
6. hash=MOVED?？
7. 找到了数组下标的第一个元素f,并且不为空，通过synchronized对f加锁  
   1. 再次判断，此时hash的下标是不是等于f
      1. f的hash值大于等于0，说明是链表？？  
         1. 记录链表的长度，bitConut = 1;
         2. 遍历链表，发现相等的key就做替换，否则在末尾添加一个节点
      2. 红黑树的话执行树的插入留存，binCount设置为2
8. 判断binCount是否大于树化阈值8，大于的话进行树化
   1. 小于阈值不树化
      1. 这个方法和 HashMap 中稍微有一点点不同，那就是它不是一定会进行红黑树转换，如果当前数组的长度小于 64，那么会选择进行数组扩容，而不是转换为红黑树
      2. **扩容**
         1. tryPresize(int size),扩容的目标size是原来size的1.5倍加1，然后向上取最近的2的n次方
      3. **迁移**
   2. 树化：
      1. 对头结点加锁，遍历链表，建立红黑树，把树放到相应的位置
9. 添加节点后需要把总个数加1，***addCount()***  ，添加总结点书流程如下  
   1.  CAS吧baseCount设置成baseCount + X，失败操作counterCells数组
   2.  随机获取counterCells的一个元素，值为a
   3.  CAS把a设置为a+x,失败就如fullAddCount方法自旋增加
## `size`
### `使用baseCount和counterCells两个变量维护`
1. 没有并发的时候使用vilatile修饰的baseCount即可
2. 有并发的时候使用，baseCount的值加上baseCount数组各位的值返回总的数组个数；所以返回的是一个估算值，和实际的数量有所不同
3. 为什么不直接使用baseCount，在有并发的时候，插入或者删除都要自旋修改baseCount，冲突的概率很大，这时候就随机选择counterCells中的一个下标的记录进行赋值或者修改
### `mappingCount`
1. map的大小超过Integer类型的最大值后可以使用mappingCount获取最大值
### `注意点`
1. key和value都不能为空
   1. 会有二义性，当我们用get方法获取一个key的时候，如果结果为null,可能没有这个key，也可能这个key的value为0(在get(key)和containskey之间)
   2. hashmap可以为null，因为containskey的返回值不一样
