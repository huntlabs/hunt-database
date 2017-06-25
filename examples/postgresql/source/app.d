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
    writeln("run Database for PostgreSQL demo.");

    Database db = new Database("postgresql://postgres:123456@localhost:5432/test?charset=utf-8");

    string sql = `INSERT INTO public.test(id, name) VALUES (1, 1);`;
    int result = db.execute(sql);
    writeln(result);
    
    Statement statement = db.query("SELECT * FROM public.test");

    ResultSet rs = statement.fetchAll();

    foreach(row; rs)
    {
        writeln(row);
    }

    db.close();
}
