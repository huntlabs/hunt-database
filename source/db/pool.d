module db.pool;

import db;

class Pool
{
	Connection _conn;
	DatabaseConfig _config;

	this(DatabaseConfig config)
	{
		this._config = config;
		initConnection();
	}

	private void initConnection()
	{
		switch (_url.scheme)
		{
			version (USE_POSTGRESQL)
			{
				case "postgresql":
					_conn = new PostgresqlConnection(_url);
					break;
			}
			version (USE_MYSQL)
			{
				case "mysql":
					_conn = new MysqlConnection(_url);
					break;
			}
			version(USE_SQLITE){
				case "sqlite":
					maxConnection = 1;
					_conn = new SQLiteConnection(_url);
					break;
			}
			default:
			throw new Exception("Don't support database driver: %s", _url.scheme);
		}
	}

	Connection getConnection()
	{
		return null;
	}

}
