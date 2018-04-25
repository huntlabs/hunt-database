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

module database.driver.mysql.resultset;

import database;

version(USE_MYSQL):

class MysqlResult : ResultSet 
{
    private MYSQL_RES* result;
    private int _rows;
    private int _columns;
    private int fetchIndex = 0;
    private string[] _fieldNames;
    private uint[] _fieldTypes;
    private string _sql;

    public Row row;

    this(MYSQL_RES* res, string sql) 
    {
        this.result = res;
        rows();
        columns();
        fields();
        this._sql = sql;

        if(this._rows)
            fetchNext();
    }

    ~this() 
    {
        if(this.result !is null)
            mysql_free_result(result);
    }

    int rows()
	{
        if(result is null)return 0;
        if(!_rows)_rows = cast(int) mysql_num_rows(result);
        return _rows;
    }

    int columns()
	{
        if(result is null)return 0;
        if(!_columns)_columns = cast(int) mysql_num_fields(result);
        return _columns;
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
        if(fetchIndex < _rows) {
            fetchNext();
        }
    }

    private void fetchNext() 
    {
        assert(result);
        auto r = mysql_fetch_row(result);
        if(r is null)
            throw new DatabaseException("there is no next row");
        auto lengths = mysql_fetch_lengths(result);
        
        auto row = new Row(this);
        for(int a = 0; a < _columns; a++) {
            auto key = _fieldNames[a];
            auto type = fromSQLType(_fieldTypes[a]);
            auto value = (*(r+a) is null) ? null : fromCstring(*(r+a), *(lengths +a));
            row.add(key,type,value);
        }
        this.row = row;
    }


    void fields() 
    {
        if(result is null)return;
        auto fields = mysql_fetch_fields(result);

        for(int i = 0; i < _columns; i++) {
            _fieldNames ~= fromCstring(fields[i].name, fields[i].name_length);
            _fieldTypes ~= fields[i].type;
        }

    }

    string[] fieldNames()
    {
        return _fieldNames;
    }
}

