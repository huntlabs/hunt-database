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
    private int _last_insert_id = 0;

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
		_affectRows = to!int(std.string.fromStringz(PQcmdTuples(res)));
		if (result == PGRES_FATAL_ERROR)
            throw new DatabaseException("DB SQL : " ~ sql ~"\rDB status : "~to!string(result)~
                    " \rEXECUTE ERROR : " ~ to!string(result));
        {
            auto reg = regex(r"[I|i][N|n][S|s][E|e][R|r][T|t].*[I|i][N|n][T|t][O|o].*.*[R|r][E|e][T|t][U|u][R|r][N|n][I|i][N|n][G|g].*");
            if(match(sql,reg)){
                auto data = new PostgresqlResult(res);
                _last_insert_id = data.front[0].to!int;
                return 1;
            }
            return result;
        }
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
        return _last_insert_id;
    }
    
    int affectedRows()
    {
        return _affectRows;
    }

    void ping()
    {
    
    }
}
