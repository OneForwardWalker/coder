# [redis](https://blog.csdn.net/lmiao1992/article/details/97516293)

# yum安装

yum install redis

## 启动

service redis start

## 交互式命令行

redis-cli

```
redis-check-aof  redis-check-rdb  redis-cli
[root@VM-4-11-centos ~]# redis-cli
127.0.0.1:6379> set 1 1
OK
127.0.0.1:6379> get 1
"1"
127.0.0.1:6379>
```

# 手动安装
[reference](https://www.cnblogs.com/hunanzp/p/12304622.html)
> yum安装目录都是固定的，比较分散  
> 需要GCC编译安装
## 启动，守护进程，显示启动方式
./bin/redis-server & ./redis.conf
> 上面的启动方式是采取后台进程方式,下面是采取显示启动方式(如在配置文件设置了daemonize属性为yes则跟后台进程方式启动其实一样)。
> 

./bin/redis-server ./redis.conf
### 守护进程
守护进程（daemon）是**生存期长**的一种进程，**没有控制终端**。它们常常在系统引导装入时启动，**仅在系统关闭时才终止**

## 测试
* config get *
```text
 200) "no"
201) "dir"
202) "/opt/software/redis/redis-5.0.7"
203) "save"
204) "3600 1 300 100 60 10000"
205) "client-output-buffer-limit"
206) "normal 0 0 0 slave 268435456 67108864 60 pubsub 33554432 8388608 60"
207) "unixsocketperm"
208) "0"
209) "slaveof"
210) ""
211) "notify-keyspace-events"
212) ""
213) "bind"
214) ""
127.0.0.1:6379> config get daemonize
1) "daemonize"
2) "no"
127.0.0.1:6379> config get databases
1) "databases"
2) "16"
127.0.0.1:6379>
```
* shutdwon [save|nosave]
关闭redis进程,通过指定一个可选的修饰符可以改变这个命令的表现形式，比如:
1. SHUTDOWN SAVE 能够在即使没有配置持久化的情况下**强制数据库存储**。
2. SHUTDOWN NOSAVE 能够在配置一个或者多个持久化策略的情况下**阻止数据库存储**. (你可以假想它为一个中断服务的 ABORT 命令)。

---
# docker安装

## 安装两个redis实例
[redis](https://www.runoob.com/docker/docker-install-redis.html)
[打通网络](https://cloud.tencent.com/developer/article/1343837)
> 为啥使用映射的端口不行呢！！
* docker pull redis:latest
> 拉取镜像
```shell
[root@VM-4-11-centos ~]# docker pull redis:latest
latest: Pulling from library/redis
461246efe0a7: Pull complete
edee06fdf403: Pull complete
04b7adc9ef61: Pull complete
6f4a4580ec0b: Pull complete
b70fc086369d: Pull complete
242936d47e59: Pull complete
Digest: sha256:ed8cba11c09451dbb3495f15951e4afb4f1ba72a4a13e135c6da06c6346e0333
Status: Downloaded newer image for redis:latest
docker.io/library/redis:latest

```
* docker images
> 查看镜像
```shell
[root@VM-4-11-centos ~]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
redis         latest    3edbb69f9a49   2 days ago      117MB
koa-demo      latest    d6f90814c3d4   12 days ago     675MB
wordpress     latest    8d2a3b437bc8   3 weeks ago     609MB
mariadb       latest    ea81af801379   6 weeks ago     383MB
ubuntu        latest    27941809078c   6 weeks ago     77.8MB
hello-world   latest    feb5d9fea6a5   10 months ago   13.3kB
node          8.4       386940f92d24   4 years ago     673MB
[root@VM-4-11-centos ~]#

```
运行redis
* docker run -itd --name redis-test01 -p 10001:6379  redis
> 运行容器1 2
```shell
[root@VM-4-11-centos ~]# docker run -itd --name redis-test01 -p 10001:6379 redis
dd315616dccc616e62febb67b4de45219037974414aa8dc302eeb217264cb0c7
[root@VM-4-11-centos ~]#

```
docker run -itd --name redis-test02 -p 10002:6379  redis
```shell
[root@VM-4-11-centos ~]# docker run -itd --name redis-test02 -p 10002:6379 redis
a27eb96e5f16d3de8a12f52872e2383266f207ed15343757d3ad482ee2dba841

```
* docker ps
> 查看运行的镜像
```shell
[root@VM-4-11-centos ~]# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS              PORTS                                         NAMES
a27eb96e5f16   redis     "docker-entrypoint.s…"   22 seconds ago       Up 21 seconds       0.0.0.0:10002->6379/tcp, :::10002->6379/tcp   redis-test02
dd315616dccc   redis     "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:10001->6379/tcp, :::10001->6379/tcp   redis-test01
[root@VM-4-11-centos ~]#

```
* docker exec -it redis-test01 /bin/bash
> 相当于进入交互模式
```shell
[root@VM-4-11-centos ~]# docker exec -it redis-test01 /bin/bash
root@dd315616dccc:/data#

```
连接redis
```shell
root@dd315616dccc:/data# redis-cli
127.0.0.1:6379> set 1 1
OK
127.0.0.1:6379> get 1
"1"
127.0.0.1:6379>
```
quit exit退出
```shell
127.0.0.1:6379> quit
root@dd315616dccc:/data# ex
exec    exit    expand  expiry  export  expr
root@dd315616dccc:/data# ex
exec    exit    expand  expiry  export  expr
root@dd315616dccc:/data# exit
exit
[root@VM-4-11-centos ~]#

```

## redis实例建立主从关系
进入02,指定master
```shell
127.0.0.1:6379> REPLICAOF 172.17.0.2 6379
OK
127.0.0.1:6379> info replication
# Replication
role:slave
master_host:172.17.0.2
master_port:6379
**master_link_status:up**
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_read_repl_offset:14
slave_repl_offset:14
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
master_failover_state:no-failover
master_replid:c3a9c5594293f20907538212714ca276b9047f6b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:14
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:15
repl_backlog_histlen:0
127.0.0.1:6379>
```
进入01,info replication 查看主从的状态
```shell
127.0.0.1:6379> info replication
# Replication
role:master
connected_slaves:1
slave0:ip=172.17.0.3,port=6379,state=online,offset=126,lag=0
master_failover_state:no-failover
master_replid:c3a9c5594293f20907538212714ca276b9047f6b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:126
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:126

```

主写：
```shell
127.0.0.1:6379> set 123 123
OK
127.0.0.1:6379> get 123
"123"
127.0.0.1:6379> set 123 1233
OK
127.0.0.1:6379>

```
从查询：
> 从写失败
```shell
127.0.0.1:6379> set 123 123
(error) READONLY You can't write against a read only replica.
127.0.0.1:6379> get 123
"123"
127.0.0.1:6379> get 123
"1233"
127.0.0.1:6379>
```

## 停掉docker
```shell
[root@VM-4-11-centos ~]# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                         NAMES
a27eb96e5f16   redis     "docker-entrypoint.s…"   15 minutes ago   Up 15 minutes   0.0.0.0:10002->6379/tcp, :::10002->6379/tcp   redis-test02
dd315616dccc   redis     "docker-entrypoint.s…"   16 minutes ago   Up 16 minutes   0.0.0.0:10001->6379/tcp, :::10001->6379/tcp   redis-test01
[root@VM-4-11-centos ~]# docker stop redis-test0
Error response from daemon: No such container: redis-test0
[root@VM-4-11-centos ~]# docker stop redis-test1
Error response from daemon: No such container: redis-test1
[root@VM-4-11-centos ~]# docker stop a27eb96e5f16
a27eb96e5f16
[root@VM-4-11-centos ~]# docker stop dd315616dccc
dd315616dccc
[root@VM-4-11-centos ~]# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[root@VM-4-11-centos ~]#

```
## 删除容器
```shell
[root@VM-4-11-centos ~]# docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                          PORTS     NAMES
a27eb96e5f16   redis     "docker-entrypoint.s…"   18 minutes ago   Exited (0) 2 minutes ago                  redis-test02
dd315616dccc   redis     "docker-entrypoint.s…"   18 minutes ago   Exited (0) About a minute ago             redis-test01
[root@VM-4-11-centos ~]# docker rm -f a27eb96e5f16
a27eb96e5f16
[root@VM-4-11-centos ~]# docker rm -f dd315616dccc
dd315616dccc
[root@VM-4-11-centos ~]# docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[root@VM-4-11-centos ~]#

```
## 如何带配置文件启动？
---
# sentinel cluster
## add redis node  
docker run -itd --name redis-test03 -p 10003:6379  redis
```shell
[root@VM-4-11-centos ~]# docker run -itd --name redis-test03 -p 10003:6379  redis
95e7d16f2850247334aabbfd22d2279b7aa843291d33e3c4b8b1953f30711357
[root@VM-4-11-centos ~]#
```
作为从节点加入集群
```shell
127.0.0.1:6379> REPLICAOF 172.17.0.3 6379
OK
127.0.0.1:6379> info replication
# Replication
role:slave
master_host:172.17.0.3
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_read_repl_offset:98520
slave_repl_offset:98520
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
master_failover_state:no-failover
master_replid:c3a9c5594293f20907538212714ca276b9047f6b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:98520
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:98493
repl_backlog_histlen:28
```
## sentinel集群-OK
[reference](https://blog.csdn.net/weixin_38305440/article/details/118585188)
```shell
[root@VM-4-11-centos ~]# mkdir /opt/sentinel/
# 末尾的 2 表示两个哨兵投票确认主服务器宕机，哨兵才会认为主服务器宕机
cat <<EOF >5000.conf
port 5000
sentinel monitor mymaster 172.17.0.3 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
EOF

cat <<EOF >5001.conf
port 5001
sentinel monitor mymaster 172.17.0.4 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
EOF

cat <<EOF >5002.conf
port 5002
sentinel monitor mymaster 172.17.0.5 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
EOF
[root@VM-4-11-centos ~]# cd /opt/sentinel/
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]# # 配置文件中的 "sentinel monitor mymaster 192.168.64.150 6379 2"
[root@VM-4-11-centos sentinel]# # 末尾的 2 表示两个哨兵投票确认主服务器宕机，哨兵才会认为主服务器宕机
[root@VM-4-11-centos sentinel]# cat <<EOF >5000.conf
> port 5000
> sentinel monitor mymaster 192.168.64.150 6379 2
> sentinel down-after-milliseconds mymaster 5000
> sentinel failover-timeout mymaster 60000
> sentinel parallel-syncs mymaster 1
> EOF
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]# cat <<EOF >5001.conf
> port 5001
> sentinel monitor mymaster 192.168.64.150 6379 2
> sentinel down-after-milliseconds mymaster 5000
> sentinel failover-timeout mymaster 60000
> sentinel parallel-syncs mymaster 1
> EOF
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]# cat <<EOF >5002.conf
> port 5002
> sentinel monitor mymaster 192.168.64.150 6379 2
> sentinel down-after-milliseconds mymaster 5000
> sentinel failover-timeout mymaster 60000
> sentinel parallel-syncs mymaster 1
> EOF
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]# ll
total 12
-rw-r--r-- 1 root root 181 Jul 22 22:52 5000.conf
-rw-r--r-- 1 root root 181 Jul 22 22:52 5001.conf
-rw-r--r-- 1 root root 181 Jul 22 22:52 5002.conf
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]# vi 500
5000.conf  5001.conf  5002.conf
[root@VM-4-11-centos sentinel]# vi 5000.conf
[root@VM-4-11-centos sentinel]# vi 5001.conf
[root@VM-4-11-centos sentinel]# vi 5002.conf
[root@VM-4-11-centos sentinel]# docker run -d --name sentinel5000 \
> -v /opt/sentinel/5000.conf:/sentinel.conf \
> --net=host \
> redis redis-sentinel /sentinel.conf
docker run -d --name sentinel5001 \
-v /opt/sentinel/5001.conf:/sentinel.conf \
--net=host \
redis redis-sentinel /sentinel.conf

docker run -d --name sentinel5002 \
-v /opt/sentinel/5002.conf:/sentinel.conf \
--net=host \
redis redis-sentinel /sentinel.conf

# 进入一个哨兵容器，查看它监控的主从服务器和其他哨兵
docker exec -it sentinel5000 redis-cli -p 5000
> sentinel master mymaster
> sentinel slaves mymaster
> sentinel sentinels mymaster
6659cb6b87e4a9b04c1dd1d19760fb1ec2a5cf2f9a40ca77c2228e8603331ba0
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]# docker run -d --name sentinel5001 \
> -v /opt/sentinel/5001.conf:/sentinel.conf \
> --net=host \
> redis redis-sentinel /sentinel.conf
2a38f429a594c324d39c562c4f60182404af6821d6308d0eaf0cb9082252cc64
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]# docker run -d --name sentinel5002 \
> -v /opt/sentinel/5002.conf:/sentinel.conf \
> --net=host \
> redis redis-sentinel /sentinel.conf
891aed1212b66b8c129596fc0d00a2da3d64dadbd9edf15ce5e19615547bdffd
[root@VM-4-11-centos sentinel]#
[root@VM-4-11-centos sentinel]# # 进入一个哨兵容器，查看它监控的主从服务器和其他哨兵
[root@VM-4-11-centos sentinel]# docker exec -it sentinel5000 redis-cli -p 5000
> sentinel master mymaster
> sentinel slaves mymaster
> sentinel sentinels mymaster
127.0.0.1:5000> info sentinel
# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_tilt_since_seconds:-1
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=mymaster,status=sdown,address=172.17.0.3:6379,slaves=1,sentinels=2
127.0.0.1:5000> quit
[root@VM-4-11-centos sentinel]#
```