module hunt.database.query.Expr;

import hunt.database.driver.Expression;
import hunt.database.Defined;
import hunt.database.query.Common;
import hunt.database.query.Comparison;

import hunt.logging;

class Expr
{
    public Comparison!T eq(T)(string key,T value)
	{   
		return new Comparison!T(key,CompareType.eq,value);
	}
    public Comparison!T ne(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.ne,value);
	}
    public Comparison!T gt(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.gt,value);
	}
    public Comparison!T lt(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.lt,value);
	}
    public Comparison!T ge(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.ge,value);
	}
    public Comparison!T le(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.le,value);
	}
    public Comparison!T like(T)(string key,T value)
	{
		return new Comparison!T(key,CompareType.like,value);
	}

    public string andX(string[] args...)
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

    public string orX(string[] args...)
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