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

    private int _encoderBufferSize = 256;
    private int _decoderBufferSize = 1024*8;
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

    // DatabaseOption addDatabaseSource(string url)
    // {
    //     assert(url);
    //     this._url = new HttpURI(url);
    //     return this;
    // }

    HttpURI url()
    {
        return _url;
    }

    DatabaseOption maximumPoolSize(int num)
    {
        this._maximumPoolSize = num;
        return this;
    }
    
    DatabaseOption minimumPoolSize(int num)
    {
        this._minimumPoolSize = num;
        return this;
    }

    int maximumPoolSize()
    {
        return _maximumPoolSize;
    }

    int minimumPoolSize()
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

    int getDecoderBufferSize() {
        return _decoderBufferSize;
    }

    DatabaseOption setDecoderBufferSize(int size) {
        assert(size > 0, "decoderBufferSize must be > 0");
        this._decoderBufferSize = size;
        return this;
    }

    int getEncoderBufferSize() {
        return _encoderBufferSize;
    }

    DatabaseOption setEncoderBufferSize(int size) {
        assert(size > 0, "encoderBufferSize must be > 0");
        this._encoderBufferSize = size;
        return this;
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