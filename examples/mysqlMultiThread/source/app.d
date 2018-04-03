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
import std.conv;
import std.process;
import std.parallelism;

import core.thread;

import database;

void main()
{
    writeln("run");

    __gshared Database db;
    __gshared DatabaseOption options;

    options = (new DatabaseOption())
        .addDatabaseSource("mysql://root:123456@localhost:3306/blog?charset=utf-8")
        .setMaximumConnection(20)
        .setConnectionTimeout(5000);

    db = new Database(options);

    int i = 0;
    while(i < 1000)
    {
        taskPool.put(task!threadTest(db,i));
        i++;
    }

    taskPool.finish(true);

    db.close();
}

void threadTest(Database db, int i)
{
    writeln("start.........", thisThreadID);
    string key = i.to!string;
    string sql = `INSERT INTO user(username) VALUES("`~key~`");`;
    db.execute(sql);

    Statement statement = db.prepare("SELECT * FROM user WHERE username = '"~key~"' LIMIT 10");

    ResultSet rs = statement.query();

    foreach(row; rs)
    {
        writeln(row);
    }

    writeln("end...",thisThreadID);
}
