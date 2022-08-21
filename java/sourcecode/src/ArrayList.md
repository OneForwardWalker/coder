[reference](https://blog.csdn.net/fighterandknight/article/details/61240861)

# ArrayList

## 属性

* **初始容量 10**
* 空对象
* 数据对象存放的地方
* 数组长度
* 数组最大长度

## 构造函数

* 无参，时我们创建的ArrayList对象中的elementData中的长度是1，size是0,当进行第一次add的时候，elementData将会变成默认的长度：10
* 带int类型的构造函数，如果传入参数，则代表指定ArrayList的初始数组长度，传入参数如果是大于等于0，则使用用户的参数初始化，如果用户传入的参数小于0，则抛出异常
* 带Collection类型的集合，先把集合转成数组，如果长度为0返回**空对象**，如果不为零，返回数组的拷贝（这里如果传入的Collection类型是ArrayList就直接把数组赋下值（**非引用**））

## add(E e)

添加的时候会确保可以放下这个元素，空间不够的话，会**扩容1.5倍**

## add(index.v)

1. 检查数字下标是否OK
2. 确保添加后数组容量OK,不够的话扩容
3. 移动元素，System.arraycopy
   指定src数组和dst数组，以及拷贝的长度，不会检查内存溢出
   public static native void arraycopy(Object src,  int  srcPos, Object dest, int destPos, int length);
4. 插入元素

## get(index)

返回指定索引处的元素

## public E set(int index, E element)

指定索引赋值，检查索引是否合法，赋新值，返回旧值

## public boolean contains(Object o)

通过indexOf(o)判断是否存在

## public int indexOf(Object o)

1. o为空，遍历比较，遇到第一个为空的返回索引值
2. o不为空。遍历通过equals比较,遇到第一个返回
3. 返回-1

## public E remove(int index)

## public boolean remove(Object o)

## public void clear()

## public List<E> subList(int arg0, int arg1)

我们看到代码中是创建了一个ArrayList 类里面的一个内部类SubList对象，传入的值中第一个参数时this参数，
其实可以理解为返回**当前list的部分视图**，真实指向的存放数据内容的地方还是同一个地方，如果修改了sublist返回的内容的话，那么原来的list也会变动
## public void trimToSize() 
trimToSize()方法的作用就是将elementData数组调整为ArrayList中实际元素个数大小的容量。
我们知道ArrayList中默认初始容量是10，当添加的元素个数大于10后，会自动扩容，容量变为原来的1.5倍，也就是说elementData数组的长度是15，但如果在添加10个元素之后，
只添加了1个元素，现在ArrayList的size其实是11，但elementData数组的length却是15，那么还有4个数组空间没有利用起来，浪费资源，就可以调用该方法调整elementData数组，
将其设置为length等于size的数组，底层是复制了一个长度为size的elementData数组返回。
[reference](https://blog.csdn.net/fighterandknight/article/details/61240861)
## public Iterator<E> iterator()
1. interator方法返回的是一个内部类，由于内部类的创建默认含有外部的this指针，所以这个内部类可以调用到外部类的属性。
2. 会使用modCount，判断list是否被修改

