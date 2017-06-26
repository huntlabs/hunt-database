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

module database.driver.postgresql.connection;

import database;
version(USE_POSTGRESQL):
pragma(lib, "pq");
pragma(lib, "pgtypes");

void error(string file = __FILE__, size_t line = __LINE__)(PGconn* con, string msg) {
    import std.conv;

    auto s = msg ~ to!string(PQerrorMessage(con));
    throw new DatabaseException(s,file,line);
}

void error(string file = __FILE__, size_t line = __LINE__)(PGconn* con, string msg, int result) {
    import std.conv;

    auto s = "error:" ~ msg ~ ": " ~ to!string(result) ~ ": " ~ to!string(PQerrorMessage(con));
    throw new DatabaseException(s,file,line);
}

int check(string file = __FILE__, size_t line = __LINE__)(PGconn* con, string msg, int result) {
    info(msg, ": ", result);
    if (result != 1)
    error!(file,line)(con, msg, result);
    return result;
}

int checkForZero(string file = __FILE__, size_t line = __LINE__)(PGconn* con, string msg, int result) {
    info(msg, ": ", result);
    if (result != 0)
    error!(file,line)(con, msg, result);
    return result;
}

class PostgresqlConnection :  Connection 
{
    public string dbname;
    private URL _url;
    private string _host;
    private string _user;
    private string _pass;
    private string _db;
    private uint _port;
    private QueryParams _querys;
    private PGconn* con;

    this(URL url)
    {
        this._url = url;
        this._port = url.port;
        this._host = url.host;
        this._user = url.user;
        this._db = (url.path)[1..$];
        this._pass = url.pass;
        this._querys = url.queryParams;
        this.dbname = this._db;
        connect();
    }

    private void connect() 
    {
		con = PQsetdbLogin(toStringz(_host),toStringz(to!string(_port)),
				null,null,toStringz(_db),toStringz(_user),toStringz(_pass));
		trace(CONNECTION_OK," status:",PQstatus(con),"\t",con);
        if (PQstatus(con) != CONNECTION_OK)
			throw new DatabaseException("login error");
    }

    ~this() {
        PQfinish(con);
    }

    void close()
    {
        PQfinish(con);
    }

    int socket() {
        return PQsocket(con);
    }

    void* handle() {
        return con;
    }

    int execute(string sql)
    {
        PGresult* res;
        res = PQexec(con,toStringz(sql));
        return PQresultStatus(res);
    }

    ResultSet queryImpl(string sql, Variant[] args...) 
    {
        trace("query sql: ", sql);
        PGresult* res;
        res = PQexec(con,toStringz(sql));
        return new PostgresqlResult(res);
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

    void ping()
    {
    
    }
}
