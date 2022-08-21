# ThreadLocal

[reference](https://www.jianshu.com/p/80866ca6c424)

> 提供了线程局部 (thread-local) 变量，这些变量与普通变量不同，每个线程都可以通过其 get 或 set方法来访问自己的独立初始化的变量副本。ThreadLocal 实例通常是类中的 private static 字段，它们希望将状态与某一个线程（例如，用户 ID 或事务 ID）相关联,只可以**存储一个值**。

## 成员变量

```java
public class ThreadLocal<T> {
    private final int threadLocalHashCode = nextHashCode();

    private static AtomicInteger nextHashCode =
        new AtomicInteger();

    private static final int HASH_INCREMENT = 0x61c88647;
```

* 初始容量 —— 必须是2的冥
* 存放数据的table，Entry类的定义在下面分析。同样，数组长度必须是2的冥
* 数组里面entrys的个数，可以用于判断table当前使用量是否超过负因子
* 进行扩容的阈值，表使用量大于它的时候进行扩容
* 阈值定义为长度的2/3

### ThreadLocalEntry->Entry，key使threadlocal对象，value是赋的值

```java
static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }
```

* Entry继承WeakReference，并且用ThreadLocal作为key.如果key为null.
  (entry.get() == null)表示key不再被引用，表示ThreadLocal对象被回收
  因此这时候entry也可以从table从清除(每个线程有一个ThreadLocalMap,里面存储了多个thread对象的值).

## get()

## ThreadLocal中的set(value)

* public void set(T value)

```java
public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            map.set(this, value);
        } else {
            createMap(t, value);
        }
    }
```

* 初始化map

```java
void createMap(Thread t, T firstValue) {
        t.threadLocals = new ThreadLocalMap(this, firstValue);
    }
```

```java
ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
            table = new Entry[INITIAL_CAPACITY];
            int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1);
            table[i] = new Entry(firstKey, firstValue);
            size = 1;
            setThreshold(INITIAL_CAPACITY);
        }
```

* 计算threadlocal对象的hash值

```java
public class ThreadLocal<T> {
    // 用到的时候才会计算
    private final int threadLocalHashCode = nextHashCode();
    // 静态对象，生成一个hash值得序列
    private static AtomicInteger nextHashCode =
        new AtomicInteger();
    // 斐波那契散列相关，使hash更加均匀
    private static final int HASH_INCREMENT = 0x61c88647;
    // 计算hash值
    private static int nextHashCode() {
        return nextHashCode.getAndAdd(HASH_INCREMENT);
    }
```

* map.set(this, value)

```java
private void set(ThreadLocal<?> key, Object value) {
            Entry[] tab = table;
            int len = tab.length;
            // 计算索引，同一个threadlocal对象的一样
            int i = key.threadLocalHashCode & (len-1);
            // 位置没有元素直接放入，有的话循环遍历，遇到可以更新的Entry终止或者某一个位置的key为null,拿到插入的位置i
            for (Entry e = tab[i];
                 e != null;
                 e = tab[i = nextIndex(i, len)]) {
                ThreadLocal<?> k = e.get();

                if (k == key) {
                    e.value = value;
                    return;
                }
                /**
                 * table[i]上的key为空，说明被回收了（上面的弱引用中提到过）。
                 * 这个时候说明改table[i]可以重新使用，用新的key-value将其替换,并删除其他无效的entry
                */
                if (k == null) {
                    replaceStaleEntry(key, value, i);
                    return;
                }
            }
            // 新建一个Entry
            tab[i] = new Entry(key, value);
            // ThreadLocalMap size++
            int sz = ++size;
            if (!cleanSomeSlots(i, sz) && sz >= threshold)
                rehash();
        }
```

* replaceStaleEntry()
  替换无效entry,后面可能有相同key的Entry?

```java
//如果向前查找没有找到无效entry，并且当前向后扫描的entry无效，则更新slotToExpunge为当前值i
private void replaceStaleEntry(ThreadLocal<?> key, Object value,
                                       int staleSlot) {
            Entry[] tab = table;
            int len = tab.length;
            Entry e;
            // 前向搜索，找到一个不为空的Entry，出现key为null的Entry肯定是因为上次GC了，而之所以去前向搜索，
            是因为很有可能其它Entry在上次GC中也没能存活。另外并不是【相邻位置有很大概率会出现stale entry】，
            而是因为它只能一个个遍历，所以从【相邻】的位置开始遍历
            int slotToExpunge = staleSlot;
            for (int i = prevIndex(staleSlot, len);
                 (e = tab[i]) != null;
                 i = prevIndex(i, len))
                if (e.get() == null)
                    slotToExpunge = i;

            // 向后遍历，是因为ThreadLocal用的是开地址，很可能当前的stale entry对应的并不是hascode为此槽索引
            的Entry，而是因为哈希冲突后移的Entry，那么很有可能hascode对应该槽的Entry会往后排。基于Thread Local Map
            中不允许有两个槽指向同一个引用的原则，如果存在那个hascode对应本槽但是在后面排列的Entry，则要【向后遍历】找到它，
            并且替换至本槽。否则直接设置值就会在Thread Local Map中存在两个指向一个ThreadLocal引用的槽
            for (int i = nextIndex(staleSlot, len);
                 (e = tab[i]) != null;
                 i = nextIndex(i, len)) {
                ThreadLocal<?> k = e.get();

                /**
                  * 如果找到了key，将其与传入的无效entry替换，也就是与table[staleSlot]进行替换
                */
                if (k == key) {
                    e.value = value;

                    tab[i] = tab[staleSlot];
                    tab[staleSlot] = e;

                    //如果向前查找没有找到无效entry，则更新slotToExpunge为当前值i
                    if (slotToExpunge == staleSlot)
                        slotToExpunge = i;
                    cleanSomeSlots(expungeStaleEntry(slotToExpunge), len);
                    return;
                }

                // 如果向前查找没有找到无效entry，并且当前向后扫描的entry无效，则更新slotToExpunge为当前值i
                if (k == null && slotToExpunge == staleSlot)
                    slotToExpunge = i;
            }

            // If key not found, put new entry in stale slot
            tab[staleSlot].value = null;
            tab[staleSlot] = new Entry(key, value);

            // If there are any other stale entries in run, expunge them
            if (slotToExpunge != staleSlot)
                cleanSomeSlots(expungeStaleEntry(slotToExpunge), len);
        }
```

* private int expungeStaleEntry(int staleSlot)

  > 清除特定位置的Entry,先把当前位置的value置为空，然后将Entry置为空。向后扫描，进行rehash，避免后面还有因为hash碰撞后移的元素（只有连续的Entry才有肯有这种情况）。
  > 清除Entry的时候也会维护hash表的性质。

  ```java
  private int expungeStaleEntry(int staleSlot) {
              Entry[] tab = table;
              int len = tab.length;

              // expunge entry at staleSlot
              tab[staleSlot].value = null;
              tab[staleSlot] = null;
              //size减1，置空后table的被使用量减1
              size--;

              // Rehash until we encounter null
              Entry e;
              int i;
              // 从staleSlot开始向后扫描一段连续的entry
              for (i = nextIndex(staleSlot, len);
                   (e = tab[i]) != null;
                   i = nextIndex(i, len)) {
                  ThreadLocal<?> k = e.get();
                  if (k == null) {
                      // 如果遇到key为null,表示无效entry，进行清理.
                      e.value = null;
                      tab[i] = null;
                      size--;
                  } else {
                      //如果key不为null,计算索引
                      int h = k.threadLocalHashCode & (len - 1);
                         /**
                            * 计算出来的索引——h，与其现在所在位置的索引——i不一致，置空当前的table[i]
                            * 从h开始向后线性探测到第一个空的slot，把当前的entry挪过去。
                         */
                          tab[i] = null;                          
                          while (tab[h] != null)
                              h = nextIndex(h, len);
                          tab[h] = e;
                      }
                  }
              }
              return i;
          }
  ```
* private boolean cleanSomeSlots(int i, int n)
> 启发式的扫描清除，扫描次数由传入的参数n决定
  ```
  private boolean cleanSomeSlots(int i, int n) {
              boolean removed = false;
              Entry[] tab = table;
              int len = tab.length;
              do {
                  i = nextIndex(i, len);
                  Entry e = tab[i];
                  // 找出Entry不为空，key为空的位置，走清理流程（清理的时候就会rehash）
                  if (e != null && e.get() == null) {
                      n = len;
                      removed = true;
                      i = expungeStaleEntry(i);
                  }
              } while ( (n >>>= 1) != 0);//控制循环次数在log2n
              return removed;
          }
  ```
* private void rehash()
> table的size超过阈值的时候，先走全清理(清理后还需要再判断一下是否超过阈值)，再走resize（扩容为原来的2倍）
  ```java
  private void rehash() {
              //全清理
              expungeStaleEntries();

              // Use lower threshold for doubling to avoid hysteresis
              if (size >= threshold - threshold / 4)
                  resize();
          }
  ```
* private void resize()
> 扩容，扩大为原来的2倍（这样保证了长度为2的冥）
  ```java
  private void resize() {
              Entry[] oldTab = table;
              int oldLen = oldTab.length;
              // 创建一个大小为原来2倍的数组
              int newLen = oldLen * 2;
              Entry[] newTab = new Entry[newLen];
              int count = 0;
              // 遍历旧的数组,中间会干掉stale ebtry,重新hash
              for (int j = 0; j < oldLen; ++j) {
                  Entry e = oldTab[j];
                  if (e != null) {
                      ThreadLocal<?> k = e.get();
                      if (k == null) {
                          e.value = null; // Help the GC
                      } else {
                          int h = k.threadLocalHashCode & (newLen - 1);
                          while (newTab[h] != null)
                              h = nextIndex(h, newLen);
                          newTab[h] = e;
                          count++;
                      }
                  }
              }

              setThreshold(newLen);
              size = count;
              table = newTab;
          }
  ```
* private void expungeStaleEntries()
> 全清理，清理所有无效entry，遍历table，找到Entry不为空，但是key为空的位置，清理单个Entry
  ```java
   private void expungeStaleEntries() {
              Entry[] tab = table;
              int len = tab.length;
              for (int j = 0; j < len; j++) {
                  Entry e = tab[j];
                  if (e != null && e.get() == null)
                      expungeStaleEntry(j);
              }
          }
  ```
* **流程**

```
代码很简单，获取当前线程，并**获取当前线程的ThreadLocalMap实例**（从getMap(Thread t)中很容易看出来）。
如果获取到的map实例不为空，调用map.set()方法，否则调用构造函数 ThreadLocal.ThreadLocalMap(this, firstValue)**实例化map**

实例化

初始化table（赋值为初始容量16）

计算索引

关于& (INITIAL_CAPACITY - 1),这是取模的一种方式，对于2的幂作为模数取模，用此代替%(2^n)，这也就是为啥容量必须为2的冥

定义了一个AtomicInteger类型(是类的一个静态变量，每次新建threadlocal对象它的值都不一样，也是把它作为threadlocal对象的hash值使用的)，每次获取当前值并加上HASH_INCREMENT，HASH_INCREMENT = 0x61c88647,关于这个值和斐波那契散列有关，其原理这里不再深究，感兴趣可自行搜索，其主要目的就是为了让哈希码能均匀的分布在2的n次方的数组里
设置Entry数组的值和size的大小
设置阈值
ThreadLocalMap中的set()
ThreadLocalMap使用线性探测法来解决哈希冲突，线性探测法的地址增量di = 1, 2, ... , m-1，其中，i为探测次数。该方法一次探测下一个地址，直到有空的地址后插入，若整个空间都找不到空余的地址，则产生溢出。假设当前table长度为16，也就是说如果计算出来key的hash值为14，如果table[14]上已经有值，并且其key与当前key不一致，那么就发生了hash冲突，这个时候将14加1得到15，取table[15]进行判断，这个时候如果还是冲突会回到0，取table[0],以此类推，直到可以插入
```

# 内存泄漏

> 由于thread和threadlocal生命周期不一致，导致key(弱引用)被回收后，value还在，value就内存泄漏。需要在get和set的流程里面做清理。

[reference](https://zhuanlan.zhihu.com/p/102571059)
# 维护hash表的性质
> 在set get和rehash的过程中都会整理key为null的元素，避免出现|k0|k0.1|k0.1|k2|k2.1|k2.2|k0.3,当key0.1的key被回收的话，获取k0.3可能获取不到，插入也会再插入到这个位置。所以key为null的时候，需要整理一下hash表，整理的逻辑有点复杂。。
