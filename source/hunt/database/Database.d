/*
 * Database - Database abstraction layer for D programing language.
 *
 * Copyright (C) 2017  Shanghai Putao Technology Co., Ltd
 *
 * Developer: HuntLabs
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.database.Database;

import hunt.database;
import hunt.sql;

version(HUNT_DEBUG) import hunt.logging.ConsoleLogger;

class Database
{
	Pool!Connection _pool;
	DatabaseOption _options;

	this(string url)
	{
		this._options = new DatabaseOption(url);
		initPool();
	}

	this(DatabaseOption options)
	{
		this._options = options;
		initPool();
	}

	DatabaseOption getOption()
	{
		return _options;
	}

	Transaction getTransaction(Connection conn) {
		return new Transaction(conn);
	}
	

	Connection getConnection() {
		auto conn = _pool.invoke();
		if(conn !is null)
			conn.ping();
		return conn;
	}

	void closeConnection(Connection conn) {
		_pool.revoke(conn);
	}

	void relaseConnection(Connection conn)
	{
		_pool.revoke(conn);
	}

	int getPoolSize()
	{
		return _pool.size;
	}

	
	private void initPool()
	{
		if(_options.minimumConnection> _options.maximumConnection) {
			throw new Exception("Out of range");
		}
		_pool = new Pool!Connection(this._options.minimumConnection,this._options.maximumConnection,&this.createConnection);
	}

	private Connection createConnection()
    {
		version(HUNT_DEBUG_MORE) infof("url: %s", _options.url);
		version (USE_POSTGRESQL)
		{
            if(_options.isPgsql)
			    return new PostgresqlConnection(_options.url);
		}
		version (USE_MYSQL)
		{
            if(_options.isMysql)
			return new MysqlConnection(_options.url);
		}
		version(USE_SQLITE){
			_options.setMaximumConnection = 1;
			_options.setMinimumConnection = 1;
            if(_options.isSqlite)
			return new SQLiteConnection(_options.url);
		}
		
		throw new DatabaseException("Unsupported database driver: "~ _options.url.scheme);
    }

	// Transaction beginTransaction()
	// {
	// 	Connection _conn = _pool.getConnection();
	// 	Transaction tran = new Transaction(this,_pool,_conn);
	// 	tran.begin();
	// 	return tran;
	// }

	int error()
	{
		return 0;
	}

	int execute(string sql)
	{
        version(HUNT_DEBUG) trace(sql);
		int ret = new Statement(this, sql).execute();
		return ret;
	}

	int execute(Connection conn, string sql)
	{
		return new Statement(this, sql).execute();
	}

	string escape(string sql){
		auto conn = getConnection();
        scope(exit) relaseConnection(conn);
		string str = conn.escape(sql);
		return str;
	}



    string escapeLiteral(string msg){
		auto conn = getConnection();
        scope(exit) relaseConnection(conn);
		string str = conn.escapeLiteral(msg);
		return str;
	}

    string escapeIdentifier(string msg){
		auto conn = getConnection();
        scope(exit) relaseConnection(conn);
		string str = conn.escapeIdentifier(msg);
		return str;
	}

	string escapeWithQuotes(string msg){
		auto conn = getConnection();
        scope(exit) relaseConnection(conn);
		string str = conn.escapeWithQuotes(msg);
		return str;
	}


	ResultSet query(string sql)
	{
        version(HUNT_DEBUG) trace(sql);
		ResultSet ret = (new Statement(this, sql)).query();
		return ret;
	}

	Statement prepare(string sql)
	{
		Statement ret = new Statement(this, sql);
		return ret;
	}

	void close()
	{
		_pool.close();	
	}

	QueryBuilder createQueryBuilder()
	{
		return (new SqlFactory(_options)).createQueryBuilder(this);
	}

	///
	/////	bool isMysql()
//	bool isPgsql()
//	bool isSqlite()
	///

	Dialect createDialect()
	{
		version(USE_MYSQL){
			if(_options.isMysql)
			return new MysqlDialect(this);
		}
         version(USE_POSTGRESQL)
		{
			if(_options.isPgsql)
			return new PostgresqlDialect(this); 
		}
		 version(USE_SQLITE)
		{
			if(_options.isSqlite)
			return new SqliteDialect(this); 
		}
        throw new DatabaseException("Unknow Dialect");
	}
}

unittest{

	/*auto db = new Database("mysql://root:123456@127.0.0.1:3306/hunt_test?charset=utf8mb4");
	Statement statement = db.prepare(`INSERT INTO users ( email , first_name , last_name ) VALUES ( :email , :firstName , :lastName )`);
	statement.setParameter(`:email`, "me@example.com");
	statement.setParameter(`:firstName`, "John");
	statement.setParameter(`:lastName`, "Doe");
	statement.execute();*/
}