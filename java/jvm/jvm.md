# jvm
[p1](https://www.bilibili.com/video/BV1Jv41157Wu?p=1&vd_source=f12804ee4e79e35de3222877ad6bbc51)
# java跨平台
JVM屏蔽了操作系统的差异，可以理解为不同的操作系统都有实现自己的JVM
# jvm组成
![image](https://user-images.githubusercontent.com/108277303/188313044-b7a89b3b-f8d0-4807-ab13-94ca977aef6b.png)
## 类装载子系统
## 运行时数据区
* 堆
* 方法区
* 虚拟机栈、线程栈  
* * 作用：方法执行时，需要启动一个线程，分配线程栈空间，每个线程都有一个线程栈空间，用来存储局部变量
* * 组成：由栈帧组成，栈帧一一对应类中的方法，栈帧按照方法调用的顺序入栈。
* * 栈帧组成：局部变量、操作数栈、动态链接、方法出口
* * * 局部变量：int a = 1;  
* * * 操作数栈：
* 程序计数器
* 本地方法栈
## 字节码执行引擎
# javap -c 
反汇编字节码文件，可读性好一点  

---
[p2](https://www.bilibili.com/video/BV1Jv41157Wu?p=2&spm_id_from=pageDriver&vd_source=f12804ee4e79e35de3222877ad6bbc51)
