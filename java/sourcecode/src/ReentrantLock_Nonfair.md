# ReentrantLock
> 非公平锁实现

## 方法
* public void lock()
```java
public void lock() {
    sync.lock();
}
```

* final void lock()
```java
final void lock() {
    // 抢占锁
    if (compareAndSetState(0, 1))
        setExclusiveOwnerThread(Thread.currentThread());
    else
        // 排队获取
        acquire(1);
}
```
* public final void acquire(int arg)
> 走公平锁流程
```java
public final void acquire(int arg) {
    if (!tryAcquire(arg) &&
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}
```

* public void unlock()
> 与公平锁一致
