module hunt.database.query.Expr;

import hunt.database.query.Expression;
import hunt.database.query.Common;
import hunt.database.query.Comparison;

import hunt.logging;

class Expr
{
    Comparison!T eq(T)(string key,T value)
	{   
		return new Comparison!T(key,CompareType.eq,value);
	}
    Comparison!T ne(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.ne,value);
	}
    Comparison!T gt(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.gt,value);
	}
    Comparison!T lt(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.lt,value);
	}
    Comparison!T ge(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.ge,value);
	}
    Comparison!T le(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.le,value);
	}
    Comparison!T like(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.like,value);
	}

    string andX(string[] args...)
    {
        string cond;
        cond ~= " ( ";
        foreach(idx ,arg ; args)
        {
            cond ~= arg;
            if (idx != args.length - 1)
                cond ~= " AND ";
        }
        cond ~= " ) ";
        return cond;
    }

    string orX(string[] args...)
    {
        string cond;
        cond ~= " ( ";
        foreach(idx ,arg ; args)
        {
            cond ~= arg;
            if (idx != args.length - 1)
                cond ~= " OR ";
        }
        cond ~= " ) ";
        // logDebug("orX : ",cond);
        return cond;
    }

}