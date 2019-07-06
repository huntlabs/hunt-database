
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
import hunt.logging;

import hunt.database;

void main()
{
    writeln("run database MySQL demo.");

    Database db = new Database("mysql://dev:111111@10.1.11.31:3306/mysql?charset=utf-8");

    Statement stmt = db.prepare("SELECT * FROM user where User = :user");
    stmt.setParameter("user","root");

    writeln(stmt.sql);

    int r = stmt.execute();
    writeln(r);

    db.close();
}
