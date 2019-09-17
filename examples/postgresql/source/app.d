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
import std.datetime;

void main() {
    writeln("run Database for PostgreSQL demo.");

    Database db = new Database(
            "postgresql://postgres:123456@10.1.11.44:5432/postgres?charset=utf-8");

    string sql = `DELETE From public.test where id=1;`;
    int result = db.execute(sql);
    tracef("result: %d", result);

    // 
    writeln("===============================");

    sql = `INSERT INTO public.test(id, val) VALUES (1, 1);`;
    result = db.execute(sql);
    tracef("result: %d", result);

    // 
    writeln("===============================");
    DateTime dt = cast(DateTime) Clock.currTime;
    Statement statement = db.prepare("Update test SET val = ':val' where id=:id");
    statement.setParameter("id", 1);
    statement.setParameter("val", dt.toISOExtString());
    result = statement.execute();
    tracef("result: %d", result);

    //
    writeln("===============================");
    statement = db.prepare("SELECT * FROM public.test where id=:id limit 10");
    statement.setParameter("id", 1);
    RowSet rs = statement.query();

    foreach (row; rs) {
        writeln(row);
    }

    db.close();
    getchar();
}
