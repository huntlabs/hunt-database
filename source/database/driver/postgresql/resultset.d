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

module database.driver.postgresql.resultset;

import database;
version(USE_POSTGRESQL):

class PostgresqlResult : ResultSet 
{
    private PGresult* res;
    private Describe[] describes;
    private string[] fields;
    private int[] fieldTypes;
    private int _rows;
    private int fetchIndex;
    private int _columns;
    public bool[] columnIsNull;
    public Row row = null;

    this(PGresult* res)
    {
        this.res = res;
        _columns = columns();
        _rows = rows();
        makeFieldInfo();
        if(this._rows)
            fetchNext();
    }
    ~this()
    {
        PQclear(res);    
    }
    void makeFieldInfo()
    {
        for (int col = 0; col < _columns; col++) 
        {
            Describe d = Describe();
            d.dbType = cast(int) PQftype(res, col);
            d.fmt = PQfformat(res, col);
            d.name = to!string(PQfname(res, col));
            this.describes ~= d;
            this.fields ~= d.name;
            this.fieldTypes ~= d.dbType;
        }
    }
    string[] fieldNames()
    {
        return fields;
    }
    bool empty()
    {
        return fetchIndex == _rows;
    }
    Row front()
    {
        return row;
    }
    void popFront()
    {
        fetchIndex++;
        if(fetchIndex < _rows) 
        {
            fetchNext();
        }
    }
    int columns()
    {
        if(res is null)return 0;
        return PQnfields(res);
    }
    int rows()
    {
        if(res is null)return 0;
        return PQntuples(res);
    }

    private void fetchNext()
    {
        auto row = new Row(this);
        for(int n=0;n<_columns;n++){
            void* dt = PQgetvalue(res, fetchIndex, n);
            int len = PQgetlength(res, fetchIndex,n);
            immutable char* ptr = cast(immutable char*) dt;
            auto key = fieldNames[n];
            auto type = fromSQLType(fieldTypes[n]);
            string value = cast(string) ptr[0 .. len];
            row.add(key,type,value);
        }
        this.row = row;
    }
}
struct Describe 
{
    int dbType;
    int fmt;
    string name;
}

enum ValueType {
    Char,

    Short,
    Int,
    Long,

    Float,
    Double,

    String,

    Date,
    Time,
    DateTime,

    Raw,

    UNKnown
}

struct Bind 
{
    ValueType type;
    int idx;
}
