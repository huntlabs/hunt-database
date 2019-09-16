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
    writeln("run Database for PostgreSQL demo.");

    Database db = new Database("postgresql://postgres:123456@10.1.11.44:5432/postgres?charset=utf-8");

    string sql = `INSERT INTO public.test(id, val) VALUES (1, 1);`;
    int result = db.execute(sql);
    tracef("result: %d", result);
    
    // Statement statement = db.prepare("SELECT * FROM public.test limit 10");

    // ResultSet rs = statement.query();

    // foreach(row; rs)
    // {
    //     writeln(row);
    // }

    db.close();
    getchar();
}
