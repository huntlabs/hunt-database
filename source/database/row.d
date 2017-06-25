/*
 * Database - Database abstraction layer for D programing language.
 *
 * Copyright (C) 2017  Shanghai Putao Technology Co., Ltd
 *
 * Developer: HuntLabs
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module database.row;

import database;

string yield(string what) { return `if(auto result = dg(`~what~`)) return result;`; }

class Row 
{
    private ResultSet _resultSet;
    public Variant[string] vars;

    this(ResultSet resultSet)
    {
        this._resultSet = resultSet;
    }

    ~this()
    {
    }

    void opDispatch(string name, T)(T val)
    {
        if (name !in vars)
            vars[name] = Variant();
        vars[name] = val;
    }

    void add(T)(string name,T val)
    {
        if (name !in vars)
            vars[name] = Variant();
        vars[name] = val;
    }

    void add(string name,TypeInfo type,string val)
    {
        if (name !in vars)
            vars[name] = Variant();
        vars[name] = val;
    }

    Variant opDispatch(string name)()
    {
        if(name in vars)
            return Variant(vars[name]);
        return Variant.init;
    }

    string opIndex(string name, string file = __FILE__, int line = __LINE__) {
        if(name !in vars)
            throw new DatabaseException("no field "~name~" in result", file, line);
        return vars[name].to!string;
    }

    override string toString()
    {
        return to!string(vars);
    }

    int opApply(int delegate(ref string, ref string) dg) {
        foreach(a, b; toStringArray())
            mixin(yield("a, b"));
        return 0;
    }

    string[string] toStringArray() {
        return cast(string[string])vars;
    }
}


