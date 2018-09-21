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

module hunt.database.url;

import std.string;
import std.conv;
import std.stdio;

@safe:

class URLException : Exception {
    this(string msg) { super(msg); }
}

ushort[string] schemeToDefaultPort;

static this() 
{
    schemeToDefaultPort = [
        "mysql": 3306,
        "postgresql": 5432,
        "sqlite":0
        ];
}

/**
 * A Unique Resource Locator.
 * 
 * URLs can be parsed (see parseURL) and implicitly convert to strings.
 */
struct URL {
    /// The URL scheme. For instance, ssh, ftp, or https.
    string scheme;

    /// The username in this URL. Usually absent. If present, there will also be a password.
    string user;

    /// The password in this URL. Usually absent.
    string pass;

    /// The hostname.
    string host;

  
    /// The port that was explicitly provided in the URL.
    ushort port;


    string path;


    string[string] query;
    string  chartset;

    string fragment;
}


bool tryParseURL(string value, out URL url) {
    url = URL.init;
    // scheme:[//[user:password@]host[:port]][/]path[?query][#fragment]
    // Scheme is optional in common use. We infer 'http' if it's not given.
    auto i = value.indexOf("//");
    if( i < 1)
        return false;
   
    url.scheme = value[0 .. i - 1];

    /// special
    if(url.scheme == "sqlite")
    {
        value = value[i + 2 .. $];
        i = value.indexOf("/");
        auto j = value.indexOf("?");
        if( j > i)
            url.path = value[i .. j];
        else
            url.path  = value[i .. $];
        return true;
    }

    value = value[i + 2 .. $];

    i = value.indexOf("@");
    if( i == -1) // no user or password
    {    
        return false;
    }
    
    //user:password
    auto userpass = value[0 .. i];
    auto arr = userpass.split(":");
 
    if(arr.length < 2)
    {
        url.user = userpass;
    }
    else{
        url.user = arr[0];
        url.pass = arr[1];
    }
    //host[:port]][/]path[?query][#fragment
    value = value[ i + 1 .. $];

    i = value.indexOf("/");
    if(i == -1)
        return false;

    auto hostport = value[0 .. i];
    arr = hostport.split(":");
    if(arr.length < 2)
    {
        url.host = hostport;
        url.port = schemeToDefaultPort[url.scheme];
    }
    else
    {
        url.host = arr[0];
        url.port = to!ushort(arr[1]);
    }

    // /path[?query][#fragment
    value = value[i  .. $];
 
    i = value.indexOf("#");
    if( i > 0)
    {
        url.fragment = value[i + 1 .. $];
        value = value[ 0 .. i];
    }

    //path[?query]
    i = value.indexOf("?");
    if( i == -1)
    {
        url.path = value;
        return true;
    }

    url.path = value[0 .. i];
    
    //xxx=xxx&xxx=ddd
    value = value[i + 1 .. $];
    arr = value.split("&");
    foreach(a ; arr)
    {
        auto kv = a.split("=");
        if(kv.length == 2) 
        {
            url.query[toLower(kv[0])] = kv[1];
        }
    }

    if( "charset" in url.query)
    {
        url.chartset = url.query["charset"];
    }
    return true;
}

URL parseURL(string value) {
	URL url;
	if (tryParseURL(value, url)) {
		return url;
	}
	throw new URLException("failed to parse URL " ~ value);
}

unittest {
    import std.stdio;
   
    /*writeln(parseURL("mysql://root:123456@127.0.0.1/test?charset=utf#test"));
    writeln(parseURL("mysql://root@127.0.0.1:3435/test?charset=utf"));
    writeln(parseURL("mysql://root:%324#4543sdf=@127.0.0.1:3435/test?charset=utf"));
    writeln(parseURL("postgresql://user@host:123/database"));
    writeln(parseURL("sqlite:///./testDB.db"));
    writeln(parseURL("sqlite://root:123123@127.0.0.1:32423/./testDB.db?charset=uft"));
    writeln(parseURL("sqlite://root:123123@127.0.0.1:32423/./testDB.db"));*/
}

