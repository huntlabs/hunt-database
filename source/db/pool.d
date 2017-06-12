module db.pool;

import db;
import core.sync.rwmutex;

class Pool
{
	Connection _conn;
	Array!Connection _conns;
	DatabaseConfig _config;
	private ReadWriteMutex _mutex;

	this(DatabaseConfig config)
	{
		this._config = config;
		_mutex = new ReadWriteMutex();
		int i = 0;
		while(i <= _config.maxConnection)
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
					_config.setMaxConnection = 1;
					return new SQLiteConnection(_config.url);
			}
			default:
			throw new Exception("Don't support database driver: %s", _config.url.scheme);
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
		return _conns.front;
	}

	void release(Connection conn)
	{
		_mutex.writer.lock();
		scope(exit)_mutex.writer.unlock();

		_conns.insertBack(conn);
	}	
}
