
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

import std.variant;

void main()
{
    info("run database MySQL demo.");

    Database db = new Database("mysql://root:password@127.0.0.1:3306/mysql?charset=utf8");

    Statement stmt = db.prepare("SELECT * FROM user where User = :user");
    stmt.setParameter("user","root");

    RowSet rs = stmt.query();
    foreach(Row r; rs) {
        infof("=============: ", r.size());
        for(int i=0; i<r.size(); i++) {
            Variant v = r.getValue(i);
            tracef("column[%d]: %s, value: %s, type: %s", i, r.getColumnName(i), v.toString(), v.type);
        }

        trace(r["Host"]);
    }


    db.close();
}
