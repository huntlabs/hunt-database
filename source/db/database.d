module db.database;

import db;

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
            version(USE_PGSQL){
			case "pgsql":
				_conn = new PostgresqlConnection(_url);
				break;
            }
            version(USE_MYSQL){
			case "mysql":
				_conn = new MysqlConnection(_url);
				break;
            }
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

	Connection _conn;
	URL _url;
}
