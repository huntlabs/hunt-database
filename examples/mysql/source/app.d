import std.stdio;
import db;

import std.experimental.logger;

void main()
{

	writeln("run");
	/*
	auto mysql = mysql_init(null);
	char value = 1; 
	mysql_options(mysql, mysql_option.MYSQL_OPT_RECONNECT, cast(char*)&value);
	size_t read_timeout = 60;
	mysql_options(mysql, mysql_option.MYSQL_OPT_READ_TIMEOUT, cast(size_t*)&read_timeout);
	mysql_options(mysql, mysql_option.MYSQL_OPT_WRITE_TIMEOUT, cast(size_t*)&read_timeout);
	mysql_real_connect(mysql, toCstring("10.1.11.31"), toCstring("dev"),
			toCstring("111111"), toCstring("blog"), 3306, null, 0);
	mysql_query(mysql, toCstring("SET NAMES 'utf8'"));
	string sql = "select * from user;";
	mysql_query(mysql, toCstring(sql));
	auto result = mysql_store_result(mysql);
	writeln(mysql_num_rows(result));

	auto r = mysql_fetch_row(result);
	if(r is null)
		throw new Exception("there is no next row");
	uint numFields = mysql_num_fields(result);
	auto lengths = mysql_fetch_lengths(result);
	writeln(numFields,lengths);
	string[] row;
	bool[] columnIsNull;
	// potential FIXME: not really binary safe

	columnIsNull.length = numFields;
	for(int a = 0; a < numFields; a++) {
		if(*(r+a) is null) {
			row ~= null;
			columnIsNull[a] = true;
		} else {
			row ~= fromCstring(*(r+a), *(lengths +a));
			//writeln("all string------", fromCstring(*(r+a)));
			//writeln("Column  ength:------", *(lengths++));
			columnIsNull[a] = false;
		}
	}
	writeln(row,columnIsNull);
	*/
	Database db = new Database("mysql://dev:111111@10.1.11.31:3306/blog?charset=utf-8");

	string sql = `insert into user(username) values("testsdf");`;
	int result = db.execute(sql);
	
	writeln(result);

	Statement statement = db.query("SELECT * FROM user");

	ResultSet rs = statement.fetchAll();

	foreach(row;rs)
	{
		writeln(row);
	}

	//db._conn.query("SELECT * from user");

	/*
	   Row[] rows = statement.fetch();
	   foreach(row; rows)
	   {
	   tracef("username: %s", row["name"]);
	   }

	   int result = db.execute("INSERT INTO users()");
	   tracef("inserted line: %s", result);

	   int result = db.execute("DELETE * FROM users WHERE id < 100");
	   tracef("deleted line: %s", result);
	 */
}
