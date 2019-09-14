module hunt.database.driver.mysql.impl.codec.DataTypeDesc;

import hunt.database.driver.mysql.impl.codec.DataType;

import hunt.util.ObjectUtils;
import std.format;

/**
 * 
 */
struct DataTypeDesc {
    int id;
    string[] binaryType;
    string[] textType;

    this(int id, string[] types) {
        this.id = id;
        this.binaryType = types;
        this.textType = types;
    }

    this(int id, string[] binaryType, string[] textType) {
        this.id = id;
        this.binaryType = binaryType;
        this.textType = textType;
    }

    string toString() {
        return format("DataType=%s(%d)", cast(DataType)id, id);
    }
}


struct DataTypes {
    enum DataTypeDesc INT1 = DataTypeDesc(ColumnType.MYSQL_TYPE_TINY, [byte.stringof, ubyte.stringof]); // Byte.class, Byte.class
    enum DataTypeDesc INT2 = DataTypeDesc(ColumnType.MYSQL_TYPE_SHORT, [short.stringof, ushort.stringof]); // Short.class, Short.class
    enum DataTypeDesc INT3 = DataTypeDesc(ColumnType.MYSQL_TYPE_INT24, [int.stringof, uint.stringof]); // Integer.class, Integer.class
    enum DataTypeDesc INT4 = DataTypeDesc(ColumnType.MYSQL_TYPE_LONG, [int.stringof, uint.stringof]); // Integer.class, Integer.class
    enum DataTypeDesc INT8 = DataTypeDesc(ColumnType.MYSQL_TYPE_LONGLONG, [long.stringof, ulong.stringof]); // Long.class, Long.class
    enum DataTypeDesc DOUBLE = DataTypeDesc(ColumnType.MYSQL_TYPE_DOUBLE, [double.stringof]); // Double.class, Double.class
    enum DataTypeDesc FLOAT = DataTypeDesc(ColumnType.MYSQL_TYPE_FLOAT, [float.stringof]); // Float.class, Float.class
    enum DataTypeDesc NUMERIC = DataTypeDesc(ColumnType.MYSQL_TYPE_NEWDECIMAL, null); // Numeric.class, Numeric.class DECIMAL
    enum DataTypeDesc STRING = DataTypeDesc(ColumnType.MYSQL_TYPE_STRING, ["string", "immutable(char)[]"]); // Buffer.class, String.class, CHAR, BINARY
    enum DataTypeDesc VARSTRING = DataTypeDesc(ColumnType.MYSQL_TYPE_VAR_STRING, ["string", "immutable(char)[]"]); // Buffer.class, String.class, VARCHAR, VARBINARY
    enum DataTypeDesc TINYBLOB = DataTypeDesc(ColumnType.MYSQL_TYPE_TINY_BLOB, ["string", "immutable(char)[]"]); // Buffer.class, String.class
    enum DataTypeDesc BLOB = DataTypeDesc(ColumnType.MYSQL_TYPE_BLOB, ["string", "immutable(char)[]"]); // Buffer.class, String.class
    enum DataTypeDesc MEDIUMBLOB = DataTypeDesc(ColumnType.MYSQL_TYPE_MEDIUM_BLOB, ["string", "immutable(char)[]"]); // Buffer.class, String.class
    enum DataTypeDesc LONGBLOB = DataTypeDesc(ColumnType.MYSQL_TYPE_LONG_BLOB, ["string", "immutable(char)[]"]); // Buffer.class, String.class
    enum DataTypeDesc DATE = DataTypeDesc(ColumnType.MYSQL_TYPE_DATE, null); //  LocalDate.class, LocalDate.class
    enum DataTypeDesc TIME = DataTypeDesc(ColumnType.MYSQL_TYPE_TIME, null); // Duration.class, Duration.class
    enum DataTypeDesc DATETIME = DataTypeDesc(ColumnType.MYSQL_TYPE_DATETIME, null); // LocalDateTime.class, LocalDateTime.class
    enum DataTypeDesc YEAR = DataTypeDesc(ColumnType.MYSQL_TYPE_YEAR, [short.stringof, ushort.stringof]); // Short.class, Short.class
    enum DataTypeDesc TIMESTAMP = DataTypeDesc(ColumnType.MYSQL_TYPE_TIMESTAMP, null); // LocalDateTime.class, LocalDateTime.class
    enum DataTypeDesc NULL = DataTypeDesc(ColumnType.MYSQL_TYPE_NULL, null, null);

    mixin ValuesMemberTempate!DataTypeDesc;

    static DataTypeDesc valueOf(int value) {
         foreach(ref DataTypeDesc d; values()) {
            if(d.id == value)
                return d;
        }

        version(HUNT_DEBUG) {
            import hunt.logging.ConsoleLogger;
            warningf("MySQL type = %d not handled - using unknown type instead", value);
        }
        //TODO need better handling
        return NULL;
    }
}