# Semaphore

[参考](https://juejin.cn/post/7042287897931677726)

## 用法
> 可以指定公平和非公平的实现
```java
public class Main {
    public static void main(String[] args) throws InterruptedException {
        // 公平锁实现
        Semaphore semaphore = new Semaphore(10, true);
        semaphore.acquire(1);
        semaphore.release(1);
    }
}
```

## 属性

## 方法
* **public void acquire(int permits)**
```apache
public void acquire(int permits) throws InterruptedException {
    if (permits < 0) throw new IllegalArgumentException();
    // 获取锁的时候响应中断
    sync.acquireSharedInterruptibly(permits);
}
```
* public final void acquireSharedInterruptibly(int arg)
```apache
public final void acquireSharedInterruptibly(int arg)
        throws InterruptedException {
    // 响应中断的逻辑
    if (Thread.interrupted())
        throw new InterruptedException();
    // 如果队列有其他等待获取的线程，直接加入队列等待唤醒
    // 如果没有足够的资源可以用，加入等待队列
    // 如果获取到了资源，成功
    if (tryAcquireShared(arg) < 0)
        doAcquireSharedInterruptibly(arg);
}
```
* protected int tryAcquireShared(int acquires)
```apache
protected int tryAcquireShared(int acquires) {
    for (;;) {
        // 队列中是否有其他线程等待获取资源
        if (hasQueuedPredecessors())
            return -1;
        // 自己已经是第一个节点尝试获取一次资源，cas成功返回剩余的资源，失败返回负数，入队等待
        int available = getState();
        int remaining = available - acquires;
        if (remaining < 0 ||
            compareAndSetState(available, remaining))
            return remaining;
    }
}
```
* public final boolean hasQueuedPredecessors()
> 判断同步队列是否有其他线程等待锁
```apache
public final boolean hasQueuedPredecessors() {
    Node h, s;
    if ((h = head) != null) {
        // 同步队列只有一个节点或者第一个节点是取消状态，从后往前找一个状态<=0的节点
        if ((s = h.next) == null || s.waitStatus > 0) {
            s = null; // traverse in case of concurrent cancellation
            for (Node p = tail; p != h && p != null; p = p.prev) {
                if (p.waitStatus <= 0)
                    s = p;
            }
        }
        // 上面那步找到了，且不是当前线程，返回同步队列不为空
        if (s != null && s.thread != Thread.currentThread())
            return true;
    }
    // 同步队列为空
    return false;
}
```
* private void doAcquireSharedInterruptibly(int arg)
> acquire失败后入队等待
```apache
private void doAcquireSharedInterruptibly(int arg)    
    throws InterruptedException {
    // 添加一个Node节点，这里会把他加入同步队列
    final Node node = addWaiter(Node.SHARED);
    boolean failed = true;
    try {
        for (;;) {
            final Node p = node.predecessor();
            // 如果是头结点或者是头结点的后继都可以尝试获取一下锁
            if (p == head) {
                // 尝试获取锁
                int r = tryAcquireShared(arg);
                // 获取成功
                if (r >= 0) {
                    //申请锁成功后，
                    setHeadAndPropagate(node, r);
                    // 就将node移出queue
                    p.next = null; // help GC
                    failed = false;
                    return;
                }
            }
            // 挂起线程
            if (shouldParkAfterFailedAcquire(p, node) &&
                parkAndCheckInterrupt())
                throw new InterruptedException();
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}
```
* private void setHeadAndPropagate(Node node, int propagate)
> 第二个参数是分配成功后剩余的资源
```apache
private void setHeadAndPropagate(Node node, int propagate) {
    // 记录旧的header
    Node h = head; // Record old head for check below
    // 设置node(head的后继)为新的head
    setHead(node);
    // 这段代码的意思是有剩余资源而且还有排队的节点就走doReleaseShared
    if (propagate > 0 || h == null || h.waitStatus < 0 ||
        (h = head) == null || h.waitStatus < 0) {
        Node s = node.next;
        if (s == null || s.isShared())
            doReleaseShared();
    }
}
```
* private void setHead(Node node)
```apache
private void setHead(Node node) {
    head = node;
    node.thread = null;
    node.prev = null;
}
```
* private void doReleaseShared()
> doReleaseShared会尝试唤醒 head后继的代表线程，如果线程已经唤醒，则仅仅设置PROPAGATE状态
```apache
private void doReleaseShared() {
    for (;;) {
        Node h = head;
        // 判断队列是否至少有两个node，没有初始化或者只有一个节点，判断head是否变化了
        if (h != null && h != tail) {
            int ws = h.waitStatus;
            // 如果状态为SIGNAL，说明h的后继是需要被通知的
            if (ws == Node.SIGNAL) {
                // 只要head成功得从SIGNAL修改为0，那么head的后继的代表线程肯定会被唤醒了
                if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))
                    continue;            // loop to recheck cases
                unparkSuccessor(h);
            }
            // 设置这种中间状态的head的status为PROPAGATE，让其status又变成负数，这样可能被被唤醒线程检测到
            else if (ws == 0 &&
                     !compareAndSetWaitStatus(h, 0, Node.PROPAGATE))
                continue;                // loop on failed CAS
        }
        if (h == head)                   // loop if head changed
            break;
    }
}
```
* **public void release(int permits)**

```apache
public void release(int permits) {
    if (permits < 0) throw new IllegalArgumentException();
    sync.releaseShared(permits);
}
```

* public final boolean releaseShared(int arg)
```apache
public final boolean releaseShared(int arg) {
    if (tryReleaseShared(arg)) {
        doReleaseShared();
        return true;
    }
    return false;
}
```

* protected final boolean tryReleaseShared(int releases)
```apache
protected final boolean tryReleaseShared(int releases) {
    for (;;) {
        int current = getState();
        int next = current + releases;
        if (next < current) // overflow
            throw new Error("Maximum permit count exceeded");
        if (compareAndSetState(current, next))
            return true;
    }
}
```
