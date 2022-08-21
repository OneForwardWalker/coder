# 使用springboot内置的tomcat启动

* 将项目打成jar包，在windows下编译，放到linux运行,启动成功

```
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 1.884 s - in com.example.demo.DemoApplicationTests
[INFO]
  [INFO] Results:
  [INFO]
  [INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
  [INFO]
  [INFO]
  [INFO] --- maven-jar-plugin:3.2.2:jar (default-jar) @ demo ---
  [INFO] Building jar: D:\study\github_desk\java\ssm\springdemo\target\demo-0.0.1-SNAPSHOT.jar
  [INFO]
  [INFO] --- spring-boot-maven-plugin:2.6.3:repackage (repackage) @ demo ---
  [INFO] Replacing main artifact with repackaged archive
  [INFO]
  [INFO] --- maven-install-plugin:2.5.2:install (default-install) @ demo ---
  [INFO] Installing D:\study\github_desk\java\ssm\springdemo\target\demo-0.0.1-SNAPSHOT.jar to E:\study\maven\com\example\demo\0.0.1-SNAPSHOT\demo-0.0.1-SNAPSHOT.jar
  [INFO] Installing D:\study\github_desk\java\ssm\springdemo\pom.xml to E:\study\maven\com\example\demo\0.0.1-SNAPSHOT\demo-0.0.1-SNAPSHOT.pom
  [INFO] ------------------------------------------------------------------------
  [INFO] BUILD SUCCESS
  [INFO] ------------------------------------------------------------------------
  [INFO] Total time:  7.059 s
  [INFO] Finished at: 2022-07-11T00:57:15+08:00
  [INFO] ------------------------------------------------------------------------
```

* 在linux上运行程序

```
[root@cenos software]# java -jar ./demo-0.0.1-SNAPSHOT.jar
SLF4J: Class path contains multiple SLF4J bindings.
  SLF4J: Found binding in [jar:file:/opt/software/demo-0.0.1-SNAPSHOT.jar!/BOOT-INF/lib/logback-classic-1.2.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
  SLF4J: Found binding in [jar:file:/opt/software/demo-0.0.1-SNAPSHOT.jar!/BOOT-INF/lib/slf4j-log4j12-1.7.33.jar!/org/slf4j/impl/StaticLoggerBinder.class]
  SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
  SLF4J: Actual binding is of type [ch.qos.logback.classic.util.ContextSelectorStaticBinder]
  
  .   ____          _            __ _ _
  /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ 
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ 
\\/  ___)| |_)| | | | | || (_| |  ) ) ) )
'  |____| .__|_| |_|_| |_\__, | / / / /
=========|_|==============|___/=/_/_/_/
  :: Spring Boot ::                (v2.6.3)

2022-07-11 00:57:27.856  INFO 565836 --- [           main] com.example.demo.DemoApplication         : Starting DemoApplication v0.0.1-SNAPSHOT using Java 1.8.0_312 on cenos with PID 565836 (/opt/software/demo-0.0.1-SNAPSHOT.jar started by root in /opt/software)
2022-07-11 00:57:27.860  INFO 565836 --- [           main] com.example.demo.DemoApplication         : No active profile set, falling back to default profiles: default
2022-07-11 00:57:29.365  INFO 565836 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8080 (http)
2022-07-11 00:57:29.366  INFO 565836 --- [           main] o.a.catalina.core.AprLifecycleListener   : An older version [1.2.23] of the Apache Tomcat Native library is installed, while Tomcat recommends a minimum version of [1.2.30]
2022-07-11 00:57:29.367  INFO 565836 --- [           main] o.a.catalina.core.AprLifecycleListener   : Loaded Apache Tomcat Native library [1.2.23] using APR version [1.6.3].
2022-07-11 00:57:29.367  INFO 565836 --- [           main] o.a.catalina.core.AprLifecycleListener   : APR capabilities: IPv6 [true], sendfile [true], accept filters [false], random [true], UDS [false].
2022-07-11 00:57:29.367  INFO 565836 --- [           main] o.a.catalina.core.AprLifecycleListener   : APR/OpenSSL configuration: useAprConnector [false], useOpenSSL [true]
2022-07-11 00:57:29.370  INFO 565836 --- [           main] o.a.catalina.core.AprLifecycleListener   : OpenSSL successfully initialized [OpenSSL 1.1.1k  FIPS 25 Mar 2021]
2022-07-11 00:57:29.398  INFO 565836 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2022-07-11 00:57:29.399  INFO 565836 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet engine: [Apache Tomcat/9.0.56]
2022-07-11 00:57:29.467  INFO 565836 --- [           main] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2022-07-11 00:57:29.468  INFO 565836 --- [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 1488 ms
2022-07-11 00:57:30.022  INFO 565836 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path ''
2022-07-11 00:57:30.039  INFO 565836 --- [           main] com.example.demo.DemoApplication         : Started DemoApplication in 2.878 seconds (JVM running for 3.511)
c2022-07-11 00:58:14.978  INFO 565836 --- [nio-8080-exec-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring DispatcherServlet 'dispatcherServlet'
2022-07-11 00:58:14.979  INFO 565836 --- [nio-8080-exec-1] o.s.web.servlet.DispatcherServlet        : Initializing Servlet 'dispatcherServlet'
2022-07-11 00:58:14.980  INFO 565836 --- [nio-8080-exec-1] o.s.web.servlet.DispatcherServlet        : Completed initialization in 1 ms
```

## 踩坑

* 本地编译使用的java版本要和linux上的一致，否则会报错

```
[root@cenos software]# java -jar ./demo-0.0.1-SNAPSHOT.jar
Exception in thread "main" java.lang.UnsupportedClassVersionError: com/example/demo/DemoApplication has been compiled by a more recent version of the Java Runtime (class file version 61.0), this version of the Java Runtime only recognizes class file versions up to 52.0
at java.lang.ClassLoader.defineClass1(Native Method)
at java.lang.ClassLoader.defineClass(ClassLoader.java:756)
at java.security.SecureClassLoader.defineClass(SecureClassLoader.java:142)
at java.net.URLClassLoader.defineClass(URLClassLoader.java:473)
at java.net.URLClassLoader.access$100(URLClassLoader.java:74)
at java.net.URLClassLoader$1.run(URLClassLoader.java:369)
at java.net.URLClassLoader$1.run(URLClassLoader.java:363)
at java.security.AccessController.doPrivileged(Native Method)
at java.net.URLClassLoader.findClass(URLClassLoader.java:362)
at java.lang.ClassLoader.loadClass(ClassLoader.java:418)
at org.springframework.boot.loader.LaunchedURLClassLoader.loadClass(LaunchedURLClassLoader.java:151)
at java.lang.ClassLoader.loadClass(ClassLoader.java:351)
at java.lang.Class.forName0(Native Method)
at java.lang.Class.forName(Class.java:348)
at org.springframework.boot.loader.MainMethodRunner.run(MainMethodRunner.java:46)
at org.springframework.boot.loader.Launcher.launch(Launcher.java:108)
at org.springframework.boot.loader.Launcher.launch(Launcher.java:58)
at org.springframework.boot.loader.JarLauncher.main(JarLauncher.java:88)
```



