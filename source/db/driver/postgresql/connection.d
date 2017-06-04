module db.driver.postgresql.connection;

import db;

class PostgresqlConnection : Connection
{
	this(URL url)
	{
	
	}

	void close()
	{
	}

	ResultSet queryImpl(string sql, Variant[] args...)
    {
        return null;
    }

    int execute(string sql)
    {
        return 0;
    }

	string escape(string sqlData)
	{
		return null;
	}
}
