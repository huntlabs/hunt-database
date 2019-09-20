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
import hunt.database.Statement;

import hunt.database.base;
import hunt.database.driver.mysql;
import hunt.database.driver.postgresql;
import hunt.database.query.QueryBuilder;

import hunt.logging.ConsoleLogger;
import hunt.net.util.HttpURI;
import hunt.text.StringBuilder;

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
		return _pool.getConnection();
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

		if(_options.isPgsql()) {
			PgConnectOptions connectOptions = new PgConnectOptions(_options.url);
			connectOptions.setDecoderBufferSize(_options.getDecoderBufferSize());
			connectOptions.setEncoderBufferSize(_options.getEncoderBufferSize());

			PoolOptions poolOptions = new PoolOptions().setMaxSize(_options.maximumConnection);
			_pool = new PgPoolImpl(connectOptions, poolOptions);

		} else if(_options.isMysql()) {
			MySQLConnectOptions connectOptions = new MySQLConnectOptions(_options.url);
			connectOptions.setDecoderBufferSize(_options.getDecoderBufferSize());
			connectOptions.setEncoderBufferSize(_options.getEncoderBufferSize());
			
			PoolOptions poolOptions = new PoolOptions().setMaxSize(_options.maximumConnection);
			_pool = new MySQLPoolImpl(connectOptions, poolOptions);

		} else {
			throw new DatabaseException("Unsupported database driver: " ~ _options.schemeName());
		}
	}

	int execute(string sql)
	{
        version(HUNT_DEBUG) trace(sql);
		SqlConnection conn = getConnection();
		scope(exit) {
			conn.close();
		}

		RowSet rs = conn.query(sql);
		return rs.rowCount();
	}

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

    // string escapeLiteral(string str) {
		
	// 	if(_options.isPgsql()) {
	// 		scope StringBuilder sb = new StringBuilder((cast(int)str.length + 10) / 10 * 11); // Add 10% for escaping.
	// 		PgUtil.escapeLiteral(sb, str, true);

	// 		return sb.toString();
	// 	} 

	// 	return str;

	// }

    // string escapeIdentifier(string msg){
	// 	auto conn = getConnection();
    //     scope(exit) relaseConnection(conn);
	// 	string str = conn.escapeIdentifier(msg);
	// 	return str;
	// }

	// string escapeWithQuotes(string str) {

	// 	if(_options.isPgsql()) {
	// 		return PgUtil.escapeWithQuotes(str);
	// 	} 

	// 	return str;
	// }


	RowSet query(string sql)
	{
		version (HUNT_SQL_DEBUG) info(sql);
		SqlConnection conn = getConnection();
		scope(exit) {
			conn.close();
		}

		RowSet rs = conn.query(sql);
		return rs;
	}

	Statement prepare(string sql)
	{
		Statement ret = new Statement(this, sql);
		return ret;
	}

	void close()
	{
		if(_pool !is null) {
			_pool.close();
			_pool = null;
		}	
	}

	QueryBuilder createQueryBuilder()
	{
		import hunt.sql.util.DBType;
		if(_options.isPgsql()) {
			return new QueryBuilder(DBType.POSTGRESQL);
		} else if(_options.isMysql()) {
			return new QueryBuilder(DBType.MYSQL);
		} else {
			throw new DatabaseException("Unsupported database driver: " ~ _options.schemeName());
		}
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