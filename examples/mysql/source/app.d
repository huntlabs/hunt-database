import std.stdio;
import db;

import std.experimental.logger;

void main()
{
	writeln("run");

	DatabaseConfig config = new DatabaseConfig("mysql://root:123456@127.0.0.1:3306/mm?charset=utf-8");
	Database db = new Database(config);

	string sql = `insert into mm_user(username) values("testsdf1111");`;
	int result = db.execute(sql);
	
	writeln(result);

	Statement statement = db.query("SELECT * FROM mm_user");

	ResultSet rs = statement.fetchAll();

	foreach(row;rs)
	{
		writeln(row);
	}

	db.close();
}
