# java8 Hashmap
[reference](https://blog.csdn.net/u013124587/article/details/52649867)
## `类属性`

```java
class hashMap {
    static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16 初始容量
        static final int MAXIMUM_CAPACITY = 1 << 30; // 最大容量
        static final float DEFAULT_LOAD_FACTOR = 0.75f; //负载因
        static final int TREEIFY_THRESHOLD = 8;// 变成树的临界值
        static final int UNTREEIFY_THRESHOLD = 6;// 变回链表的临界值
        static final int MIN_TREEIFY_CAPACITY = 64;// 当哈希表的大小超过这个阈值，才会把链式结构转化成树型结构，否则仅采取扩容来尝试减少冲突
        //哈希表(存捅的)
        transient Node<K,V>[] table;
        //哈希表中键值对的个数
        transient int size;
        //哈希表被修改的次数
        transient int modCount;
        //它是通过capacity*load factor计算出来的，当size到达这个值时，就会进行扩容操作
        int threshold;
        //负载因子
        final float loadFactor;
}
```

## Node类
> 链表节点的类型，包含key/value/hash/next字段
```java
static class Node<K,V> implements Map.Entry<K,V> {
    final int hash;
    final K key;
    V value;
    Node<K,V> next;
}
```

## get(key):
> 实现步骤大致如下：  
    1、通过hash值获取该key映射到的桶。  
    2、桶上的key就是要查找的key，则直接命中。  
    3、桶上的key不是要查找的key，则查看后续节点：  
    　（1）如果后续节点是树节点，通过调用树的方法查找该key。  
    　（2）如果后续节点是链式节点，则通过循环遍历链查找该key。  
* public V get(Object key)
```java
public V get(Object key) {
    Node<K,V> e;
    // 计算key的hash值，获取节点的值
    return (e = getNode(hash(key), key)) == null ? null : e.value;
}
```
* hash
> 求hash值，key的hashcode异或hashcode右移16位的结果，充分利用hashcode的高位
```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```
* getNode()
```java
final Node<K,V> getNode(int hash, Object key) {
    Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
    // 判断hash表不为空和key对应的桶上不为空
    if ((tab = table) != null && (n = tab.length) > 0 &&
        (first = tab[(n - 1) & hash]) != null) {
        // 是否直接命中
        if (first.hash == hash && // always check first node
            // 这里比较了key的内存地址和存储的值，两个有一个相等就行
            ((k = first.key) == key || (key != null && key.equals(k))))
            return first;
        // 判断是都有hash碰撞
        if ((e = first.next) != null) {
            // 如果是树化后的，调用树的查找算法
            if (first instanceof TreeNode)
                return ((TreeNode<K,V>)first).getTreeNode(hash, key);
            // 如果是链表，遍历获取
            do {
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    return e;
            } while ((e = e.next) != null);
        }
    }
    return null;
}
```
## `put`
* public V put(K key, V value)
```java
public V put(K key, V value) {
    return putVal(hash(key), key, value, false, true);
}
```
* final V putVal(int hash, K key, V value, boolean onlyIfAbsent, boolean evict)
```java
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
               boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    // 如果hash表为空就初始化一个hash表
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
        
    // 如果当前hash桶没有冲突，直接插入
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    else {
        Node<K,V> e; K k;
        // 如果桶上节点的key与当前key重复，那你就是我要找的节点了,这边就是做更新
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            e = p;
        // 如果是采用红黑树的方式处理冲突，则通过红黑树的putTreeVal方法去插入这个键值对
        else if (p instanceof TreeNode)
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        // 否则就是传统的链式结构
        else {
            // 采用循环遍历的方式，判断链中是否有重复的key
            for (int binCount = 0; ; ++binCount) {
                // 到了链尾还没找到重复的key，则说明HashMap没有包含该键
                if ((e = p.next) == null) {
                    // 创建一个新节点插入到尾部
                    p.next = newNode(hash, key, value, null);
                    // 链的长度大于TREEIFY_THRESHOLD=8这个临界值，则把链变为红黑树
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        // hash表的长度大于等于64的时候才会树化，否则还是走扩容
                        treeifyBin(tab, hash);
                    break;
                }
                // 找到了重复的key，就是替换
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    break;
                p = e;
            }
        }
        // e是存在的意思，如果上面找到了e就是做更新，再判断一下是不是onlyifabsent的，不是的话就直接更新
        if (e != null) { // existing mapping for key
            V oldValue = e.value;
            // 处理onlyIfAbsent
            if (!onlyIfAbsent || oldValue == null)
                e.value = value;
            // hashmap的话不会报错，在linkedhashmap里面有实现
            afterNodeAccess(e);
            return oldValue;
        }
    }
    // 更新不会修改modCount,增加才会
    ++modCount;
    // size是总的键值对个数，阈值是总的个数和负载因子的乘积
    if (++size > threshold)
        resize();
    // 这个方法在linkedhashmap里面才有实现
    afterNodeInsertion(evict);
    return null;
}
```

## `remove`
* public V remove(Object key)
> 返回删除的值
```java
public V remove(Object key) {
    Node<K,V> e;
    return (e = removeNode(hash(key), key, null, false, true)) == null ?
    null : e.value;
}
```
* final Node<K,V> removeNode(int hash, Object key, Object value, boolean matchValue, boolean movable)
```java
final Node<K,V> removeNode(int hash, Object key, Object value,
                           boolean matchValue, boolean movable) {
    Node<K,V>[] tab; Node<K,V> p; int n, index;
    // 如果当前key映射到的桶不为空
    if ((tab = table) != null && (n = tab.length) > 0 &&
        (p = tab[index = (n - 1) & hash]) != null) {
        Node<K,V> node = null, e; K k; V v;
        // 如果桶上的节点就是要找的key，则直接命中
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
            node = p;
        // 查找的时候冲突了
        else if ((e = p.next) != null) {
            // 在红黑树中查找
            if (p instanceof TreeNode)
                node = ((TreeNode<K,V>)p).getTreeNode(hash, key);
            // 在链表中查找
            else {
                do {
                    if (e.hash == hash &&
                        ((k = e.key) == key ||
                         (key != null && key.equals(k)))) {
                        node = e;
                        break;
                    }
                    p = e;
                } while ((e = e.next) != null);
            }
        }
        // 找到了要删除的节点，不匹配值matchValue=false,删除
        if (node != null && (!matchValue || (v = node.value) == value ||
                             (value != null && value.equals(v)))) {
            // 通过调用红黑树的方法来删除节点
            if (node instanceof TreeNode)
                ((TreeNode<K,V>)node).removeTreeNode(this, tab, movable);
            // 使用链表的操作来删除节点
            else if (node == p)
                tab[index] = node.next;
            else
                p.next = node.next;
            // 删除也会增加修改次数
            ++modCount;
            // 容量-1
            --size;
            // hashmap没有操作
            afterNodeRemoval(node);
            return node;
        }
    }
    return null;
}
```


## `resize`
* final Node<K,V>[] resize()
> 每次以2的倍数扩容，所以扩容后的节点要么在原位置，要么在原位置+旧容量，保证了rehash后每个桶上的节点的个数必定小于原来桶上的个数，
> 保证了rehash之后不会出现更严重的冲突
```java
final Node<K,V>[] resize() {
        Node<K,V>[] oldTab = table;
        int oldCap = (oldTab == null) ? 0 : oldTab.length;
        int oldThr = threshold;
        int newCap, newThr = 0;
        // 计算扩容后的阈值和容量
        // 旧表不为空
        if (oldCap > 0) {
            // 旧表的容量大于最大值们无法扩容，返回旧表
            if (oldCap >= MAXIMUM_CAPACITY) {
                threshold = Integer.MAX_VALUE;
                return oldTab;
            }
            // 没超过最大值则扩为原来的两倍，这里有一点，就是没有达到最大值就可以扩容
            else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                     oldCap >= DEFAULT_INITIAL_CAPACITY)
                // 阈值左移1位
                newThr = oldThr << 1; // double threshold
        }
        else if (oldThr > 0) // initial capacity was placed in threshold
            newCap = oldThr;
        else {               // 初始化，新的阈值和容量，zero initial threshold signifies using defaults
            newCap = DEFAULT_INITIAL_CAPACITY;
            newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
        }
        if (newThr == 0) {
            float ft = (float)newCap * loadFactor;
            newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                      (int)ft : Integer.MAX_VALUE);
        }
        // 新的阈值
        threshold = newThr;
        @SuppressWarnings({"rawtypes","unchecked"})
        // 创建新的哈希表
        Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
        table = newTab;
        // 遍历旧哈希表的每个桶，重新计算桶里元素的新位置
        if (oldTab != null) {
            for (int j = 0; j < oldCap; ++j) {
                Node<K,V> e;
                if ((e = oldTab[j]) != null) {
                    oldTab[j] = null;
                    //如果桶上只有一个键值对，则直接插入
                    if (e.next == null)
                        newTab[e.hash & (newCap - 1)] = e;
                    // 如果是通过红黑树来处理冲突的，则调用相关方法把树分离开
                    else if (e instanceof TreeNode)
                        ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                    //如果采用链式处理冲突，这里不用树化，肯定是没有达到树化阈值的
                    else { // preserve order
                        Node<K,V> loHead = null, loTail = null;
                        Node<K,V> hiHead = null, hiTail = null;
                        Node<K,V> next;
                        do {
                            next = e.next;
                            if ((e.hash & oldCap) == 0) {
                                if (loTail == null)
                                    loHead = e;
                                else
                                    loTail.next = e;
                                loTail = e;
                            }
                            else {
                                if (hiTail == null)
                                    hiHead = e;
                                else
                                    hiTail.next = e;
                                hiTail = e;
                            }
                        } while ((e = next) != null);
                        if (loTail != null) {
                            loTail.next = null;
                            newTab[j] = loHead;
                        }
                        if (hiTail != null) {
                            hiTail.next = null;
                            newTab[j + oldCap] = hiHead;
                        }
                    }
                }
            }
        }
        return newTab;
    }
```



## `注意点`
1. 允许key，value为空
2. 在这里有一个需要注意的地方，有些文章指出当哈希表的桶占用超过阈值时就进行扩容，这是不对的；实际上是当哈希表中的键值对个数超过阈值时，才进行扩容的
