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

	private void initPool()
	{
		_pool = new Pool(this._options);
	}

	Transaction beginTransaction()
	{
		Connection _conn = _pool.getConnection();
		Transaction tran = new Transaction(this,_pool,_conn);
		tran.begin();
		return tran;
	}

	int error()
	{
		return 0;
	}

	int execute(string sql)
	{
		return new Statement(_pool, sql).execute();
	}

	ResultSet query(string sql)
	{
		return (new Statement(_pool, sql)).query();
	}

	Statement prepare(string sql)
	{
		return new Statement(_pool, sql);
	}

	void close()
	{
		_pool.close();	
	}

	SqlBuilder createSqlBuilder()
	{
		return (new SqlFactory()).createMySqlBuilder();
	}

	Dialect createDialect()
	{
		version(USE_MYSQL){
			return new MysqlDialect();
		}
        else version(USE_POSTGRESQL)
		{
			return new PostgresqlDialect(); 
		}
		else version(USE_SQLITE)
		{
			return new SqliteDialect(); 
		}
        else
			throw new DatabaseException("Unknow Dialect");
	}
}
