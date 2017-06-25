## Database
Database abstraction layer for D programing language, support PostgreSQL / MySQL / SQLite.

## Example
```D

import std.stdio;
import std.experimental.logger;

import database;

void main()
{
	writeln("run database MySQL demo.");

	Database db = new Database("mysql://root:123456@localhost:3306/test?charset=utf-8");

	int result = db.execute(`INSERT INTO user(username) VALUES("test");`);
	writeln(result);

	Statement stmt = db.query("SELECT * FROM user LIMIT 10");
	foreach(row; stmt.fetchAll())
	{
		writeln(row.username);
	}

	db.close();
}

```