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

module database.transaction;

import database;

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

    int execute(string sql)
    {
        isExpire();
        return new Statement(_conn ,sql).execute();
    }

    ResultSet query(string sql)
    {
        isExpire();
        return new Statement(_conn ,sql).query();
    }

    Statement prepare(string sql)
    {
        isExpire();
        return new Statement(_conn, sql);
    }
    
    private void isExpire()
    {
        if(_isExpire)
            throw new DatabaseException("transaction was expired");
    }
}
