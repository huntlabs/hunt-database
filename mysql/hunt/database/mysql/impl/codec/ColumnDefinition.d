module hunt.database.mysql.impl.codec.ColumnDefinition;

import hunt.database.mysql.impl.codec.DataType;

final class ColumnDefinition {
    /*
        https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_com_query_response_text_resultset_column_definition.html
     */
    private string catalog;
    private string schema;
    private string table;
    private string orgTable;
    private string name;
    private string orgName;
    private int characterSet;
    private long columnLength;
    private DataType type;
    private int flags;
    private byte decimals;

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
        this.catalog = catalog;
        this.schema = schema;
        this.table = table;
        this.orgTable = orgTable;
        this.name = name;
        this.orgName = orgName;
        this.characterSet = characterSet;
        this.columnLength = columnLength;
        this.type = type;
        this.flags = flags;
        this.decimals = decimals;
    }

    string catalog() {
        return catalog;
    }

    string schema() {
        return schema;
    }

    string table() {
        return table;
    }

    string orgTable() {
        return orgTable;
    }

    string name() {
        return name;
    }

    string orgName() {
        return orgName;
    }

    int characterSet() {
        return characterSet;
    }

    long columnLength() {
        return columnLength;
    }

    DataType type() {
        return type;
    }

    int flags() {
        return flags;
    }

    byte decimals() {
        return decimals;
    }

    override
    string toString() {
        return "ColumnDefinition{" ~
            "catalog='" ~ catalog ~ "\'" ~
            ", schema='" ~ schema ~ "\'" ~
            ", table='" ~ table ~ "\'" ~
            ", orgTable='" ~ orgTable ~ "\'" ~
            ", name='" ~ name ~ "\'" ~
            ", orgName='" ~ orgName ~ "\'" ~
            ", characterSet=" ~ characterSet ~
            ", columnLength=" ~ columnLength ~
            ", type=" ~ type ~
            ", flags=" ~ flags ~
            ", decimals=" ~ decimals ~
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