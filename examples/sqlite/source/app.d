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

import database;

void main()
{
    writeln("run Database for SQLite demo.");

    Database db = new Database("sqlite:///./testDB.db");

    string sql = `INSERT INTO test(name, pass, age) VALUES("test", "123", 12)`;

    db.execute(sql);

    Statement statement = db.query("SELECT * FROM test");

    ResultSet rs = statement.fetchAll();

    foreach(row; rs)
    {
        writeln(row);
    }

    db.close();
}
