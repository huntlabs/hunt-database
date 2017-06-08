/**
 * This module contains misc utility functions which may help in implementation of DB drivers.
 */
module db.driver.utils;

import std.datetime;

string copyCString(T)(const T* c, int actualLength = -1) if (is(T == char) || is (T == ubyte)) {
    const(T)* a = c;
    if(a is null)
        return null;
    
    if(actualLength == -1) {
        T[] ret;
        while(*a) {
            ret ~= *a;
            a++;
        }
        return cast(string)ret;
    } else {
        return cast(string)(a[0..actualLength].idup);
    }
    
}

TimeOfDay parseTimeoid(const string timeoid)
{
    import std.format;
    string input = timeoid.dup;
    int hour, min, sec;
    formattedRead(input, "%s:%s:%s", &hour, &min, &sec);
    return TimeOfDay(hour, min, sec);
}

Date parseDateoid(const string dateoid)
{
    import std.format: formattedRead;
    string input = dateoid.dup;
    int year, month, day;
    formattedRead(input, "%s-%s-%s", &year, &month, &day);
    return Date(year, month, day);
}
