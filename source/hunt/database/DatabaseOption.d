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

module hunt.database.DatabaseOption;

import hunt.net.util.HttpURI;

/**
 * 
 */
class DatabaseOption
{

    private int _maxLifetime = 30000;
    private int _minimumPoolSize = 1;
    private int _maximumPoolSize = 2;
    private int _minldle = 1;
    private int _connectionTimeout = 10000;
    private HttpURI _url;
    
    // this()
    // {
    
    // }

    this(string url)
    {
        this._url = new HttpURI(url);
    }

    DatabaseOption addDatabaseSource(string url)
    {
        assert(url);
        this._url = new HttpURI(url);
        return this;
    }

    HttpURI url()
    {
        return _url;
    }

    DatabaseOption setMaximumConnection(int num)
    {
        this._maximumPoolSize = num;
        return this;
    }
    DatabaseOption setMinimumConnection(int num)
    {
        this._minimumPoolSize = num;
        return this;
    }

    int maximumConnection()
    {
        return _maximumPoolSize;
    }

    int minimumConnection()
    {
        return _minimumPoolSize;
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

    string schemeName() {
        return _url.getScheme();
    }

	bool isMysql()
	{
		return _url.getScheme() == "mysql";
	}
	bool isPgsql()
	{
		return _url.getScheme() == "postgresql";
	}
}