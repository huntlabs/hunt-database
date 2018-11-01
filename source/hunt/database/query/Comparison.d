module hunt.database.query.Comparison;

import hunt.database.Defined;
import hunt.database.query.Common;
import hunt.lang;
import std.conv;

class Comparison(T)
{
    private string _var;
    private CompareType _op;
    private T _value;

    this(string var ,CompareType op , T value )
    {
        _var = var;
        _op = op;
        _value = value;
    }

    @property T value()
    {
        return _value;
    }

    @property string variant()
    {
        return _var;
    }

    @property string operator()
    {
        return _op;
    }

    override string toString()
    {
        static if(is(T == string) || is(T == String))
            return _var ~ " " ~ _op ~ " "~ quoteSqlString(_value.to!string);
        else
            return _var ~ " " ~ _op ~ " "~ _value.to!string;
    }
}