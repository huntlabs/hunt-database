import std.stdio;
import db;

import std.experimental.logger;

void main()
{
	writeln("run");

	Database db = new Database("mysql://dev:111111@10.1.11.31:3306/blog?charset=utf-8");

	string sql = `insert into user(username) values("testsdf");`;
	int result = db.execute(sql);
	
	writeln(result);

	Statement statement = db.query("SELECT * FROM user");

	ResultSet rs = statement.fetchAll();

	foreach(row;rs)
	{
		writeln(row);
	}

	db.close();
}
