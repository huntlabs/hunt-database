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

module database.driver.postgresql.binding;

import core.stdc.stdio;

version(USE_POSTGRESQL):
auto fromSQLType(uint type){return typeid(string);}
pragma(lib, "pq");
pragma(lib, "pgtypes");
extern(System) {
    enum BOOLOID = 16;
    enum BYTEAOID = 17;
    enum CHAROID = 18;
    enum NAMEOID = 19;
    enum INT8OID = 20;
    enum INT2OID = 21;
    enum INT2VECTOROID = 22;
    enum INT4OID = 23;
    enum REGPROCOID = 24;
    enum TEXTOID = 25;
    enum OIDOID = 26;
    enum TIDOID = 27;
    enum XIDOID = 28;
    enum CIDOID = 29;
    enum OIDVECTOROID = 30;
    enum JSONOID = 114;
    enum XMLOID = 142;
    enum PGNODETREEOID = 194;
    enum POINTOID = 600;
    enum LSEGOID = 601;
    enum PATHOID = 602;
    enum BOXOID = 603;
    enum POLYGONOID = 604;
    enum LINEOID = 628;
    enum FLOAT4OID = 700;
    enum FLOAT8OID = 701;
    enum ABSTIMEOID = 702;
    enum RELTIMEOID = 703;
    enum TINTERVALOID = 704;
    enum UNKNOWNOID = 705;
    enum CIRCLEOID = 718;
    enum CASHOID = 790;
    enum MACADDROID = 829;
    enum INETOID = 869;
    enum CIDROID = 650;
    enum INT2ARRAYOID = 1005;
    enum INT4ARRAYOID = 1007;
    enum TEXTARRAYOID = 1009;
    enum OIDARRAYOID = 1028;
    enum FLOAT4ARRAYOID = 1021;
    enum ACLITEMOID = 1033;
    enum CSTRINGARRAYOID = 1263;
    enum BPCHAROID = 1042;
    enum VARCHAROID = 1043;
    enum DATEOID = 1082;
    enum TIMEOID = 1083;
    enum TIMESTAMPOID = 1114;
    enum TIMESTAMPTZOID = 1184;
    enum INTERVALOID = 1186;
    enum TIMETZOID = 1266;
    enum BITOID = 1560;
    enum VARBITOID = 1562;
    enum NUMERICOID = 1700;
    enum REFCURSOROID = 1790;
    enum REGPROCEDUREOID = 2202;
    enum REGOPEROID = 2203;
    enum REGOPERATOROID = 2204;
    enum REGCLASSOID = 2205;
    enum REGTYPEOID = 2206;
    enum REGTYPEARRAYOID = 2211;
    enum UUIDOID = 2951;
    enum LSNOID = 3220;
    enum TSVECTOROID = 3614;
    enum GTSVECTOROID = 3642;
    enum TSQUERYOID = 3615;
    enum REGCONFIGOID = 3734;
    enum REGDICTIONARYOID = 3769;
    enum JSONBOID = 3802;
    enum INT4RANGEOID = 3904;
    enum RECORDOID = 2249;
    enum RECORDARRAYOID = 2287;
    enum CSTRINGOID = 2275;
    enum ANYOID = 2276;
    enum ANYARRAYOID = 2277;
    enum VOIDOID = 2278;
    enum TRIGGEROID = 2279;
    enum EVTTRIGGEROID = 3838;
    enum LANGUAGE_HANDLEROID = 2280;
    enum INTERNALOID = 2281;
    enum OPAQUEOID = 2282;
    enum ANYELEMENTOID = 2283;
    enum ANYNONARRAYOID = 2776;
    enum ANYENUMOID = 3500;
    enum FDW_HANDLEROID = 3115;
    enum ANYRANGEOID = 3831;

    enum PGRES_EMPTY_QUERY = 0;

    enum CONNECTION_OK = 0;
    enum PGRES_COMMAND_OK = 1;
    enum PGRES_TUPLES_OK = 2;
    enum PGRES_COPY_OUT = 3;
    enum PGRES_COPY_IN = 4;
    enum PGRES_BAD_RESPONSE = 5;
    enum PGRES_NONFATAL_ERROR = 6;
    enum PGRES_FATAL_ERROR = 7;
    enum PGRES_COPY_BOTH = 8;
    enum PGRES_SINGLE_TUPLE = 9;

    alias ExecStatusType=int;
    alias Oid=uint;

    struct PGconn {};

    PGconn* PQconnectdb(const char*);
    PGconn* PQsetdbLogin(const char*,const char*,
			const char*,const char*,
			const char*,const char*,
			const char*);
    PGconn *PQconnectdbParams(const char **keywords, const char **values, int expand_dbname);
    void PQfinish(PGconn*);

    int PQstatus(PGconn*);
    const (char*) PQerrorMessage(PGconn*);

    struct PGresult {};

    int PQsendQuery(PGconn *conn, const char *command);
    
    PGresult *PQgetResult(PGconn *conn);

    int    PQsetSingleRowMode(PGconn *conn);

    ExecStatusType PQresultStatus(const PGresult *res);
    char *PQresStatus(ExecStatusType status);

    PGresult * PQexec(PGconn *conn, const char *command);
    
	char *PQcmdTuples(PGresult *res);
	
    PGresult *PQexecParams(
            PGconn *conn,
            const char *command,
            int nParams,
            const Oid *paramTypes,
            const char ** paramValues,
            const int *paramLengths,
            const int *paramFormats,
            int resultFormat);

    PGresult *PQprepare(
            PGconn *conn,
            const char *stmtName,
            const char *query,
            int nParams,
            const Oid *paramTypes);

    /*
       PGresult *PQexecPrepared(
       PGconn *conn,
       const char *stmtName,
       int nParams,
       const char *const *paramValues,
       const int *paramLengths,
       const int *paramFormats,
       int resultFormat);
     */

    PGresult* PQexecPrepared(
            PGconn*,
            const char* stmtName,
            int nParams,
            const char** paramValues,
            const int* paramLengths,
            const int* paramFormats,
            int resultFormat);

    int    PQntuples(const PGresult *res);
    int PQnfields(PGresult*);

    char *PQgetvalue(const PGresult *res, int row_number, int column_number);
    int    PQgetlength(const PGresult *res, int tup_num, int field_num);
    int    PQgetisnull(const PGresult *res, int tup_num, int field_num);

    Oid PQftype(const PGresult *res, int column_number);
    int PQfformat(const PGresult *res, int field_num);
    char *PQfname(const PGresult *res, int field_num);

    void PQclear(PGresult *res);

    char *PQresultErrorMessage(const PGresult *res);

    // date

    /* see pgtypes_date.h */

    alias long date; // long?
    void PGTYPESdate_julmdy(date, int *);
    void PGTYPESdate_mdyjul(int *mdy, date *jdate);

    // numeric

    enum DECSIZE = 30;

    alias ubyte NumericDigit;

    struct numeric {
        int            ndigits;        /* number of digits in digits[] - can be 0! */
        int            weight;            /* weight of first digit */
        int            rscale;            /* result scale */
        int            dscale;            /* display scale */
        int            sign;            /* NUMERIC_POS, NUMERIC_NEG, or NUMERIC_NAN */
        NumericDigit *buf;            /* start of alloc'd space for digits[] */
        NumericDigit *digits;        /* decimal digits */
    };

    struct decimal {
        int            ndigits;        /* number of digits in digits[] - can be 0! */
        int            weight;            /* weight of first digit */
        int            rscale;            /* result scale */
        int            dscale;            /* display scale */
        int            sign;            /* NUMERIC_POS, NUMERIC_NEG, or NUMERIC_NAN */
        NumericDigit[DECSIZE] digits;        /* decimal digits */
    }

    int PGTYPESnumeric_to_int(numeric *nv, int *ip);

    // non blocking calls

    alias PostgresPollingStatusType = int;
    enum {
        PGRES_POLLING_FAILED = 0,
        PGRES_POLLING_READING,        /* These two indicate that one may      */
        PGRES_POLLING_WRITING,        /* use select before polling again.   */
        PGRES_POLLING_OK,
        PGRES_POLLING_ACTIVE        /* unused; keep for awhile for backwards
                                     * compatibility */
    } 

    PostgresPollingStatusType PQconnectPoll(PGconn *conn);

    int    PQsocket(const PGconn *conn);

    int PQsendQuery(PGconn *conn, const char *command);

    int PQsendQueryParams(
            PGconn *conn,
            const char *command,
            int nParams,
            const Oid *paramTypes,
            const char ** paramValues,
            const int *paramLengths,
            const int *paramFormats,
            int resultFormat);

    int PQsendQueryPrepared(
            PGconn *conn,
            const char *stmtName,
            int nParams,
            const char **paramValues,
            const int *paramLengths,
            const int *paramFormats,
            int resultFormat);

    int PQsendDescribePrepared(PGconn *conn, const char *stmtName);
    int    PQsendDescribePrepared(PGconn *conn, const char *stmt);
    int PQconsumeInput(PGconn *conn);
    int PQisBusy(PGconn *conn);
    int PQsetnonblocking(PGconn *conn, int arg);
    int PQisnonblocking(const PGconn *conn);

    int    PQflush(PGconn *conn);

    struct PGnotify {
        char* relname;
        int be_pid;
        char* extra;
        private PGnotify* next;
    }

    PGnotify *PQnotifies(PGconn *conn);
    void PQfreemem(void *ptr);



    enum   TYPTYPE_BASE    =    'b'; /* base type (ordinary scalar type) */
    enum   TYPTYPE_COMPOSITE =    'c' ;/* composite (e.g., table's rowtype) */
    enum   TYPTYPE_DOMAIN    =    'd' ;/* domain over another type */
    enum   TYPTYPE_ENUM        ='e' ;/* enumerated type */
    enum   TYPTYPE_PSEUDO    =    'p'; /* pseudo-type */
    enum   TYPTYPE_RANGE        ='r'; /* range type */
        
    enum   TYPCATEGORY_INVALID    ='\0';    /* not an allowed category */
    enum   TYPCATEGORY_ARRAY        ='A';
    enum   TYPCATEGORY_BOOLEAN    ='B';
    enum   TYPCATEGORY_COMPOSITE=    'C';
    enum   TYPCATEGORY_DATETIME    ='D';
    enum   TYPCATEGORY_ENUM        ='E';
    enum   TYPCATEGORY_GEOMETRIC=    'G';
    enum   TYPCATEGORY_NETWORK    ='I'        ;/* think INET */
    enum   TYPCATEGORY_NUMERIC    ='N';
    enum   TYPCATEGORY_PSEUDOTYPE ='P';
    enum   TYPCATEGORY_RANGE        ='R';
    enum   TYPCATEGORY_STRING    =    'S';
    enum   TYPCATEGORY_TIMESPAN=    'T';
    enum   TYPCATEGORY_USER        ='U';
    enum   TYPCATEGORY_BITSTRING=    'V'    ;    /* er ... "varbit"? */
    enum   TYPCATEGORY_UNKNOWN    ='X';

    bool IsPolymorphicType(int typid) 
    {
        return ((typid) == ANYELEMENTOID || 
            (typid) == ANYARRAYOID || 
            (typid) == ANYNONARRAYOID || 
            (typid) == ANYENUMOID || 
            (typid) == ANYRANGEOID);
    }
}

