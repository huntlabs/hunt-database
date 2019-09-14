module hunt.database.driver.mysql.impl.codec.Packets;

/**
 * MySQL Packets.
 */
enum Packets : int {
    OK_PACKET_HEADER = 0x00,
    EOF_PACKET_HEADER = 0xFE,
    ERROR_PACKET_HEADER = 0xFF,
    PACKET_PAYLOAD_LENGTH_LIMIT = 0xFFFFFF
}


/**
 * 
 */
static final class OkPacket {

    private long _affectedRows;
    private long _lastInsertId;
    private int _serverStatusFlags;
    private int _numberOfWarnings;
    private string _statusInfo;
    private string _sessionStateInfo;

    this(long affectedRows, long lastInsertId, int serverStatusFlags, int numberOfWarnings, 
            string statusInfo, string sessionStateInfo) {
        this._affectedRows = affectedRows;
        this._lastInsertId = lastInsertId;
        this._serverStatusFlags = serverStatusFlags;
        this._numberOfWarnings = numberOfWarnings;
        this._statusInfo = statusInfo;
        this._sessionStateInfo = sessionStateInfo;
    }

    long affectedRows() {
        return _affectedRows;
    }

    long lastInsertId() {
        return _lastInsertId;
    }

    int serverStatusFlags() {
        return _serverStatusFlags;
    }

    int numberOfWarnings() {
        return _numberOfWarnings;
    }

    string statusInfo() {
        return _statusInfo;
    }

    string sessionStateInfo() {
        return _sessionStateInfo;
    }
}


/**
 * 
 */
final class EofPacket {

    private int _numberOfWarnings;
    private int _serverStatusFlags;

    this(int numberOfWarnings, int serverStatusFlags) {
        this._numberOfWarnings = numberOfWarnings;
        this._serverStatusFlags = serverStatusFlags;
    }

    int numberOfWarnings() {
        return _numberOfWarnings;
    }

    int serverStatusFlags() {
        return _serverStatusFlags;
    }
}

enum ServerStatusFlags : int {
    /*
        https://dev.mysql.com/doc/dev/mysql-server/latest/mysql__com_8h.html#a1d854e841086925be1883e4d7b4e8cad
     */

    SERVER_STATUS_IN_TRANS = 0x0001,
    SERVER_STATUS_AUTOCOMMIT = 0x0002,
    SERVER_MORE_RESULTS_EXISTS = 0x0008,
    SERVER_STATUS_NO_GOOD_INDEX_USED = 0x0010,
    SERVER_STATUS_NO_INDEX_USED = 0x0020,
    SERVER_STATUS_CURSOR_EXISTS = 0x0040,
    SERVER_STATUS_LAST_ROW_SENT = 0x0080,
    SERVER_STATUS_DB_DROPPED = 0x0100,
    SERVER_STATUS_NO_BACKSLASH_ESCAPES = 0x0200,
    SERVER_STATUS_METADATA_CHANGED = 0x0400,
    SERVER_QUERY_WAS_SLOW = 0x0800,
    SERVER_PS_OUT_PARAMS = 0x1000,
    SERVER_STATUS_IN_TRANS_READONLY = 0x2000,
    SERVER_SESSION_STATE_CHANGED = 0x4000
}