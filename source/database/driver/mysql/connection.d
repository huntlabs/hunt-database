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

module database.driver.mysql.connection;

import database;

version(USE_MYSQL):

class MysqlConnection : Connection
{
    public string dbname;
    private URL _url;
    private string _host;
    private string _user;
    private string _pass;
    private string _db;
    private uint _port;
    private QueryParams _querys;
    private MYSQL* mysql;

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

    ~this() 
    {
        if(mysql)
            mysql_close(mysql);
        mysql = null;
    }

    private void connect()
    {
        mysql = mysql_init(null);
        //my_bool reconnect = 1;
        //mysql_options(mysql, mysql_option.MYSQL_OPT_RECONNECT, &reconnect);
        if(!mysql_real_connect(mysql, toCstring(_host), toCstring(_user), 
                toCstring(_pass), toCstring(_db), _port, null, 0))
            throw new DatabaseException("DB connect error " ~ error());
        mysql_set_character_set(mysql, toCstring("utf8"));
    }

    int execute(string sql)
    {
        assert(mysql);
        auto v = toCstring(sql);
        int result = mysql_query(mysql, v);
		if(result != 0)
			throw new DatabaseException("SQL : " ~ sql ~" \rDB status : "~result.to!string~" \rEXECUTE ERROR :" ~ error());
		return result;
    }

    void startTransaction() 
    {
        query("START TRANSACTION");
    }

    string clientInfo()
    {
        return fromCstring(mysql_get_client_info());
    }

    string error() 
    {
        return fromCstring(mysql_error(mysql));
    }
    void close() 
    {
        if(mysql)
            mysql_close(mysql);
    }
    void ping()
    {
        if(pingMysql())
            connect();
    }
    int pingMysql()
    {
        return mysql_ping(mysql);
    }

    size_t getThreadId()
    {
        return mysql_thread_id(mysql);
    }

    int lastInsertId() 
    {
        return cast(int) mysql_insert_id(mysql);
    }

    int affectedRows() 
    {
        return cast(int) mysql_affected_rows(mysql);
    }

    override ResultSet queryImpl(string sql, Variant[] args...) 
    {
        assert(mysql);
        sql = escapedVariants(sql, args);
        mysql_query(mysql, toCstring(sql));
        return new MysqlResult(mysql_store_result(mysql), sql);
    }

    string escape(string str) 
    {
        ubyte[] buffer = new ubyte[str.length * 2 + 1];
        buffer.length = mysql_real_escape_string(mysql, buffer.ptr, 
                cast(cstring) str.ptr, cast(uint) str.length);
        return cast(string) buffer;
    }

    string escapedVariants(in string sql, Variant[] t) 
    {
        if(t.length > 0 && sql.indexOf("?") != -1) {
            string fixedup;
            int currentIndex;
            int currentStart = 0;
            foreach(int i, dchar c; sql) {
                if(c == '?') {
                    fixedup ~= sql[currentStart .. i];

                    int idx = -1;
                    currentStart = i + 1;
                    if((i + 1) < sql.length) {
                        auto n = sql[i + 1];
                        if(n >= '0' && n <= '9') {
                            currentStart = i + 2;
                            idx = n - '0';
                        }
                    }
                    if(idx == -1) {
                        idx = currentIndex;
                        currentIndex++;
                    }

                    if(idx < 0 || idx >= t.length)
                        throw new DatabaseException("SQL Parameter index is out of bounds: " ~ to!string(idx) ~ " at `"~sql[0 .. i]~"`");

                    fixedup ~= toSql(t[idx]);
                }
            }

            fixedup ~= sql[currentStart .. $];

            return fixedup;
        }

        return sql;
    }

    string toSql(Variant a) {
        auto v = a.peek!(string);
        return toSql(*v);
    }

    string toSql(string s) {
        if(s is null)return "NULL";
        return '\'' ~ escape(s) ~ '\'';
    }

    string toSql(long s) {
        return to!string(s);
    }
}

cstring toCstring(string c) 
{
    return toStringz(c);
}
string fromCstring(cstring c, size_t len = size_t.max) {
    string ret;
    if(c is null)return null;
    if(len == 0)return "";
    if(len == size_t.max) {
        auto iterator = c;
        len =0;
        while(*iterator)
        {
            iterator++;
            len++;
        }
        assert(len >= 0);
    }
    ret = cast(string) (c[0 .. len].idup);
    return ret;
}

