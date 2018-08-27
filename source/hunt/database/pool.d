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

module hunt.database.pool;

import hunt.database;
import std.container.array;
import core.sync.rwmutex;

class Pool
{
    Connection _conn;
    Array!Connection _conns;
    DatabaseOption _config;
    ReadWriteMutex _mutex;
	int _pool_length;

    this(DatabaseOption config)
    {
        this._config = config;
        _mutex = new ReadWriteMutex();
        int i = 0;
        while(i < _config.minimumConnection)
        {
            _conns.insertBack(initConnection);
            i++;
        }
		_pool_length = i;
    }

    ~this()
    {
        _mutex.destroy();
    }



    private Connection initConnection()
    {
		version (USE_POSTGRESQL)
		{
            if(_config.isPgsql)
			    return new PostgresqlConnection(_config.url);
		}
		version (USE_MYSQL)
		{
            if(_config.isMysql)
			return new MysqlConnection(_config.url);
		}
		version(USE_SQLITE){
			_config.setMaximumConnection = 1;
			_config.setMinimumConnection = 1;
            if(_config.isSqlite)
			return new SQLiteConnection(_config.url);
		}
		
			throw new DatabaseException("Don't support database driver: "~ _config.url.scheme);
    }

    Connection getConnection()
    {
        _mutex.writer.lock();
        scope(exit) {
            if(_conns.length)
                _conns.linearRemove(_conns[0..1]);
            _mutex.writer.unlock();
        }
        Connection conn;
        if(!_conns.length)
        {
            conn = initConnection();
            _conns.insertBack(conn);
            _pool_length++;
        }
        else
            conn = _conns.front;
        version(USE_MYSQL){conn.ping();}
        return conn;
    }

    void release(Connection conn)
    {
        _mutex.writer.lock();
        scope(exit)_mutex.writer.unlock();
        _conns.insertBack(conn);
    }    

	void close()
	{
        _mutex.writer.lock();
        scope(exit)_mutex.writer.unlock();
		foreach(c;_conns){
			c.close();
		}	
	}
}
