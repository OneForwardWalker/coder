
# 多路复用问题
[reference](https://blog.csdn.net/Oooo_mumuxi/article/details/108164013)
## BIO缺陷
socket读写方法阻塞当前线程，且每条连接需要占用一个线程。客户端多的话没有这么多的线程可用。
## NIO怎么解决多客户端的问题
NIO可以用一个线程去检查N个socket

## select原理
每次调用select函数，都会涉及用户态和内核态的切换。还需要检查select传递的fd,遍历文件描述符，检查socket的状态，复杂度是O(N)的。

## select 监听socket的数量有没有限制
默认可以监听1024个socket，数据结构使用的位图，默认长度修改起来不容易。

## select 调用后未发现socket就绪，后续再有socket就绪后，select如何感知是不停的轮询吗
select没有数据后，需要把当前线程挂起，从工作队列移到等待队列，如果有数据发送到网卡，会执行**中断**的逻辑，判断数据包是哪个socket的数据，通过端口号就可以找到对应的socket实例，从等待队列再移动到工作队列，就可以读写数据了。

## poll和select的区别
使用的数据结构不一样，使用的是数组，poll解决了文集描述符1024的限制
## epoll技术
> 1. select和poll的缺陷，每次与内核交互都需要把所有的fd传进去，涉及到内核态和用户态的内存拷贝比较耗时。
> 2. 需要遍历才知道那个fd有数据了。

