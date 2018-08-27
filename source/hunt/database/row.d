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

module hunt.database.row;

import hunt.database;

import std.algorithm.comparison;
import std.regex;




public class RowDataS {
	string name;
	string value;
	TypeInfo type;
} 

public class RowData {
	RowDataS[string] _data;
	void addData(string name, RowDataS data) {
		_data[name] = data;
	}
	RowDataS getData(string name) {
		return _data.get(name, null);
	}
	RowDataS[string] getAllData() {return _data;}
}

class Row 
{
	private ResultSet _resultSet;
	private string[string] vars;
	private TypeInfo[string] types;

	RowData[string] rowData;

	private int count;

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
		auto nameFields = split(name, "__");
		if (nameFields.length == 3 && nameFields[1] == "as") {
			RowDataS data = new RowDataS;
			data.type = type;
			data.value = val;
			if (nameFields[0] !in rowData)
				rowData[nameFields[0]] = new RowData();
			rowData[nameFields[0]].addData(nameFields[2], data); 
		}
	}

	RowData getAllRowData(string table) {
		return rowData.get(table, null);
	}


	string opDispatch(string name, string file = __FILE__,int line = __LINE__)()
	{
		if(name !in vars)
			throw new DatabaseException("no field "~name~" in result", file, line);
		return vars[name];
	}
	
	string opIndex(int index,string file = __FILE__,int line = __LINE__) {
		int i = 0;
		foreach(k,v;vars){
			if(i == index)
				return v;
			i++;
		}
		throw new DatabaseException("no index "~index.to!string~" in result", file, line);
	}

	string opIndex(string name, string file = __FILE__, int line = __LINE__) {
		if(name !in vars)
			throw new DatabaseException("no field "~name~" in result", file, line);
		return vars[name].to!string;
	}

	bool exist(string name) {
		return (name in vars) !is null;
	}

	ulong getSize() {
		return vars.length;
	}

	override string toString()
	{
		return to!string(vars);
	}

	string[string] toStringArray() {
		return vars;
	}
}


