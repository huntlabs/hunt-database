module hunt.database.mysql.impl.codec.DataType;

// import io.netty.util.collection.IntObjectHashMap;
// import io.netty.util.collection.IntObjectMap;
// import io.vertx.core.buffer.Buffer;
// import hunt.database.base.data.Numeric;

// import java.time.Duration;
// import java.time.LocalDate;
// import java.time.LocalDateTime;

enum DataType {
    INT1 = ColumnType.MYSQL_TYPE_TINY,
    INT2 = ColumnType.MYSQL_TYPE_SHORT,
    INT3 = ColumnType.MYSQL_TYPE_INT24,
    INT4 = ColumnType.MYSQL_TYPE_LONG,
    INT8 = ColumnType.MYSQL_TYPE_LONGLONG,
    DOUBLE = ColumnType.MYSQL_TYPE_DOUBLE,
    FLOAT = ColumnType.MYSQL_TYPE_FLOAT,
    NUMERIC = ColumnType.MYSQL_TYPE_NEWDECIMAL,
    STRING = ColumnType.MYSQL_TYPE_STRING,
    VARSTRING = ColumnType.MYSQL_TYPE_VAR_STRING,
    TINYBLOB = ColumnType.MYSQL_TYPE_TINY_BLOB,
    BLOB = ColumnType.MYSQL_TYPE_BLOB,
    MEDIUMBLOB = ColumnType.MYSQL_TYPE_MEDIUM_BLOB,
    LONGBLOB = ColumnType.MYSQL_TYPE_LONG_BLOB,
    DATE = ColumnType.MYSQL_TYPE_DATE,
    TIME = ColumnType.MYSQL_TYPE_TIME,
    DATETIME = ColumnType.MYSQL_TYPE_DATETIME,
    YEAR = ColumnType.MYSQL_TYPE_YEAR,
    TIMESTAMP = ColumnType.MYSQL_TYPE_TIMESTAMP,
    NULL = ColumnType.MYSQL_TYPE_NULL
}


/*
    Type of column definition
    https://dev.mysql.com/doc/dev/mysql-server/latest/binary__log__types_8h.html#aab0df4798e24c673e7686afce436aa85
 */
enum ColumnType : int {
    MYSQL_TYPE_DECIMAL = 0x00,
    MYSQL_TYPE_TINY = 0x01,
    MYSQL_TYPE_SHORT = 0x02,
    MYSQL_TYPE_LONG = 0x03,
    MYSQL_TYPE_FLOAT = 0x04,
    MYSQL_TYPE_DOUBLE = 0x05,
    MYSQL_TYPE_NULL = 0x06,
    MYSQL_TYPE_TIMESTAMP = 0x07,
    MYSQL_TYPE_LONGLONG = 0x08,
    MYSQL_TYPE_INT24 = 0x09,
    MYSQL_TYPE_DATE = 0x0A,
    MYSQL_TYPE_TIME = 0x0B,
    MYSQL_TYPE_DATETIME = 0x0C,
    MYSQL_TYPE_YEAR = 0x0D,
    MYSQL_TYPE_VARCHAR = 0x0F,
    MYSQL_TYPE_BIT = 0x10,
    MYSQL_TYPE_JSON = 0xF5,
    MYSQL_TYPE_NEWDECIMAL = 0xF6,
    MYSQL_TYPE_ENUM = 0xF7,
    MYSQL_TYPE_SET = 0xF8,
    MYSQL_TYPE_TINY_BLOB = 0xF9,
    MYSQL_TYPE_MEDIUM_BLOB = 0xFA,
    MYSQL_TYPE_LONG_BLOB = 0xFB,
    MYSQL_TYPE_BLOB = 0xFC,
    MYSQL_TYPE_VAR_STRING = 0xFD,
    MYSQL_TYPE_STRING = 0xFE,
    MYSQL_TYPE_GEOMETRY = 0xFF,

    /*
        Internal to MySQL Server
     */
    MYSQL_TYPE_NEWDATE = 0x0E,
    MYSQL_TYPE_TIMESTAMP2 = 0x11,
    MYSQL_TYPE_DATETIME2 = 0x12,
    MYSQL_TYPE_TIME2 = 0x13
}