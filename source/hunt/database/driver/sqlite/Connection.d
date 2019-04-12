/*
 * Database - Database abstraction layer for D programing language.
 *
 * Copyright (C) 2017  Shanghai Putao Technology Co., Ltd
 *
 * Developer: HuntLabs
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.database.driver.sqlite.Connection;

version(USE_SQLITE):

import hunt.database;
import hunt.logging;
import std.path;
import std.file;
import core.stdc.string;

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

        sqlite3* conn;
        sqlite3_stmt* stmt;
        bool closed;
        bool autocommit;

        int _last_insert_id;
        int _affectRows;
        Object[string] _parameters;

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
        if(conn !is null)
            close();
    }

    void close()
    {
        if(!closed) {
            checkClosed();

            int res = sqlite3_close(conn);
            if (res != SQLITE_OK)
            throw new DatabaseException("SQLite Error " ~ to!string(
                res) ~ " while trying to close DB " ~ filename ~ " : " ~ getError());
            closed = true;
            conn = null;
        }
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
        // logInfo("len : ",_parameters.length);
        if(_parameters.length > 0)
        {
            auto rc = sqlite3_prepare(conn, toStringz(sql), cast(int)strlen(toStringz(sql)), &stmt, null);
            // logInfo("rc : ",rc," sql :",sql);
            if (rc != SQLITE_OK)
            {
            //    fprintf(stderr, "sql error:%s\n", sqlite3_errmsg(db));
            }
            foreach(k,v; _parameters) {
                auto idx = sqlite3_bind_parameter_index(stmt,toStringz(":" ~ k));
                // logInfo("idx : ",idx," key : ",k);
                sqlite3_bind_text(stmt, idx, toStringz(v.toString), cast(int)strlen(toStringz(v.toString)), SQLITE_STATIC);

            }

            int code = sqlite3_step(stmt);
            if(code != SQLITE_DONE)
            {
                logError("sqlite3_step errorCode  : ",code," msg : ", fromStringz(sqlite3_errmsg(conn)));
            }

            _last_insert_id = cast(int)sqlite3_last_insert_rowid(conn);
            _affectRows = sqlite3_changes(conn);
            sqlite3_finalize(stmt);
            return code;
        }
        else
        {
            int code = sqlite3_exec(conn,toStringz(sql),&myCallback,null,null);
            if(code != 0)
                throw new DatabaseException("SQL : " ~ sql ~" \rDB status : "~code.to!string~" \rEXECUTE ERROR :" ~ getError());
            _last_insert_id = cast(int)sqlite3_last_insert_rowid(conn);
            _affectRows = sqlite3_changes(conn);
            return code;
        }
        
    }
	
	void begin()
	{
		execute("begin");
	}
	void rollback()
	{
		execute("rollback");
	}
	void commit()
	{
		execute("commit");
	}

    string escape(string sql)
    {
        // FIXME: Escape value properly to prevent accidental SQL injection
        return sql;
    }
    int lastInsertId()
    {
        return _last_insert_id;
    }
    
    int affectedRows()
    {
        return _affectRows;
    }

    void ping()
    {
        
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

    string escapeLiteral(string msg)
    {
        // FIXME: Escape value properly to prevent accidental SQL injection
        return `"` ~ msg ~ `"`;
    }

    string escapeIdentifier(string msg)
    {
        // FIXME: Escape db identifier properly to prevent accidental SQL injection
        return msg;
    }

    string escapeWithQuotes(string msg)
    {
        return `"` ~ msg ~ `"`;
    }

    string getDBType()
    {
        return "sqlite";
    }

    override void setParams(Object[string] param){
        _parameters = param;
    }
}  
extern(C) int myCallback(void *a_parm, int argc, char **argv,
                         char **column)
{
    return 0;
}

extern(C) void myCB(void *a_parm)
{
}
enum State {
    Init,
    Execute,
}
