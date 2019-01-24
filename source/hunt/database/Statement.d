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

import hunt.database;
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

class Statement
{
    private Database _db = null;
    private string _sql;
    private bool _isUsed = false;
    private int _lastInsertId;
	private int _affectRows;
    private ResultSet _rs;
    private Object[string] _parameters;

    this(Database db)
    {
        _db = db;
    }

    this(Database db, string sql)
    {
        _db = db;
        prepare(sql);
    }

    void prepare(string sql)
    {
		assert(sql.length);
        this._sql = sql;
    }
     public void setParameter(R)(string key, R param)
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
        else static if(is(R == class))
        {
            _parameters[key] = param;
        }
        else
        {
            throw new Exception("IllegalArgument not support : " ~ R.stringof);
        }
    }

    string sql()
    {
        string str = _sql;
        auto conn = _db.getConnection();
        scope(exit) _db.relaseConnection(conn);

        foreach (k, v; _parameters)
        {
            auto re = regex(r":" ~ k ~ r"([^\w]*)", "g");
            if ((cast(String) v !is null) || (cast(Nullable!string)v !is null))
            {
                if(conn.getDBType() == "postgresql")
                    str = str.replaceAll(re, conn.escapeLiteral(v.toString())  ~ "$1");
                else
                   str = str.replaceAll(re, "'" ~ conn.escape(v.toString()) ~ "'"  ~ "$1"); 
            }
            else
            {
                str = str.replaceAll(re, v.toString() ~ "$1" );
            }
        }
        return str;
    }

    int execute()
    {
        isUsed();
        assert(sql);
        version(HUNT_DEBUG)logDebug(sql);
        auto conn = _db.getConnection();
        scope(exit) _db.relaseConnection(conn);

        int status = conn.execute(sql);
        _lastInsertId = conn.lastInsertId();
		_affectRows = conn.affectedRows();
        // return status;
        return _affectRows;
    }

    int count()
    {
        isUsed();
        assert(sql);
        auto conn = _db.getConnection();
        scope(exit) _db.relaseConnection(conn);

        auto r = conn.query(sql);
        auto res = r.front();
        return res[0].to!int;
    }

    int lastInsertId()
    {
        return _lastInsertId;    
    }
    
	int affectedRows()
    {
        return _affectRows;    
    }
    
    Row fetch()
    {
        if(!_rs)_rs = query();
        scope(exit){
            if(!_rs.empty)
                _rs.popFront();
            else 
                throw new DatabaseException("ResultSet is empty");
        }
        return _rs.front();
    }

    ResultSet query()
    {
        isUsed();
        assert(sql);
        auto conn = _db.getConnection();
        scope(exit) _db.relaseConnection(conn);

        _rs = conn.query(sql);
        return _rs;
    }

    void close()
    {

    }

    private void isUsed()
    {
        scope(exit)_isUsed=true;
        if(_isUsed)throw new DatabaseException("statement was used");
    }

}

