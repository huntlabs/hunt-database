import std.stdio;
import db;

import std.experimental.logger;

void main()
{
	writeln("run");

	DatabaseConfig config;
	Database db;
	string sql;
	int result;
	Statement stmt;
	ResultSet rs;
	Row row;

	config = (new DatabaseConfig())
		.addDatabaseSource("mysql://dev:111111@10.1.11.31:3306/blog?charset=utf-8")
		.setMaxConnection(20)
		.setConnectionTimeout(5000);
	db = new Database(config);

	sql = `insert into user(username) values("testsdf1111");`;
	result = db.execute(sql);
	writeln(result);

	stmt = db.query("SELECT * FROM user limit 10");
	rs = stmt.fetchAll();
	foreach(_row;rs)
	{
		writeln(_row);
	}

	sql = "select count(*) from user;";
	stmt = db.query(sql);
	writeln(stmt.fetch());

	db.close();
}
