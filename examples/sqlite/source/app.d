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

import std.stdio;

import database;

void main()
{
	DatabaseOption options = new DatabaseOption("sqlite:///./testDB.db");
	Database db = new Database(options);

	string sql = `insert into test(name,pass,age) values("testsdf","123",12);`;

    db.execute(sql);

	Statement statement = db.query("SELECT * FROM test");

	ResultSet rs = statement.fetchAll();

    
	foreach(row;rs)
	{
		writeln(row);
	}

	db.close();
}
