module database.driver.sqlite.builder;

public import database.driver.builder;
import database.defined;
import database.driver.expression;
import database.driver.sqlite.syntax;

class SqliteQueryBuilder : QueryBuilder 
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

    QueryBuilder from(string tableName, string tableNameAlias = null)
    {
        _tableName = tableName;
        _tableNameAlias = tableNameAlias.length ? tableNameAlias : tableName;
        return this;
    }
    QueryBuilder selectImpl(string[] args)
    {
        _selectKeys = null;
        _selectKeys = args;
        _method = Method.Select;
        return this;
    }
    QueryBuilder count()
    {
        _method = Method.Count;
        return this;
    }
    QueryBuilder insert(string tableName)
    {
        _tableName = tableName;
        _method = Method.Insert;
        return this;
    }
    QueryBuilder update(string tableName)
    {
        _tableName = tableName;
        _method = Method.Update;
        return this;
    }
    QueryBuilder remove(string tableName)
    {
        _tableName = tableName;
        _method = Method.Delete;
        return this;
    }
    QueryBuilder where(string expression)
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
    QueryBuilder whereImpl(string key,CompareType type,string value)
    {
        _whereKeys ~= new WhereExpression(key,type,value);
        return this;
    }
    QueryBuilder where(MultiWhereExpression expr)
    {
        _multiWhereStr ~= expr.toString;
        return this;
    }
    QueryBuilder having(string expression)
    {
        _having = expression;
        return this;
    }
    MultiWhereExpression expr()
    {
        return new MultiWhereExpression();
    }
    QueryBuilder join(JoinMethod joinMethod,string table,string tablealias,string joinWhere)
    {
        _joins ~= new JoinExpression(joinMethod,table,tablealias,joinWhere);
        return this;
    }
    QueryBuilder join(JoinMethod joinMethod,string table,string joinWhere)
    {
        return join(joinMethod,table,table,joinWhere);
    }
    QueryBuilder innerJoin(string table,string tablealias,string joinWhere)
    {
        return join(JoinMethod.InnerJoin,table,tablealias,joinWhere);
    }
    QueryBuilder innerJoin(string table,string joinWhere)
    {
        return innerJoin(table,table,joinWhere);
    }
    QueryBuilder leftJoin(string table,string tableAlias,string joinWhere)
    {
        return join(JoinMethod.LeftJoin,table,tableAlias,joinWhere);
    }
    QueryBuilder leftJoin(string table,string joinWhere)
    {
        return leftJoin(table,table,joinWhere);
    }
    QueryBuilder rightJoin(string table,string tableAlias,string joinWhere)
    {
        return join(JoinMethod.RightJoin,table,tableAlias,joinWhere);
    }
    QueryBuilder rightJoin(string table,string joinWhere)
    {
        return rightJoin(table,table,joinWhere);
    }
    QueryBuilder fullJoin(string table,string tableAlias,string joinWhere)
    {
        return join(JoinMethod.FullJoin,table,tableAlias,joinWhere);
    }
    QueryBuilder fullJoin(string table,string joinWhere)
    {
        return fullJoin(table,table,joinWhere);
    }
    QueryBuilder crossJoin(string table,string tableAlias)
    {
        return join(JoinMethod.CrossJoin,table,tableAlias,null);
    }
    QueryBuilder crossJoin(string table)
    {
        return crossJoin(table,table);
    }
    QueryBuilder groupBy(string expression)
    {
        _groupby = expression;
        return this;
    }
    QueryBuilder orderBy (string key,string order = "DESC")
    {
        _orderByKey = key;
        _order = order;
        return this;
    }
    QueryBuilder offset(int offset)
    {
        _offset = offset;
        return this;
    }
    QueryBuilder limit(int limit)
    {
        _limit = limit;
        return this;
    }
    QueryBuilder values(string[string] arr)
    {
        foreach(key,value;arr){
            auto expr = new ValueExpression(key,value);
            _values[key] = expr;
            if(value == "?")_valuesParameters ~= expr;
        }
        return this;
    }
    QueryBuilder set(string key,string value)
    {
        auto expr = new ValueExpression(key,value);
        _values[key] = expr;
        if(value == "?")_valuesParameters ~= expr;
        return this;
    }
    QueryBuilder setParameter(int index,string value)
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

    QueryBuilder setAutoIncrease(string key)
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

    SqliteSyntax build()
    {
        return new SqliteSyntax(this);
    }
}
