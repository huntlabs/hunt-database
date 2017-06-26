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

    int result = db.execute(`INSERT INTO user(username) VALUES("test")`);
    writeln(result);

    foreach(row; db.query("SELECT * FROM user LIMIT 10"))
    {
        writeln(row["username"]);
    }

    db.close();
}

```

## API

- Database.execute(string) -> Statement.execute(string) : Return number of rows affected (INSERT/UPDATE/DELETE).
- Database.query(string) -> Statement.query(string) : Return Statement object for query(SELECT).
- Database.createStatement() : Create a Statement object.
- Database.prepare(string) -> Statement.prepare(string) : Create a prepared Statement object.
- Statement.prepare(string) : Create a prepared Statement object.
- Statement.execute(string) : Return number of rows affected (like INSERT/UPDATE/CREATE).
- Statement.execute() : For Database.prepare(string), return number of rows affected.
- Statement.query(string) : Return ResultSet object, for query(like SELECT).
- Statement.query() : For Database.prepare(string), return ResultSet object.
- Statement.fetch() : Return ResultSet pop() one row, for Statement.query();
- Statement.lastInsertId() : Statement.execute() for insert sql, return lastInsertId.
