# CountDownLatch

一个同步器：能够让一个或者多个线程等待等待某个条件的到来再继续执行。
![](https://img-blog.csdnimg.cn/20200530104258389.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2JveV9qaWFvamlhbg==,size_16,color_FFFFFF,t_70)

## 方法

### 具体方法

* await()、await(timeout,unit)

```java
public void await() throws InterruptedException {
        // 尝试获取锁，这里传的参数并没有用到
        sync.acquireSharedInterruptibly(1);
    }
```

```java
public final void acquireSharedInterruptibly(int arg)
            throws InterruptedException {
        if (Thread.interrupted())
            throw new InterruptedException();
        // 尝试获取锁失败后，就阻塞等待
        if (tryAcquireShared(arg) < 0)
            doAcquireSharedInterruptibly(arg);
    }
```

```java
protected int tryAcquireShared(int acquires) {
            // 就是简单判断了下state是不是0，返回后state也可能为零，state在初始化的时候就是N
            return (getState() == 0) ? 1 : -1;
        }
```

```java
private void doAcquireSharedInterruptibly(int arg)
        throws InterruptedException {
        // Node.SHARED，初始化了一个Node对象，这个方法只会有主线程进来
        final Node node = addWaiter(Node.SHARED);
        boolean failed = true;
        try {
            // 自旋
            for (;;) {
                // 前继节点永远是自己
                final Node p = node.predecessor();
                // true
                if (p == head) {
                    // 判断state的状态
                    int r = tryAcquireShared(arg);
                    // 可以获取到所
                    if (r >= 0) {
                        setHeadAndPropagate(node, r);
                        p.next = null; // help GC
                        failed = false;
                        return;
                    }
                }
                // 设置waitstatus为-1，设置成功后返回false继续自旋；本来waitstatus就是-1的话，返回true,阻塞等待唤醒
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

* countDown()

```java
public void countDown() {
        sync.releaseShared(1);
    }
```

```java
public final boolean releaseShared(int arg) {
        // 改state的值，如果返回true，就可以释放锁了
        if (tryReleaseShared(arg)) {
            // 释放锁
            doReleaseShared();
            return true;
        }
        return false;
    }
```

```java
protected boolean tryReleaseShared(int releases) {
            // 自旋修改state，如果修改为0这个线程就尝试唤醒主线程
            for (;;) {
                int c = getState();
                if (c == 0)
                    return false;
                int nextc = c-1;
                if (compareAndSetState(c, nextc))
                    return nextc == 0;
            }
        }
    }
```

```java
private void doReleaseShared() {
        for (;;) {            
            Node h = head;
            // 说明有人在排队
            if (h != null && h != tail) {
                int ws = h.waitStatus;
                // 头结点的waitstaus为-1，后面有节点等待
                if (ws == Node.SIGNAL) {
                    // waitStatus从-1改为0
                    if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))
                        continue;            // loop to recheck cases
                    // 唤醒后面等待的线程
                    unparkSuccessor(h);
                }
                else if (ws == 0 &&
                         !compareAndSetWaitStatus(h, 0, Node.PROPAGATE))
                    continue;                // loop on failed CAS
            }
            if (h == head)                   // loop if head changed
                break;
        }
    }
```
unpark等待的线程
```java
private void unparkSuccessor(Node node) {

        int ws = node.waitStatus;
        if (ws < 0)
            compareAndSetWaitStatus(node, ws, 0);

        // 从后往前遍历，找到一个waitstaus<=0的节点，剔除无效的节点
        Node s = node.next;
        if (s == null || s.waitStatus > 0) {
            s = null;
            for (Node t = tail; t != null && t != node; t = t.prev)
                if (t.waitStatus <= 0)
                    s = t;
        }
        if (s != null)
            // 唤醒后面的线程
            LockSupport.unpark(s.thread);
    }
```

