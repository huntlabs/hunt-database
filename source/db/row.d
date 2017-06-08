module db.row;

import db;

string yield(string what) { return `if(auto result = dg(`~what~`)) return result;`; }

class Row 
{
	public string[string] row;
	public ResultSet resultSet;

	this(string[string] row)
	{
		this.row = row;
	}

	~this()
	{
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


