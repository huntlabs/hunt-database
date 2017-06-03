import std.stdio;
import db;

import std.experimental.logger;

void main()
{
	Database db = new Database("mysql://dev:111111@10.1.11.31:3306/blog?charset=utf-8");
	
	Statement statement = db.query("SELECT * FROM user");
	
	//ResultSet rs = statement.fetchAll();
	db._conn.query("SELECT * from user");

	/*
	Row[] rows = statement.fetch();
	foreach(row; rows)
	{
		tracef("username: %s", row["name"]);
	}

	int result = db.execute("INSERT INTO users()");
	tracef("inserted line: %s", result);

	int result = db.execute("DELETE * FROM users WHERE id < 100");
	tracef("deleted line: %s", result);
	*/
}
