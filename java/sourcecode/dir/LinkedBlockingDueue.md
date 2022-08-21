# LinkedBlockingDeque

可选有界阻塞双端队列，基于链表

## 构造函数

### public LinkedBlockingDeque()

> 默认容量为整数的最大值

```java
    public LinkedBlockingDeque() {
        this(Integer.MAX_VALUE);
    }
```

### public LinkedBlockingDeque(int capacity)

> 带初始容量初始化

```java
    public LinkedBlockingDeque(int capacity) {
        if (capacity <= 0) throw new IllegalArgumentException();
        this.capacity = capacity;
    }
```

### public LinkedBlockingDeque(Collection<? extends E> c)

> 带集合初始化

```java
    public LinkedBlockingDeque(Collection<? extends E> c) {
        // 设置最大容量为Integer的最大值
        this(Integer.MAX_VALUE);
        // 获取本对象的可重入锁
        final ReentrantLock lock = this.lock;
        // 初始化的时候只有一个线程所以不会有竞争
        lock.lock(); // Never contended, but necessary for visibility
        try {
            for (E e : c) {
                if (e == null)
                    throw new NullPointerException();
                // 遍历，加入双端队列
                if (!linkLast(new Node<E>(e)))
                    throw new IllegalStateException("Deque full");
            }
        } finally {
            lock.unlock();
        }
    }
```

```java
    private boolean linkLast(Node<E> node) {
        // assert lock.isHeldByCurrentThread();
        if (count >= capacity)
            return false;
        Node<E> l = last;
        node.prev = l;
        last = node;
        if (first == null)
            first = node;
        else
            l.next = node;
        ++count;
        // 添加完成一个元素后，使用condition的signal方法
        notEmpty.signal();
        return true;
    }
```

### public boolean add(E e)

> 添加一个元素

```java
    public boolean add(E e) {
        addLast(e);
        return true;
    }
```

> addLast

```java
    public void addLast(E e) {
        if (!offerLast(e))
            throw new IllegalStateException("Deque full");
    }
```

> 使用了可重入锁，保证添加到链表是串行的

```java
    public boolean offerLast(E e) {
        if (e == null) throw new NullPointerException();
        Node<E> node = new Node<E>(e);
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            return linkLast(node);
        } finally {
            lock.unlock();
        }
    }
```

### public void addFirst(E e)

> 添加到第一个元素

```java
   public void addFirst(E e) {
        if (!offerFirst(e))
            throw new IllegalStateException("Deque full");
    }
```

> 获取可重入锁，添加到头部

```java
    public boolean offerFirst(E e) {
        if (e == null) throw new NullPointerException();
        Node<E> node = new Node<E>(e);
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            return linkFirst(node);
        } finally {
            lock.unlock();
        }
    }
```

> 添加到头结点

```java
    private boolean linkFirst(Node<E> node) {
        // assert lock.isHeldByCurrentThread();
        if (count >= capacity)
            return false;
        Node<E> f = first;
        node.next = f;
        first = node;
        if (last == null)
            last = node;
        else
            f.prev = node;
        ++count;
        notEmpty.signal();
        return true;
    }
```

### addLast

> 同addFirst,只是添加的位置不一样

### clear()

> 清理链表

```java
public void clear() {
        // 获取可重入锁
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            // 循环遍历清理链表
            for (Node<E> f = first; f != null; ) {
                f.item = null;
                Node<E> n = f.next;
                f.prev = null;
                f.next = null;
                f = n;
            }
            first = last = null;
            count = 0;
            // 清空后调用condition的方法
            notFull.signalAll();
        } finally {
            lock.unlock();
        }
    }
```

# public boolean contains(Object o)

> 加锁，遍历判断是否包含

```java
    public boolean contains(Object o) {
        if (o == null) return false;
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            for (Node<E> p = first; p != null; p = p.next)
                if (o.equals(p.item))
                    return true;
            return false;
        } finally {
            lock.unlock();
        }
    }
```

### public Iterator `<E>` descendingIterator()

> 返回一个**逆序的**迭代器，迭代器可以获取头结点和下一个节点

```java
    public Iterator<E> descendingIterator() {
        return new DescendingItr();
    }
```

### public int drainTo(Collection<? super E> c, int maxElements)

> 把队列的元素**移动**到另一个集合，移动的过程需要获取锁

```java
    public int drainTo(Collection<? super E> c, int maxElements) {
        if (c == null)
            throw new NullPointerException();
        if (c == this)
            throw new IllegalArgumentException();
        if (maxElements <= 0)
            return 0;
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            int n = Math.min(maxElements, count);
            for (int i = 0; i < n; i++) {
                c.add(first.item);   // In this order, in case add() throws.
                unlinkFirst();
            }
            return n;
        } finally {
            lock.unlock();
        }
    }
```

### public E element()

> 等同于getFirst

```java
    public E element() {
        return getFirst();
    }
```

### public E getFirst()

> 获取队头的元素

```java
    public E getFirst() {
        E x = peekFirst();
        if (x == null) throw new NoSuchElementException();
        return x;
    }
```

> 先获取锁，返回第一个元素，没有的话就返回null

```java
    public E peekFirst() {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            return (first == null) ? null : first.item;
        } finally {
            lock.unlock();
        }
    }
```

### public E getLast()

> 逻辑同getFirst

### public Iterator `<E>` iterator()

> 迭代器，返回正常顺序的迭代器

```java
    public Iterator<E> iterator() {
        return new Itr();
    }
```

### public boolean offer(E e)

> 添加元素，跟add没区别

```java
    public boolean offer(E e) {
        return offerLast(e);
    }
```

### public boolean offerLast(E e)

> 添加一个元素到队尾，直接返回失败的话就返回false

```java
    public boolean offerLast(E e) {
        if (e == null) throw new NullPointerException();
        Node<E> node = new Node<E>(e);
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            return linkLast(node);
        } finally {
            lock.unlock();
        }
    }
```

### public boolean offerLast(E e, long timeout, TimeUnit unit)

> 带超时添加到队尾，失败的话condition await等待

```java
    public boolean offerLast(E e, long timeout, TimeUnit unit)
        throws InterruptedException {
        if (e == null) throw new NullPointerException();
        Node<E> node = new Node<E>(e);
        long nanos = unit.toNanos(timeout);
        // 获取锁（可以被中断）
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            while (!linkLast(node)) {
                if (nanos <= 0)
                    return false;
                // condution
                nanos = notFull.awaitNanos(nanos);
            }
            return true;
        } finally {
            lock.unlock();
        }
    }
```

### public E peek()

> 获取第一个元素

```java
    public E peek() {
        return peekFirst();
    }
```

> 获取锁
> 返回第一个元素

```java
    public E peekFirst() {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            return (first == null) ? null : first.item;
        } finally {
            lock.unlock();
        }
    }
```

### public E peekLast()

> 同peekFirst()

### public E poll()

> 获取并弹出第一个元素

```java
    public E poll() {
        return pollFirst();
    }
```

> 获取锁，删除并返回第一个元素

```java
    public E pollFirst() {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            return unlinkFirst();
        } finally {
            lock.unlock();
        }
    }
```

> 删除第一个元素，通知队列非空

```java
    private E unlinkFirst() {
        // assert lock.isHeldByCurrentThread();
        Node<E> f = first;
        if (f == null)
            return null;
        Node<E> n = f.next;
        E item = f.item;
        f.item = null;
        f.next = f; // help GC
        first = n;
        if (n == null)
            last = null;
        else
            n.prev = null;
        --count;
        notFull.signal();
        return item;
    }
```
### public E poll(long timeout, TimeUnit unit)
> 阻塞获取头部元素
```java
    public E poll(long timeout, TimeUnit unit) throws InterruptedException {
        return pollFirst(timeout, unit);
    }
```
> 获取第一个元素
```java
    public E pollFirst(long timeout, TimeUnit unit)
        throws InterruptedException {
        long nanos = unit.toNanos(timeout);
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            E x;
            while ( (x = unlinkFirst()) == null) {
                if (nanos <= 0)
                    return null;
                // 队列为空就阻塞
                nanos = notEmpty.awaitNanos(nanos);
            }
            return x;
        } finally {
            lock.unlock();
        }
    }
```
### public E pollFirst()
> poll
### public E pollFirst(long timeout, TimeUnit unit)
> 等于

略...基本都是加锁操作dequeue，需要阻塞或者通知的使用lock的condition
