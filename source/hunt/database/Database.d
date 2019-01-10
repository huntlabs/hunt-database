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
		return _pool.invoke();
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
		_pool = new Pool!Connection(this._options.minimumConnection,this._options.maximumConnection,&this.createConnection);
	}

	private Connection createConnection()
    {
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
		
			throw new DatabaseException("Don't support database driver: "~ _options.url.scheme);
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
		int ret = new Statement(this, sql).execute();
		return ret;
	}

	int execute(Connection conn, string sql)
	{
		return new Statement(this, sql).execute();
	}

	string escape(string sql){
		Connection conn = _pool.invoke();
		string str = conn.escape(sql);
		_pool.revoke(conn);
		return str;
	}



    string escapeLiteral(string msg){
		Connection conn = _pool.invoke();
		string str = conn.escapeLiteral(msg);
		_pool.revoke(conn);
		return str;
	}

    string escapeIdentifier(string msg){
		Connection conn = _pool.invoke();
		string str = conn.escapeIdentifier(msg);
		_pool.revoke(conn);
		return str;
	}


	ResultSet query(string sql)
	{
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