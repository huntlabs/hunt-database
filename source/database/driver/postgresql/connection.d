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

    private int _affectRows = 0;

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
        if (PQstatus(con) != CONNECTION_OK)
			throw new DatabaseException("login error " ~ to!string(PQerrorMessage(con)));
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
        _affectRows = 0;
        PGresult* res;
        res = PQexec(con,toStringz(sql));
        int result = PQresultStatus(res);
		if (result != PGRES_COMMAND_OK)
			throw new DatabaseException("DB status : "~to!string(result)~
					" EXECUTE ERROR " ~ to!string(result));
		_affectRows = to!int(std.string.fromStringz(PQcmdTuples(res)));
        return result;
    }

    ResultSet queryImpl(string sql, Variant[] args...) 
    {
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
        return _affectRows;
    }

    void ping()
    {
    
    }
}
