module db.statement;

import db;

class Statement
{
	private Pool _pool;
	private Connection _conn;
	private string _sql;
    
	this(Pool pool,string sql)
    {
		this._pool = pool;
		this._sql = sql;
    }

	string sql()
	{
		return _sql;
	}
    
	ResultSet fetchAll()
	{
		_conn = _pool.getConnection();
		scope(exit){_pool.release(_conn);}
		return _conn.query(sql);
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
