module db.driver.mysql.connection;

import db;

class MysqlConnection : Connection
{
	public string dbname;
	private URL _url;
	private string _host;
	private string _user;
	private string _pass;
	private string _db;
	private uint _port;
	private QueryParams _querys;
	private MYSQL* mysql;

	this(URL url) 
	{
		this._url = url;
		this._port = url.port;
		this._host = url.host;
		this._user = url.user;
		this._db = (url.path)[1..$];
		this._pass = url.pass;
		this._querys = url.queryParams;
		this.dbname = this._db;
		connect();
		auto charset = _querys["charset"];
		if(!charset.empty())
			execute("SET NAMES '"~ charset.front ~"'");
	}

	~this() 
	{
	}

	private void connect()
	{
		try{
			mysql = mysql_init(null);
			char value = 1; 
			mysql_options(mysql, mysql_option.MYSQL_OPT_RECONNECT, cast(char*)&value);
			size_t read_timeout = 60;
			mysql_options(mysql, mysql_option.MYSQL_OPT_READ_TIMEOUT, cast(size_t*)&read_timeout);
			mysql_options(mysql, mysql_option.MYSQL_OPT_WRITE_TIMEOUT, cast(size_t*)&read_timeout);
			mysql_real_connect(mysql, toCstring(_host), toCstring(_user), 
					toCstring(_pass), toCstring(_db), _port, null, 0);
		}
		catch(DatabaseException ex)
		{
			std.stdio.writeln(error());
		}
	}

	int execute(string sql)
	{
		return mysql_query(mysql, toCstring(sql));
	}

	void startTransaction() 
	{
		query("START TRANSACTION");
	}

	string clientInfo()
	{
		return fromCstring(mysql_get_client_info());
	}

	string error() 
	{
		return fromCstring(mysql_error(mysql));
	}
	void close() 
	{
		try{
			mysql_close(mysql);
		}catch(Exception ex)
		{
		}
	}
	int pingMysql()
	{
		return mysql_ping(mysql);
	}

	size_t getThreadId()
	{
		return mysql_thread_id(mysql);
	}

	public int lastInsertId() 
	{
		return cast(int) mysql_insert_id(mysql);
	}
	string escape(string str) 
	{
		ubyte[] buffer = new ubyte[str.length * 2 + 1];
		buffer.length = mysql_real_escape_string(mysql, buffer.ptr, cast(cstring) str.ptr, cast(uint) str.length);
		return cast(string) buffer;
	}

	string escaped(T...)(string sql, T t) 
	{
		static if(t.length > 0) {
			string fixedup;
			int pos = 0;


			void escAndAdd(string str, int q) {
				ubyte[] buffer = new ubyte[str.length * 2 + 1];
				buffer.length = mysql_real_escape_string(mysql, buffer.ptr, cast(cstring) str.ptr, str.length);

				fixedup ~= sql[pos..q] ~ '\'' ~ cast(string) buffer ~ '\'';

			}

			foreach(a; t) {
				int q = sql[pos..$].indexOf("?");
				if(q == -1)
					break;
				q += pos;

				static if(__traits(compiles, t is null)) {
					if(t is null)
						fixedup  ~= sql[pos..q] ~ "NULL";
					else
						escAndAdd(to!string(*a), q);
				} else {
					string str = to!string(a);
					escAndAdd(str, q);
				}

				pos = q+1;
			}

			fixedup ~= sql[pos..$];

			sql = fixedup;

		}

		return sql;
	}

	ResultByDataObject!R queryDataObject(R = DataObject, T...)(string sql, T t) 
	{
		// modify sql for the best data object grabbing
		sql = fixupSqlForDataObjectUse(sql);
		//import std.stdio;
		//writeln(sql);
		auto magic = query(sql, t);
		//writeln("------------------------");
		return ResultByDataObject!R(cast(MySqlResult) magic, this);
	}


	ResultByDataObject!R queryDataObjectWithCustomKeys(R = DataObject, T...)
		(string[string] keyMapping, string sql, T t) 
		{
			sql = fixupSqlForDataObjectUse(sql, keyMapping);

			auto magic = query(sql, t);
			return ResultByDataObject!R(cast(MySqlResult) magic, this);
		}

	int affectedRows() 
	{
		return cast(int) mysql_affected_rows(mysql);
	}

	override ResultSet queryImpl(string sql, Variant[] args...) 
	{
		//writeln(__FUNCTION__,__LINE__,sql);
		import std.stdio;

		sql = escapedVariants(this, sql, args);

		try{
			mysql_query(mysql, toCstring(sql));
		}
		catch(DatabaseException ex)
		{
			std.stdio.writeln( ex.msg, " :::: " , sql);
		}
		//writeln(__FUNCTION__,__LINE__,sql);
		return new MySqlResult(mysql_store_result(mysql), sql);
	}
}

string escapedVariants(Connection conn, in string sql, Variant[string] t) {
	if(t.keys.length <= 0 || sql.indexOf("?") == -1) {
		return sql;
	}

	string fixedup;
	int currentStart = 0;
	// FIXME: let's make ?? render as ? so we have some escaping capability
	foreach(int i, dchar c; sql) {
		if(c == '?') {
			fixedup ~= sql[currentStart .. i];

			int idxStart = i + 1;
			int idxLength;

			bool isFirst = true;

			while(idxStart + idxLength < sql.length) {
				char C = sql[idxStart + idxLength];

				if((C >= 'a' && C <= 'z') || (C >= 'A' && C <= 'Z') || C == '_' || (!isFirst && C >= '0' && C <= '9'))
					idxLength++;
				else
					break;

				isFirst = false;
			}

			auto idx = sql[idxStart .. idxStart + idxLength];

			if(idx in t) {
				fixedup ~= toSql(conn, t[idx]);
				currentStart = idxStart + idxLength;
			} else {
				// just leave it there, it might be done on another layer
				currentStart = i;
			}
		}
	}

	fixedup ~= sql[currentStart .. $];

	return fixedup;
}

string toSql(Connection conn, Variant a) {
	auto v = a.peek!(void*);
	if(v && (*v is null))
		return "NULL";
	else {
		string str = to!string(a);
		return '\'' ~ conn.escape(str) ~ '\'';
	}

	assert(0);
}

string toSql(string s, Connection conn) {
	if(s is null)
		return "NULL";
	return '\'' ~ conn.escape(s) ~ '\'';
}

string toSql(long s, Connection conn) {
	return to!string(s);
}

string escapedVariants(Connection conn, in string sql, Variant[] t) 
{
	if(t.length > 0 && sql.indexOf("?") != -1) {
		string fixedup;
		int currentIndex;
		int currentStart = 0;
		foreach(int i, dchar c; sql) {
			if(c == '?') {
				fixedup ~= sql[currentStart .. i];

				int idx = -1;
				currentStart = i + 1;
				if((i + 1) < sql.length) {
					auto n = sql[i + 1];
					if(n >= '0' && n <= '9') {
						currentStart = i + 2;
						idx = n - '0';
					}
				}
				if(idx == -1) {
					idx = currentIndex;
					currentIndex++;
				}

				if(idx < 0 || idx >= t.length)
					throw new Exception("SQL Parameter index is out of bounds: " ~ to!string(idx) ~ " at `"~sql[0 .. i]~"`");

				fixedup ~= toSql(conn, t[idx]);
			}
		}

		fixedup ~= sql[currentStart .. $];

		return fixedup;
	}

	return sql;
}

cstring toCstring(string c) {
	return cast(cstring) toStringz(c);
}


string fromCstring(cstring c, size_t len = size_t.max) {
	string ret;
	if(c is null)
		return null;
	if(len == 0)
		return "";
	if(len == size_t.max) {
		auto iterator = c;
		len =0;
		while(*iterator)
		{
			iterator++;

			// note they are both byte pointers, so this is sane
			//len = cast(int) iterator - cast(int) c;
			len++;
		}
		assert(len >= 0);
	}

	ret = cast(string) (c[0 .. len].idup);

	return ret;
}

