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
	int rows()
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
