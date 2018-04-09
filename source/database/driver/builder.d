module database.driver.builder;

public import std.array;
public import std.string;

import database.defined;
import database.driver.expression;
import database.driver.syntax;

public import database.exception;

interface QueryBuilder
{
    QueryBuilder from(string tableName, string tableNameAlias = null);
    QueryBuilder select(T...)(T args)
    {
        string[] arr;
        foreach(arg;args){
            arr ~= arg;
        }
        return selectImpl(arr);
    }
    QueryBuilder selectImpl(string[] args);
    QueryBuilder insert(string tableName);
    QueryBuilder update(string tableName);
    QueryBuilder remove(string tableName);
    QueryBuilder where(string expression);
    alias total = count;
    QueryBuilder count();
    QueryBuilder having(string expression);
    QueryBuilder eq(T)(string key,T value)
    {
        return whereImpl(key, CompareType.eq, value.to!string);
    }
    QueryBuilder ne(T)(string key, T value)
    {
        return whereImpl(key, CompareType.ne, value.to!string);
    }
    QueryBuilder gt(T)(string key,T value)
    {
        return whereImpl(key, CompareType.gt, value.to!string);
    }
    QueryBuilder lt(T)(string key, T value)
    {
        return whereImpl(key, CompareType.lt, value.to!string);
    }
    QueryBuilder ge(T)(string key, T value)
    {
        return whereImpl(key, CompareType.ge, value.to!string);
    }
    QueryBuilder le(T)(string key, T value)
    {
        return whereImpl(key, CompareType.le, value.to!string);
    }
    QueryBuilder like(T)(string key, T value)
    {
        return whereImpl(key, CompareType.like, value.to!string);
    }
    QueryBuilder where(T)(string key, CompareType type, T value)
    {
        return whereImpl(key, type, value.to!string);
    }
    QueryBuilder whereImpl(string key, CompareType type, string value);
    QueryBuilder where(MultiWhereExpression expr);
    MultiWhereExpression expr();
    QueryBuilder join(JoinMethod joinMethod, string table,string tablealias,string joinWhere);
    QueryBuilder join(JoinMethod joinMethod, string table,string joinWhere);
    QueryBuilder innerJoin(string table, string tablealias,string joinWhere);
    QueryBuilder innerJoin(string table, string joinWhere);
    QueryBuilder leftJoin(string table, string tableAlias,string joinWhere);
    QueryBuilder leftJoin(string table, string joinWhere);
    QueryBuilder rightJoin(string table, string tableAlias,string joinWhere);
    QueryBuilder rightJoin(string table, string joinWhere);
    QueryBuilder fullJoin(string table, string tableAlias,string joinWhere);
    QueryBuilder fullJoin(string table, string joinWhere);
    QueryBuilder crossJoin(string table, string tableAlias);
    QueryBuilder crossJoin(string table);
    QueryBuilder groupBy(string expression);
    QueryBuilder orderBy (string key, string order = "DESC");
    QueryBuilder offset(int offset);
    QueryBuilder limit(int limit);
    QueryBuilder values(string[string] arr);
    QueryBuilder set(string key, string value);
    QueryBuilder setParameter(int index, string value);
    
    QueryBuilder setAutoIncrease(string key);
    
    string tableName();
    string tableNameAlias();
    Method method();
    string[] selectKeys();
    string having();
    string groupBy();
    string orderBy();
    string order();
    int limit();
    int offset();
    string multiWhereStr();
    WhereExpression[] whereKeys();
    ValueExpression[string] values();
    JoinExpression[] joins();
    string getAutoIncrease();
    
    SqlSyntax build();
}
