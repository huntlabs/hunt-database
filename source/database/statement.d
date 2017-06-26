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

    void bind(ParamType type = ParamType.PARAM_STR ,T = string)
        (string key,T value)
    {
        
    }

    string sql()
    {
        return _sql;
    }

    int execute()
    {
        isUsed();
        _conn = _pool.getConnection();
        scope(exit){_pool.release(_conn);}
        _conn.execute(sql);
        _lastInsertId = _conn.lastInsertId();
        return _conn.affectedRows();
    }

    int lastInsertId()
    {
        return _lastInsertId;    
    }
    
    Row fetch()
    {
        return fetchAll().front();
    }

    ResultSet fetchAll()
    {
        isUsed();
        _conn = _pool.getConnection();
        scope(exit){_pool.release(_conn);}
        return _conn.query(sql);
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
