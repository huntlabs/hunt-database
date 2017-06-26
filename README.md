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

- Database.execute(string sql): Return number of rows affected (like INSERT/UPDATE/CREATE).
- Database.query(string sql): Return Statement object for query(like SELECT).
- Database.prepare(string sql): Create a prepared Statement object.
- Database.createStatement(): Create a Statement object.
- Statement.fetchAll(): Return ResultSet object, for Database.prepare(string sql).
- Statement.fetch(): Return a row, for Database.prepare(string sql);
- Statement.execute(string sql); Return number of rows affected (like INSERT/UPDATE/CREATE).
- Statement.query(string sql); Return Statement object for query(like SELECT).
- Statement.execute(); For Database.prepare(string sql), return number of rows affected.
- Statement.query(); For Database.prepare(string sql), return ResultSet.
- Statement.lastInsertId(); Statement.execute() for insert sql, return lastInsertId.
