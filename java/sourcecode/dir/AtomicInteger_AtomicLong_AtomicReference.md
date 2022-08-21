# AtomicInteger AtomicLong AtomicReference
[reference](https://www.cnblogs.com/-beyond/p/13095768.html)
> **unsafe**:  
> Unsafe可以执行低级别、不安全操作的方法，比如直接访问系统内存资源、自主管理内存资源等.使用Unsafe，可以实现内存操作、**CAS**、内存屏障...在AtomicInteger中，主要用来进行CAS操作  
> **valueOffset:**  
> valueOffset为字段value的内存偏移地址（相对于atomicInteger对象基地址的偏移）

> 这三个类的实现基本一致，只不过使用了unsafe的不同原子接口

# AtomicIneger
## public final int getAndSet(int newValue)
```java
    public final int getAndSet(int newValue) {
        return unsafe.getAndSetInt(this, valueOffset, newValue);
    }
```
### unafe
> 循环赋值，直到成功，返回修改之前的值
```java
    public final int getAndSetInt(Object o, long offset, int newValue) {
        int v;
        do {
            v = getIntVolatile(o, offset);
        } while (!compareAndSwapInt(o, offset, v, newValue));
        return v;
    }
```
