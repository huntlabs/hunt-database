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

module database.driver.connection;

import database;

interface Connection
{
    // return affected line quantity
    int execute(string sql);

    int lastInsertId();
    int affectedRows();

    // return Statement object
    ResultSet queryImpl(string sql, Variant[] args...);

    void close();

    void ping();

    string escape(string sql);

    ResultSet query(T...)(string sql, T t)
    {
        Variant[] args;
        foreach(arg; t) {
            Variant a;
            static if(__traits(compiles, a = arg))
                a = arg;
            else
                a = to!string(t);
            args ~= a;
        }
        return queryImpl(sql, args);
    }
}
