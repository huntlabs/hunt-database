module hunt.database.Utils;

import hunt.database;


public T safeConvert(F,T)(F value)
{
    try
    {
        return to!T(value);
    }
    catch
    {
        return T.init;
    }
}

auto fromSQLType(uint type)
{
    return typeid(string);
}
