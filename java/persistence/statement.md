[reference](https://blog.csdn.net/minose/article/details/85040646)
# PreparedStatement、Statement、CallableStatement
> PreparedStatement是用来执行SQL查询语句的API之一，java提供了PreparedStatement和Statement和CallableStatement来执行查询。  
> PreparedStatement用于条件查询，Statement用于普通查询，CallableStatement则是用于存储过程
## JDBC
### 引入jdbc的jar
[reference](https://blog.csdn.net/tantangyueyue/article/details/115182700)
### 示例
```java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class Main {

    public static final String URL = "jdbc:mysql://localhost:3306/test";
    public static final String USER = "root";
    public static final String PASSWORD = "root";

    public static void main(String[] args) throws Exception {
        // 1.加载驱动程序
        Class.forName("com.mysql.cj.jdbc.Driver");
        // 2. 获得数据库连接
        Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
        // 3. Statement操作数据库，实现增删改查
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM user;");
        // 如果有数据，rs.next()返回true
        while (rs.next()) {
             System.out.println(rs.getString("name") + " 年龄：" + rs.getInt("age"));
        }
        System.out.println("===========");
        // 4. 重新获得数据库连接
        Connection conn1 = DriverManager.getConnection(URL, USER, PASSWORD);
        // 5.PreparedStatement
        PreparedStatement preparedStatement = conn1.prepareStatement("select * from user where name = ?;");
        preparedStatement.setObject(1, "admin");
        ResultSet rs1 = preparedStatement.executeQuery();
        while (rs1.next()) {
            System.out.println(rs1.getString("name") + " 年龄：" + rs1.getInt("age"));
        }
    }
}

```
## PreparedStatement
> 数据库系统会对sql语句进行**预编译**处理（如果JDBC驱动支持的话），预处理语句将被预先编译好，这条预编译的sql查询语句能在将来的查询中重用，这样一来，它比**Statement对象生成的查询速度更快**  
> 不支持预编译SQL查询的JDBC驱动，在调用connection.prepareStatement(sql)的时候，它**不会把SQL查询语句发送给数据库做预处理**，而是等到执行查询动作的时候（调用executeQuery()方法时）才把查询语句发送个数据库，这种情况和使用Statement是一样的  
> 占位符的索引**从1开始**
## Statement
> 在对数据库只执行一次性存取的时侯，用 Statement 对象进行处理。**PreparedStatement 对象的开销比Statement大**，对于一次性操作并不会带来额外的好处
