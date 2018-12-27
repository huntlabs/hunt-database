
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

import hunt.database;

void main()
{
    writeln("run database MySQL demo.");

    Database db = new Database("mysql://putao:putao123@10.1.11.17:3306/PaiBot?charset=utf-8");

    Statement stmt = db.prepare("SELECT * FROM ugc_common_response where username = :username and age = :age");
    stmt.setParameter(":username","viile");
    stmt.setParameter(":age",10);

    writeln(stmt.sql);

    db.close();
}
