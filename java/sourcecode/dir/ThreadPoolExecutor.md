[reference](https://www.cnblogs.com/KingJack/p/9595621.html)
[Java8 ThreadPoolExecutor 源码详解](https://blog.csdn.net/cx897459376/article/details/106159387)

# ThreadPoolExecutor

## 类属性

> AtomicInteger ctl:
> ctl是主要的控制状态，是一个复合类型的变量，其中包括了两个概念。
> workerCount：表示**有效的线程数目**
> runState：线程池里**线程的运行状态**

```java
class ThreadPoolExecutor {
    // 见上面的注释
    private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));
    // 存储个数所占的位数，32-3=29
    private static final int COUNT_BITS = Integer.SIZE - 3;
    // 线程池最大数量，2^29 - 1
    private static final int CAPACITY   = (1 << COUNT_BITS) - 1;
  
    // 我们可以看出有5种runState状态，证明至少需要3位来表示runState状态,所以高三位就是表示runState了
    private static final int RUNNING    = -1 << COUNT_BITS;
    private static final int SHUTDOWN   =  0 << COUNT_BITS;
    private static final int STOP       =  1 << COUNT_BITS;
    private static final int TIDYING    =  2 << COUNT_BITS;
    private static final int TERMINATED =  3 << COUNT_BITS;
  
    // Packing and unpacking ctl
    private static int runStateOf(int c)     { return c & ~CAPACITY; }
    private static int workerCountOf(int c)  { return c & CAPACITY; }
    private static int ctlOf(int rs, int wc) { return rs | wc; }

    // 用于存放线程任务的阻塞队列
    private final BlockingQueue<Runnable> workQueue;
    // 线程池当中的线程集合，只有当拥有mainLock锁的时候，才可以进行访问
    private final ReentrantLock mainLock = new ReentrantLock();
    // 线程池当中的线程集合，只有当拥有mainLock锁的时候，才可以进行访问
    private final HashSet<Worker> workers = new HashSet<Worker>();
    // 等待条件支持终止??
    private final Condition termination = mainLock.newCondition();

}
```

> 线程池状态
>
> 1. RUNNING: 可以接受新任务并且处理已经在阻塞队列的任务
> 2. SHUTDOWN: 不接受新任务，但是处理已经在阻塞队列的任务
> 3. STOP: 不接受新任务，也不处理阻塞队列里的任务，并且会中断正在处理的任务
> 4. TIDYING: 所有任务都被中止，workerCount是0，线程状态转化为TIDYING并且调用terminated()钩子方法
> 5. TERMINATED: terminated()钩子方法已经完成

## 方法

* new ThreadPoolExecutor(***)

```java
public class Main {
    public static void main(String[] args) throws InterruptedException {
        ThreadPoolExecutor threadExecutor = new ThreadPoolExecutor(
            32, 
            64,
            10, 
            TimeUnit.SECONDS,
            new LinkedBlockingDeque<>(),
            Executors.defaultThreadFactory(), 
            new ThreadPoolExecutor.AbortPolicy());
    }
}
```

**参数含义：**

> 1.corePoolSize(核心线程池大小)：当提交一个任务到线程池时，线程池会创建一个线程来执行任务，即使其他空闲的基本线程能够执行新任务也会创建线程，当任务数大于核心线程数的时候就不会再创建。在这里要注意一点，线程池刚创建的时候，其中并没有创建任何线程，而是等任务来才去创建线程，除非调用了prestartAllCoreThreads()或者prestartCoreThread()方法 ，这样才会预先创建好corePoolSize个线程或者一个线程。
> 2.maximumPoolSize(线程池最大线程数)：线程池允许创建的最大线程数，如果队列满了，并且已创建的线程数小于最大线程数，则线程池会再创建新的线程执行任务。值得注意的是，如果使用了无界队列，此参数就没有意义了。
> 3.keepAliveTime(线程活动保持时间)：此参数默认在线程数大于corePoolSize的情况下才会起作用， 当线程的空闲时间达到keepAliveTime的时候就会终止，直至线程数目小于corePoolSize。不过如果调用了allowCoreThreadTimeOut方法，则当线程数目小于corePoolSize的时候也会起作用.
> 4.unit(keelAliveTime的时间单位)：keelAliveTime的时间单位，一共有7种，在这里就不列举了。
> 5.workQueue(阻塞队列)：阻塞队列，用来存储等待执行的任务，这个参数也是非常重要的，在这里简单介绍一下几个阻塞队列。
>
> * ArrayBlockingQueue：这是一个基于数组结构的有界阻塞队列，此队列按照FIFO的原则对元素进行排序。
> * LinkedBlockingQueue：一个基于链表结构的阻塞队列，此队列按照FIFO排序元素，吞吐量通常要高于ArrayBlockingQueue。静态工厂方法Executors.newFixedThreadPool()就是使用了这个队列。
> * SynchronousQueue：一个不存储元素的阻塞队列。每个插入操作必须等到另一个线程调用移除操作，否则插入操作一直处于阻塞状态。吞吐量通常要高于LinkedBlockingQueue，静态工厂方法Executors.newCachedThreadPool()就使用了这个队列。
> * PriorityBlockingQueue：一个具有优先级的无阻塞队列。
>
> 6. handler(饱和策略)；当线程池和队列都满了，说明线程池已经处于饱和状态了，那么必须采取一种策略来处理还在提交过来的新任务。这个饱和策略默认情况下是AbortPolicy，表示无法处理新任务时抛出异常。共有四种饱和策略提供，当然我们也可以选择自己实现饱和策略。
>
> * AbortPolicy：直接丢弃并且抛出RejectedExecutionException异常
> * CallerRunsPolicy：只用调用者所在线程来运行任务。
> * DiscardOldestPolicy：丢弃队列里最近的一个任务，并执行当前任务。
> * DiscardPolicy：丢弃任务并且不抛出异常。

* execute(runnable)

```java
threadExecutor.execute(() -> {
            System.out.println("test");
        });
```

public void execute(Runnable command)

> 这边的流程是
>
> 1. 检查核心线程池是不是满了，没满直接addwoker。满了加队列（里面有在判断一次，保证任务可以执行到），加队列失败就利用最大线程数执行任务
> 2. addWorker的第二个参数是决定走最大线程池还是核心线程池

```java
public void execute(Runnable command) {
    if (command == null)
        throw new NullPointerException();
    // 判断线程个数是否小于核心线程池数量，小于走addWoker流程
    int c = ctl.get();
    if (workerCountOf(c) < corePoolSize) {
        if (addWorker(command, true))
            return;
        c = ctl.get();
    }
    // 检查线程池的状态，正常的话加入任务队列
    if (isRunning(c) && workQueue.offer(command)) {
        int recheck = ctl.get();
        // 再次检查，防止在添加到队列之前，核心线程池的任务都跑完了，没人执行这个任务
        // 线程池状态不对，拒绝任务
        if (! isRunning(recheck) && remove(command))
            reject(command);
        // 没有线程了，再添加一个worker
        else if (workerCountOf(recheck) == 0)
            addWorker(null, false);
    }
    // 加入阻塞队列失败，则尝试以线程池最大线程数新开线程去执行该任务
    else if (!addWorker(command, false))
        reject(command);
}
```

* private boolean addWorker(Runnable firstTask, boolean core)

> 流程：
>
> 1. 获取线程池的状态不满足要求，返回，满足自旋将线程数加1，加的过程中线程池状态变化需要重新走这个方法
> 2. 占位成功后，新建一个worker,获取可重入锁，更新wokers集合，添加成功后就启动worker

```java
private boolean addWorker(Runnable firstTask, boolean core) {
    retry:
    for (;;) {
        int c = ctl.get();
        int rs = runStateOf(c);

        // 线程池shutdown了，还在加任务进来，不接受
        if (rs >= SHUTDOWN &&
            ! (rs == SHUTDOWN &&
               firstTask == null &&
               ! workQueue.isEmpty()))
            return false;

        for (;;) {
            int wc = workerCountOf(c);
            // 如果workerCount超出最大值或者大于corePoolSize/maximumPoolSize，入队列或者开启核心线程池之外的woker
            if (wc >= CAPACITY ||
                wc >= (core ? corePoolSize : maximumPoolSize))
                return false;
            // 通过CAS操作，使workerCount数量+1，成功则跳出循环，回到retry标记,这里是先占一个位置，然后开启woker
            if (compareAndIncrementWorkerCount(c))
                break retry;
            // CAS操作失败，再次获取线程池的控制状态
            c = ctl.get();  // Re-read ctl
            // 线程池状态改变了就从头再来一遍
            if (runStateOf(c) != rs)
                continue retry;
            // else CAS failed due to workerCount change; retry inner loop
        }// endfor
    }// end for
  
    // 通过以上循环，能执行到这是workerCount成功+1了
    // worker开始标记
    boolean workerStarted = false;
    // worker添加标记
    boolean workerAdded = false;
    // 初始化worker为null
    Worker w = null;
    try {
        // 初始化一个当前Runnable对象的worker对象
        w = new Worker(firstTask);
        final Thread t = w.thread;
        //如果线程不为null
        if (t != null) {
            //初始线程池的锁
            final ReentrantLock mainLock = this.mainLock;
            mainLock.lock();
            try {
                // 获取锁后再次检查，获取线程池runState
                int rs = runStateOf(ctl.get());
                // 当runState小于SHUTDOWN或者runState等于SHUTDOWN并且firstTask为null
                if (rs < SHUTDOWN ||
                    (rs == SHUTDOWN && firstTask == null)) {
                    //线程未启动就存活，抛出IllegalThreadStateException异常
                    if (t.isAlive()) // precheck that t is startable
                        throw new IllegalThreadStateException();
                    //将worker对象添加到workers集合当中
                    workers.add(w);
                    int s = workers.size();
                    //如果大小超过largestPoolSize
                    if (s > largestPoolSize)
                        largestPoolSize = s;
                    //标记worker已经被添加
                    workerAdded = true;
                }
            } finally {
                mainLock.unlock();
            }
            //如果worker添加成功
            if (workerAdded) {
                //启动线程
                t.start();
                //标记worker已经启动
                workerStarted = true;
            }
        }
    } finally {
        // 如果worker没有启动成功
        if (! workerStarted)
            //workerCount-1的操作
            addWorkerFailed(w);
    }
    //返回worker是否启动的标记
    return workerStarted;
}
```

* private void addWorkerFailed(Worker w)

```java
private void addWorkerFailed(Worker w) {
    final ReentrantLock mainLock = this.mainLock;
    mainLock.lock();
    try {
        if (w != null)
            workers.remove(w);
        decrementWorkerCount();
        tryTerminate();
    } finally {
        mainLock.unlock();
    }
}
```

* final void tryTerminate()
* final void runWorker(Worker w)

> 接下来我们用文字来说明一下执行任务这个方法的具体逻辑和流程。
>
> 1. 首先在方法一进来，就执行了w.unlock()，这是为了将AQS的状态改为0，因为只有getState() >= 0的时候，线程才可以被中断；
> 2. 判断firstTask是否为空，为空则通过getTask()获取任务，不为空接着往下执行
> 3. 判断是否符合中断状态，符合的话设置中断标记
> 4. 执行beforeExecute()，task.run()，afterExecute()方法
> 5. 任何一个出异常都会导致任务执行的终止；进入processWorkerExit来退出任务
>    6.正常执行的话会接着回到步骤2

```java
final void runWorker(Worker w) {
    Thread wt = Thread.currentThread();
    Runnable task = w.firstTask;
    w.firstTask = null;
    // worker集成aqs，初始化的时候=-1，设置为0，然后就可以lock这个worker了，也可以避免在跑到这里之前被中断，保证添加到线程池的任务可以被执行
    w.unlock(); // allow interrupts
    //是否突然完成
    boolean completedAbruptly = true;
    try {
        // worker实例的task不为空，或者通过getTask获取的不为空
        while (task != null || (task = getTask()) != null) {
            //获取锁,执行任务的时候不会被shutdown设置中断状态
            w.lock();
            if ((runStateAtLeast(ctl.get(), STOP) ||
                 (Thread.interrupted() &&
                  runStateAtLeast(ctl.get(), STOP))) &&
                !wt.isInterrupted())
                wt.interrupt();
            try {
                beforeExecute(wt, task);
                Throwable thrown = null;
                try {
                    //执行任务
                    task.run();
                } catch (RuntimeException x) {
                    thrown = x; throw x;
                } catch (Error x) {
                    thrown = x; throw x;
                } catch (Throwable x) {
                    thrown = x; throw new Error(x);
                } finally {
                    afterExecute(task, thrown);
                }
            } finally {
                task = null;
                w.completedTasks++;
                w.unlock();
            }
        }
        completedAbruptly = false;
    } finally {
        processWorkerExit(w, completedAbruptly);
    }
}
```

* getTask(**)

```java
private Runnable getTask() {
        boolean timedOut = false; // Did the last poll() time out?

        for (;;) {
            // 获取线程池当前状态赋值为rs
            int c = ctl.get();
            int rs = runStateOf(c);
            
            // Check if queue empty only if necessary.
            // 如果线程池状态等于SHUTDOWN 并且队列为空
            // 如果线程池状态大于等于STOP
            // 那么当前线程池workerCount减一，返回空
            if (rs >= SHUTDOWN && (rs >= STOP || workQueue.isEmpty())) {
                decrementWorkerCount();
                return null;
            }
            // 获取当前线程池的workerCount
            int wc = workerCountOf(c);

            // Are workers subject to culling?
            // 判断当前线程池核心线程是否允许超时，或者当前线程数是否已经超过核心数
            boolean timed = allowCoreThreadTimeOut || wc > corePoolSize;
      
            // 线程池线程数大于maximumPoolSize，并且timed为true，并且已经timeout
            // (timeout 在往下的代码会赋值) ，并且wc >1 ,并且workQueue已经为空，即任务已经处理完毕
            if ((wc > maximumPoolSize || (timed && timedOut))
                && (wc > 1 || workQueue.isEmpty())) {
                if (compareAndDecrementWorkerCount(c))
                    return null;
                continue;
            }

            try {
                // 如果time 为true，即核心线程允许超时，或者当前线程池线程数已经超过核心数
                // 那么调用阻塞队列的poll(keepAliveTime, TimeUnit.NANOSECONDS)方法
                // 那么线程池中如果一条线程处于空闲状态超过keepAliveTime秒后
                // 即超过keepAliveTime秒后还没有从队列中拉取到任务，即为null
                // 这个方法返回null后，runWorker的while循环退出，线程消亡
                // 如果time为false，那么会一直等待获取任务，
                // 一般会有<=corePoolSize条线程一直阻塞等待获取任务
                Runnable r = timed ?
                    workQueue.poll(keepAliveTime, TimeUnit.NANOSECONDS) :
                    workQueue.take();
                if (r != null)
                    return r;
                // 把timedOut设置为true，下一次循环会直接返回null
                timedOut = true;
            } catch (InterruptedException retry) {
                timedOut = false;
            }
        }
    }
```
* shutdown()
> 关闭线程池，拒绝再接收任务，但是保证执行完以及提交的任务

```java

```
* shutdownNow()
> 关闭线程池，尝试中断正在执行的任务
```java

```


## **锁**

[线程池里面的几个锁](https://www.cnblogs.com/thisiswhy/p/15493027.html)

* **mainLock**

> 是一个可重入锁，**execute**的流程用来添加一个worker到workers(是一个hashset)和操作longestSize(用来记录线程池中，
> 曾经出现过的最大线程数)。**shutdown**的时候也会中断线程，这里用锁是为了避免**中断风暴**（interrupt storms）的风险。

* **Woker对象的锁**

> worker 类存在的主要意义就是为了维护线程的中断状态。正在执行任务的线程不应该被中断，**可以保证线程池shutdown的时候，提交
> 的任务可以被执行掉**。

* **shutdown和shutdownNow的区别**

> 1、**shutDown()**
> 当线程池调用该方法时,线程池的状态则立刻变成SHUTDOWN状态。此时，则**不能再往线程池中添加任何任务**，否则将会抛出RejectedExecutionException异常。但是，此时**线程池不会立刻退出，直到添加到线程池中的任务都已经处理完成，才会退出**。
> 2、**shutdownNow()**
> 执行该方法，线程池的状态立刻变成STOP状态，并试图停止所有正在执行的线程，不再处理还在池队列中等待的任务，当然，它会返回那些未执行的任务。
