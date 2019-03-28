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

module hunt.database.Transaction;

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

class Transaction
{
    private Connection _conn;
    private bool _isExpire = false;

    this(Connection conn)
    {
        this._conn = conn;
    }
 
    void begin()
    {
        _conn.begin;
        _isExpire = false;
    }

    void commit()
    {
        _conn.commit;
        _isExpire = true;
    }

    void rollback()
    {
        _conn.rollback;
        _isExpire = true;
    }

    // int execute(string sql)
    // {
    //     isExpire();
    //     return new Statement(_conn ,sql).execute();
    // }

    // ResultSet query(string sql)
    // {
    //     isExpire();
    //     return new Statement(_conn ,sql).query();
    // }

    TransStatement prepare(string sql)
    {
        isExpire();
        return new TransStatement(_conn, sql);
    }
    
    private void isExpire()
    {
        if(_isExpire)
            throw new DatabaseException("transaction was expired");
    }
}

class TransStatement
{
    private Connection _conn ;
    private string _sql;
    private bool _isUsed = false;
    private int _lastInsertId;
	private int _affectRows;
    private ResultSet _rs;
    private Object[string] _parameters;


    this(Connection conn, string sql)
    {
        _conn = conn;
        prepare(sql);
    }

    void prepare(string sql)
    {
		assert(sql.length);
        this._sql = sql;
        _needReset = true;

    }

    private bool _needReset =false;

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
        _needReset = true;
    }

    private string sql()
    {
        if(!_needReset)
            return _str;

        string str = _sql;

        foreach (k, v; _parameters)
        {
            auto re = regex(r":" ~ k ~ r"([^\w]*)", "g");
            if ((cast(String) v !is null) || (cast(Nullable!string)v !is null))
            {
                if(_conn.getDBType() == "postgresql")
                    str = str.replaceAll(re, _conn.escapeLiteral(v.toString())  ~ "$1");
                else
                   str = str.replaceAll(re, "'" ~ _conn.escape(v.toString()) ~ "'"  ~ "$1"); 
            }
            else
            {
                str = str.replaceAll(re, v.toString() ~ "$1" );
            }
        }

        _needReset = false;  
        _str = str;
        return str;
    }
    private string _str;

    int execute()
    {
        isUsed();
        
       
        string execSql = sql();
        assert(execSql);
        version(HUNT_DEBUG)logDebug(execSql);

        int status = _conn.execute(execSql);
        _lastInsertId = _conn.lastInsertId();
		_affectRows = _conn.affectedRows();
        // return status;
        return _affectRows;
    }

    int count()
    {
        isUsed();
        
        string execSql = sql();
        assert(execSql);

        auto r = _conn.query(execSql);
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
        string execSql = sql();
        assert(execSql);
        version(HUNT_DEBUG) info(execSql);

        _rs = _conn.query(execSql);
        version(HUNT_DEBUG) {
            tracef("result size: row=%d, col=%d", _rs.rows(), _rs.columns());
        //     foreach(Row r; _rs) {
        //         trace(r.toString());
        //     }
        }
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

