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

module database.driver.sqlite.resultset;

version(USE_SQLITE):

import database;

import core.stdc.string : strlen;

class SqliteResult : ResultSet
{
    private sqlite3* conn;
    private sqlite3_stmt* st;
    private string sql;
    private string[] _fieldNames;
    private int _columns;
    private int _rows;
    private char** dbResult;
    private char* errmsg;
    private bool firstLine = true;
    private int nCount;
    private int fetchIndex;
    private int index;
    
    public Row row;

    this(sqlite3* conn,string sql)
    {
        this.conn = conn;
        this.sql = sql;

        int res = sqlite3_get_table(conn,toStringz(sql), &dbResult, &_rows, &_columns, &errmsg);
        if(res != SQLITE_OK)
            throw new DatabaseException("sqlite get data error");
        nCount = _rows * _columns;
        if(this._rows)
            fetchNext();
    }

    ~this()
    {
        sqlite3_free_table(dbResult);
        sqlite3_free(errmsg);
        sqlite3_finalize(st);
        dbResult = null;
        st = null;
        errmsg = null;
    }

    string[] fieldNames()
    {
        return _fieldNames;
    }
    bool empty()
    {
        return fetchIndex == _rows;
    }
    Row front()
    {
        return this.row;
    }
    void popFront()
    {
        fetchIndex++;
        if(fetchIndex < _rows) {
            fetchNext();
        }
    }
    int rows()
    {
        return _rows;
    }
    int columns()
    {
        return _columns;
    }

    private void fetchNext()
    {
        if(firstLine)
        {
            for(int i = 0;i<_columns;i++)
            {
                _fieldNames ~= cast(string)fromStringz(dbResult[i]);
            }
            index++;
            firstLine = false;
        }
        auto row = new Row(this);
        for(int i = _columns * index;i<(_columns * (index + 1));i++)
        {
            //row[_fieldNames[i % _columns ]] = cast(string)fromStringz(dbResult[i]);
            auto key = _fieldNames[i % _columns ];
            auto type = typeid(string);
            auto value = cast(string)fromStringz(dbResult[i]);
            row.add(key,type,value);
        }
        index++;
        this.row = row;
    }
}
