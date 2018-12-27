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

import hunt.database;

void main()
{
    writeln("run Database for SQLite demo.");

    Database db = new Database("sqlite:///./testDB.db");

    db.execute(`CREATE TABLE user(
            name CAHR(50),
            email CAHR(100),
            money REAL,
            status INT
            );`);

    string sql = q{
        INSERT INTO  user(name,email,money,status) VALUES("viile","viile@dlang.org",10.5,1);
    };

    auto r = db.execute(sql);

    writeln(r);

    Statement statement = db.prepare("SELECT * FROM user");

    ResultSet rs = statement.query();

    foreach(row; rs)
    {
        writeln(row);
    }

    db.close();
}
