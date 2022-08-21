# mybatis缓存
> [参考](https://juejin.cn/column/6977186563188867108)
## 一级缓存（局部缓存）
    1. 作用域在session级别，中间有修改操作会清除一级缓存，查询不同的mapper.xml缓存不生效
    2. 设置mapper.xml的flushCache，可以设定执行语句后清除缓存（一级和二级均会被删除）
## 二级缓存（全局缓存）
    1. 作用域在mapper下面
## 自定义缓存
    自定义
# 打开关闭一级或者二级换存
[reference](https://blog.csdn.net/qq_19314763/article/details/113534304)
# 同时打开一级和二级缓存的时候先读取那个,先读取二级再读取一级
[reference](https://blog.csdn.net/zzti_erlie/article/details/109562745)
