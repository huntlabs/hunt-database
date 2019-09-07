module hunt.database.mysql.impl.codec.ColumnDefinition;

import hunt.database.mysql.impl.codec.DataType;
import hunt.database.mysql.impl.codec.DataTypeDesc;
import std.conv;

/**
 * 
 * 
 * See_Also:
 *      https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response_text_resultset_column_definition.html
 */
final class ColumnDefinition {
    private string _catalog;
    private string _schema;
    private string _table;
    private string _orgTable;
    private string _name;
    private string _orgName;
    private int _characterSet;
    private long _columnLength;
    private DataType _type;
    private int _flags;
    private byte _decimals;

    this(string catalog,
        string schema,
        string table,
        string orgTable,
        string name,
        string orgName,
        int characterSet,
        long columnLength,
        DataType type,
        int flags,
        byte decimals) {
        this._catalog = catalog;
        this._schema = schema;
        this._table = table;
        this._orgTable = orgTable;
        this._name = name;
        this._orgName = orgName;
        this._characterSet = characterSet;
        this._columnLength = columnLength;
        this._type = type;
        this._flags = flags;
        this._decimals = decimals;
    }

    string catalog() {
        return _catalog;
    }

    string schema() {
        return _schema;
    }

    string table() {
        return _table;
    }

    string orgTable() {
        return _orgTable;
    }

    string name() {
        return _name;
    }

    string orgName() {
        return _orgName;
    }

    int characterSet() {
        return _characterSet;
    }

    long columnLength() {
        return _columnLength;
    }

    DataType type() {
        return _type;
    }

    int flags() {
        return _flags;
    }

    byte decimals() {
        return _decimals;
    }

    override
    string toString() {
        return "ColumnDefinition{" ~
            "catalog='" ~ _catalog ~ "\'" ~
            ", schema='" ~ _schema ~ "\'" ~
            ", table='" ~ _table ~ "\'" ~
            ", orgTable='" ~ _orgTable ~ "\'" ~
            ", name='" ~ _name ~ "\'" ~
            ", orgName='" ~ _orgName ~ "\'" ~
            ", characterSet=" ~ _characterSet.to!string() ~
            ", columnLength=" ~ _columnLength.to!string() ~
            ", type=" ~ _type.to!string() ~
            ", flags=" ~ _flags.to!string() ~
            ", decimals=" ~ _decimals.to!string() ~
            '}';
    }

}


/*
    https://dev.mysql.com/doc/dev/mysql-server/latest/group__group__cs__column__definition__flags.html
 */
enum ColumnDefinitionFlags : int {
    NOT_NULL_FLAG = 0x00000001,
    PRI_KEY_FLAG = 0x00000002,
    UNIQUE_KEY_FLAG = 0x00000004,
    MULTIPLE_KEY_FLAG = 0x00000008,
    BLOB_FLAG = 0x00000010,
    UNSIGNED_FLAG = 0x00000020,
    ZEROFILL_FLAG = 0x00000040,
    BINARY_FLAG = 0x00000080,
    ENUM_FLAG = 0x00000100,
    AUTO_INCREMENT_FLAG = 0x00000200,
    TIMESTAMP_FLAG = 0x00000400,
    SET_FLAG = 0x00000800,
    NO_DEFAULT_VALUE_FLAG = 0x00001000,
    ON_UPDATE_NOW_FLAG = 0x00002000,
    NUM_FLAG = 0x00008000,
    PART_KEY_FLAG = 0x00004000,
    GROUP_FLAG = 0x00008000,
    UNIQUE_FLAG = 0x00010000,
    BINCMP_FLAG = 0x00020000,
    GET_FIXED_FIELDS_FLAG = 0x00040000,
    FIELD_IN_PART_FUNC_FLAG = 0x00080000,
    FIELD_IN_ADD_INDEX = 0x00100000,
    FIELD_IS_RENAMED = 0x00200000,
    FIELD_FLAGS_STORAGE_MEDIA = 22,
    FIELD_FLAGS_STORAGE_MEDIA_MASK = 3 << FIELD_FLAGS_STORAGE_MEDIA,
    FIELD_FLAGS_COLUMN_FORMAT = 24,
    FIELD_FLAGS_COLUMN_FORMAT_MASK = 3 << FIELD_FLAGS_COLUMN_FORMAT,
    FIELD_IS_DROPPED = 0x04000000,
    EXPLICIT_NULL_FLAG = 0x08000000,
    FIELD_IS_MARKED = 0x10000000
}