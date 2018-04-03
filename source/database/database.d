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

import database.factory;
import database.option;
import database.pool;
import database.statement;
import database.transaction;

import database.driver.connection;
import database.driver.resultset;
import database.driver.builder;
import database.driver.dialect;


class Database
{
    Pool _pool;
    DatabaseOption _options;
    Factory _factory;

    this(string url)
    {
        this._options = new DatabaseOption(url);
        initObjects();
    }

    this(DatabaseOption options)
    {
        this._options = options;
        initObjects();
    }

    private void initObjects()
    {
        _factory = new Factory(this._options.url.scheme);
        _pool = new Pool(this._options, _factory);
    }

    Transaction beginTransaction()
    {
        Connection conn = _pool.getConnection();
        Transaction tran = new Transaction(_pool, conn);
        tran.begin();
        return tran;
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

    SqlBuilder createSqlBuilder()
    {
        return this._factory.createSqlBuilder();
    }

    Dialect createDialect()
    {
        return this._factory.createDialect();
    }
}
