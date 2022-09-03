# 什么是zookeeper
[reference](https://blog.csdn.net/m0_48795607/article/details/116458096)
zookeeper是一个分布式协同系统。布式应用程序可以基于Zookeeper实现诸如数据发布/订阅、负载均衡、命名服务、分布式协调/通知、集群管理、Master 选举、分布式锁和分布式队列等功能。  
# 提供的能力
1. 文件系统
2. 通知机制
# zookeeper文件系统
zookeeper提供了一套多层级的节点命名空间，节点叫做znode。注意区分与文件系统的区别，文件系统的目录节点是不能保存数据的。  
zookeeper为了保证数据读写的销量，选在**内存**保存这些数据，所以不能保存太多的数据，每个节点最大1M。
# ZAB协议
是专门为zookeeper设计的一种支持崩溃恢复的原子广播协议。  
ZAB协议包括两张基本的模式，崩溃恢复和消息广播。 
当由于集群启动或者leader服务器宕机、重启或者网络故障导致不存在过半的服务器与leader服务器保持正常通信的时候，所有的服务器进入崩溃恢复模式。
当半数以上的服务器可以和leader正常通信的时候，进入广播模式，leader开始接受客户端的请求生产事务提案来进行事务的请求。
# 数据节点的类型
* persistent-持久节点
除非手动删除，否则一直在zookeeper上
* ephemeral-临时节点
生命周期与客户端会话的生命周期绑定
* persistent_sequential-持久顺序节点
增加了顺序属性，**节点名后边会追加一个由父节点维护的自增整型数字**
* EPHEMERAL_SEQUENTIAL-临时顺序节点
临时顺序节点基本特性同临时节点，增加了顺序属性，节点名后边会追加一个由父节点维护的自增整型数字
# zookeeper watch机制
客户端向服务端的某个znode注册一个watch监听，当服务端的一些指定事件触发了这个watch，服务端会通知客户端。
## 工作机制
1. 客户端注册watch
2. 服务端处理watch
3. 客户端回调watch
## watch特性 （一次性、不报序、会丢失）
1. 一次性
注册一次服务端通知一次，避免数据频繁变更服务器压力过大
2. 串行
客户端回调的过程是一个串行同步的过程
3. 轻量  
* 通知非常简单，只会告诉客户端发生了事件，而不会说明事件的具体内容
* 注册的时候并没有把watch对象实例传递到服务端，仅仅是在客户端请求中使用boolean进行了标记  
4. watcher event异步发送watcher的通知事件**从server发送到client是异步的**,不能保证发送的顺序。
5. 注册watcher getData、exists、getChildren ？
6. 触发watcher create、delete、setData ？
7. watch事件丢失
[丢失](https://blog.csdn.net/wenniuwuren/article/details/78116891)
> **你与一个服务断开（比如zk服务宕机），你将不会获得任何 watch，直到连接重连**。因此，session 事件将会发送给所有 watch 处理器。
> 使用 session 事件进入一个安全模式：当断开连接的时候将不会收到任何事件，因此您的进程应该以该模式保守运行
