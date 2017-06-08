module db.driver.mysql.resultset;

import db;
version(USE_MYSQL): 
class MysqlResult : ResultSet 
{
	private MYSQL_RES* result;
	private int itemsTotal;
	private int itemsUsed;
	private string[] _fieldNames;
	public bool[] columnIsNull;
	public Row row;

	string sql;

	this(MYSQL_RES* res, string sql) 
	{
		this.result = res;
		this.itemsTotal = length();
		this.itemsUsed = 0;
		this.sql = sql;

		if(this.itemsTotal)
			fetchNext();
	}

	~this() 
	{
		if(this.result !is null)
			mysql_free_result(result);
	}


	MYSQL_FIELD[] fields() {
		int numFields = mysql_num_fields(result);
		auto fields = mysql_fetch_fields(result);

		MYSQL_FIELD[] ret;
		for(int i = 0; i < numFields; i++) {
			ret ~= fields[i];
		}

		return ret;
	}

	int length() {
		if(result is null)
			return 0;
		return cast(int) mysql_num_rows(result);
	}
	int columns() {
		if(result is null)return 0;
		return mysql_num_fields(result);
	}

	bool empty() 
	{
		return itemsUsed == itemsTotal;
	}

	Row front() 
	{
		return row;
	}

	void popFront() 
	{
		itemsUsed++;
		if(itemsUsed < itemsTotal) {
			fetchNext();
		}
	}

	private void fetchNext() 
	{
		assert(result);
		auto r = mysql_fetch_row(result);
		if(r is null)
			throw new Exception("there is no next row");
		uint numFields = mysql_num_fields(result);
		auto lengths = mysql_fetch_lengths(result);
		string[string] row;

		columnIsNull.length = numFields;
		string[] _fieldNames = fieldNames();
		for(int a = 0; a < numFields; a++) {
			if(*(r+a) is null) {
				row[_fieldNames[a]] = null;
				columnIsNull[a] = true;
			} else {
				row[_fieldNames[a]] = fromCstring(*(r+a), *(lengths +a));
				columnIsNull[a] = false;
			}
		}

		this.row = new Row(row);
		this.row.resultSet = this;
	}


	string[] fieldNames() {
		int numFields = mysql_num_fields(result);
		auto fields = mysql_fetch_fields(result);

		string[] names;
		for(int i = 0; i < numFields; i++) {
			names ~= fromCstring(fields[i].name, fields[i].name_length);
		}

		return names;
	}
}

