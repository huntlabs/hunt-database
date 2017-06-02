module db.statement;

import db;

class Statement
{
	private Connection _conn;
	private string _sql;
    
	this(Connection conn,string sql)
    {
		this._conn = conn;
		this._sql = sql;
    }
    
	ResultSet fetchAll()
	{
		return _conn.query(_sql);
	}

	~this()
	{
		_conn = null;
		_sql = null;
	}
}
