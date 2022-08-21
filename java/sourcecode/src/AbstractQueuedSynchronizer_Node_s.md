[reference](https://www.cnblogs.com/micrari/p/6937995.html)

# AbstractQueuedSynchronizer

## Node-共享锁

* public final void acquireShared(int arg)

> tryAcquireShared由实现类实现

```java
    public final void acquireShared(int arg) {
        if (tryAcquireShared(arg) < 0)
            doAcquireShared(arg);
    }
```

* private void doAcquireShared(int arg)

```java
private void doAcquireShared(int arg) {
        // 添加一个节点，addwaiter会初始化一个head,后继指向添加的节点，添加节点的nextwaiter是shared
        final Node node = addWaiter(Node.SHARED);
        boolean failed = true;
        try {
            boolean interrupted = false;
            for (;;) {
                final Node p = node.predecessor();
                if (p == head) {
                    // 是头结点的后继节点就可以参数改hi获取锁
                    int r = tryAcquireShared(arg);          
                    if (r >= 0) {
                        // 一旦共享获取成功，设置新的头结点，并且唤醒后继线程
                        setHeadAndPropagate(node, r);
                        p.next = null; // help GC
                        if (interrupted)
                            selfInterrupt();
                        failed = false;
                        return;
                    }
                }
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    interrupted = true;
            }
        } finally {
            if (failed)
                cancelAcquire(node);
        }
    }
```

* private void setHeadAndPropagate(Node node, int propagate)

> 这个函数做的事情有两件:
> 1.在获取共享锁成功后，**设置head节点**
> 2.根据调用tryAcquireShared返回的状态以及节点本身的等待状态来判断是否要需要唤醒后继线程。

```java
    private void setHeadAndPropagate(Node node, int propagate) {
        // 把当前的head封闭在方法栈上，用以下面的条件检查。
        Node h = head; // Record old head for check below
        setHead(node);
        // 当传递了传播条件的时候，继续向后唤醒其他的等待者
        if (propagate > 0 
            // 头节点为空(在其他线程被释放了)或者头结点的状态<0（有其他线程在等待）
            || h == null || h.waitStatus < 0 ||
            (h = head) == null || h.waitStatus < 0) {

            Node s = node.next;
            // 当前节点为空或者是共享模式再去唤醒后继节点
            if (s == null || s.isShared())
                doReleaseShared();
        }
    }
```

* private void doReleaseShared()

> 主要做的事情就是唤醒后续节点，与互斥锁不一样的是，这里唤醒的可能不是一个节点

```java
    private void doReleaseShared() {
        for (;;) {
            // 自旋的第一步都是首先获取头结点，头结点会被其他线程修改
            Node h = head;
            // 队列里面至少有两个节点
            if (h != null && h != tail) {
                int ws = h.waitStatus;
                // 后续有节点在等待唤醒，转换为初始状态
                if (ws == Node.SIGNAL) {
                    if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))
                        continue;            // loop to recheck cases
                    // 解锁线程
                    unparkSuccessor(h);
                }
                // 如果h节点的状态为0，需要设置为PROPAGATE用以保证唤醒的传播。
                else if (ws == 0 &&
                         !compareAndSetWaitStatus(h, 0, Node.PROPAGATE))
                    continue;                // loop on failed CAS
            }
            // 头结点改变跳出循环
            if (h == head)                   // loop if head changed
                break;
        }
    }
```

* public final boolean releaseShared(int arg)

```java
    public final boolean releaseShared(int arg) {
        // 有不同的实现
        if (tryReleaseShared(arg)) {
            // 释放成功的话就测试唤醒后续的节点
            doReleaseShared();
            return true;
        }
        return false;
    }
```
