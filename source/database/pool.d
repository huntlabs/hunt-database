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

module database.pool;

import database;
import std.container.array;
import core.sync.rwmutex;

class Pool
{
    Connection _conn;
    Array!Connection _conns;
    DatabaseOption _config;
    ReadWriteMutex _mutex;

    this(DatabaseOption config)
    {
        this._config = config;
        _mutex = new ReadWriteMutex();
        int i = 0;
        while(i < _config.maximumConnection)
        {
            _conns.insertBack(initConnection);
            i++;
        }
    }

    ~this()
    {
        _mutex.destroy();
    }

    private Connection initConnection()
    {
        switch (_config.url.scheme)
        {
            version (USE_POSTGRESQL)
            {
                case "postgresql":
                    return new PostgresqlConnection(_config.url);
            }
            version (USE_MYSQL)
            {
                case "mysql":
                    return new MysqlConnection(_config.url);
            }
            version(USE_SQLITE){
                case "sqlite":
                    _config.setMaximumConnection = 1;
                    return new SQLiteConnection(_config.url);
            }
            default:
            throw new DatabaseException("Don't support database driver: "~ _config.url.scheme);
        }
    }

    Connection getConnection()
    {
        _mutex.writer.lock();
        scope(exit) {
            _conns.linearRemove(_conns[0..1]);
            _mutex.writer.unlock();
        }
        if(!_conns.length)_conns.insertBack(initConnection);
        version(USE_MYSQL){_conns.front.ping();}
        return _conns.front;
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
