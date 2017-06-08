import std.stdio;

import db;

void main()
{
	Database db = new Database("sqlite:///./testDB.db");

	string sql = `insert into test(name,pass,age) values("testsdf","123",12);`;

    db.execute(sql);

	Statement statement = db.query("SELECT * FROM test");

	ResultSet rs = statement.fetchAll();

    
	foreach(row;rs)
	{
		writeln(row);
	}

	db.close();
}
