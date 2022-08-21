[reference](https://blog.csdn.net/qq_37666598/article/details/104050293)

# **Object**

## **native method**

> jdk的源码有java代码、c、c++和汇编组成，java代码中存在java方法和本地方法。native方法在java中只有定义，没有实现，但和抽象方法不同，也无法和abstract连用，本地方法是**由其他语言编写实现**，编译成机器代码，**保存在动态链接库**中，所有虚拟机装载包含本地方法的动态库。

## **getClass()**

> 返回一个类对象的引用，与具体对象的实例无关，同一个类的不同实例，返回的是同一个引用

```java
public final native Class<?> getClass();
```

## **hashCode()**

> 计算对象的hash值，根据对象的内存地址计算得出的数字；不同对象的可能一样，同一对象的一定相同

```java
public native int hashCode();
```

## **equals()**

> 比较对象的内存地址，如果不重写，与==无异

```java
public boolean equals(Object obj) {
        return (this == obj);
    }
```

## **clone()**

默认**浅拷贝**，克隆出一个对象，默认只拷贝基础数据类型，引用数据类型不做拷贝。克隆出的对象和原对象不相等，里面的基础数据类型不相同，引用类型相同

* 深拷贝，需要实现**Cloneable**接口

> 克隆基础数据类型和引用类型

* 浅拷贝

> 克隆基础数据类型

```java
protected native Object clone() throws CloneNotSupportedException;
```

## **toString()**

> 默认返回全限定类名@16进制hash码

```java
public String toString() {
        return getClass().getName() + "@" + Integer.toHexString(hashCode());
    }
```

## **finalize()**

> 对象被回收时，垃圾回收器调用的方法

```java
protected void finalize() throws Throwable { }
```

## **wait()**

```java
public final native void wait(long timeout) throws InterruptedException;
```

* **阻塞线程，让出cpu**。Object wait() 方法让当前线程进入等待状态。直到其他线程调用此对象的 notify() 方法或 notifyAll() 方法。**为什么需要synchronized包裹，
  保证原子性，wait的时候加入等待队列和唤醒同步队列的原子性**；notify时，将线程移动至同步队列时，锁的状态不会发生变化。

### **synchronized**

* 执行monitor enter指令如果获取锁不成功，会将该线程添加到该monitor对象对应的同步队列 **SynchronizedQueue**，
* 当占用该monitor对象的线程执行monitor out时就会唤醒同步队列中的线程。

### **Monitor**

* Monitor对象 中包含一个**同步队列**（由 _cxq 和 _EntryList 组成）和一个**等待队列**（ _WaitSet ）

### **synchronized的同步队列和等待队列流程**

如果同步块没有调用wait那就执行完monitor.exit后释放锁，如果同步块执行了wait,就把线程加入等待队列。

* [reference](https://juejin.cn/post/6942286145380155428)

## **notify()**

notify随机唤醒一个等待的线程

```java
public final native void notify();
```

## **notifyAll()**

notifyAll唤醒所有等待的线程，哪一个线程获取到cpu便会有限执行

```java
public final native void notifyAll();
```
