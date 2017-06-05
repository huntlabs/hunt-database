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

	string sql()
	{
		return _sql;
	}
    
	ResultSet fetchAll()
	{
		//writeln(__FUNCTION__,__LINE__,sql);
		return _conn.query(_sql);
	}

	~this()
	{
		_conn = null;
		_sql = null;
	}
}
