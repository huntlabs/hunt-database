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

module hunt.database.Statement;

import hunt.database.Database;
import hunt.database.DatabaseOption;
import hunt.database.base;
import hunt.database.query.Common;

import hunt.logging;
import hunt.String;
import hunt.Integer;
import hunt.Long;
import hunt.Double;
import hunt.Float;
import hunt.Byte;
import hunt.Short;
import hunt.Nullable;

import std.stdio;
import std.regex;
import std.variant;

/**
 * 
 * See_Also:
 *    https://www.codemeright.com/blog/post/named-parameterized-query-java
 *    https://www.javaworld.com/article/2077706/named-parameters-for-preparedstatement.html
 *    https://github.com/marcosemiao/jdbc-named-parameters/tree/master/src/main/java/fr/ms/sql
 */
class Statement
{
    private SqlConnection _sqlConn = null;
    private string _sql;
    private bool _isUsed = false;
    private int _lastInsertId;
    private int _affectRows;
    private RowSet _rs;
    private Object[string] _parameters;

    private DatabaseOption _options;

    this(SqlConnection db, DatabaseOption options)
    {
        _sqlConn = db;
        _options = options;
    }

    this(SqlConnection db, string sql, DatabaseOption options)
    {
        _sqlConn = db;
        _options = options;
        prepare(sql);
    }

    void prepare(string sql)
    {
        assert(sql.length);
        this._sql = sql;
        _needReset = true;

    }

    private bool _needReset = false;

    void setParameter(R)(string key, R param)
    {
        static if (is(R == int) || is(R == uint))
        {
            _parameters[key] = new Integer(param);
        }
        else static if (is(R == string) || is(R == char) || is(R == byte[]))
        {
            _parameters[key] = new String(param);
        }
        else static if (is(R == bool))
        {
            _parameters[key] = new Boolean(param);
        }
        else static if (is(R == double))
        {
            _parameters[key] = new Double(param);
        }
        else static if (is(R == float))
        {
            _parameters[key] = new Float(param);
        }
        else static if (is(R == short) || is(R == ushort))
        {
            _parameters[key] = new Short(param);
        }
        else static if (is(R == long) || is(R == ulong))
        {
            _parameters[key] = new Long(param);
        }
        else static if (is(R == byte) || is(R == ubyte))
        {
            _parameters[key] = new Byte(param);
        }
        else static if (is(R == class))
        {
            _parameters[key] = param;
        }
        else
        {
            throw new Exception("IllegalArgument not support : " ~ R.stringof);
        }
        _needReset = true;
    }

    // string sql()
    // {
    //     auto conn = _sqlConn.getConnection();
    //     scope (exit)
    //         _sqlConn.relaseConnection(conn);
    //     return sql(conn);
    // }

    private string sql(SqlConnection conn)
    {
        if (!_needReset)
            return _str;

        string str = _sql;

        foreach (string k, Object v; _parameters)
        {
            auto re = regex(r":" ~ k ~ r"([^\w]*)", "g");
            if ((cast(String) v !is null) || (cast(Nullable!string) v !is null))
            {
                str = str.replaceAll(re, "'" ~ v.toString() ~ "'" ~ "$1");
                
        //         if (_sqlConn.getOption().isPgsql() || _sqlConn.getOption().isMysql()) {
        //             // str = str.replaceAll(re, conn.escapeLiteral(v.toString()) ~ "$1");
        //             // str = str.replaceAll(re, v.toString() ~ "$1");
        // // warning(str ~ "      " ~ v.toString() ~ "$1");
        //         // } else if (_sqlConn.getOption().isMysql()) {
        //             // str = str.replaceAll(re, "'" ~ conn.escape(v.toString()) ~ "'" ~ "$1");
        //             str = str.replaceAll(re, "'" ~ v.toString() ~ "'" ~ "$1");
        //         }
        //         else
        //         {
        //             str = str.replaceAll(re, quoteSqlString(v.toString()) ~ "$1");
        //         }
            }
            else
            {
                str = str.replaceAll(re, v.toString() ~ "$1");
            }
        }

        _needReset = false;
        _str = str;
        return str;
    }

    private string _str;

    int execute()
    {
        string execSql = sql(_sqlConn);

        version (HUNT_SQL_DEBUG_MORE) {
            logDebug(execSql);
        }

        _rs = _sqlConn.query(execSql);
        _lastInsertId = 0;

        if(_options.isPgsql()) {
            Row row = _rs.lastRow();
            if(row !is null) {
                _lastInsertId = row.getInteger(0);
            }
        } else if (_options.isMysql()) {
            import hunt.database.driver.mysql.MySQLClient;
            Variant value2 = _rs.property(MySQLClient.LAST_INSERTED_ID);
            if(value2.type != typeid(int)) {
                warning("Not expected type: ", value2.type);
            } else {
                _lastInsertId = value2.get!int();
            }
        } 

        // import hunt.database.driver.mysql.MySQLClient;
        // Variant value2 = _rs.property(MySQLClient.LAST_INSERTED_ID);
        // if(value2.type != typeid(int)) {
        //     version(HUNT_DEBUG) warning("Not expected type: ", value2.type);
        //     _lastInsertId = 0;
        // } else {
        //     _lastInsertId = value2.get!int();
        // }        

        _affectRows = _rs.rowCount();
        return _affectRows;
    }

    
    int execute(string lastIdName)
    {
        string execSql = sql(_sqlConn);
        version (HUNT_SQL_DEBUG_MORE) logDebug(execSql);

        _rs = _sqlConn.query(execSql);
        _lastInsertId = 0;

        if(_options.isPgsql()) {
            Row row = _rs.lastRow();
            if(row !is null) {
                _lastInsertId = row.getInteger(lastIdName);
            }
        } else if (_options.isMysql()) {
            import hunt.database.driver.mysql.MySQLClient;
            Variant value2 = _rs.property(MySQLClient.LAST_INSERTED_ID);
            if(value2.type != typeid(int)) {
                warning("Not expected type: ", value2.type);
            } else {
                _lastInsertId = value2.get!int();
            }
        }

        _affectRows = _rs.rowCount();
        return _affectRows;
    }

    int lastInsertId()
    {
        return _lastInsertId;
    }

    int affectedRows()
    {
        return _affectRows;
    }


    int count()
    {
        Row res = fetch();
        return res.getInteger(0);
    }

    Row fetch()
    {
        if (!_rs)
            _rs = query();

        foreach(Row r; _rs) {
            return r;
        }

        throw new DatabaseException("RowSet is empty");
    }

    RowSet query()
    {
        string execSql = sql(null);
        _rs = _sqlConn.query(execSql);
        return _rs;
    }

    // void close()
    // {
    //     version (HUNT_DEBUG)
    //         info("statement closed");
    // }

    // private void isUsed()
    // {
    //     // scope (exit)
    //     //     _isUsed = true;
    //     if (_isUsed)
    //         throw new DatabaseException("statement was used");
    //     _isUsed = true;
    // }

}
