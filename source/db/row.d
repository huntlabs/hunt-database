module db.row;

import db;

string yield(string what) { return `if(auto result = dg(`~what~`)) return result;`; }

class Row 
{
	string[] row;
	ResultSet resultSet;

	string opIndex(size_t idx, string file = __FILE__, int line = __LINE__) {
		if(idx >= row.length)
			throw new Exception(text("index ", idx, " is out of bounds on result"), file, line);
		return row[idx];
	}

	string opIndex(string name, string file = __FILE__, int line = __LINE__) {
		auto idx = resultSet.getFieldIndex(name);
		if(idx >= row.length)
			throw new Exception(text("no field ", name, " in result"), file, line);
		return row[idx];
	}

	override string toString() {
		return to!string(row);
	}

	string[string] toAA() {
		string[string] a;

		string[] fn = resultSet.fieldNames();

		foreach(i, r; row)
			a[fn[i]] = r;

		return a;
	}

	int opApply(int delegate(ref string, ref string) dg) {
		foreach(a, b; toAA())
			mixin(yield("a, b"));

		return 0;
	}

	string[] toStringArray() {
		return row;
	}
}


