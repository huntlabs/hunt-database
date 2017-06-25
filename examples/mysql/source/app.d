
import std.stdio;
import std.experimental.logger;

import database;

void main()
{
    writeln("run database MySQL demo.");

    Database db = new Database("mysql://dev:111111@10.1.11.31:3306/blog?charset=utf-8");

    int result = db.execute(`INSERT INTO user(username) VALUES("test");`);
    writeln(result);

    Statement stmt = db.query("SELECT * FROM user LIMIT 10");
    foreach(row; stmt.fetchAll())
    {
        writeln(row.username);
    }

    db.close();
}
