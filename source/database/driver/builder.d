module database.driver.builder;

public import std.array;
public import std.string;

import database.defined;
import database.driver.expression;
import database.driver.syntax;

public import database.exception;

interface SqlBuilder
{
    SqlBuilder from(string tableName,string tableNameAlias = null);
    SqlBuilder select(T...)(T args)
    {
        string[] arr;
        foreach(arg;args){
            arr ~= arg;
        }
        return selectImpl(arr);
    }
    SqlBuilder selectImpl(string[] args);
    SqlBuilder insert(string tableName);
    SqlBuilder update(string tableName);
    SqlBuilder remove(string tableName);
    SqlBuilder where(string expression);
    alias total = count;
    SqlBuilder count();
    SqlBuilder having(string expression);
    SqlBuilder eq(T)(string key,T value)
    {
        return whereImpl(key,CompareType.eq,value.to!string);
    }
    SqlBuilder ne(T)(string key,T value)
    {
        return whereImpl(key,CompareType.ne,value.to!string);
    }
    SqlBuilder gt(T)(string key,T value)
    {
        return whereImpl(key,CompareType.gt,value.to!string);
    }
    SqlBuilder lt(T)(string key,T value)
    {
        return whereImpl(key,CompareType.lt,value.to!string);
    }
    SqlBuilder ge(T)(string key,T value)
    {
        return whereImpl(key,CompareType.ge,value.to!string);
    }
    SqlBuilder le(T)(string key,T value)
    {
        return whereImpl(key,CompareType.le,value.to!string);
    }
    SqlBuilder like(T)(string key,T value)
    {
        return whereImpl(key,CompareType.like,value.to!string);
    }
    SqlBuilder where(T)(string key,CompareType type,T value)
    {
        return whereImpl(key,type,value.to!string);
    }
    SqlBuilder whereImpl(string key,CompareType type,string value);
    SqlBuilder where(MultiWhereExpression expr);
    MultiWhereExpression expr();
    SqlBuilder join(JoinMethod joinMethod,string table,string tablealias,string joinWhere);
    SqlBuilder join(JoinMethod joinMethod,string table,string joinWhere);
    SqlBuilder innerJoin(string table,string tablealias,string joinWhere);
    SqlBuilder innerJoin(string table,string joinWhere);
    SqlBuilder leftJoin(string table,string tableAlias,string joinWhere);
    SqlBuilder leftJoin(string table,string joinWhere);
    SqlBuilder rightJoin(string table,string tableAlias,string joinWhere);
    SqlBuilder rightJoin(string table,string joinWhere);
    SqlBuilder fullJoin(string table,string tableAlias,string joinWhere);
    SqlBuilder fullJoin(string table,string joinWhere);
    SqlBuilder crossJoin(string table,string tableAlias);
    SqlBuilder crossJoin(string table);
    SqlBuilder groupBy(string expression);
    SqlBuilder orderBy (string key,string order = "DESC");
    SqlBuilder offset(int offset);
    SqlBuilder limit(int limit);
    SqlBuilder values(string[string] arr);
    SqlBuilder set(string key,string value);
    SqlBuilder setParameter(int index,string value);
    
    SqlBuilder setAutoIncrease(string key);
    
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

