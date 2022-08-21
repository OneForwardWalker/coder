[reference](https://www.cnblogs.com/micrari/p/6937995.html)

# AbstractQueuedSynchronizer

AQS的主要使用方式是**继承它作为一个内部辅助类实现同步原语**，它可以简化你的并发工具的内部实现，屏蔽同步状态管理、线程的排队、等待与唤醒等底层操作。
AQS设计基于**模板方法**模式，开发者需要继承同步器并且重写指定的方法，将其组合在并发组件的实现中，调用同步器的模板方法，模板方法会调用使用者重写的方法。

## Node

* public final void acquire(int arg)

> 1. 获取独占锁，对中断不敏感（不响应中断）
> 2. 首先尝试加一次锁，成功就返回
> 3. 否则把当前线程封装成Node对象插入到队列中，在队列中会检测是否是头结点的后继，并尝试获取锁
> 4. 如果获取失败，通过LockSuppport阻塞当前线程，直到释放锁的线程唤醒或者中断，随后再次尝试获取锁，如次反复

```java
public final void acquire(int arg) {
        if (!tryAcquire(arg) &&
            // Node.EXCLUSIVE = null
            acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
            selfInterrupt();
    }
```

* protected boolean tryAcquire(int arg)

> 不同的同步类的实现不一样

* private Node addWaiter(Node mode)

> 在队列中新增一个节点

```java
private Node addWaiter(Node mode) {
        // 新增一个节点,后继为null
        Node node = new Node(Thread.currentThread(), mode);
        // Try the fast path of enq; backup to full enq on failure
        Node pred = tail;
        // 队列不为空直接尾插
        if (pred != null) {  
            node.prev = pred;
            if (compareAndSetTail(pred, node)) {
                // 设置尾节点成功后，原来的尾节点指向当前的新尾节点
                pred.next = node;
                // node是入队成功的节点
                return node;
            }
        }
        // 队列为空的时候入队
        enq(node);
        return node;
    }
```

> Node的构造方法,新增一个Node，后继为null

```java
Node(Thread thread, Node mode) {     // Used by addWaiter
            this.nextWaiter = mode;
            this.thread = thread;
        }
```

* private Node enq(final Node node)

> 将节点入队，自旋加乐观锁并发入队

```java
    private Node enq(final Node node) {
        // 自旋
        for (;;) {
            Node t = tail;
            // 队列为空
            if (t == null) { // Must initialize
                // 抢先设置头节点
                if (compareAndSetHead(new Node()))
                    // 设置尾节点            
                    tail = head;
            } else {
                // 队列不为空，尾插，先将新节点的前继指向尾结点
                node.prev = t;
                // 抢先设置尾节点，设置成功就说明入队成功
                if (compareAndSetTail(t, node)) {
                    // 设置原来尾结点的后继
                    t.next = node;
                    // 返回原来的尾节点，好像没用到
                    return t;
                }
            }
        }
    }
```

* final boolean acquireQueued(final Node node, int arg)

> 1. 在队列中通过此方法获取锁，**不响应中断**

```java
    final boolean acquireQueued(final Node node, int arg) {
        boolean failed = true;
        try {
            boolean interrupted = false;
            for (;;) {
                // 获取p的前继节点，只有一个的话就是自己
                final Node p = node.predecessor();
                // 如果节点的前继节点是head节点尝试获取锁
                if (p == head && tryAcquire(arg)) {
                    // 获取成功，把当前节点设置为头节点
                    setHead(node);
                    // 原来头节点的后继干掉
                    p.next = null; // help GC
                    failed = false;
                    // 返回false
                    return interrupted;
                }
                // 获取锁失败了，根据前继节点判断是否要阻塞
                // 如果阻塞的过程被中断，设置中断标志位为true
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    interrupted = true;
            }
        } finally {
            // 因为其他场景获取锁失败的，需要取消获取锁
            if (failed)
                cancelAcquire(node);
        }
    }
```

* private static boolean shouldParkAfterFailedAcquire(Node pred, Node node)

> 根据前驱节点的waitstaus判断是否需要阻塞当前线程

```java
    private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
        int ws = pred.waitStatus;    
        if (ws == Node.SIGNAL)
            // 前驱结点设置为-1，表示释放锁的时候会唤醒后续节点
            // 后续节点可以阻塞自己
            return true;
        if (ws > 0) {
            // 如果前继节点为取消，向前遍历，更新当前节点的前驱为往前的第一个非取消节点，回到循环继续获取锁
            do {
                node.prev = pred = pred.prev;
            } while (pred.waitStatus > 0);
            pred.next = node;
        } else {
            // waitstatus为0或者-3，设置前驱节点的状态为-1
            // 之后再获取一次锁（这边直接阻塞，会导致线程无法被唤醒）
            compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
        }
        return false;
    }
```

* private void cancelAcquire(Node node)

> 该方法实现某个node取消获取锁。

```java
private void cancelAcquire(Node node) {
        // Ignore if node doesn't exist
        if (node == null)
            return;
        node.thread = null;
        // Skip cancelled predecessors
        Node pred = node.prev;
        while (pred.waitStatus > 0)
            node.prev = pred = pred.prev;

        // 记录pred节点的后继为predNext，后续CAS会用到
        Node predNext = pred.next;

        // 将当前节点的waitstatus状态改为 1
        node.waitStatus = Node.CANCELLED;

        // 如果node是尾结点，移除自己
        // 设置尾结点为遍历到的那个非取消节点
        if (node == tail && compareAndSetTail(node, pred)) {
            // 设置最后一个节点的后继为null
            compareAndSetNext(pred, predNext, null);
        } else {
            // 如果node还有后继节点，这种情况要做的事情是把pred和后继非取消节点拼起来
            int ws;
            if (pred != head &&
                ((ws = pred.waitStatus) == Node.SIGNAL ||
                 (ws <= 0 && compareAndSetWaitStatus(pred, ws, Node.SIGNAL))) &&
                pred.thread != null) {
                Node next = node.next;
                if (next != null && next.waitStatus <= 0)
                    compareAndSetNext(pred, predNext, next);
            } else {
                unparkSuccessor(node);
            }

            node.next = node; // help GC
        }
    }
```
* private void unparkSuccessor(Node node)
> 唤醒后继线程
```java
    private void unparkSuccessor(Node node) {
        // 尝试将node的等待状态置为0,这样的话,后继争用线程可以有机会再尝试获取一次锁
        int ws = node.waitStatus;
        if (ws < 0)
            compareAndSetWaitStatus(node, ws, 0);

        // 这里的逻辑就是如果node.next存在并且状态不为取消，则直接唤醒s即可
        // 否则需要从tail开始向前找到node之后最近的非取消节点。
        Node s = node.next;
        // 1.如果s为null不代表他就是tail,
        //   不妨考虑到如下场景：
        //   node某时刻为tail
        //   有新线程通过addWaiter中的if分支或者enq方法添加自己
        //   compareAndSetTail成功
        //   此时这里的Node s = node.next读出来s == null，但事实上node已经不是tail，它有后继了!
        // 2.s.waitStatus > 0表示取消，不会唤醒
        if (s == null || s.waitStatus > 0) {
            s = null;
            for (Node t = tail; t != null && t != node; t = t.prev)
                if (t.waitStatus <= 0)
                    s = t;
        }
        // s不为null直接唤醒
        if (s != null)
            LockSupport.unpark(s.thread);
    }

```
## 流程
![](https://images2015.cnblogs.com/blog/584724/201706/584724-20170612211300368-774544064.png)
## 释放独占锁
* public final boolean release(int arg)
> 整个release做的事情就是  
1.调用tryRelease  
2.如果tryRelease返回true也就是独占锁被完全释放，唤醒后继线程。  
3.这里的唤醒是根据head几点来判断的，上面代码的注释中也分析了head节点的情况，只有在head存在并且等待状态小于零的情况下唤醒。  
```java
    public final boolean release(int arg) {
        if (tryRelease(arg)) {
            Node h = head;
            if (h != null && h.waitStatus != 0)
                unparkSuccessor(h);
            return true;
        }
        return false;
    }
```
