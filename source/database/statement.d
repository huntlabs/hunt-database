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
    private Connection _conn = null;
    private string _sql;
    private bool _isUsed = false;
	private bool _isTransaction = false;
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

	this(Pool pool,Connection conn,string sql)
	{
		this._pool = pool;
		this._conn = conn;
		this._sql = sql;
		this._isTransaction = true;
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
        scope(exit){releaseConnection();}
        int status = getConnection.execute(sql);
        _lastInsertId = getConnection.lastInsertId();
		_affectRows = getConnection.affectedRows();
        return status;
    }

    int count()
    {
        isUsed();
        assert(sql);
        scope(exit){releaseConnection();}
        auto r = getConnection.query(sql);
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
        _conn = _pool.getConnection();
        scope(exit){_pool.release(_conn);}
        _rs = _conn.query(sql);
        return _rs;
    }

    void close()
    {

    }

	private Connection getConnection()
	{
		if(_conn is null)	
			_conn = _pool.getConnection();
		return _conn;
	}

	private void releaseConnection()
	{
		if(!_isTransaction && _conn !is null)
			_pool.release(_conn);
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
