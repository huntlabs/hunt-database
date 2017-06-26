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

- Database.execute(string sql) -> Statement.execute(string sql) : Return number of rows affected (like INSERT/UPDATE/CREATE).
- Database.query(string sql) -> Statement.query(string sql) : Return Statement object for query(like SELECT).
- Database.createStatement() : Create a Statement object.
- Database.prepare(string sql) -> Statement.prepare(string sql) : Create a prepared Statement object.
- Statement.prepare(string sql) : Create a prepared Statement object.
- Statement.execute(string sql) : Return number of rows affected (like INSERT/UPDATE/CREATE).
- Statement.execute() : For Database.prepare(string sql), return number of rows affected.
- Statement.query(string sql) : Return ResultSet object, for query(like SELECT).
- Statement.query() : For Database.prepare(string sql), return ResultSet object.
- Statement.fetch() : Return ResultSet pop() one row, for Statement.query();
- Statement.lastInsertId() : Statement.execute() for insert sql, return lastInsertId.
