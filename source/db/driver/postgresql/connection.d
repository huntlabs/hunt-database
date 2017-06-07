module db.driver.postgresql.connection;

import db;
version(USE_PGSQL):
pragma(lib, "pq");
pragma(lib, "pgtypes");

void error(string file = __FILE__, size_t line = __LINE__)(PGconn* con, string msg) {
    import std.conv;

    auto s = msg ~ to!string(PQerrorMessage(con));
    throw new DatabaseException(s,file,line);
}

void error(string file = __FILE__, size_t line = __LINE__)(PGconn* con, string msg, int result) {
    import std.conv;

    auto s = "error:" ~ msg ~ ": " ~ to!string(result) ~ ": " ~ to!string(PQerrorMessage(con));
    throw new DatabaseException(s,file,line);
}

int check(string file = __FILE__, size_t line = __LINE__)(PGconn* con, string msg, int result) {
    info(msg, ": ", result);
    if (result != 1)
    error!(file,line)(con, msg, result);
    return result;
}

int checkForZero(string file = __FILE__, size_t line = __LINE__)(PGconn* con, string msg, int result) {
    info(msg, ": ", result);
    if (result != 0)
    error!(file,line)(con, msg, result);
    return result;
}

class PostgresqlConnection :  Connection 
{
    public string dbname;
    private URL _url;
    private string _host;
    private string _user;
    private string _pass;
    private string _db;
    private uint _port;
    private QueryParams _querys;
    private PGconn* con;

    this(URL url)
    {
        this._url = url;
        this._port = url.port;
        this._host = url.host;
        this._user = url.user;
        this._db = (url.path)[1..$];
        this._pass = url.pass;
        this._querys = url.queryParams;
        this.dbname = this._db;
        connect();
    }

    private void connect() 
    {
        string conninfo;
        conninfo ~= "host=" ~ _host;
        if(_port > 0) conninfo ~= " port=" ~ to!string(_port);
        conninfo ~= " dbname=" ~ _db;
        if(_user.length) conninfo ~= " user=" ~ _user;
        if(_pass.length) conninfo ~= " password=" ~ _pass;
        trace("link string is : ", conninfo);
        con = PQconnectdb(toStringz(conninfo));
        if (PQstatus(con) != CONNECTION_OK)
        throw new DatabaseException("login error");
    }

    ~this() {
        PQfinish(con);
    }

    void close()
    {
        PQfinish(con);
    }

    int socket() {
        return PQsocket(con);
    }

    void* handle() {
        return con;
    }

    int execute(string sql)
    {
        return 0; 
    }

    override ResultSet queryImpl(string sql, Variant[] args...) 
    {
        trace("query sql: ", sql);
        PGresult* res;
        res = PQexec(con,toStringz(sql));
        return new PgsqlResult(res);
    }
}
/*
struct Statement {
    Connection* connection;
    string sql;
    Allocator* allocator;
    PGconn* con;
    string name;
    PGresult* prepareRes;
    PGresult* res;

    this(Connection* connection_, string sql_) {
        connection = connection_;
        sql = sql_;
        allocator = &connection.db.allocator;
        con = connection.con;
        //prepare();
    }

    ~this() {
    }

    void bind(int n, int value) {
    }

    void bind(int n, const char[] value) {
    }

    void query() {
        import std.conv;

        trace("query sql: ", sql);

        static if (Policy.nonblocking) {

            checkForZero(con, "PQsetnonblocking", PQsetnonblocking(con, 1));

            check(con, "PQsendQueryPrepared", PQsendQuery(con,toStringz(sql)));

            do {
                Policy.Handler handler;
                handler.addSocket(posixSocket());
                log("waiting: ");
                checkForZero(con, "PQflush", PQflush(con));
                handler.wait();
                check(con, "PQconsumeInput", PQconsumeInput(con));

                PGnotify* notify;
                while ((notify = PQnotifies(con)) != null) {
                    info("notify: ", to!string(notify.relname));
                    PQfreemem(notify);
                }

            }
            while (PQisBusy(con) == 1);

            res = PQgetResult(con);

        }
        else {
            res = PQexec(con,toStringz(sql));
        }
    }

    void query(X...)(X args) {
        info("query sql: ", sql);

    }

    bool hasRows() {
        return rowCout() > 0;
    }

    int rowCout()
    {
        int r = 0;
        if(res !is null) r = PQntuples(res);
        return r;
    }
    void prepare() {
        const Oid* paramTypes;
        prepareRes = PQprepare(con, toStringz(name), toStringz(sql), 0, paramTypes);
    }

    auto error(string msg) {
        import std.conv;

        string s;
        s ~= msg ~ ", " ~ to!string(PQerrorMessage(con));
        return new DatabaseException(s);
    }

    void reset() {
    }

    private auto posixSocket() {
        int s = PQsocket(con);
        if (s == -1)
        throw new DatabaseException("can't get socket");
        return s;
    }

}
*/
/*
struct Describe {
    int dbType;
    int fmt;
    string name;
}
// use std.database.front.ValueType not std.traits.ValueType
alias ValueType = std.database.front.ValueType;
struct Bind {
    ValueType type;
    int idx;
}

struct Result {
    Statement* stmt;
    PGconn* con;
    PGresult* res;
    int columns;
    Array!Describe describe;
    ExecStatusType status;
    int row;
    int rows;
    bool hasResult_;
    bool fristFecth = true;

    // artifical bind array (for now)
    Array!Bind bind;

    this(Statement* stmt_, int rowArraySize_) {
        stmt = stmt_;
        con = stmt.con;
        res = stmt.res;
        trace("build a rulest!");
        setup();

        build_describe();
        build_bind();
        trace("end a rulest!");
    }

    ~this() {
        trace("~this() { rulest!");
        if (res)
        close();
    }

    bool setup() {
        // trace("setup");
        if (!res) {
            throw error("no result: result is null");
        }
        status = PQresultStatus(res);
        rows = PQntuples(res);
        // trace("status is ", status);
        // not handling PGRESS_SINGLE_TUPLE yet
        if (status == PGRES_COMMAND_OK) {
            close();
            return false;
        }
        else if (status == PGRES_EMPTY_QUERY) {
            close();
            return false;
        }
        else if (status == PGRES_TUPLES_OK) {
            return true;
        }
        else 
        throw error(res, status);
    }

    void build_describe() {
        import std.conv;
        trace("build_describe!");
        // called after next()
        columns = PQnfields(res);
        for (int col = 0; col != columns; col++) {
            describe ~= Describe();
            auto d = &describe.back();
            d.dbType = cast(int) PQftype(res, col);
            d.fmt = PQfformat(res, col);
            d.name = to!string(PQfname(res, col));
        }
    }

    void build_bind() {
        trace("build_bind!");
        // artificial bind setup
        bind.reserve(columns);
        for (int i = 0; i < columns; ++i) {
            auto d = &describe[i];
            bind ~= Bind();
            auto b = &bind.back();
            b.type = ValueType.String;
            b.idx = i;
            switch (d.dbType) {
                case CHAROID:
                b.type = ValueType.Char;
                break;
                case TEXTOID:
                case NAMEOID:
                case VARCHAROID:
                b.type = ValueType.String;
                break;
                case BOOLOID:
                case INT4OID:
                b.type = ValueType.Int;
                break;
                case INT2OID:
                b.type = ValueType.Short;
                break;
                case INT8OID:
                b.type = ValueType.Long;
                break;
                case FLOAT4OID:
                b.type = ValueType.Float;
                break;
                case FLOAT8OID:
                b.type = ValueType.Double;
                break;
                case DATEOID:
                b.type = ValueType.Date;
                break;
                case TIMEOID:
                b.type = ValueType.Time;
                break;
                case TIMESTAMPOID:
                b.type = ValueType.DateTime;
                break;
                case BYTEAOID:
                b.type = ValueType.Raw;
                break;
                default:
                b.type = ValueType.UNKnown;
                break;
                // throw new DatabaseException("unsupported type");
            }
        }
    }

    int fetch() {
        int r = 0;
        if(fristFecth)
        r = rows > 0 ? 1 : 0;
        else 
        {
            ++row;
            r = row != rows ? 1 : 0;
        }
        fristFecth = false;
        return r;
    }

    bool singleRownext() {
        if (res)
        PQclear(res);
        res = PQgetResult(con);
        if (!res)
        return false;
        status = PQresultStatus(res);

        if (status == PGRES_COMMAND_OK) {
            close();
            return false;
        }
        else if (status == PGRES_SINGLE_TUPLE)
        return true;
        else if (status == PGRES_TUPLES_OK) {
            close();
            return false;
        }
        else
        throw error(status);
    }

    void close() {
        if (!res)
        throw error("couldn't close result: result was not open");
        res = PQgetResult(con);
        if (res)
        throw error("couldn't close result: was not finished");
        res = null;
    }

    auto error(string file = __FILE__, size_t line = __LINE__)(string msg) {
        return new DatabaseException(msg,file,line);
    }

    auto error(string file = __FILE__, size_t line = __LINE__)(ExecStatusType status) {
        import std.conv;

        string s = "result error: " ~ to!string(PQresStatus(status));
        return new DatabaseException(s,file,line);
    }

    auto error(string file = __FILE__, size_t line = __LINE__)(PGresult* res, ExecStatusType status) {
        import std.conv;

        const char* msg = PQresultErrorMessage(res);
        string s = "error: " ~ to!string(PQresStatus(status)) ~ ", message:" ~ to!string(msg);
        return new DatabaseException(s,file,line);
    }


    auto name(size_t idx) {
        return describe[idx].name;
    }

    ubyte[] rawData(Cell* cell) {
        auto ptr = cast(ubyte*) data(cell.bind.idx);
        return ptr[0 .. len(cell.bind.idx)];
    }

    Variant getValue(Cell* cell) {
        import std.conv;

        Variant value;
        if (isNull(cell))
        return value;

        void* dt = data(cell.bind.idx);
        int leng = len(cell.bind.idx);
        immutable char* ptr = cast(immutable char*) dt;
        string str = cast(string) ptr[0 .. leng];
        switch (type(cell.bind.idx)) {
            case VARCHAROID: 
            case TEXTOID:
            case NAMEOID:{
                value = str;
            }
            break;
            case INT2OID: {
                value = parse!short(str);
            }
            break;
            case INT4OID: {
                value = parse!int(str);
            }
            break;
            case INT8OID: {
                value = parse!long(str);
            }
            break;
            case FLOAT4OID: {
                value = parse!float(str);
            }
            break;
            case FLOAT8OID: {
                value = parse!double(str);
            }
            break;
            case DATEOID: {
                import std.format: formattedRead;
                string input = str;
                int year, month, day;
                formattedRead(input, "%s-%s-%s", &year, &month, &day);
                value =  Date(year, month, day);
            }
            break;
            case TIMESTAMPOID: {
                import std.string;

                value = DateTime.fromISOExtString(str.translate([' ' : 'T']).split('.').front());
            }
            break;
            case TIMEOID: {
                value = parseTimeoid(str);
            }
            break;
            case BYTEAOID: {
                value = byteaToUbytes(str);
            }
            break;
            case CHAROID: {
                value = cast(char)(leng > 0 ? str[0] : 0x00);
            }
    break;
case BOOLOID: {

    if (str == "true" || str == "t" || str == "1")
    value = 1;
    else if (str == "false" || str == "f" || str == "0")
    value = 0;
    else 
    value = parse!int(str);
}
break;
default:
    break;
}
trace("value is : ",value );
return value;
    }

    bool isNull(Cell* cell) {
        return PQgetisnull(res, row, cell.bind.idx) != 0;
    }

    void checkType(int a, int b) {
        if (a != b)
        throw new DatabaseException("type mismatch");
    }

    void* data(int col) {
        return PQgetvalue(res, row, col);
    }

    bool isNull(int col) {
        return PQgetisnull(res, row, col) != 0;
    }

    auto type(int col) {
        return describe[col].dbType;
    }

    int fmt(int col) {
        return describe[col].fmt;
    }

    int len(int col) {
        return PQgetlength(res, row, col);
    }

}

// the under is from ddbc:
import core.vararg;
import std.exception;
import std.meta;
import std.range.primitives;
import std.traits;
import std.format;

Time parseTimeoid(const string timeoid) {
    import std.format;

    string input = timeoid.dup;
    int hour, min, sec;
    formattedRead(input, "%s:%s:%s", &hour, &min, &sec);
    return Time(hour, min, sec);
}

ubyte[] byteaToUbytes(string s) {
    if (s is null)
    return null;
    ubyte[] res;
    bool lastBackSlash = 0;
    foreach (ch; s) {
        if (ch == '\\') {
            if (lastBackSlash) {
                res ~= '\\';
                lastBackSlash = false;
            }
            else {
                lastBackSlash = true;
            }
        }
        else {
            if (lastBackSlash) {
                if (ch == '0') {
                    res ~= 0;
                }
                else if (ch == 'r') {
                    res ~= '\r';
                }
                else if (ch == 'n') {
                    res ~= '\n';
                }
                else if (ch == 't') {
                    res ~= '\t';
                }
                else {
                }
            }
            else {
                res ~= cast(byte) ch;
            }
            lastBackSlash = false;
        }
    }
    return res;
}
*/
