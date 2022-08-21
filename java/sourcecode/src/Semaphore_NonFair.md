# Semaphore

[参考](https://juejin.cn/post/7042287897931677726)

## 用法
> 可以指定公平和非公平的实现
```java
public class Main {
    public static void main(String[] args) throws InterruptedException {
        Semaphore semaphore = new Semaphore(10);
        semaphore.acquire(1);
        semaphore.release(1);
    }
}
```

## 属性

## 方法

---
## 注意点
