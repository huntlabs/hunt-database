module db.database;

import db;
import db.driver.sqlite.connection;

class Database
{
	this(string url)
	{
		this._url = url.parseURL;
		initConnection();
	}

	private void initConnection()
	{
		switch(_url.scheme)
		{
			case "postgresql":
				_conn = new PostgresqlConnection(_url);
				break;
			case "mysql":
				_conn = new MysqlConnection(_url);
				break;
			case "sqlite":
				_conn = new SQLiteConnection(_url);
				break;
			default:
				throw new Exception("Don't support database driver: %s", _url.scheme);
		}
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
		return new Statement(_conn,sql);
	}

	void close()
	{

	}
	
	Connection _conn;
	URL _url;
}
