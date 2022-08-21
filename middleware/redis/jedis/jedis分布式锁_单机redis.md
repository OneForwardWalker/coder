# 分布式锁By Jedis and redis
## 悲观不可重入
> 需要实现阻塞逻辑、死锁容错，释放的时候也要判断是不是加锁的那个客户端
```java
public class DTLock {

    private ApplicationContext applicationContext;

    private  AtomicReference<ScheduledFuture> atomicReference;

    private String lockKey;
    private String clienId;

    private static final String LOCK_SUCCESS = "OK";
    private static final Long RELEASE_SUCCESS = 1L;

    public boolean lock(long timeout) throws Exception {
        long starttime = TimeUnit.NANOSECONDS.toMillis(System.nanoTime());
        while (!tryLock()) {
            // 获取锁失败
            long resttime =
                starttime + TimeUnit.SECONDS.toMillis(timeout) - TimeUnit.NANOSECONDS.toMillis(System.nanoTime());
            if (resttime <= 0L) {
                return false;
            }
            resttime = Math.min(resttime, 100L); // 睡眠间隔
            TimeUnit.MILLISECONDS.sleep(resttime);
        }
        return true;
    }

    public boolean unlock() throws Exception {
        return unlock(3);
    }

    private boolean unlock(int retry) throws Exception {
        ScheduledFuture<?> future = (ScheduledFuture<?>) atomicReference.getAndSet(null);
        if (future != null) {
            future.cancel(false);
        }
        boolean unlockresult = unLockBlocked(retry);
        if (!unlockresult) {
            System.out.println("release 失败");
        }
        return unlockresult;
    }

    private boolean unLockBlocked(int retry) throws Exception {
        Jedis jedis = null;
        for (int i = 0; i < retry; i++) {

            try {
                jedis = applicationContext.getBean(RedisService.class).jedisPool.getResource();
                if (jedis == null) {
                    throw new Exception("redis connect error.");
                }
                if (jedis.eval(
                    "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end",
                    Collections.singletonList(lockKey), Collections.singletonList(clienId)).equals(1L)) {
                    return true;
                }
            } catch (Exception e) {
                System.out.println("connect failed,retry");
            } finally {
                jedis.close();
            }
            TimeUnit.SECONDS.sleep(1);
        }
        if (retry == 4) {
            throw new Exception("release failed!");
        }
        return false;
    }

    private boolean tryLock() throws Exception {
        boolean isGetLock = lockUnblocked(10L);
        if (isGetLock) {
            ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(1);
            ScheduledFuture<?> scheduledFuture =
                scheduledExecutorService.scheduleWithFixedDelay(() -> {}, 5L, 5L, TimeUnit.SECONDS);
            ScheduledFuture<?> existing = atomicReference.getAndSet(scheduledFuture);
            if (existing != null) {
                // 不响应中断
                existing.cancel(false);
            }
            return true;
        } else {
            return false;
        }
    }

    private boolean lockUnblocked(long expire) throws Exception {
        Jedis jedis = null;
        boolean var4;
        try {
            jedis = applicationContext.getBean(RedisService.class).jedisPool.getResource();
            if (jedis == null) {
                throw new Exception("redis connect error.");
            }
            var4 = lockUnblockOnRedis(jedis, expire);
        }  finally {
            assert jedis != null;
            jedis.close();
        }
        return var4;
    }

    private boolean lockUnblockOnRedis(Jedis jedis, long expireTime) {
        SetParams setParams = SetParams.setParams().ex(expireTime).nx();
        return "OK".equals(jedis.set(lockKey, clienId, setParams));
    }

}

```
