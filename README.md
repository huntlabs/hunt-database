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

-  int Database.execute(string sql)  Return number of execute result.
```D
    int result = db.execute('INSERT INTO user(username) VALUES("test")');
    // if execute error ,db will throw an DatabaseException
```
-  ResultSet Database.query(sql) Return ResultSet object for query(SELECT).
```D
    ResultSet rs = db.query("SELECT * FROM user LIMIT 10")
```
-  Statement Database.prepare(sql) Create a prepared Statement object.
```D
   Statement stmt = db.prepare("SELECT * FROM user where username = :username and password = :password LIMIT 10")
```
- Statement.bind(param, value) : bind param value to :param for sql.
```D
   stmt.bind(":username","viile");
```
- ResultSet Statement.fetchAll()  Return ResultSet 
```D
    ResultSet rs = stmt.fetchAll();
```
- Row Statement.fetch()  Return Row 
```D
    ResultSet rs = stmt.fetch();
```
- Statement.lastInsertId() : Statement.execute() for insert sql, return lastInsertId.
