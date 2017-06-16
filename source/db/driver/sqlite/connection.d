module db.driver.sqlite.connection;

version(USE_SQLITE):
import db;

version (Windows)
{
    pragma(lib, "sqlite3");
}
else version (linux)
{
    pragma(lib, "sqlite3");
}
else version (Posix)
{
    pragma(lib, "libsqlite3");
}
else version (darwin)
{
    pragma(lib, "libsqlite3");
}
else
{
    pragma(msg, "You will need to manually link in the SQLite library.");
}

class SQLiteConnection : Connection
{
    private
    {
        URL _url;
        string filename;
        string _host;
        string _user;
        string _pass;
        string _db;
        uint _port;

        QueryParams _querys;
        sqlite3* conn;
        sqlite3_stmt* st;
        bool closed;
        bool autocommit;
    }

    this(URL url)
    {

        this._url = url;
        this._port = url.port;
        this._host = url.host;
        this._user = url.user;
        string p = url.path;
        if (p[0 .. 2] == "/.")
        p = (url.path)[1 .. $];

        this.filename = buildPath(dirName(thisExePath), p);

        this._pass = url.pass;
        this._querys = url.queryParams;
        closed = false;

        trace("Trying to open a sqlite file:", filename);

        int flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
        int res = sqlite3_open_v2(toStringz(filename), &conn,flags,null);
        if (res != SQLITE_OK)
        throw new DatabaseException("SQLite Error " ~ to!string(
            res) ~ " while trying to open DB " ~ filename ~ " : " ~ getError());
        assert(conn !is null);
        setAutoCommit(true);
    }

    ~this()
    {
        close();
    }

    void close()
    {
        checkClosed();

        int res = sqlite3_close(conn);
        if (res != SQLITE_OK)
        throw new SQLException("SQLite Error " ~ to!string(
            res) ~ " while trying to close DB " ~ filename ~ " : " ~ getError());
        closed = true;
        conn = null;
    }

    void setAutoCommit(bool autoCommit)
    {
        this.autocommit = autoCommit;
    }


    ResultSet queryImpl(string sql, Variant[] args...)
    {
        return new SqliteResult(conn,sql);
    }

    int execute(string sql)
    {
        int code = sqlite3_exec(conn,toStringz(sql),&myCallback,null,null);
        return code;
    }

    string escape(string sql)
    {
        return sql;
    }
	int lastInsertId()
	{
		return 0;
	}
	
	int affectedRows()
	{
		return 0;
	}

    private string getError()
    {
        return cast(string)fromStringz(sqlite3_errmsg(conn));
    }

    private void checkClosed()
    {
        if (closed)
        throw new DatabaseException("Connection is already closed");
    }
}  
extern(C) int myCallback(void *a_parm, int argc, char **argv,
                         char **column)
{
    return 0;
}

enum State {
    Init,
    Execute,
}
