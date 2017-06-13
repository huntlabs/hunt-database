import std.stdio;
import db;

import std.experimental.logger;

void main()
{
	writeln("run");

	DatabaseConfig config = (new DatabaseConfig())
		.addDatabaseSource("mysql://dev:111111@10.1.11.31:3306/blog?charset=utf-8")
		.setMaxConnection(20)
		.setConnectionTimeout(5000);
	Database db = new Database(config);

	string sql = `insert into user(username) values("testsdf1111");`;
	int result = db.execute(sql);
	
	writeln(result);

	Statement statement = db.query("SELECT * FROM user limit 10");

	ResultSet rs = statement.fetchAll();

	foreach(row;rs)
	{
		writeln(row);
	}

	db.close();
}
