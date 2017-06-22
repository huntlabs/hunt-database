import std.stdio;
import db;

import std.conv;
import core.thread;
import std.process;
import std.parallelism;

void main()
{
	writeln("run");

	__gshared Database db;
	__gshared DatabaseConfig config;
	config = (new DatabaseConfig())
		.addDatabaseSource("mysql://dev:111111@10.1.11.31:3306/blog?charset=utf-8")
		.setMaxConnection(20)
		.setConnectionTimeout(5000);
	db = new Database(config);

	int i = 0;
	while(i < 1000){
		taskPool.put(task!threadTest(db,i));
		i++;
	}
	taskPool.finish(true);
	db.close();
}
void threadTest(Database db,int i)
{
	writeln("start.........",thisThreadID);
	string key = i.to!string;
	string sql = `insert into user(username) values("`~key~`");`;
	db.execute(sql);

	Statement statement = db.query("SELECT * FROM user where username = '"~key~"' limit 10");

	ResultSet rs = statement.fetchAll();
	auto user  = statement.fetch();
	user['id'];
	foreach(row;rs)
	{
		writeln(row);
	}
	writeln("end...",thisThreadID);
}
