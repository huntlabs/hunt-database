module db.driver.connection;

import db;

interface Connection
{
	// return affected line quantity
	int execute(string sql);

	// return Statement object
	ResultSet queryImpl(string sql, Variant[] args...);

	string escape(string sql);

	void close();


	final ResultSet query(T...)(string sql, T t) {
		Variant[] args;
		foreach(arg; t) {
			Variant a;
			static if(__traits(compiles, a = arg))
				a = arg;
			else
				a = to!string(t);
			args ~= a;
		}
		return queryImpl(sql, args);
	}
}
