[reference](https://www.cnblogs.com/dennyzhangdd/p/7280032.html)

# Thread

## 线程状态

> NEW  新建
> RUNNABLE 可运行
> BLOCKING  阻塞等待锁
> WAITING  等待其他线程的操作
> TIMED_WAITING  限时等待
> TERMINATED  终止

* （JVM）线程状态转换

> 就绪和运行对应JVM的RUNNABLE状态，线程运行中会通过wait()/join()/LockSupport.park()/parkUntil()进入无限等待状态，等待notify/notifyall/unpark唤醒；
> sleep(v)/join(v)/wait(v)/parkNanos()/parkUntil()进入限期等待，到期后系统唤醒；
> 等待获得锁/IO阻塞进入阻塞状态，获的锁或者IO完成接触阻塞；

## 方法

### start()

```java
public synchronized void start() {
 
        if (threadStatus != 0)
            throw new IllegalThreadStateException();
        group.add(this);

        boolean started = false;
        try {
            start0();
            started = true;
        } finally {
            try {
                if (!started) {
                    group.threadStartFailed(this);
                }
            } catch (Throwable ignore) {
                /* do nothing. If start0 threw a Throwable then
                  it will be passed up the call stack */
            }
        }
    }
```

导致此线程开始执行；Java虚拟机调用此线程的run方法。
结果是两个线程同时运行：当前线程（从调用start方法返回）和另一个线程（执行其run方法）。
**多次启动线程永远是不合法的。特别是，线程一旦完成执行，就不能重新启动。**

### run()

```java
public void run() {
        if (target != null) {
            target.run();
        }
    }
```

如果此线程是使用单独的Runnable运行对象构造的，则调用该Runnable对象的运行方法；否则，此方法不执行任何操作并返回。

### sleep()

```java
public static native void sleep(long millis) throws InterruptedException;
```

```java
public static void sleep(long millis, int nanos)
```

使当前执行的线程在指定的毫秒数内休眠（暂时停止执行），这取决于系统计时器和调度程序的精度和准确性。**线程不会失去任何监视器的所有权**。

### yeild()

```java
public static native void yield();
```

向调度程序发出的提示，即当前线程愿意产生其当前对处理器的使用。调度程序可以自由地忽略此提示。
yeild是一种启发式尝试，旨在改善线程之间的相对进度，否则这些线程将过度利用CPU。它的使用应与详细的分析和基准测试相结合，以确保它实际上具有预期的效果。
这种方法很少使用。它**可能有助于调试或测试目的**，在这些目的中，它可能有助于再现由于竞争条件而产生的错误。在设计并发控制构造（如java.util.concurrent.locks包中的构造）时，它也可能很有用。它跟sleep方法类似，同样**不会释放锁**。但是yield不能控制具体的交出CPU的时间，另外，yield方法只能让**拥有相同优先级的线程**有获取CPU执行时间的机会。注意，调用yield方法并**不会让线程进入阻塞状态，而是让线程重回就绪状态**，它只需要等待重新获取CPU执行时间，这一点是和sleep方法不一样的

### join()

```java
public final void join() throws InterruptedException {
        join(0);
    }
```

```java
public final synchronized void join(long millis)
    throws InterruptedException {
        long base = System.currentTimeMillis();
        long now = 0;

        if (millis < 0) {
            throw new IllegalArgumentException("timeout value is negative");
        }

        if (millis == 0) {
            while (isAlive()) {
                wait(0);
            }
        } else {
            while (isAlive()) {
                long delay = millis - now;
                if (delay <= 0) {
                    break;
                }
                wait(delay);
                now = System.currentTimeMillis() - base;
            }
        }
    }
```

等待此线程死亡。调用此方法的行为方式与调用完全相同.可以看出，当调用thread.join()方法后，**main线程会进入等待**，然后等待thread执行完之后再继续执行。实际上调用join方法是**调用了Object的wait方法**，这个可以通过查看源码得知.wait方法会让线程进入阻塞状态(是在主线程调用的)，并且会释放线程占有的锁，并交出CPU执行权限

### interrupt()

```java
public void interrupt() {
        if (this != Thread.currentThread())
            checkAccess();

        synchronized (blockerLock) {
            Interruptible b = blocker;
            if (b != null) {
                interrupt0();           // Just to set the interrupt flag
                b.interrupt(this);
                return;
            }
        }
        interrupt0();
    }
```

interrupt，中断。单独调用interrupt方法可以使得**处于阻塞状态的线程**抛出一个异常，也就说，它可以用来中断一个正处于阻塞状态的线程；

### stop和destroy已经废弃

## LockSupport

### park()和unpark()原理
> **park不会释放锁**，没有获得许可的时候，只会阻塞当前线程。object的wait会释放锁，进入等待队列
**park()**

```java
public static void park() {
        UNSAFE.park(false, 0L);
    }
```

```java
public static void parkNanos(long nanos) {
        if (nanos > 0)
            UNSAFE.park(false, nanos);
    }
```

```java
public static void parkUntil(long deadline) {
        UNSAFE.park(true, deadline);
    }
```

**unpark()**

```java
public static void unpark(Thread thread) {
        if (thread != null)
            UNSAFE.unpark(thread);
    }
```
# 注意点
1. unpark函数为线程提供“许可(permit)”，park函数则等待“许可”。这个有点像信号量，但是这个“许可”是不能叠加的，**“许可”是一次性的**。
比如线程B连续调用了三次unpark函数，当线程A调用park函数就使用掉这个“许可”，如果线程A再次调用park，则进入等待状态.
2. unpark函数可以先于park调用。比如线程B调用unpark函数，给线程A发了一个“许可”，那么当线程A调用park时，它发现已经有“许可”了，那么它会马上再继续运行。**
3. **park/unpark模型真正解耦了线程之间的同步，线程之间不再需要一个Object或者其它变量来存储状态，不再需要关心对方的状态。**
