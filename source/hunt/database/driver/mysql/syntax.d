module hunt.database.driver.mysql.syntax;

import hunt.database;
import hunt.sql;

class MySqlSyntax : SqlSyntax
{
	SqlBuilder _builder;

	SQLBuilder _sqlBuilder;

	this(MySqlBuilder builder)
	{
		this._builder = builder;
	}

	string selectExpr()
	{
		string select;
		if(!_builder.selectKeys.length) {
			if (_builder.getDistinct()) {
				select ~= "DISTINCT * ";
			}
			else {
				select = " * ";
			}
		}
		else {
			foreach(v;_builder.selectKeys){
				select ~= v ~ ",";
			}
			select = select[0 .. $-1];
			if (_builder.selectKeys.length == 1 && _builder.getDistinct()) {
				select = "DISTINCT " ~ select;
			}
		}
		return select;
	}
	string whereExpr()
	{
		string where;
		if(_builder.whereKeys.length){
			int i = 0;
			where = " WHERE ";
			foreach(v;_builder.whereKeys){
				i++;
				where ~= v.toString;
				if(i<_builder.whereKeys.length) where ~= " AND ";
			}
		}
		if (_builder.multiWhereStr.length){
			where ~= where.length ? (" AND " ~ _builder.multiWhereStr) : (" WHERE" ~ _builder.multiWhereStr);
		}
		return where;
	}
	string joinExpr()
	{
		string joinstr;
		if(_builder.joins.length)
			foreach(join;_builder.joins){joinstr ~= join.toString;}
		return joinstr;
	}
	string groupByExpr()
	{
		if(_builder.groupBy.length) {
			string s = "GROUP BY";
			foreach(k,v; _builder.groupBy) {
				if (k != 0)
					s ~= ",";
				s ~= (" " ~ v );
			}
			return  s;
		}
		return null;
	}
	string havingExpr()
	{
		if(_builder.having.length) 
			return  " HAVING " ~ _builder.having;
		return null;
	}
	string orderExpr()
	{
		if(_builder.orderBy.length && _builder.order.length) {
			string s = " ORDER BY";
			foreach(k,v; _builder.orderBy) {
				if (k != 0)
					s ~= ",";
				s ~= (" " ~ v ~ " " ~ _builder.order[k]);
			}
			return  s;
		}
		return null;
	}
	string limitExpr()
	{
		if(_builder.limit > 0)
			return " LIMIT " ~ (_builder.limit).to!string;
		return null;
	}
	string offsetExpr()
	{
		if(_builder.offset > 0) 
			return " OFFSET " ~ (_builder.offset).to!string;
		return null;
	}

	string setExpr()
	{
		string set;
		if(_builder.values.length){
			set ~= " SET ";
			int i = 0;
			foreach(k,v;_builder.values){
				i++;
				set ~= v.toString;
				if(i<_builder.values.length) set ~= " , ";
			}
		}else{
			throw new DatabaseException("query builder update method have not set values");
		}
		return set;
	}

	string insertExpr()
	{
		if(!_builder.values.length) throw new DatabaseException("query build insert have not values");
		string keys;
		string values;
		foreach(k,v;_builder.values){
			keys ~= k~",";
			values ~= v.value~",";
		}
		return "(" ~ keys[0.. $-1] ~ ") VALUES("~ values[0..$-1]  ~")";
	}

	
	
	string autoIncreaseExpr()
	{
		return "";
	}

	string showTables() {
		return "show tables";
	}
	string descTable() {
		return "desc "~_builder.tableName;
	}

	override string toString()
	{
		if(!_builder.tableName.length && _builder.method != Method.ShowTables)
			throw new DatabaseException("query build table name not exists");
		string str;
		switch(_builder.method){
			case Method.Select:
				str ~= Method.Select;
				str ~= selectExpr();
				str ~= " FROM " ~ _builder.tableName ~ " " ~ _builder.tableNameAlias ~ " ";
				str ~= joinExpr();
				str ~= whereExpr();
				str ~= groupByExpr();
				str ~= havingExpr();
				str ~= orderExpr();
				str ~= limitExpr();
				str ~= offsetExpr();
				break;
			case Method.Update:
				str ~= Method.Update ~ " " ~ _builder.tableName;
				str ~= setExpr();
				str ~= whereExpr();
				str ~= orderExpr();
				str ~= limitExpr();
				break;
			case Method.Delete:
				str ~= Method.Delete ~ " " ~ _builder.tableName;
				str ~= whereExpr();
				str ~= orderExpr();
				str ~= limitExpr();
				break;
			case Method.Insert:
				str ~= Method.Insert ~ " " ~ _builder.tableName;
				str ~= insertExpr();
				break;
			case Method.Count:
				str ~= Method.Count ~ _builder.tableName ~ whereExpr(); 
				break;
			case Method.ShowTables:
				str ~= showTables();
				break;
			case Method.DescTable:
				str ~= descTable();
				break;
			default:
				throw new DatabaseException("query build method not found");
		}
		return str;
	}
}
