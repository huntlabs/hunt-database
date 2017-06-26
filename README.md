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

## Use DatabaseOption to instantiate a Database object
```D
    DatabaseOption option = new DatabaseOption("mysql://root:123456@localhost:3306/test?charset=utf-8");
    option.setMaximumConnection = 5;
    Database db = new Database(option);
```

## API

- Database.execute(sql) -> Statement.execute(sql) : Return number of rows affected (INSERT/UPDATE/DELETE).
- Database.query(sql) -> Statement.query(sql) : Return Statement object for query(SELECT).
- Database.prepare(sql) -> Statement.prepare(sql) : Create a prepared Statement object.
- Statement.prepare(sql) : Create a prepared Statement object.
- Statement.execute(sql) : Return number of rows affected (like INSERT/UPDATE/CREATE).
- Statement.execute() : For Database.prepare(sql), return number of rows affected.
- Statement.query(string) : Return ResultSet object, for query(like SELECT).
- Statement.query() : For Database.prepare(sql), return ResultSet object.
- Statement.fetch() : Return ResultSet pop() one row, for Statement.query();
- Statement.lastInsertId() : Statement.execute() for insert sql, return lastInsertId.
- Statement.bind(param, value) : bind param value to :param for sql.
