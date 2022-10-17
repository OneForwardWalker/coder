# ip与long转换
```java
import java.util.Random;

public class Main {
    public static void main(String[] args) {
        System.out.println(new Main().ipToLong("100.100.1.10"));
        System.out.println(new Main().longToIp(1684275466L));
    }

    private long ipToLong(String ip) {
        String[] strs = ip.split("\\.");
        return Long.parseLong(strs[0]) << 24
                | Long.parseLong(strs[1]) << 16
                | Long.parseLong(strs[2]) << 8
                | Long.parseLong(strs[3]);
    }

    private String longToIp(Long ip) {
        return ((ip >> 24) & 0xFF) + "." +
                ((ip >> 16) & 0xFF) + "." +
                ((ip >> 8) & 0xFF) + "." +
                (ip & 0xFF);
    }

}
```
```text
1684275466
100.100.1.10
```
