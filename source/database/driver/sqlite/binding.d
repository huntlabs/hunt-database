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

module database.driver.sqlite.binding;

version(USE_SQLITE):

auto fromSQLType(uint type)
{
    return typeid(string);
}

public import etc.c.sqlite3;
