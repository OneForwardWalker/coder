# docker 安装mysql
[reference](https://www.runoob.com/docker/docker-install-mysql.html)
```shell
[root@VM-4-11-centos ~]# docker pull mysql:latest
latest: Pulling from library/mysql
e54b73e95ef3: Pull complete
327840d38cb2: Pull complete
642077275f5f: Pull complete
e077469d560d: Pull complete
cbf214d981a6: Pull complete
7d1cc1ea1b3d: Pull complete
d48f3c15cb80: Pull complete
94c3d7b2c9ae: Pull complete
f6cfbf240ed7: Pull complete
e12b159b2a12: Pull complete
4e93c6fd777f: Pull complete
Digest: sha256:152cf187a3efc56afb0b3877b4d21e231d1d6eb828ca9221056590b0ac834c75
Status: Downloaded newer image for mysql:latest
docker.io/library/mysql:latest
[root@VM-4-11-centos ~]# docker im
image   images  import
[root@VM-4-11-centos ~]# docker im
image   images  import
[root@VM-4-11-centos ~]# docker images
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
redis         latest    3edbb69f9a49   2 days ago      117MB
mysql         latest    33037edcac9b   8 days ago      444MB
koa-demo      latest    d6f90814c3d4   13 days ago     675MB
wordpress     latest    8d2a3b437bc8   3 weeks ago     609MB
mariadb       latest    ea81af801379   6 weeks ago     383MB
ubuntu        latest    27941809078c   6 weeks ago     77.8MB
hello-world   latest    feb5d9fea6a5   10 months ago   13.3kB
node          8.4       386940f92d24   4 years ago     673MB
[root@VM-4-11-centos ~]# docker run -itd --name mysql01 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root mysql
afb0e09952f89380246db8cbc62f5c595ce9c7d82d40402fab16c9f9e7865936
[root@VM-4-11-centos ~]# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
afb0e09952f8   mysql     "docker-entrypoint.s…"   22 seconds ago   Up 21 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   mysql01
242225df22d3   redis     "docker-entrypoint.s…"   2 hours ago      Up 2 hours      0.0.0.0:10002->6379/tcp, :::10002->6379/tcp            redis-test02
a0b7b4a2decd   redis     "docker-entrypoint.s…"   2 hours ago      Up 2 hours      0.0.0.0:10001->6379/tcp, :::10001->6379/tcp            redis-test01
[root@VM-4-11-centos ~]# mysql -h localhost -u root -p
-bash: mysql: command not found
[root@VM-4-11-centos ~]# docker exec -it mysql01 bash
bash-4.4# mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.29 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>

```

## 如何查看mysql的日志文件
> 需要从docker拷到宿主机，不太方便
[拷到宿主机](https://blog.csdn.net/fen_fen/article/details/109203262)
> 
# 带配置文件和目录映射安装
