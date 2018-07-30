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

module database.database;

import database;

class Database
{
	Pool _pool;
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

	Transaction getTransaction(Connection conn) {
		return new Transaction(conn);
	}
	

	Connection getConnection() {
		return _pool.getConnection();
	}

	void closeConnection(Connection conn) {
		_pool.release(conn);
	}


	
	private void initPool()
	{
		_pool = new Pool(this._options);
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
		Connection conn = _pool.getConnection();
		int ret = new Statement(conn, sql).execute();
		_pool.release(conn);
		return ret;
	}

	int execute(Connection conn, string sql)
	{
		return new Statement(conn, sql).execute();
	}

	string escape(string sql){
		Connection conn = _pool.getConnection();
		string str = conn.escape(sql);
		_pool.release(conn);
		return str;
	}



    string escapeLiteral(string msg){
		Connection conn = _pool.getConnection();
		string str = conn.escapeLiteral(msg);
		_pool.release(conn);
		return str;
	}

    string escapeIdentifier(string msg){
		Connection conn = _pool.getConnection();
		string str = conn.escapeIdentifier(msg);
		_pool.release(conn);
		return str;
	}


	ResultSet query(string sql)
	{
		Connection conn = _pool.getConnection();
		ResultSet ret = (new Statement(conn, sql)).query();
		_pool.release(conn);
		return ret;
	}

	Statement prepare(string sql)
	{
		Connection conn = _pool.getConnection();
		Statement ret = new Statement(conn, sql);
		_pool.release(conn);
		return ret;
	}

	void close()
	{
		_pool.close();	
	}

	SqlBuilder createSqlBuilder()
	{
		return (new SqlFactory(_options)).createBuilder(this);
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
