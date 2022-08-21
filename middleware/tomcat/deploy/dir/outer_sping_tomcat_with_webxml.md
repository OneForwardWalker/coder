# 使用外置的tomcat部署spring工程

## 部署tomcat

* **下载源码包，解压到环境**

```
[root@cenos apache-tomcat-8.5.47]# ll
total 144
drwxr-x--- 2 root root  4096 Jul 10 20:20 bin
-rw-r----- 1 root root 19318 Oct  7  2019 BUILDING.txt
drwx------ 3 root root  4096 Jul 10 21:20 conf
-rw-r----- 1 root root  5407 Oct  7  2019 CONTRIBUTING.md
drwxr-x--- 2 root root  4096 Jul 10 17:55 lib
-rw-r----- 1 root root 57011 Oct  7  2019 LICENSE
drwxr-x--- 2 root root  4096 Jul 10 21:22 logs
-rw-r----- 1 root root  1726 Oct  7  2019 NOTICE
-rw-r----- 1 root root  3255 Oct  7  2019 README.md
-rw-r----- 1 root root  7136 Oct  7  2019 RELEASE-NOTES
-rw-r----- 1 root root 16262 Oct  7  2019 RUNNING.txt
drwxr-x--- 2 root root  4096 Jul 10 17:55 temp
drwxr-x--- 8 root root  4096 Jul 10 21:11 webapps
drwxr-x--- 3 root root  4096 Jul 10 17:56 work
[root@cenos apache-tomcat-8.5.47]# cd ..
[root@cenos tomcat]# ls
apache-tomcat-8.5.47  apache-tomcat-8.5.47.tar.gz
[root@cenos tomcat]#
```

* **bin目录下面启动或者停止tomcat**
  同时有windows的和linux的

```
[root@cenos bin]# ll
total 860
  -rw-r----- 1 root root  35109 Oct  7  2019 bootstrap.jar
  -rw-r----- 1 root root  15953 Oct  7  2019 catalina.bat
  -rwxr-x--- 1 root root  23567 Oct  7  2019 catalina.sh
  -rw-r----- 1 root root   1664 Oct  7  2019 catalina-tasks.xml
  -rw-r----- 1 root root   2123 Oct  7  2019 ciphers.bat
  -rwxr-x--- 1 root root   1997 Oct  7  2019 ciphers.sh
  -rw-r----- 1 root root  25197 Oct  7  2019 commons-daemon.jar
  -rw-r----- 1 root root 206895 Oct  7  2019 commons-daemon-native.tar.gz
  -rw-r----- 1 root root   2040 Oct  7  2019 configtest.bat
  -rwxr-x--- 1 root root   1922 Oct  7  2019 configtest.sh
  -rwxr-x--- 1 root root   8513 Oct  7  2019 daemon.sh
  -rw-r----- 1 root root   2091 Oct  7  2019 digest.bat
  -rwxr-x--- 1 root root   1965 Oct  7  2019 digest.sh
  -rw-r----- 1 root root   3460 Oct  7  2019 setclasspath.bat
  -rwxr-x--- 1 root root   3708 Oct  7  2019 setclasspath.sh
  -rw-r----- 1 root root   2020 Oct  7  2019 shutdown.bat
  -rwxr-x--- 1 root root   1902 Oct  7  2019 shutdown.sh
  -rw-r----- 1 root root   2022 Oct  7  2019 startup.bat
  -rwxr-x--- 1 root root   1904 Oct  7  2019 startup.sh
  -rw-r----- 1 root root  49937 Oct  7  2019 tomcat-juli.jar
  -rw-r----- 1 root root 419428 Oct  7  2019 tomcat-native.tar.gz
  -rw-r----- 1 root root   4574 Oct  7  2019 tool-wrapper.bat
  -rwxr-x--- 1 root root   5515 Oct  7  2019 tool-wrapper.sh
  -rw-r----- 1 root root   2026 Oct  7  2019 version.bat
  -rwxr-x--- 1 root root   1908 Oct  7  2019 version.sh
```
