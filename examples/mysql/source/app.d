
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

    Database db = new Database("mysql://putao:putao123@10.1.11.17:3306/PaiBot?charset=utf-8");

    int result = db.execute(`insert into ugc_common_response(rid, response, weight, age, roleid, rolename, groupid) values(1106, 'you are welcome', 34, 18, 1037, 'man', 56);`);
    writeln(result);

    Statement stmt = db.prepare("SELECT * FROM ugc_common_response LIMIT 10");


    ResultSet rs = stmt.query();


    foreach(row; rs)
    {
        writeln(row.response);
    }

    auto tran = db.beginTransaction();
    tran.execute("insert into blog(uid,title,content) values(12,'111111dddd','fffffff');");
    tran.rollback();
    db.close();
}
