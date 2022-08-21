[reference](https://www.cnblogs.com/micrari/p/7219751.html)

# AbstractQueuedSynchronizer

Condition在JUC中使用很多，最常见的就是各种BlockingQueue了。

## 流程

以LinkedBlockingDeque为例

* await流程，这个是具体到一个条件，比如队列满条件是notfull这个conditionObject，调用这个condition下的await:

1. 创建节点加入到条件队列
   1. 触发时机
      1. 当队列慢，有入队请求
      2. 当队列空，有出队请求
   2. 流程
      1. 最开始持有锁，添加一个元素到条件队列（这里是没有竟态的，外部有锁）
         1. 顺序添加一个节点到条件队列中去
      2. 添加到等待队列后，就释放可重入锁（这里不会失败）
      3. 循环判断是否在同步队列（只要没有再同步队列就阻塞）
         1. 不在就**阻塞**当前线程（这里需要等待signal来释放信号，解除阻塞）
         2. **唤醒后**
            1. 判断中断的状态
               1. 被中断就继续循环，判断是否在同步队列，这里还是会被阻塞
         3. 在就尝试获取锁(这个是被唤醒了，可能会有竟态，因为用的是非公平的可重入锁)，这里会自**旋获取锁获取不到就阻塞**
         4. 获取到锁之后（队列会继续**循环尝试**添加直到成功），清理一波取消的节点
         5. 根据中断的条件，重新中断或者抛出中断异常
2. 队列添加成功，释放互斥锁

* signal流程: 条件队列入队、出队有没有竟态？
  1. 触发条件
     1. 队列新出队一个元素，调用signal()
     2. 队列清空，调用signalAll()
  2. 流程
     1. 将队列中第一个节点转移到同步队列
        1. **循环**将条件队列的头结点waitstatus转为0，这里必须将状态从CONDITION流转到0,如果失败则说明节点被取消,因为这里不会存在signal的竞争。
           1. 转失败说明取消了，继续操作下一个
           2. 转成功说明可以入队了
              1. 自旋入同步队列，返回前驱节点
              2. 前驱节点取消或者改变前驱的等待状态为-1，
                 1. 改成功就再循环一次等待唤醒
                 2. 改失败就说明可以等待唤醒了，进入正常的获取锁的流程

## Condition

java.util.concurrent.locks.Condition是JUC提供的**与Java的Object中wait/notify/notifyAll类似功能的一个接口**，通过此接口，线程可以在某个特定的条件下等待/唤醒
**与wait/notify/notifyAll操作需要获得对象监视器类似，一个Condition实例与某个互斥锁绑定**，在此**Condition实例进行等待/唤醒操作的调用也需要获得互斥锁**，线程被唤醒后需要再次获取到锁，否则将继续等待。
而与原生的wait/notify/notifyAll等API不同的地方在于,**JUC提供的Condition具有更丰富的功能，例如等待可以响应/不响应中断，可以设定超时时间或是等待到某个具体时间点**。
此外一把互斥锁可以绑定多个Condition，这意味着**在同一把互斥锁上竞争的线程可以在不同的条件下等待**，唤醒时可以根据条件来唤醒线程，这是Object中的wait/notify/notifyAll不具备的机制

### public final void await() throws InterruptedException

```java
public final void await() throws InterruptedException {
    // 对中断敏感
    if (Thread.interrupted())
        throw new InterruptedException();
    // 加入到条件队列中
    Node node = addConditionWaiter();
    // 完全释放互斥锁(无论锁是否可以重入)，如果没有持锁，会抛出异常
    // 调用可重入锁的释放锁代码
    int savedState = fullyRelease(node);
    int interruptMode = 0;
    // 只要仍未转移到同步队列就阻塞。
    while (!isOnSyncQueue(node)) {
        // 阻塞
        LockSupport.park(this);
        // 获取中断模式
        if ((interruptMode = checkInterruptWhileWaiting(node)) != 0)
            break;
    }
    if (acquireQueued(node, savedState) && interruptMode != THROW_IE)
        interruptMode = REINTERRUPT;
    if (node.nextWaiter != null) // clean up if cancelled
        unlinkCancelledWaiters();
    if (interruptMode != 0)
        reportInterruptAfterWait(interruptMode);
}
```

#### private Node addConditionWaiter()

> ConditionObject的数据结构和addConditionWaiter,只有头尾两个指针

```java
public class ConditionObject implements Condition, java.io.Serializable {
    private static final long serialVersionUID = 1173984872572414699L;
    /** First node of condition queue. */
    private transient Node firstWaiter;
    /** Last node of condition queue. */
    private transient Node lastWaiter;

    public ConditionObject() { }

    private Node addConditionWaiter() {
        Node t = lastWaiter;
        // 最后一个节点的waitstatus不为-2
        if (t != null && t.waitStatus != Node.CONDITION) {
            unlinkCancelledWaiters();
            t = lastWaiter;
        }
        // 新建一个Node节点，节点的waitstatus为-2
        Node node = new Node(Thread.currentThread(), Node.CONDITION);
        if (t == null)
            // 设置为头结点
            firstWaiter = node;
        else
            // 设置尾结点的后继为当前节点
            t.nextWaiter = node;
        // 设置尾结点
        lastWaiter = node;
        return node;
    }
```

#### private void unlinkCancelledWaiters()

> 删除取消等待的节点，从头到尾扫一遍，删除所有的取消节点

```java
private void unlinkCancelledWaiters() {
    // 从第一个开始扫描
    Node t = firstWaiter;
    // 记录上一个非取消的节点
    Node trail = null;
    // 遍历链表
    while (t != null) {
        // 获取后面的节点
        Node next = t.nextWaiter;
        // 节点的状态是取消的话
        if (t.waitStatus != Node.CONDITION) {
            // 修改节点后续为空，如果需要用就用next
            t.nextWaiter = null;
            // 如果没有最新的头部节点,就把next作为头结点
            if (trail == null)
                firstWaiter = next;
            else
                // 这边可以删除中间节点
                trail.nextWaiter = next;
            // next为空，说明遍历完成了
            if (next == null)  
                lastWaiter = trail;
        }
        else
            // 更新最新的非取消节点
            trail = t;
        // t指向下一个未扫描的节点
        t = next;
    }
}
```

#### private int checkInterruptWhileWaiting(Node node)

> 线程被唤醒后，检查中断状态。
> 1.如果线程未被中断返回0

```java
private int checkInterruptWhileWaiting(Node node) {
    return Thread.interrupted() ?
        (transferAfterCancelledWait(node) ? THROW_IE : REINTERRUPT) :
        0;
}
```

#### transferAfterCancelledWait(Node node)

> 1.线程中断且入同步队列成功,返回THROW_IE表示后续要抛出InterruptedException。
> 2.线程中断且未能入同步队列(由于被signal方法唤醒),则返回REINTERRUPT表示后续重新中断。

```java
    final boolean transferAfterCancelledWait(Node node) {
        if (compareAndSetWaitStatus(node, Node.CONDITION, 0)) {
            enq(node);
            return true;
        }
        while (!isOnSyncQueue(node))
            // 不会释放锁
            Thread.yield();
        return false;
    }
```

#### boolean isOnSyncQueue(Node node)

> 判断节点是否在头部队列里面

```java
final boolean isOnSyncQueue(Node node) {
    // waitstatus状态为-2或着没有前继就不在
    if (node.waitStatus == Node.CONDITION || node.prev == null)
        return false;
    // 有后继就说明在
    if (node.next != null) // If has successor, it must be on queue
        return true;
    // 遍历队列寻找是否存在这个节点
    return findNodeFromTail(node);
}
```

#### private boolean findNodeFromTail(Node node)

> 遍历寻找节点

```java
private boolean findNodeFromTail(Node node) {
    Node t = tail;
    for (;;) {
        if (t == node)
            return true;
        if (t == null)
            return false;
        t = t.prev;
    }
}
```

#### private void reportInterruptAfterWait(int interruptMode)

> 响应中断标志

```java
private void reportInterruptAfterWait(int interruptMode)
    throws InterruptedException {
    if (interruptMode == THROW_IE)
        throw new InterruptedException();
    else if (interruptMode == REINTERRUPT)
        selfInterrupt();
}
```

---
[reference](https://blog.csdn.net/c_royi/article/details/81214656)
### public final void signal()
```java
public final void signal() {
    // 调用 signal 方法的线程必须持有当前的独占锁
    if (!isHeldExclusively())
        throw new IllegalMonitorStateException();
    // 将这个线程对应的 node 从条件队列转移到阻塞队列
    Node first = firstWaiter;
    if (first != null)
        doSignal(first);
}
```
#### private void doSignal(Node first)
```java
private void doSignal(Node first) {
    do {
          // 将 firstWaiter 指向 first 节点后面的第一个
        // 如果将队头移除后，后面没有节点在等待了，那么需要将 lastWaiter 置为 null
        if ( (firstWaiter = first.nextWaiter) == null)
            lastWaiter = null;
        // 因为 first 马上要被移到阻塞队列了，和条件队列的链接关系在这里断掉
        first.nextWaiter = null;
    } while (!transferForSignal(first) &&
             (first = firstWaiter) != null);
      // 这里 while 循环，如果 first 转移不成功，那么选择 first 后面的第一个节点进行转移，依此类推
}
```
#### final boolean transferForSignal(Node node)
```java
final boolean transferForSignal(Node node) {

    // CAS 如果失败，说明此 node 的 waitStatus 已不是 Node.CONDITION，说明节点已经取消，
    // 既然已经取消，也就不需要转移了，方法返回，转移后面一个节点
    // 否则，将 waitStatus 置为 0
    if (!compareAndSetWaitStatus(node, Node.CONDITION, 0))
        return false;

    // enq(node): 自旋进入阻塞队列的队尾
    // 注意，这里的返回值 p 是 node 在阻塞队列的前驱节点
    Node p = enq(node);
    int ws = p.waitStatus;
    // ws > 0 说明 node 在阻塞队列中的前驱节点取消了等待锁，直接唤醒 node 对应的线程。唤醒之后会怎么样，后面再解释
    // 如果 ws <= 0, 那么 compareAndSetWaitStatus 将会被调用，上篇介绍的时候说过，节点入队后，需要把前驱节点的状态设为 Node.SIGNAL(-1)
    if (ws > 0 || !compareAndSetWaitStatus(p, ws, Node.SIGNAL))
        // 如果前驱节点取消或者 CAS 失败，会进到这里唤醒线程，之后的操作看下一节
        LockSupport.unpark(node.thread);
    return true;
}
```
