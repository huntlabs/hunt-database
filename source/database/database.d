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

module database.database;

import database;

class Database
{
    Pool _pool;
    DatabaseOption _options;
    private Connection _conn = null;

    this(string url)
    {
        this._options = new DatabaseOption(url);
        initPool();
    }

    this(DatabaseOption options)
    {
        this._options = options;
        initPool();
    }

    private void initPool()
    {
        _pool = new Pool(this._options);
    }

    bool beginTransaction()
    {
        if(_conn is null)
            _conn = _pool.getConnection();
        return false;
    }

    bool commit()
    {
        scope(exit){_pool.release(_conn);_conn = null;}
        return false;
    }

    bool rollback()
    {
        scope(exit){_pool.release(_conn);_conn = null;}
        return false; 
    }

    int error()
    {
        return 0;
    }

    int execute(string sql)
    {
        if(_conn is null)
            return new Statement(_pool, sql).execute();
        else 
            return _conn.execute(sql);
    }

    ResultSet query(string sql)
    {
        return (new Statement(_pool, sql)).query();
    }

    Statement prepare(string sql)
    {
        return new Statement(_pool, sql);
    }

    void close()
    {
		_pool.close();	
    }
}
