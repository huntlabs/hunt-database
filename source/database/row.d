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

module database.row;

import database;

class Row 
{
	private ResultSet _resultSet;
	private string[string] vars;
	private TypeInfo[string] types;

	this(ResultSet resultSet)
	{
		this._resultSet = resultSet;
	}

	~this()
	{
	}

	void opDispatch(string name, T)(T val)
	{
		if (name in vars)
			throw new DatabaseException("field "~name~" exits");
		vars[name] = val;
	}

	void add(string name,TypeInfo type,string val)
	{
		if (name in vars)
			throw new DatabaseException("field "~name~" exits");
		vars[name] = val;
		types[name] = type;
	}

	string opDispatch(string name,string file = __FILE__,int line = __LINE__)()
	{
		if(name !in vars)
			throw new DatabaseException("no field "~name~" in result", file, line);
		return vars[name];
	}

	string opIndex(string name, string file = __FILE__, int line = __LINE__) {
		if(name !in vars)
			throw new DatabaseException("no field "~name~" in result", file, line);
		return vars[name].to!string;
	}

	override string toString()
	{
		return to!string(vars);
	}

	string[string] toStringArray() {
		return vars;
	}
}


