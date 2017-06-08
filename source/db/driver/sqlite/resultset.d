module db.driver.sqlite.resultset;

version(USE_SQLITE):
import db;
import core.stdc.string : strlen;

class SqliteResult : ResultSet
{
	private int itemsTotal;
	private int itemsUsed;
	public bool[] columnIsNull;
	private Row row;
	private sqlite3* conn;
	private sqlite3_stmt* st;
	private string sql;
	private string[] _fieldNames;
	private int _columns;
	private char** dbResult;
	private char* errmsg;
	private bool firstLine = true;
	private int nCount;
	private int index;

	this(sqlite3* conn,string sql)
	{
		this.conn = conn;
		this.sql = sql;

		writeln(sql);
		
		int res = sqlite3_get_table(conn,toStringz(sql), &dbResult, &itemsTotal, &_columns, &errmsg );
		nCount = itemsTotal * _columns;
		if(this.itemsTotal)
			fetchNext();
		
		/*
		int res = sqlite3_prepare_v2(conn, toStringz(sql),
				cast(int) sql.length + 1, &st, null);
		if (res != SQLITE_OK)
			throw new DatabaseException("prepare");
		int binds_ = sqlite3_bind_parameter_count(st);
		int nlength = 0;
		int status = SQLITE_ROW;
		while(status == SQLITE_ROW){
			status = sqlite3_step(st);
			nlength++;
		}
		writeln(__LINE__,nlength);
		int columns = sqlite3_column_count(st);
		int length = sqlite3_data_count(st);
		writeln(__LINE__,":",columns);
		writeln(__LINE__,":",length);
		for(int i = 0;i<columns * nlength;i++)
		{
			auto ptr = sqlite3_column_name(st, i);
			string type = cast(string) ptr[0 .. strlen(ptr)];
			writeln(__LINE__,":",type);
			ubyte * bytes = cast(ubyte *)sqlite3_column_blob(st, i);
			int len = sqlite3_column_bytes(st, i);
			string value = cast(string)bytes[0..len];
			writeln(__LINE__,":",value);
		}
		*/
		
	}

	~this()
	{
		sqlite3_free_table(dbResult);
		sqlite3_finalize(st);
		st = null;
	}

	string[] fieldNames()
	{
		return _fieldNames;
	}
	bool empty()
	{
		return itemsUsed == itemsTotal;
	}
	Row front()
	{
		return this.row;
	}
	void popFront()
	{
		itemsUsed++;
		if(itemsUsed < itemsTotal) {
			fetchNext();
		}
	}
	int length()
	{
		return itemsTotal;
	}
	int columns()
	{
		return _columns;
	}

	private void fetchNext()
	{
		if(firstLine)
		{
			for(int i = 0;i<_columns;i++)
			{
				_fieldNames ~= cast(string)fromStringz(dbResult[i]);
			}
			index++;
			firstLine = false;
		}
		string[string] row;
		for(int i = _columns * index;i<(_columns * (index + 1));i++)
		{
			row[_fieldNames[i % _columns ]] = cast(string)fromStringz(dbResult[i]);
		}
		index++;
		
		this.row = new Row(row);
		this.row.resultSet = this;
	}
}
