

import db;
import std.stdio;
import std.experimental.logger.core;

pragma(lib, "sqlite3");

void main()
{
	/*
	//sqlite://relative
	Database db = new Database("sqlite:///./db/db-test.sqlite");

	string sql = `insert into user(username) values("testsdf");`;

	// URL url;
	// url.scheme = "sqlite";

	// url.path="db/db-test.sqlite";
	// trace(url.toString());

	// url.path="./db/db-test.sqlite";
	// trace(url.toString());

	// url.path="../db/db-test.sqlite";
	// trace(url.toString());

	// url.path="/db/db-test.sqlite";
	// trace(url.toString());

	// int result = db.execute(sql);
	
	// writeln(result);

	Statement statement = db.query("SELECT * FROM user");

	ResultSet rs = statement.fetchAll();

	foreach(row;rs)
	{
		writeln(row);
	}

	db.close();
	*/
}
