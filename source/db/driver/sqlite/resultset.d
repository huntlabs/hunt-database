module db.driver.sqlite.resultset;

import db;
import etc.c.sqlite3;

class SQLITEResultSet : ResultSet
{
    private SQLiteStatement stmt;
    private sqlite3_stmt* rs;
    ResultSetMetaData metadata;
    private bool closed;
    private int currentRowIndex;
    //        private int rowCount;
    private int[string] columnMap;
    private bool lastIsNull;
    private int columnCount;

    private bool _last;
    private bool _first;

    // checks index, updates lastIsNull, returns column type
    int checkIndex(int columnIndex)
    {
        enforceEx!SQLException(columnIndex >= 1 && columnIndex <= columnCount,
                "Column index out of bounds: " ~ to!string(columnIndex));
        int res = sqlite3_column_type(rs, columnIndex - 1);
        lastIsNull = (res == SQLITE_NULL);
        return res;
    }

    void checkClosed()
    {
        if (closed)
            throw new SQLException("Result set is already closed");
    }

public:

    void lock()
    {
        stmt.lock();
    }

    void unlock()
    {
        stmt.unlock();
    }

    this(SQLiteStatement stmt, sqlite3_stmt* rs, ResultSetMetaData metadata)
    {
        this.stmt = stmt;
        this.rs = rs;
        this.metadata = metadata;
        closed = false;
        this.columnCount = sqlite3_data_count(rs); //metadata.getColumnCount();
        for (int i = 0; i < columnCount; i++)
        {
            columnMap[metadata.getColumnName(i + 1)] = i;
        }
        currentRowIndex = -1;
        _first = true;
    }

    void onStatementClosed()
    {
        closed = true;
    }

    string decodeTextBlob(ubyte[] data)
    {
        char[] res = new char[data.length];
        foreach (i, ch; data)
        {
            res[i] = cast(char) ch;
        }
        return to!string(res);
    }

    // ResultSet interface implementation

    //Retrieves the number, types and properties of this ResultSet object's columns
    override ResultSetMetaData getMetaData()
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();
        return metadata;
    }

    override void close()
    {
        if (closed)
            return;
        checkClosed();
        lock();
        scope (exit)
            unlock();
        stmt.closeResultSet();
        closed = true;
    }

    override bool first()
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();
        throw new SQLException("Not implemented");
    }

    override bool isFirst()
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();
        return _first;
    }

    override bool isLast()
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();
        return _last;
    }

    override bool next()
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();

        if (_first)
        {
            _first = false;
            //writeln("next() first time invocation, columnCount=" ~ to!string(columnCount));
            //return columnCount > 0;
        }

        int res = sqlite3_step(rs);
        if (res == SQLITE_DONE)
        {
            _last = true;
            columnCount = sqlite3_data_count(rs);
            //writeln("sqlite3_step = SQLITE_DONE columnCount=" ~ to!string(columnCount));
            // end of data
            return columnCount > 0;
        }
        else if (res == SQLITE_ROW)
        {
            //writeln("sqlite3_step = SQLITE_ROW");
            // have a row
            currentRowIndex++;
            columnCount = sqlite3_data_count(rs);
            return true;
        }
        else
        {
            enforceEx!SQLException(false,
                    "Error #" ~ to!string(res) ~ " while reading query result: " ~ copyCString(
                        sqlite3_errmsg(stmt.conn.getConnection())));
            return false;
        }
    }

    override int findColumn(string columnName)
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();
        int* p = (columnName in columnMap);
        if (!p)
            throw new SQLException("Column " ~ columnName ~ " not found");
        return *p + 1;
    }

    override bool getBoolean(int columnIndex)
    {
        return getLong(columnIndex) != 0;
    }

    override ubyte getUbyte(int columnIndex)
    {
        return cast(ubyte) getLong(columnIndex);
    }

    override byte getByte(int columnIndex)
    {
        return cast(byte) getLong(columnIndex);
    }

    override short getShort(int columnIndex)
    {
        return cast(short) getLong(columnIndex);
    }

    override ushort getUshort(int columnIndex)
    {
        return cast(ushort) getLong(columnIndex);
    }

    override int getInt(int columnIndex)
    {
        return cast(int) getLong(columnIndex);
    }

    override uint getUint(int columnIndex)
    {
        return cast(uint) getLong(columnIndex);
    }

    override long getLong(int columnIndex)
    {
        checkClosed();
        checkIndex(columnIndex);
        lock();
        scope (exit)
            unlock();
        auto v = sqlite3_column_int64(rs, columnIndex - 1);
        return v;
    }

    override ulong getUlong(int columnIndex)
    {
        return cast(ulong) getLong(columnIndex);
    }

    override double getDouble(int columnIndex)
    {
        checkClosed();
        checkIndex(columnIndex);
        lock();
        scope (exit)
            unlock();
        auto v = sqlite3_column_double(rs, columnIndex - 1);
        return v;
    }

    override float getFloat(int columnIndex)
    {
        return cast(float) getDouble(columnIndex);
    }

    override byte[] getBytes(int columnIndex)
    {
        checkClosed();
        checkIndex(columnIndex);
        lock();
        scope (exit)
            unlock();
        const byte* bytes = cast(const byte*) sqlite3_column_blob(rs, columnIndex - 1);
        int len = sqlite3_column_bytes(rs, columnIndex - 1);
        byte[] res = new byte[len];
        for (int i = 0; i < len; i++)
            res[i] = bytes[i];
        return res;
    }

    override ubyte[] getUbytes(int columnIndex)
    {
        checkClosed();
        checkIndex(columnIndex);
        lock();
        scope (exit)
            unlock();
        const ubyte* bytes = cast(const ubyte*) sqlite3_column_blob(rs, columnIndex - 1);
        int len = sqlite3_column_bytes(rs, columnIndex - 1);
        ubyte[] res = new ubyte[len];
        for (int i = 0; i < len; i++)
            res[i] = bytes[i];
        return res;
    }

    override string getString(int columnIndex)
    {
        checkClosed();
        checkIndex(columnIndex);
        lock();
        scope (exit)
            unlock();
        const char* bytes = cast(const char*) sqlite3_column_text(rs, columnIndex - 1);
        int len = sqlite3_column_bytes(rs, columnIndex - 1);
        char[] res = new char[len];
        for (int i = 0; i < len; i++)
            res[i] = bytes[i];
        return cast(string) res;
    }

    override DateTime getDateTime(int columnIndex)
    {
        string s = getString(columnIndex);
        DateTime dt;
        if (s is null)
            return dt;
        try
        {
            return DateTime.fromISOString(s);
        }
        catch (Throwable e)
        {
            throw new SQLException("Cannot convert string to DateTime - " ~ s);
        }
    }

    override Date getDate(int columnIndex)
    {
        string s = getString(columnIndex);
        Date dt;
        if (s is null)
            return dt;
        try
        {
            return Date.fromISOString(s);
        }
        catch (Throwable e)
        {
            throw new SQLException("Cannot convert string to DateTime - " ~ s);
        }
    }

    override TimeOfDay getTime(int columnIndex)
    {
        string s = getString(columnIndex);
        TimeOfDay dt;
        if (s is null)
            return dt;
        try
        {
            return TimeOfDay.fromISOString(s);
        }
        catch (Throwable e)
        {
            throw new SQLException("Cannot convert string to DateTime - " ~ s);
        }
    }

    override Variant getVariant(int columnIndex)
    {
        checkClosed();
        int type = checkIndex(columnIndex);
        lock();
        scope (exit)
            unlock();
        Variant v = null;
        if (lastIsNull)
            return v;
        switch (type)
        {
        case SQLITE_INTEGER:
            v = getLong(columnIndex);
            break;
        case SQLITE_FLOAT:
            v = getDouble(columnIndex);
            break;
        case SQLITE3_TEXT:
            v = getString(columnIndex);
            break;
        case SQLITE_BLOB:
            v = getUbytes(columnIndex);
            break;
        default:
            break;
        }
        return v;
    }

    override bool wasNull()
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();
        return lastIsNull;
    }

    override bool isNull(int columnIndex)
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();
        checkIndex(columnIndex);
        return lastIsNull;
    }

    //Retrieves the Statement object that produced this ResultSet object.
    override Statement getStatement()
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();
        return stmt;
    }

    //Retrieves the current row number
    override int getRow()
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();
        if (currentRowIndex < 0)
            return 0;
        return currentRowIndex + 1;
    }

    //Retrieves the fetch size for this ResultSet object.
    override int getFetchSize()
    {
        checkClosed();
        lock();
        scope (exit)
            unlock();
        return -1;
    }
}
