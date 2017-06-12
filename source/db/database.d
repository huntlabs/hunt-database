module db.database;

import db;

class Database
{
	Connection _conn;
	Pool _pool;
	DatabaseConfig _config;

	this(DatabaseConfig config)
	{
		this._config = config;
		initPool();
	}

	private void initPool()
	{
		_pool = new Pool(this._config);
	}

	bool beginTransaction()
	{
		return false;
	}

	bool commit()
	{
		return false;
	}

	int error()
	{
		return 0;
	}

	int execute(string sql)
	{
		return _conn.execute(sql);
	}

	Statement query(string sql)
	{
		return new Statement(_conn, sql);
	}

	void close()
	{

	}

}
