# AtomicBoolean
> 线程安全的Boolean类型  
> 线程不安全示例  [线程不安全]([12](https://blog.csdn.net/zmx729618/article/details/52767736))
## 属性
1. 静态unsafe类
2. 值的偏移量
3. volatile int类型的value
## 构造方法，带参和不带参(默认false)
## 方法
### public final boolean get()
> 返回布尔值 value != 0  
```java
public final boolean get() {
        return value != 0;
}
```
### public final boolean compareAndSet(boolean expect, boolean update)
> 原子的比较，传入初始值和预期值，只有一个线程可以修改成功
```java
    public final boolean compareAndSet(boolean expect, boolean update) {
        int e = expect ? 1 : 0;
        int u = update ? 1 : 0;
        return unsafe.compareAndSwapInt(this, valueOffset, e, u);
    }
```
### public boolean weakCompareAndSet(boolean expect, boolean update)
> 与compareAndSet无异
### public final void set(boolean newValue)
> 注意数据类型转换，value用boolean是不是也可以？
```java
public final void set(boolean newValue) {
        value = newValue ? 1 : 0;
    }
```
### public final boolean get()
```java
    public final boolean get() {
        return value != 0;
    }
```
### public final void lazySet(boolean newValue)
> 最终设置为给定值
```java
    public final void lazySet(boolean newValue) {
        int v = newValue ? 1 : 0;
        unsafe.putOrderedInt(this, valueOffset, v);
    }
```
### public final boolean getAndSet(boolean newValue)
> 设置新值，返回旧值(旧值不稳定)
```java
    public final boolean getAndSet(boolean newValue) {
        boolean prev;
        do {
            prev = get();
        } while (!compareAndSet(prev, newValue));
        return prev;
    }
```
