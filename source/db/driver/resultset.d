module db.driver.resultset;

import db;

interface ResultSet {
	string[] fieldNames();
	bool empty() @property;
	Row front() @property;
	void popFront() ;
	int length() @property;
	int columns() @property;
}
