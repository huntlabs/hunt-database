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

module database.exception;

class DatabaseException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

class SQLException : Exception
{
    protected string _stateString;
    this(string msg, string stateString, string f = __FILE__, size_t l = __LINE__)
    {
        super(msg, f, l);
        _stateString = stateString;
    }

    this(string msg, string f = __FILE__, size_t l = __LINE__)
    {
        super(msg, f, l);
    }

    this(Throwable causedBy, string f = __FILE__, size_t l = __LINE__)
    {
        super(causedBy.msg, causedBy, f, l);
    }

    this(string msg, Throwable causedBy, string f = __FILE__, size_t l = __LINE__)
    {
        super(causedBy.msg, causedBy, f, l);
    }

    this(string msg, string stateString, Throwable causedBy, string f = __FILE__, size_t l = __LINE__)
    {
        super(causedBy.msg, causedBy, f, l);
        _stateString = stateString;
    }
}
