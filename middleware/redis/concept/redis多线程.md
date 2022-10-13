# reids的多线程和单线程
[redis多线程](https://blog.csdn.net/MOU_IT/article/details/118164184)

# 多线程怎么利用
1. IO多线程，提高redis的IO能力，使用多线程充分利用多核优势，提高客户端的数量。 
2. 核心线程多线程，可以根据key做hash分散利用多个核心线程。但是可以在单VM上面使用多个redis进程，也可以满足使用多核心 
