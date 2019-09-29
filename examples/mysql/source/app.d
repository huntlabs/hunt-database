
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
    info("run database MySQL demo.");

    Database db = new Database("mysql://dev:111111@10.1.11.31:3306/mysql?charset=utf8");

    Statement stmt = db.prepare("SELECT * FROM user where User = :user");
    stmt.setParameter("user","root");

    int r = stmt.execute();
    info(r);

    db.close();
}
