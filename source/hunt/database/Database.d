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

import hunt.database.DatabaseOption;

import hunt.database.base;
import hunt.database.driver.mysql;
import hunt.database.driver.postgresql;

import hunt.logging.ConsoleLogger;

/**
 * 
 */
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

	~this() {
		close();
	}

	DatabaseOption getOption()
	{
		return _options;
	}

	Transaction getTransaction(SqlConnection conn) {
		return conn.begin();
	}
	

	SqlConnection getConnection() {
		auto conn = _pool.getConnectionAsync().get();
		return conn;
	}

	void closeConnection(SqlConnection conn) {
		conn.close();
	}

	void relaseConnection(SqlConnection conn)
	{
		conn.close();
	}

	// int getPoolSize()
	// {
	// 	return _pool.size;
	// }

	
	private void initPool()
	{
		import hunt.database.driver.mysql.impl.MySQLPoolImpl;
		import hunt.database.driver.postgresql.impl.PostgreSQLPoolImpl;
		import hunt.database.Url;

		if(_options.isPgsql) {
			URL url = _options.url;

			PgConnectOptions connectOptions = new PgConnectOptions();
			connectOptions.setHost(url.host);
			connectOptions.setPort(url.port);
			connectOptions.setUser(url.user);
			connectOptions.setPassword(url.pass);        
			connectOptions.setDatabase(url.path);

			PoolOptions poolOptions = new PoolOptions().setMaxSize(_options.maximumConnection);
			_pool = new PgPoolImpl(connectOptions, poolOptions);

		} else if(_options.isPgsql) {
			URL url = _options.url;

			MySQLConnectOptions connectOptions = new MySQLConnectOptions();
			connectOptions.setHost(url.host);
			connectOptions.setPort(url.port);
			connectOptions.setUser(url.user);
			connectOptions.setPassword(url.pass);        
			connectOptions.setDatabase(url.path);
			connectOptions.setCollation(url.chartset);

			PoolOptions poolOptions = new PoolOptions().setMaxSize(_options.maximumConnection);
			_pool = new MySQLPoolImpl(connectOptions, poolOptions);

		} else {
			throw new DatabaseException("Unsupported database driver: " ~ _options.schemeName());
		}
	}

	// int error()
	// {
	// 	return 0;
	// }

	// int execute(string sql)
	// {
    //     version(HUNT_DEBUG) trace(sql);
	// 	int ret = new Statement(this, sql).execute();
	// 	return ret;
	// }

	// int execute(SqlConnection conn, string sql)
	// {
	// 	return new Statement(this, sql).execute();
	// }

	// string escape(string sql){
	// 	auto conn = getConnection();
    //     scope(exit) relaseConnection(conn);
	// 	string str = conn.escape(sql);
	// 	return str;
	// }

    // string escapeLiteral(string msg){
	// 	auto conn = getConnection();
    //     scope(exit) relaseConnection(conn);
	// 	string str = conn.escapeLiteral(msg);
	// 	return str;
	// }

    // string escapeIdentifier(string msg){
	// 	auto conn = getConnection();
    //     scope(exit) relaseConnection(conn);
	// 	string str = conn.escapeIdentifier(msg);
	// 	return str;
	// }

	// string escapeWithQuotes(string msg){
	// 	auto conn = getConnection();
    //     scope(exit) relaseConnection(conn);
	// 	string str = conn.escapeWithQuotes(msg);
	// 	return str;
	// }


	// ResultSet query(string sql)
	// {
    //     version(HUNT_DEBUG) trace(sql);
	// 	ResultSet ret = (new Statement(this, sql)).query();
	// 	return ret;
	// }

	// Statement prepare(string sql)
	// {
	// 	Statement ret = new Statement(this, sql);
	// 	return ret;
	// }

	void close()
	{
		if(_pool !is null) {
			_pool.close();
			_pool = null;
		}	
	}

	// QueryBuilder createQueryBuilder()
	// {
	// 	return (new SqlFactory(_options)).createQueryBuilder(this);
	// }


	// Dialect createDialect()
	// {
	// 	version(USE_MYSQL){
	// 		if(_options.isMysql)
	// 		return new MysqlDialect(this);
	// 	}
    //      version(USE_POSTGRESQL)
	// 	{
	// 		if(_options.isPgsql)
	// 		return new PostgresqlDialect(this); 
	// 	}
	// 	 version(USE_SQLITE)
	// 	{
	// 		if(_options.isSqlite)
	// 		return new SqliteDialect(this); 
	// 	}
    //     throw new DatabaseException("Unknow Dialect");
	// }
}

unittest{

	/*auto db = new Database("mysql://root:123456@127.0.0.1:3306/hunt_test?charset=utf8mb4");
	Statement statement = db.prepare(`INSERT INTO users ( email , first_name , last_name ) VALUES ( :email , :firstName , :lastName )`);
	statement.setParameter(`:email`, "me@example.com");
	statement.setParameter(`:firstName`, "John");
	statement.setParameter(`:lastName`, "Doe");
	statement.execute();*/
}