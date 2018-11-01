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

module hunt.database.Statement;

import hunt.database;

import std.stdio;

class Statement
{
    private Connection _conn = null;
    private string _sql;
    private bool _isUsed = false;
    private int _lastInsertId;
	private int _affectRows;
    private ResultSet _rs;
	private ExprElement[] sql_prepare;
	private string[string] param_value;

    this(Connection conn)
    {
        _conn = conn;
    }

    this(Connection conn, string sql)
    {
        _conn = conn;
        prepare(sql);
    }

    void prepare(string sql)
    {
		assert(sql.length);
        this._sql = sql;
        sql ~= " ";
		int length = cast(int)sql.length;
		int index = 0;
        auto expr = new ExprStatus;
		while(index < length){
            auto status = expr.append(sql[index]);
            if(status){
                sql_prepare ~= ExprElement(cast(ExprElementType)status,expr.result);
                if(status == ExprElementType.key){
                    param_value[expr.result] = expr.result;
                }
            }
           index++; 
		}
    }

    void setParameter(T = string)(string key, T value)
    {
        assert(key in param_value);
        param_value[key] = _conn.escapeLiteral(value.to!string);
    }

    string sql()
    {
        string str;
        foreach(element;sql_prepare){
            if(element.type == ExprElementType.key){
                str ~= param_value[element.value] ~ " ";
            }else{
                str ~= element.value ~ " ";
            }
        }
        _sql = str;
        return _sql;
    }

    int execute()
    {
        isUsed();
        assert(sql);
        log(sql);
        int status = this._conn.execute(sql);
        _lastInsertId = this._conn.lastInsertId();
		_affectRows = this._conn.affectedRows();
        // return status;
        return _affectRows;
    }

    int count()
    {
        isUsed();
        assert(sql);
        auto r = this._conn.query(sql);
        auto res = r.front();
        return res[0].to!int;
    }

    int lastInsertId()
    {
        return _lastInsertId;    
    }
    
	int affectedRows()
    {
        return _affectRows;    
    }
    
    Row fetch()
    {
        if(!_rs)_rs = query();
        scope(exit){
            if(!_rs.empty)
                _rs.popFront();
            else 
                throw new DatabaseException("ResultSet is empty");
        }
        return _rs.front();
    }

    ResultSet query()
    {
        isUsed();
        assert(sql);
        _rs = this._conn.query(sql);
        return _rs;
    }

    void close()
    {

    }

    private void isUsed()
    {
        scope(exit)_isUsed=true;
        if(_isUsed)throw new DatabaseException("statement was used");
    }

}

struct ExprElement
{
    ExprElementType type;
    string value;
}

enum ExprElementType : uint {
	start = 0,
	element = 1,
	key = 2
}

class ExprStatus
{
	ExprElementType type = ExprElementType.start;
	string result;
	char[] buf;
	

	int append(char c)
	{
		if(type == ExprElementType.start){
            buf ~= c;
			if(c == ' '){				
				type = ExprElementType.element;
			}else if(c == ':'){
				type = ExprElementType.key;
			}else{
				type = ExprElementType.element;
			}
		}else if(type == ExprElementType.element){
			if(c == ' '){				
                result = cast(string)buf;
                buf = [];
                type = ExprElementType.start;
                return cast(int)ExprElementType.element;
            }else{
                buf ~= c;
            }
		}else{
			if(c == ' '){				
                result = cast(string)buf;
                buf = [];
                type = ExprElementType.start;
                return cast(int)ExprElementType.key;
            }else{
                buf ~= c; 
            }
		}
		return cast(int)ExprElementType.start;
	}
}
