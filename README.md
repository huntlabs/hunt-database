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

    auto db = new Database("mysql://root:123456@localhost:3306/test?charset=utf-8");

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
auto options = new DatabaseOption("mysql://root:123456@localhost:3306/test");
options.setMaximumConnection(5);

auto db = new Database(options);

db.execute("SET NAMES utf8");
```

## API

-  int Database.execute(string sql)  Return number of execute result.
```D
    int result = db.execute('INSERT INTO user(username) VALUES("Brian")');
    // if execute error ,db will throw an DatabaseException
```
-  ResultSet Database.query(sql) Return ResultSet object for query(SELECT).
```D
    ResultSet rs = db.query("SELECT * FROM user LIMIT 10");
```
-  Statement Database.prepare(sql) Create a prepared Statement object.
```D
   Statement stmt = db.prepare("SELECT * FROM user where username = :username and age = :age LIMIT 10")
```
- Statement.bind(param, value) : bind param's value to :param for sql.
```D
   stmt.bind("username", "viile");
   stmt.bind("age", 18);
```
- ResultSet Statement.query()  Return ResultSet 
```D
    ResultSet rs = stmt.query();
```
- Row Statement.fetch()  Return Row 
```D
    Row row = stmt.fetch();
    writeln(row["username"]);
```
- int Statement.execute() : return execute status for prepared Statement object. 
```D
    int result = stmt.execute();
```
- Statement.lastInsertId() : Statement.execute() for insert sql, return lastInsertId.
