module db.databaseconfig;

import db;

class DatabaseConfig
{
	private int _maxConnection = 50;
	private int _connectionTimeout = 10000;
	private URL _url;
	
	this(string url)
	{
		this._url = url.parseURL;
	}

	DatabaseConfig addDatabaseSource(string url)
	{
		assert(url);
		this._url = url.parseURL;
		return this;
	}
	URL url()
	{
		return _url;
	}

	DatabaseConfig setMaxConnection(int num)
	{
		assert(num);
		this._maxConnection = num;
		return this;
	}

	int maxConnection()
	{
		return _maxConnection;
	}
	
	DatabaseConfig setConnectionTimeout(int time)
	{
		assert(time);
		this._connectionTimeout = time;
		return this;
	}

	int connectionTimeout()
	{
		return _connectionTimeout;
	}
}
