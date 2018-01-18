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
    private Database _db;
    private Pool _pool;
    private Connection _conn;
    private bool _released = false;
    private bool _isExpire = false;

    this(Database db,Pool pool,Connection conn)
    {
        this._db = db;
        this._pool = pool;
        this._conn = conn;
    }

    ~this()
    {
        release();
    }

    void release()
    {
        if(_conn !is null){
            _pool.release(_conn);
            _conn = null;
        }
    }
    
    void begin()
    {
        _conn.begin;
    }

    void commit()
    {
        scope(exit){_isExpire=true;release();}
        _conn.commit;
    }

    void rollback()
    {
        scope(exit){_isExpire=true;release();}
        _conn.rollback;
    }

    int execute(string sql)
    {
        isExpire();
        return new Statement(_pool,_conn ,sql).execute();
    }

    ResultSet query(string sql)
    {
        isExpire();
        return (new Statement(_pool,_conn, sql)).query();
    }

    Statement prepare(string sql)
    {
        isExpire();
        return new Statement(_pool,_conn, sql);
    }
    
    private void isExpire()
    {
        if(_isExpire)
            throw new DatabaseException("transaction was expired");
    }
}
