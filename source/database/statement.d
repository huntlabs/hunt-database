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

module database.statement;

import database;

class Statement
{
    private Pool _pool;
    private Connection _conn;
    private string _sql;
    private bool _isUsed = false;
    private int _lastInsertId;
	private int _affectRows;
    private ResultSet _rs;
    
    this(Pool pool)
    {
        this._pool = pool;
    }

    this(Pool pool,string sql)
    {
        this._pool = pool;
        this._sql = sql;
    }

    void prepare(string sql)
    {
        this._sql = sql;
    }

    void setParameter(ParamType type = ParamType.PARAM_STR, T = string)
        (string key, T value)
    {
        // bind param value to sql
    }

    string sql()
    {
        return _sql;
    }

    int execute()
    {
        isUsed();
        assert(sql);
        _conn = _pool.getConnection();
        scope(exit){_pool.release(_conn);}
        int status = _conn.execute(sql);
        _lastInsertId = _conn.lastInsertId();
		_affectRows = _conn.affectedRows();
        return status;
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
        _conn = _pool.getConnection();
        scope(exit){_pool.release(_conn);}
        _rs = _conn.query(sql);
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
    ~this()
    {
        _conn = null;
        _sql = null;
    }
}
