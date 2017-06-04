module db.driver.mysql.resultset;

import db;

class MySqlResult : ResultSet 
{
	private int[string] mapping;
	private MYSQL_RES* result;

	private int itemsTotal;
	private int itemsUsed;

	string sql;

	this(MYSQL_RES* r, string sql) {
		result = r;
		itemsTotal = length();
		itemsUsed = 0;
		this.sql = sql;

		// prime it
		if(itemsTotal)
			fetchNext();
	}

	~this() {
		if(result !is null)
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


	override int length() {
		if(result is null)
			return 0;
		return cast(int) mysql_num_rows(result);
	}

	override bool empty() {
		return itemsUsed == itemsTotal;
	}

	override Row front() {
		return row;
	}

	override void popFront() {
		itemsUsed++;
		if(itemsUsed < itemsTotal) {
			fetchNext();
		}
	}

	override int getFieldIndex(string field) {
		if(mapping is null)
			makeFieldMapping();
		debug {
			if(field !in mapping)
				throw new Exception(field ~ " not in result");
		}
		return mapping[field];
	}

	private void makeFieldMapping() {
		int numFields = mysql_num_fields(result);
		auto fields = mysql_fetch_fields(result);

		if(fields is null)
			return;

		for(int i = 0; i < numFields; i++) {
			if(fields[i].name !is null)
				mapping[fromCstring(fields[i].name, fields[i].name_length)] = i;
		}
	}

	private void fetchNext() {
		assert(result);
		auto r = mysql_fetch_row(result);
		if(r is null)
			throw new Exception("there is no next row");
		uint numFields = mysql_num_fields(result);
		auto lengths = mysql_fetch_lengths(result);
		string[] row;
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

		this.row.row = row;
		this.row.resultSet = this;
	}


	override string[] fieldNames() {
		int numFields = mysql_num_fields(result);
		auto fields = mysql_fetch_fields(result);

		string[] names;
		for(int i = 0; i < numFields; i++) {
			names ~= fromCstring(fields[i].name, fields[i].name_length);
		}

		return names;
	}



	bool[] columnIsNull;
	Row row;
}

