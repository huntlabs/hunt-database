module db.statement;

import db;

class Statement
{
	private Connection _conn;
	private string _sql;


	this(Connection conn)
    {
		this._conn = conn;
    }
    
	this(Connection conn,string sql)
    {
		this._conn = conn;
		this._sql = sql;
    }

	string sql()
	{
		return _sql;
	}
    
	ResultSet fetchAll()
	{
		return _conn.query(_sql);
	}

	void close()
	{

	}

	~this()
	{
		_conn = null;
		_sql = null;
	}
}
