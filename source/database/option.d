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

module database.option;

import database.url;

alias DatabaseConfig = DatabaseOption;
class DatabaseOption
{

    private int _maxLifetime = 30000;
    private int _minimumPoolSize = 1;
    private int _maximumPoolSize = 64;
    private int _minldle = 1;
    private int _connectionTimeout = 10000;
    private URL _url;
    
    this()
    {
    
    }

    this(string url)
    {
        this._url = url.parseURL;
    }

    DatabaseOption addDatabaseSource(string url)
    {
        assert(url);
        this._url = url.parseURL;
        return this;
    }

    URL url()
    {
        return _url;
    }

    DatabaseOption setMaximumConnection(int num)
    {
        assert(num);
        this._maximumPoolSize = num;
        return this;
    }

    int maximumConnection()
    {
        return _maximumPoolSize;
    }
    
    DatabaseOption setConnectionTimeout(int time)
    {
        assert(time);
        this._connectionTimeout = time;
        return this;
    }

    int connectionTimeout()
    {
        return _connectionTimeout;
    }

	bool isMysql()
	{
		return _url.scheme == "mysql";
	}
	bool isPgsql()
	{
		return _url.scheme == "postgresql";
	}
	bool isSqlite()
	{
		return _url.scheme == "sqlite";
	}
}
