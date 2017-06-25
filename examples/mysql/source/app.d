
/*
 * Database - Database abstraction layer for D programing language.
 *
 * Copyright (C) 2017  Shanghai Putao Technology Co., Ltd
 *
 * Developer: HuntLabs
 *
 * Licensed under the Apache-2.0 License.
 *
 */

import std.stdio;
import std.experimental.logger;

import database;

void main()
{
    writeln("run database MySQL demo.");

    Database db = new Database("mysql://root:123456@localhost:3306/blog?charset=utf-8");

    int result = db.execute(`INSERT INTO user(username) VALUES("test")`);
    writeln(result);

    Statement stmt = db.query("SELECT * FROM user LIMIT 10");

    foreach(row; stmt.fetchAll())
    {
        writeln(row.username);
    }

    db.close();
}
