module db.row;

import db;

string yield(string what) { return `if(auto result = dg(`~what~`)) return result;`; }

class Row 
{
	private string[string] row;
	private ResultSet _resultSet;
	public Variant[string] vars;

	this(string[string] row)
	{
		this.row = row;
	}

	this(ResultSet resultSet)
	{
		this._resultSet = resultSet;
	}

	~this()
	{
	}

	void opDispatch(string name, T)(T val)
	{
		if (name !in vars)
			vars[name] = Variant();
		vars[name] = val;
	}
	void add(T)(string name,T val)
	{
		if (name !in vars)
			vars[name] = Variant();
		vars[name] = val;
	}
	Variant opDispatch(string name)()
	{
		if(name in vars)
			return Variant(vars[name]);
		return Variant.init;
	}
	string opIndex(string name, string file = __FILE__, int line = __LINE__) {
		if(name !in row)
			throw new DatabaseException(text("no field ", name, " in result"), file, line);
		return row[name];
	}

	override string toString() {
		return to!string(row);
	}

	int opApply(int delegate(ref string, ref string) dg) {
		foreach(a, b; toStringArray())
			mixin(yield("a, b"));

		return 0;
	}

	string[string] toStringArray() {
		return row;
	}
}


