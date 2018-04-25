module database.driver.expression;

import database;

class Expression
{
    string value;
}

class WhereExpression : Expression
{
    string key;
    string op;
    string value;
    this(string key , string op, string value)
    {
        this.key = key;
        this.op = op;
        this.value = value;
    }
    string formatKey(string str)
    {
        return str;
    }
    string formatValue(string str)
    {
        if(str == null)return "null";
        return str;
    }
    override string toString()
    {
        return formatKey(key) ~ " " ~ op ~ " "~ formatValue(value);
    }
}

class ValueExpression : Expression
{
    string key;
    string value;
    this(string key , string value)
    {
        this.key = key;
        this.value = value;
    }
    override string toString()
    {
        return  key ~ " = " ~ value ;
    }
}

class JoinExpression : Expression
{
    JoinMethod _join;
    string _table;
    string _tableAlias;
    string _on;
    this(JoinMethod join,string table,string tableAlias,string on)
    {
        _join = join;
        _table = table;
        _tableAlias = tableAlias;
        _on = on;
    }
    override string toString()
    {
        string str = " " ~ _join ~ " " ~ _table ~ " " ~ _tableAlias ~ " ";
        if(_join != JoinMethod.CrossJoin) str ~= " ON " ~ _on ~ " ";
        return str;
    }
}

class MultiWhereExpression : Expression
{
    Relation _relation;
    MultiWhereExpression[] childs;
    WhereExpression expr;
    override string toString()
    {
        if(childs.length){
            auto len = childs.length;
            int i = 0;
            string str;
            foreach(child;childs)
            {
                str ~= child.toString;
                if( i < len-1 )str ~=  (_relation == Relation.And ? " AND " : " OR ");
                i++;
            }
            return "(" ~ str ~ ")";
        }else{
            return "(" ~ expr.toString ~ ")";
        }
    }
    MultiWhereExpression eq(string key,string value)
    {
        if(value == null)
        expr = new WhereExpression(key,"is",null);
        else 
        expr = new WhereExpression(key,"=",value);
        return this;
    }
    MultiWhereExpression ne(string key,string value)
    {
        if(value == null)
        expr = new WhereExpression(key,"is not",null);
        else 
        expr =  new WhereExpression(key,"!=",value);
        return this;
    }
    MultiWhereExpression gt(string key,string value)
    {
        expr =  new WhereExpression(key,">",value);
        return this;
    }
    MultiWhereExpression lt(string key,string value)
    {
        expr = new WhereExpression(key,"<",value);
        return this;
    }
    MultiWhereExpression ge(string key,string value)
    {
        expr = new WhereExpression(key,">=",value);
        return this;
    }
MultiWhereExpression le(string key,string value)
{
    expr = new WhereExpression(key,"<=",value);
    return this;
}
MultiWhereExpression like(string key,string value)
{
    expr = new WhereExpression(key,"like",value);
    return this;
}
MultiWhereExpression andX(T...)(T args)
{
    _relation = Relation.And; 
    foreach(v;args)
    {
        childs ~= v;
    }
    return this;
}
MultiWhereExpression orX(T...)(T args)
{
    _relation = Relation.Or; 
    foreach(v;args)
    {
        childs ~= v;
    }
    return this;
}
}
