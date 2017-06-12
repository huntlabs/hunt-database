import std.stdio;
import db;

import std.conv;
import core.thread;
import std.parallelism;

void main()
{
	writeln("run");

	__gshared Database db;
	db = new Database("mysql://dev:111111@10.1.11.31:3306/blog?charset=utf-8");

	string sql = `insert into user(username) values("testsdf");`;


	int i = 0;
	while(i < 10){
		taskPool.put(task!threadTest(db,i));
		i++;
	}

	Thread.sleep(10.seconds);
	
	db.close();
	
	writeln("end...");
}
void threadTest(Database db,int i)
{
	db.execute(`insert into user(username) values("`~i.to!string~`");`);

	Statement statement = db.query("SELECT * FROM user");

	//ResultSet rs = statement.fetchAll();

	//foreach(row;rs)
	//{
		//writeln(row);
	//}

}
