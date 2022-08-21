[安装](https://www.cnblogs.com/kendoziyu/p/15778778.html)
```shell

[root@VM-4-11-centos data]# docker exec -it 0d6c3a8e7201 /bin/bash
root@0d6c3a8e7201:/# ls
bin   dev                         etc   lib    media  opt   root  sbin  sys  usr
boot  docker-entrypoint-initdb.d  home  lib64  mnt    proc  run   srv   tmp  var
root@0d6c3a8e7201:/#
root@0d6c3a8e7201:/# psql -U postgres
psql (14.4 (Debian 14.4-1.pgdg110+1))
Type "help" for help.

postgres=# quit
root@0d6c3a8e7201:/# psql -U postgres -W
Password:
psql (14.4 (Debian 14.4-1.pgdg110+1))
Type "help" for help.

postgres=# create database test;
CREATE DATABASE
postgres=# quit
root@0d6c3a8e7201:/#
root@0d6c3a8e7201:/# exit
exit

```