module database.driver.postgresql.builder;

public import database.driver.builder;
import database.defined;
import database.driver.expression;
import database.driver.postgresql.syntax;


class PostgresqlSqlBuilder : SqlBuilder 
{
	Method _method;
	string _tableName;
	string _tableNameAlias;
	string[] _selectKeys = ["*"];
	string _having;
	string _groupby;
	string _orderByKey;
	string _order;
	int _offset;
	int _limit;
	string _multiWhereStr;
	WhereExpression[] _whereKeys;
	WhereExpression[] _whereKeysParameters;
	ValueExpression[string] _values;
	ValueExpression[] _valuesParameters;
	JoinExpression[] _joins;

	string _autoIncreaseKey;

    string formatTableName(string tableName)
    {
        return (tableName.split(".").length == 1) ? "public."~tableName : tableName;
    }

	SqlBuilder from(string tableName,string tableNameAlias = null)
	{
        _tableName = formatTableName(tableName);
		_tableNameAlias = tableNameAlias.length ? tableNameAlias : tableName;
		return this;
	}
	SqlBuilder selectImpl(string[] args)
	{
		_selectKeys = null;
		_selectKeys = args;
		_method = Method.Select;
		return this;
	}
	SqlBuilder count()
	{
		_method = Method.Count;
		return this;
	}
	SqlBuilder insert(string tableName)
	{
        _tableName = formatTableName(tableName);
		_method = Method.Insert;
		return this;
	}
	SqlBuilder update(string tableName)
	{
        _tableName = formatTableName(tableName);
		_method = Method.Update;
		return this;
	}
	SqlBuilder remove(string tableName)
	{
        _tableName = formatTableName(tableName);
		_method = Method.Delete;
		return this;
	}
	SqlBuilder where(string expression)
	{
		if(!expression.length)return this;
		auto arr = split(strip(expression)," ");
		if(arr.length != 3){
			_multiWhereStr ~= expression;	
		}else{
			auto expr = new WhereExpression(arr[0],arr[1],arr[2]);
			_whereKeys ~= expr;
			if(arr[2] == "?")_whereKeysParameters ~= expr;
		}
		return this;
	}
	SqlBuilder whereImpl(string key,CompareType type,string value)
	{
		_whereKeys ~= new WhereExpression(key,type,value);
		return this;
	}
	SqlBuilder where(MultiWhereExpression expr)
	{
		_multiWhereStr ~= expr.toString;
		return this;
	}
	SqlBuilder having(string expression)
	{
		_having = expression;
		return this;
	}
	MultiWhereExpression expr()
	{
		return new MultiWhereExpression();
	}
	SqlBuilder join(JoinMethod joinMethod,string table,string tablealias,string joinWhere)
	{
		_joins ~= new JoinExpression(joinMethod,table,tablealias,joinWhere);
		return this;
	}
	SqlBuilder join(JoinMethod joinMethod,string table,string joinWhere)
	{
		return join(joinMethod,table,table,joinWhere);
	}
	SqlBuilder innerJoin(string table,string tablealias,string joinWhere)
	{
		return join(JoinMethod.InnerJoin,table,tablealias,joinWhere);
	}
	SqlBuilder innerJoin(string table,string joinWhere)
	{
		return innerJoin(table,table,joinWhere);
	}
	SqlBuilder leftJoin(string table,string tableAlias,string joinWhere)
	{
		return join(JoinMethod.LeftJoin,table,tableAlias,joinWhere);
	}
	SqlBuilder leftJoin(string table,string joinWhere)
	{
		return leftJoin(table,table,joinWhere);
	}
	SqlBuilder rightJoin(string table,string tableAlias,string joinWhere)
	{
        return join(JoinMethod.RightJoin,table,tableAlias,joinWhere);
	}
	SqlBuilder rightJoin(string table,string joinWhere)
	{
        return rightJoin(table,table,joinWhere);
	}
	SqlBuilder fullJoin(string table,string tableAlias,string joinWhere)
	{
		return join(JoinMethod.FullJoin,table,tableAlias,joinWhere);
	}
	SqlBuilder fullJoin(string table,string joinWhere)
	{
		return fullJoin(table,table,joinWhere);
	}
	SqlBuilder crossJoin(string table,string tableAlias)
	{
		return join(JoinMethod.CrossJoin,table,tableAlias,null);
	}
	SqlBuilder crossJoin(string table)
	{
		return crossJoin(table,table);
	}
	SqlBuilder groupBy(string expression)
	{
		_groupby = expression;
		return this;
	}
	SqlBuilder orderBy (string key,string order = "DESC")
	{
		_orderByKey = key;
		_order = order;
		return this;
	}
	SqlBuilder offset(int offset)
	{
		_offset = offset;
		return this;
	}
	SqlBuilder limit(int limit)
	{
		_limit = limit;
		return this;
	}
	SqlBuilder values(string[string] arr)
	{
		foreach(key,value;arr){
			auto expr = new ValueExpression(key,value);
			_values[key] = expr;
			if(value == "?")_valuesParameters ~= expr;
		}
		return this;
	}
	SqlBuilder set(string key,string value)
	{
		auto expr = new ValueExpression(key,value);
		_values[key] = expr;
		if(value == "?")_valuesParameters ~= expr;
		return this;
	}
	SqlBuilder setParameter(int index,string value)
	{
		if(_whereKeysParameters.length){
			if(index > _whereKeysParameters.length - 1)
				throw new DatabaseException("query builder setParameter range valite");
			_whereKeysParameters[index].value = value;
		}else{
			if(index > _valuesParameters.length - 1)
				throw new DatabaseException("query builder setParameter range valite");
			_valuesParameters[index].value = value;
		}
		return this;
	}

	SqlBuilder setAutoIncrease(string key)
	{
		_autoIncreaseKey = key;
		return this;
	}

	string getAutoIncrease()
	{
		return _autoIncreaseKey;
	}

	string tableName()
	{
		return this._tableName;
	}

    string tableNameAlias()
    {
        return this._tableNameAlias;
    }

    Method method()
    {
        return this._method;
    }

    string[] selectKeys()
    {
        return this._selectKeys;
    }

    string having()
    {
        return this._having;
    }

    string groupBy()
    {
        return this._groupby;
    }

    string orderBy()
    {
        return this._orderByKey;
    }

    string order()
    {
        return this._order;
    }

    int limit()
    {
        return this._limit;
    }

    int offset()
    {
        return this._offset;
    }

    string multiWhereStr()
    {
        return this._multiWhereStr;
    }

    WhereExpression[] whereKeys()
    {
        return this._whereKeys;
    }

    ValueExpression[string] values()
    {
        return this._values;
    }

    JoinExpression[] joins()
    {
        return this._joins;
    }

	PostgresqlSqlSyntax build()
	{
		return new PostgresqlSqlSyntax(this);
	}
}
