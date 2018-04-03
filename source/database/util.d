module database.util;

import std.string : toStringz;

alias const(char)* cstring;

public T safeConvert(F, T)(F value)
{
    try
    {
        import std.conv : to;
        return to!T(value);
    }
    catch
    {
        return T.init;
    }
}

cstring toCstring(string c) 
{
    return toStringz(c);
}

string fromCstring(cstring c, size_t len = size_t.max)
{
    string ret;
    if(c is null)return null;
    if(len == 0)return "";
    if(len == size_t.max) {
        auto iterator = c;
        len =0;
        while(*iterator)
        {
            iterator++;
            len++;
        }
        assert(len >= 0);
    }
    ret = cast(string) (c[0 .. len].idup);
    return ret;
}
