module db.resultset.resultset;

import db;

interface ResultSet {
	// name for associative array to result index
	int getFieldIndex(string field);
	string[] fieldNames();

	// this is a range that can offer other ranges to access it
	bool empty() @property;
	Row front() @property;
	void popFront() ;
	int length() @property;

	/* deprecated */ final ResultSet byAssoc() { return this; }
}
