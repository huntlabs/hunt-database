module db.driver.mysql.resultset;

import db;
version(USE_MYSQL): 
class MysqlResult : ResultSet 
{
	private MYSQL_RES* result;
	private int _rows;
	private int _columns;
	private int fetchIndex = 0;
	private string[] _fieldNames;
	private string _sql;

	public Row row;

	this(MYSQL_RES* res, string sql) 
	{
		this.result = res;
		this._rows = rows();
		this._columns = columns();
		this._fieldNames = fieldNames();
		this._sql = sql;

		if(this._rows)
			fetchNext();
	}

	~this() 
	{
		if(this.result !is null)
			mysql_free_result(result);
	}

	int rows() {
		if(result is null)return 0;
		return cast(int) mysql_num_rows(result);
	}
	int columns() {
		if(result is null)return 0;
		return cast(int) mysql_num_fields(result);
	}

	bool empty() 
	{
		return fetchIndex == _rows;
	}

	Row front() 
	{
		return row;
	}

	void popFront() 
	{
		fetchIndex++;
		if(fetchIndex < _rows) {
			fetchNext();
		}
	}

	private void fetchNext() 
	{
		assert(result);
		auto r = mysql_fetch_row(result);
		if(r is null)
			throw new DatabaseException("there is no next row");
		auto lengths = mysql_fetch_lengths(result);
		
		string[string] row;
		for(int a = 0; a < _columns; a++) {
			row[_fieldNames[a]] = (*(r+a) is null) ? null : fromCstring(*(r+a), *(lengths +a));
		}

		this.row = new Row(row);
		this.row.resultSet = this;
	}


	string[] fieldNames() 
	{
		auto fields = mysql_fetch_fields(result);

		string[] names;
		for(int i = 0; i < _columns; i++) {
			names ~= fromCstring(fields[i].name, fields[i].name_length);
		}

		return names;
	}
}

