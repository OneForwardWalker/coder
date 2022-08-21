# AbstractQueuedSynchronizer

## Node屬性
[参考](https://juejin.cn/post/6940640373655994399)
```java
static final class Node {
        // 共享鎖 
        static final Node SHARED = new Node();
        // 互斥鎖
        static final Node EXCLUSIVE = null;
        // 取消获取锁
        static final int CANCELLED =  1;
        // 标识需要被前面的节点唤醒
        static final int SIGNAL    = -1;
        // condition节点，在等待队列，等待加入条件队列。结合BlockingQueue说明
        static final int CONDITION = -2;
        // 结合Semaphore说明
        static final int PROPAGATE = -3;

        volatile int waitStatus;

        // 前驱节点
        volatile Node prev;

        // 后继节点
        volatile Node next;
        // Node对应的线程
        volatile Thread thread;
        // 赋值为最开始的共享锁或者互斥锁
        Node nextWaiter;

```