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

module hunt.database.driver.postgresql.Connection;

import hunt.database;
version(USE_POSTGRESQL):

class PostgresqlConnection :  Connection 
{
    public string dbname;
    private URL _url;
    private string _host;
    private string _user;
    private string _pass;
    private string _db;
    private uint _port;
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

    private void reconnect()
    {
        if (PQstatus(con) != CONNECTION_OK)
            connect(); 
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
        reconnect();
        _affectRows = 0;
        PGresult* res;
        res = PQexec(con,toStringz(sql));
        int result = PQresultStatus(res);
		_affectRows = safeConvert!(char[],int)(std.string.fromStringz(PQcmdTuples(res)));
		if (result == PGRES_FATAL_ERROR)
            throw new DatabaseException("DB SQL : " ~ sql ~"\r\nDB status : "~to!string(result)~
                    " \r\nEXECUTE ERROR : " ~ to!string(result) ~"\r\n"~cast(string)fromStringz(PQresultErrorMessage(res)));
        {
            auto reg = regex(r"[I|i][N|n][S|s][E|e][R|r][T|t].*[I|i][N|n][T|t][O|o].*.*[R|r][E|e][T|t][U|u][R|r][N|n][I|i][N|n][G|g].*");
            if(match(sql,reg)){
                auto data = new PostgresqlResult(res);
                _last_insert_id = safeConvert!(string,int)(data.front[0]);
                return 1;
            }
            return result;
        }
    }

    ResultSet queryImpl(string sql, Variant[] args...) 
    {
        reconnect();
        PGresult* res;
        res = PQexec(con,toStringz(sql));
        return new PostgresqlResult(res);
    }

    string escape(string msg)
    {
        auto buf = PQescapeString(con, msg.toStringz, msg.length);
        if (buf is null)
            throw new DatabaseException("Unable to escape value: " ~ msg);

        string res = buf.fromStringz.to!string;
        PQfreemem(buf);

        return res;
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
    
    void begin()
    {
        execute_sql("begin");
    }

    void rollback()
    {
        execute_sql("rollback");
    }

    void commit()
    {
        execute_sql("commit");
    }

    private void execute_sql(string sql)
    {
        reconnect();
        PQexec(con,toStringz(sql));
    }

    string escapeLiteral(string msg)
    {
        auto buf = PQescapeLiteral(con, msg.toStringz, msg.length);
        if (buf is null)
            throw new DatabaseException("Unable to escape value: " ~ msg);

        string res = buf.fromStringz.to!string;
        PQfreemem(buf);

        return res;
    }

    string escapeIdentifier(string msg)
    {
        auto buf = PQescapeIdentifier(con, msg.toStringz, msg.length);
        if (buf is null)
            throw new DatabaseException("Unable to escape value: " ~ msg);

        string res = buf.fromStringz.to!string;
        PQfreemem(buf);

        return res;
    }
}
