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

module database.driver.resultset;

import database;

interface ResultSet {
    string[] fieldNames();
    bool empty() @property;
    Row front() @property;
    void popFront() ;
    int rows() @property;
    int columns() @property;
}
