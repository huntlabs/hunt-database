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

module database.statement;

import database;

class Statement
{
    private Pool _pool;
    private Connection _conn = null;
    private string _sql;
    private bool _isUsed = false;
	private bool _isTransaction = false;
    private int _lastInsertId;
	private int _affectRows;
    private ResultSet _rs;
	private ExprElement[] sql_prepare;
	private string[string] param_value;

    this(Pool pool)
    {
        this._pool = pool;
        this._conn = pool.getConnection();
    }

    this(Pool pool,string sql)
    {
        this._pool = pool;
        this._conn = pool.getConnection();
        prepare(sql);
    }

	this(Pool pool,Connection conn,string sql)
	{
		this._pool = pool;
		this._conn = conn;
        prepare(sql);
		this._isTransaction = true;
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
        scope(exit){releaseConnection();}
        int status = getConnection.execute(sql);
        _lastInsertId = getConnection.lastInsertId();
		_affectRows = getConnection.affectedRows();
        return status;
    }

    int count()
    {
        isUsed();
        assert(sql);
        scope(exit){releaseConnection();}
        auto r = getConnection.query(sql);
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
        _conn = _pool.getConnection();
        scope(exit){_pool.release(_conn);}
        _rs = _conn.query(sql);
        return _rs;
    }

    void close()
    {

    }

	private Connection getConnection()
	{
		if(_conn is null)	
			_conn = _pool.getConnection();
		return _conn;
	}

	private void releaseConnection()
	{
		if(!_isTransaction && _conn !is null)
			_pool.release(_conn);
	}

    private void isUsed()
    {
        scope(exit)_isUsed=true;
        if(_isUsed)throw new DatabaseException("statement was used");
    }
    ~this()
    {
        _conn = null;
        _sql = null;
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
