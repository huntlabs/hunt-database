module db.driver.sqlite.connection;

// import db.database;
import db.driver.connection;
import db.driver.resultset;
import db.driver.utils;
import db.exception;
import db.statement;
import db.url;

import std.algorithm;
import std.conv;
import std.datetime;
import std.exception;
import std.path;
import std.file;
import std.stdio;
import std.string;
import std.variant;
import core.sync.mutex;

import etc.c.sqlite3;
import std.experimental.logger.core;

version (Windows)
{
	pragma(lib, "sqlite3");
}
else version (linux)
{
	pragma(lib, "sqlite3");
}
else version (Posix)
{
	pragma(lib, "libsqlite3");
}
else version (darwin)
{
	pragma(lib, "libsqlite3");
}
else
{
	pragma(msg, "You will need to manually link in the SQLite library.");
}

class SQLiteConnection : Connection
{
	private
	{
		string filename;
		string _host;
		string _user;
		string _pass;
		string _db;
		uint _port;

		QueryParams _querys;
		sqlite3* conn;
		bool closed;
		bool autocommit;
		Mutex mutex;

		Statement[] activeStatements;
	}

	this(URL url)
	{
		mutex = new Mutex();

		// this._url = url;
		this._port = url.port;
		this._host = url.host;
		this._user = url.user;
		string p = url.path;
		if (p[0 .. 2] == "/.")
			p = (url.path)[1 .. $];

		this.filename = buildPath(dirName(thisExePath), p);

		this._pass = url.pass;
		this._querys = url.queryParams;
		closed = false;

		// trace("path=", url.path);
		trace("Trying to open a sqlite file:", filename);

		//writeln("trying to connect");
		int res = sqlite3_open(toStringz(filename), &conn);
		if (res != SQLITE_OK)
			throw new SQLException("SQLite Error " ~ to!string(
					res) ~ " while trying to open DB " ~ filename ~ " : " ~ getError());
		assert(conn !is null);
		setAutoCommit(true);
	}

	void close()
	{
		checkClosed();

		lock();
		scope (exit)
			unlock();

		closeUnclosedStatements();
		int res = sqlite3_close(conn);
		if (res != SQLITE_OK)
			throw new SQLException("SQLite Error " ~ to!string(
					res) ~ " while trying to close DB " ~ filename ~ " : " ~ getError());
		closed = true;
	}

	void commit()
	{
		checkClosed();

		lock();
		scope (exit)
			unlock();

		// Statement stmt = createStatement();
		// scope (exit)
		// 	stmt.close();
		// stmt.executeUpdate("COMMIT");
	}

	void setAutoCommit(bool autoCommit)
	{
		checkClosed();
		if (this.autocommit == autoCommit)
			return;
		lock();
		scope (exit)
			unlock();

		Statement stmt = createStatement();
		scope (exit)
			stmt.close();
		//TODO:
		//stmt.executeUpdate("SET autocommit = " ~ (autoCommit ? "ON" : "OFF"));
		this.autocommit = autoCommit;
	}

	void lock()
	{
		mutex.lock();
	}

	void unlock()
	{
		mutex.unlock();
	}

	ResultSet queryImpl(string sql, Variant[] args...)
	{
		return null;
	}

	int execute(string sql)
	{
		return 0;
	}

	string escape(string sqlData)
	{
		return null;
	}

	Statement createStatement()
	{
		checkClosed();

		lock();
		scope (exit)
			unlock();

		Statement stmt = new Statement(this, "");
		activeStatements ~= stmt;
		return stmt;
	}

	private string getError()
	{
		return copyCString(sqlite3_errmsg(conn));
	}

	private void checkClosed()
	{
		if (closed)
			throw new SQLException("Connection is already closed");
	}

	private void closeUnclosedStatements()
	{
		Statement[] list = activeStatements.dup;
		foreach (stmt; list)
		{
			stmt.close();
		}
	}
}

/**
*/
class SQLiteStatement : Statement
{
	private
	{

		SQLiteConnection conn;
		//  Command * cmd;
		//  ddbc.drivers.mysql.ResultSet rs;
		// SQLiteResultSet resultSet;

		bool closed;
	}

public:
	void checkClosed()
	{
		enforceEx!SQLException(!closed, "Statement is already closed");
	}

	void lock()
	{
		conn.lock();
	}

	void unlock()
	{
		conn.unlock();
	}

	this(SQLiteConnection conn)
	{
		this.conn = conn;
		super(conn);
	}

public:
	SQLiteConnection getConnection()
	{
		checkClosed();
		return conn;
	}

	// private PreparedStatement _currentStatement;
	private ResultSet _currentResultSet;

	private void closePreparedStatement()
	{
		// if (_currentResultSet !is null)
		// {
		// 	_currentResultSet.close();
		// 	_currentResultSet = null;
		// }
		// if (_currentStatement !is null)
		// {
		// 	_currentStatement.close();
		// 	_currentStatement = null;
		// }
	}

	// override ddbc.core.ResultSet executeQuery(string query)
	// {
	// 	closePreparedStatement();
	// 	_currentStatement = conn.prepareStatement(query);
	// 	_currentResultSet = _currentStatement.executeQuery();
	// 	return _currentResultSet;
	// }

	//    string getError() {
	//        return copyCString(PQerrorMessage(conn.getConnection()));
	//    }

	int executeUpdate(string query)
	{
		Variant dummy;
		return executeUpdate(query, dummy);
	}

	int executeUpdate(string query, out Variant insertId)
	{
		closePreparedStatement();
		// _currentStatement = conn.prepareStatement(query);
		// return _currentStatement.executeUpdate(insertId);
		return 0;
	}

	override void close()
	{
		checkClosed();
		lock();
		scope (exit)
			unlock();
		closePreparedStatement();
		closed = true;
		// conn.onStatementClosed(this);
	}

	void closeResultSet()
	{
	}
}
