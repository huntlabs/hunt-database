

import db;

import std.experimental.logger;

void main()
{
	Database db = new Database("postgres://root:123456@localhost:2345/dbname?charset=utf-8");
	
	Statement statement = db.query("SELECT * FROM users");

	Row[] rows = statement.fetch();
	foreach(row; rows)
	{
		tracef("username: %s", row["name"]);
	}

	int result = db.execute("INSERT INTO users()");
	tracef("inserted line: %s", result);

	int result = db.execute("DELETE * FROM users WHERE id < 100");
	tracef("deleted line: %s", result);
}
