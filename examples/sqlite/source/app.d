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

    db.execute(`CREATE TABLE if not exists user(
            id   INT,
            name CAHR(50),
            email CAHR(100),
            money REAL,
            status INT
            );`);

    string sql = q{
        INSERT INTO  user(id,name,email,money,status) VALUES(1,"viile","viile@dlang.org",10.5,1);
    };

    auto r = db.execute(sql);

    writeln(r);

    Statement statement = db.prepare("SELECT * FROM user");

    ResultSet rs = statement.query();

    foreach(row; rs)
    {
        writeln(row);
    }

    auto stmt = db.prepare(`UPDATE user SET email = :email WHERE name = :name and id=:id;`);
    stmt.setParameter("email", `gao'xc@putao.com`);
    stmt.setParameter("name", "viile");
    stmt.setParameter("id", 1);
    writeln("sql : ",stmt.sql);
    writeln(stmt.execute()," affectedRows : ",stmt.affectedRows());

    Statement stmt2 = db.prepare("SELECT * FROM user");
    ResultSet rs2 = stmt2.query();

    foreach(row; rs2)
    {
        writeln(row);
    }

    db.close();
}
