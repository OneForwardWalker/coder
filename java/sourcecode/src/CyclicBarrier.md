# CyclicBarrier
[reference](https://www.cnblogs.com/funyoung/p/13633450.html)
> 基于reentrantLock的Condition实现
## 使用
```java
public class Solution implements Runnable {
    // 这边不是静态的就有问题
    static CyclicBarrier cyclicBarrier = new CyclicBarrier(10);

    public static void main(String[] args) throws BrokenBarrierException, InterruptedException {


        for (int i = 0; i < 10; i++) {
            new Thread(new Solution()).start();
        }

        TimeUnit.SECONDS.sleep(100);
    }

    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName());
        try {
            int s = Math.abs(new Random().nextInt(5));
            System.out.println("sleep:" + s);
            TimeUnit.SECONDS.sleep(s);
            cyclicBarrier.await();
            System.out.println(Thread.currentThread().getName() + "end");
        } catch (InterruptedException | BrokenBarrierException e) {
            e.printStackTrace();
        }
    }
}

```
## 属性




## CyclicBarrier为什么可以复用
> 最后一个线程走到await的流程中的时候，会重新恢复count个数。

