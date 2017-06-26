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
        return false;
    }

    bool commit()
    {
        return false;
    }

    int error()
    {
        return 0;
    }

    int execute(string sql)
    {
        return new Statement(_pool, sql).execute();
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
