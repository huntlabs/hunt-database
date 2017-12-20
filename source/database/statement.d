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
	private string[] sql_prepare;
	private int[string] param_key;
	private string[string] param_value;
    
    this(Pool pool)
    {
        this._pool = pool;
    }

    this(Pool pool,string sql)
    {
        this._pool = pool;
        this._sql = sql;
    }

	this(Pool pool,Connection conn,string sql)
	{
		this._pool = pool;
		this._conn = conn;
		this._sql = sql;
		this._isTransaction = true;
	}

    void prepare(string sql)
    {
		assert(sql.length);
        this._sql = sql;
		int length = cast(int)sql.length;
		int index = 0;
		while(index < length){
			
		}
    }

    void setParameter(T = string)(string key, T value)
    {
        // bind param value to sql
    }

    string sql()
    {
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

enum ExprElementType : uint {
	start = 0,
	element = 1,
	key = 2
}

class exprStatus
{
	ExprElementType type = ExprElementType.start;
	string result;
	char[] buf;
	

	int append(char c)
	{
		if(type == ExprElementType.start){
			if(c == ' '){				
			}else if(c == ':'){
				type = ExprElementType.key;

			}else{
				type = ExprElementType.element;
			}
			
		}else if(type == ExprElementType.element){

		
		}else{
		
		}

		return 0;
	}
}
