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

module database.defined;

import std.datetime;
import std.variant;
import std.json;

// look other data type https://dev.mysql.com/doc/workbench/en/wb-migration-database-postgresql-typemapping.html?spm=5176.100239.blogcont69388.22.hCGHvq

enum FieldType
{
    FIELD_TYPE_CHAR,

    FIELD_TYPE_SHORT,
    FIELD_TYPE_INT,
    FIELD_TYPE_LONG,

    FIELD_TYPE_FLOAT,
    FIELD_TYPE_DOUBLE,

    FIELD_TYPE_STRING,

    FIELD_TYPE_DATE,
    FIELD_TYPE_TIME,
    FIELD_TYPE_DATE_TIME,

    FIELD_TYPE_RAW
}

enum ParamType
{
    PARAM_BOOL,
    PARAM_NULL,
    PARAM_INT,
    PARAM_STR,
    PARAM_LOB,
    PARAM_STMT,
    PARAM_INPUT_OUTPUT
}

enum SqlType {
    //sometimes referred to as a type code, that identifies the generic SQL type ARRAY.
    //ARRAY,
    ///sometimes referred to as a type code, that identifies the generic SQL type BIGINT.
    BIGINT,
    ///sometimes referred to as a type code, that identifies the generic SQL type BINARY.
    //BINARY,
    //sometimes referred to as a type code, that identifies the generic SQL type BIT.
    BIT,
    ///sometimes referred to as a type code, that identifies the generic SQL type BLOB.
    BLOB,
    ///somtimes referred to as a type code, that identifies the generic SQL type BOOLEAN.
    BOOLEAN,
    ///sometimes referred to as a type code, that identifies the generic SQL type CHAR.
    CHAR,
    ///sometimes referred to as a type code, that identifies the generic SQL type CLOB.
    CLOB,
    //somtimes referred to as a type code, that identifies the generic SQL type DATALINK.
    //DATALINK,
    ///sometimes referred to as a type code, that identifies the generic SQL type DATE.
    DATE,
    ///sometimes referred to as a type code, that identifies the generic SQL type DATETIME.
    DATETIME,
    ///sometimes referred to as a type code, that identifies the generic SQL type DECIMAL.
    DECIMAL,
    //sometimes referred to as a type code, that identifies the generic SQL type DISTINCT.
    //DISTINCT,
    ///sometimes referred to as a type code, that identifies the generic SQL type DOUBLE.
    DOUBLE,
    ///sometimes referred to as a type code, that identifies the generic SQL type FLOAT.
    FLOAT,
    ///sometimes referred to as a type code, that identifies the generic SQL type INTEGER.
    INTEGER,
    //sometimes referred to as a type code, that identifies the generic SQL type JAVA_OBJECT.
    //JAVA_OBJECT,
    ///sometimes referred to as a type code, that identifies the generic SQL type LONGNVARCHAR.
    LONGNVARCHAR,
    ///sometimes referred to as a type code, that identifies the generic SQL type LONGVARBINARY.
    LONGVARBINARY,
    ///sometimes referred to as a type code, that identifies the generic SQL type LONGVARCHAR.
    LONGVARCHAR,
    ///sometimes referred to as a type code, that identifies the generic SQL type NCHAR
    NCHAR,
    ///sometimes referred to as a type code, that identifies the generic SQL type NCLOB.
    NCLOB,
    ///The constant in the Java programming language that identifies the generic SQL value NULL.
    NULL,
    ///sometimes referred to as a type code, that identifies the generic SQL type NUMERIC.
    NUMERIC,
    ///sometimes referred to as a type code, that identifies the generic SQL type NVARCHAR.
    NVARCHAR,
    ///indicates that the SQL type is database-specific and gets mapped to a object that can be accessed via the methods getObject and setObject.
    OTHER,
    //sometimes referred to as a type code, that identifies the generic SQL type REAL.
    //REAL,
    //sometimes referred to as a type code, that identifies the generic SQL type REF.
    //REF,
    //sometimes referred to as a type code, that identifies the generic SQL type ROWID
    //ROWID,
    ///sometimes referred to as a type code, that identifies the generic SQL type SMALLINT.
    SMALLINT,
    //sometimes referred to as a type code, that identifies the generic SQL type XML.
    //SQLXML,
    //sometimes referred to as a type code, that identifies the generic SQL type STRUCT.
    //STRUCT,
    ///sometimes referred to as a type code, that identifies the generic SQL type TIME.
    TIME,
    //sometimes referred to as a type code, that identifies the generic SQL type TIMESTAMP.
    //TIMESTAMP,
    ///sometimes referred to as a type code, that identifies the generic SQL type TINYINT.
    TINYINT,
    ///sometimes referred to as a type code, that identifies the generic SQL type VARBINARY.
    VARBINARY,
    ///sometimes referred to as a type code, that identifies the generic SQL type VARCHAR.
    VARCHAR,
}

enum MysqlField {
	//MysqlFieldAffinity Numeric Types
	BIT,
	TINYINT,
	BOOL,
	SMALLINT,
	MEDIUMINT,
	INT,
	INTEGER,
	BIGINT,
	SERIAL,
	DECIMAL,
	DEC,
	FLOAT,
	DOUBLE,
	//MysqlFieldAffinity Date/Time Types
	DATE,
	DATETIME,
	TIMESTAMP,
	TIME,
	YEAR,
	//MysqlFieldAffinity String Types
	BINARY,
	VARBINARY,
	TINYBLOB,
	TINYTEXT,
	BLOB,
	TEXT,
	MEDIUMBLOB,
	MEDIUMTEXT,
	LONGBLOB,
	LONGTEXT,
	ENUM,
	SET
}
enum PgsqlField {
	//PgsqlFieldAffinity Numeric Types
	SMALLINT,
	INTEGER,
	BIGINT,
	DECIMAL,
	NUMERIC,
	REAL,
	DOUBLE,
	SMALLSERIAL,
	SERIAL,
	BIGSERIAL,
	//PgsqlFieldAffinity Monetary Type
	MONEY,
	//PgsqlFieldAffinity Character Types
	CHARACTER,
	TEXT,
	//PgsqlFieldAffinity Binary Data Type
	BYTEA,
	//PgsqlFieldAffinity Date/Time Types
	TIMESTAMP,
	DATE,
	TIME,
	INTERVAL,
	//PgsqlFieldAffinity Boolean Type
	BOOLEAN,
	//PgsqlFieldAffinity Enumerated Type
	ENUM,
	//PgsqlFieldAffinity Geometric Types
	POINT,
	LINE,
	LSEG,
	BOX,
	PATH,
	POLYGON,
	CIRCLE,
	//PgsqlFieldAffinity Network Address Types
	CIDR,
	INET,
	MACADDR,
	//PgsqlFieldAffinity Bit String Type
	BIT,
	//PgsqlFieldAffinity Text Search Types
	TSVECTOR,
	TSQUERY,
	//PgsqlFieldAffinity UUID Type
	UUID,
	//PgsqlFieldAffinity XML Type
	XML,
	//PgsqlFieldAffinity JSON Type
	JSON,
	//PgsqlFieldAffinity Arrays Type
	ARRAYS,
	//OTHER
}

enum SqliteField {
	//SqliteFieldAffinity INTEGER Types
	INT,
	INTEGER,
	TINYINT,
	SMALLINT,
	MEDIUMINT,
	BIGINT,
	UNSIGNEDBIGINT,
	INT2,
	INT8,
	//SqliteFieldAffinity Text Types
	CHARACTER,
	VARCHAR,
	NCHAR,
	NVARCHAR,
	TEXT,
	CLOB,
	//SqliteFieldAffinity Blob Type
	BLOB,
	//SqliteFieldAffinity REAL Type
	REAL,
	DOUBLE,
	FLOAT,
	//SqliteFieldAffinity Numeric Types
	NUMERIC,
	DECIMAL,
	BOOLEAN,
	DATE,
	DATETIME,
}

enum MysqlFieldAffinity {
	Numeric,
	DateTime,
	String,
	JSON,
}
enum PgsqlFieldAffinity {
	Numeric,
	Monetary,
	Character,
	BinaryData,
	DateTime,
	Boolean,
	Enumerated,
	Geometric,
	NetworkAddress ,
	BitString,
	TextSearch,
	UUID,
	XML,
	JSON,
	Arrays,
	Composite,
	Range,
	ObjectIdentifier,
	pg_lsn,
	Pseudos
}
enum SqliteFieldAffinity {
	TEXT,
	NUMERIC,
	INTEGER,
	REAL,
	BLOB,
}

class DlangDataType {
	string getName(){return "void";}
}

class dBoolType : DlangDataType {
	override string getName(){return "bool";}
}
class dByteType : DlangDataType {
	override string getName(){return "byte";}
}
class dUbyteType : DlangDataType {
	override string getName(){return "ubyte";}
}
class dShortType : DlangDataType {
	override string getName(){return "short";}
}
class dUshortType : DlangDataType {
	override string getName(){return "ushort";}
}
class dIntType : DlangDataType {
	override string getName(){return "int";}
}
class dUintType : DlangDataType {
	override string getName(){return "uint";}
}
class dLongType : DlangDataType {
	override string getName(){return "long";}
}
class dUlongType : DlangDataType {
	override string getName(){return "ulong";}
}
class dFloatType : DlangDataType {
	override string getName(){return "float";}
}
class dDoubleType : DlangDataType {
	override string getName(){return "double";}
}
class dRealType : DlangDataType {
	override string getName(){return "real";}
}
class dIfloatType : DlangDataType {
	override string getName(){return "ifloat";}
}
class dIdoubleType : DlangDataType {
	override string getName(){return "idouble";}
}
class dIrealType : DlangDataType {
	override string getName(){return "ireal";}
}
class dCfloatType : DlangDataType {
	override string getName(){return "cfloat";}
}
class dCdoubleType : DlangDataType {
	override string getName(){return "cdouble";}
}
class dCrealType : DlangDataType {
	override string getName(){return "creal";}
}
class dCharType : DlangDataType {
	override string getName(){return "char";}
}
class dWcharType : DlangDataType {
	override string getName(){return "wchar";}
}
class dDcharType : DlangDataType {
	override string getName(){return "dchar";}
}
class dEnumType : DlangDataType {
	override string getName(){return "enum";}
}
class dStructType : DlangDataType {
	override string getName(){return "struct";}
}
class dUnionType : DlangDataType {
	override string getName(){return "union";}
}
class dClassType : DlangDataType {
	override string getName(){return "class";}
}
class dStringType : DlangDataType {
	override string getName(){return "string";}
}
class dJsonType : DlangDataType {
	override string getName(){return "json";}
}
class dDateType : DlangDataType {
	override string getName(){return "date";}
}
class dTimeType : DlangDataType {
	override string getName(){return "time";}
}


DlangDataType getDlangDataType(T)(T val)
{
	static if(is(T == int))
		 return new dIntType();
	else static if(is(T == bool))
		 return new dBoolType();
	else static if(is(T == byte))
		 return new dByteType();
	else static if(is(T == ubyte))
		 return new dUbyteType();
	else static if(is(T == short))
		 return new dShortType();
	else static if(is(T == ushort))
		 return new dUshortType();
	else static if(is(T == uint))
		 return new dUintType();
	else static if(is(T == long))
		 return new dLongType();
	else static if(is(T == float))
		 return new dFloatType();
	else static if(is(T == double))
		 return new dDoubleType();
	else static if(is(T == real))
		 return new dRealType();
	else static if(is(T == ifloat))
		 return new dIfloatType();
	else static if(is(T == idouble))
		 return new dIdoubleType();
	else static if(is(T == ireal))
		 return new dIrealType();
	else static if(is(T == cfloat))
		 return new dCfloatType();
	else static if(is(T == cdouble))
		 return new dCdoubleType();
	else static if(is(T == creal))
		 return new dCrealType();
	else static if(is(T == char))
		 return new dCharType();
	else static if(is(T == wchar))
		 return new dWcharType();
	else static if(is(T == dchar))
		 return new dCharType();
	else static if(is(T == enum))
		 return new dEnumType();
	else static if(is(T == JSONValue))
		 return new dJsonType();
	else static if(is(T == SysTime))
		 return new dTimeType();
	else static if(is(T == DateTime))
		 return new dDateType();
	else 
		 return new dStringType();
}
string getDlangDataTypeStr(T)()
{
	static if(is(T == int))
		return "dIntType";
	else static if(is(T == bool))
		return "dBoolType";
	else static if(is(T == byte))
		return "dByteType";
	else static if(is(T == ubyte))
		return "dUbyteType";
	else static if(is(T == short))
		return "dShortType";
	else static if(is(T == ushort))
		return "dUshortType";
	else static if(is(T == uint))
		return "dUintType";
	else static if(is(T == long))
		return "dLongType";
	else static if(is(T == float))
		return "dFloatType";
	else static if(is(T == double))
		return "dDoubleType";
	else static if(is(T == real))
		return "dRealType";
	else static if(is(T == ifloat))
		return "dIfloatType";
	else static if(is(T == idouble))
		return "dIdoubleType";
	else static if(is(T == ireal))
		return "dIrealType";
	else static if(is(T == cfloat))
		return "dCfloatType";
	else static if(is(T == cdouble))
		return "dCdoubleType";
	else static if(is(T == creal))
		return "dCrealType";
	else static if(is(T == char))
		return "dCharType";
	else static if(is(T == wchar))
		return "dWcharType";
	else static if(is(T == dchar))
		return "dCharType";
	else static if(is(T == enum))
		return "dEnumType";
	else static if(is(T == JSONValue))
		return "dJsonType";
	else static if(is(T == SysTime))
		return "dTimeType";
	else static if(is(T == DateTime))
		return "dDateType";
	else 
		return "dStringType";
}
string getDlangTypeStr(T)()
{
	static if(is(T == int))
		return "int";
	else static if(is(T == bool))
		return "bool";
	else static if(is(T == byte))
		return "byte";
	else static if(is(T == ubyte))
		return "ubyte";
	else static if(is(T == short))
		return "short";
	else static if(is(T == ushort))
		return "ushort";
	else static if(is(T == uint))
		return "uint";
	else static if(is(T == long))
		return "long";
	else static if(is(T == float))
		return "float";
	else static if(is(T == double))
		return "double";
	else static if(is(T == real))
		return "real";
	else static if(is(T == ifloat))
		return "ifloat";
	else static if(is(T == idouble))
		return "idouble";
	else static if(is(T == ireal))
		return "ireal";
	else static if(is(T == cfloat))
		return "cfloat";
	else static if(is(T == cdouble))
		return "cdouble";
	else static if(is(T == creal))
		return "creal";
	else static if(is(T == char))
		return "char";
	else static if(is(T == wchar))
		return "wchar";
	else static if(is(T == dchar))
		return "dchar";
	else static if(is(T == JSONValue))
		return "JSONValue";
	else 
		return "string";
}

enum JoinMethod : string {
    InnerJoin = " INNER JOIN ",
    LeftJoin = " LEFT JOIN ",
    RightJoin = " RIGHT JOIN ",
    FullJoin = " FULL JOIN ",
    CrossJoin = " CROSS JOIN ",
}
enum Method : string {
    Select = " SELECT ",
    Insert = " INSERT INTO ",
    Update = " UPDATE ",
    Delete = " DELETE FROM",
	Count = " SELECT count(*) FROM "
}
enum Relation : string {
    And = " AND ", 
    Or = " OR "
}
enum CompareType : string {
    eq = " = ", 
    ne = " != ", 
    gt = " > ", 
    lt = " < ", 
    ge = " >= ", 
    le = " <= ", 
    eqnull = " is ",
    nenull = " is not ",
    like = " like "
}
