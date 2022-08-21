# Boolean

## 属性

```
// 布尔二值，直接复用的静态对象
public static final Boolean TRUE = new Boolean(true);
public static final Boolean FALSE = new Boolean(false);
// 布尔值，boolean类型
private final boolean value;
```

## 构造函数

> 传入的字符串会被直接转化为小写，所以True TRUe都是可以的

```java
public Boolean(boolean value) {
    this.value = value;
}
```

> 传入字符串

```java
public Boolean(String s) {
    this(parseBoolean(s));
}
```

> 字符串解析成boolean值

```
public static boolean parseBoolean(String s) {
    return ((s != null) && s.equalsIgnoreCase("true"));
}
```

## public static boolean getBoolean(String name)
> 获取系统变量
```java
public static boolean getBoolean(String name) {
    boolean result = false;
    try {
        result = parseBoolean(System.getProperty(name));
    } catch (IllegalArgumentException | NullPointerException e) {
    }
    return result;
}
```
