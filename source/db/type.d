module db.type;
import db;
import std.datetime;
import std.variant;

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

enum TypeInfo 
{
	BOOL,
	NULL,
	INTEGER,
	STRING
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

interface DataSetWriter {
	void setFloat(int parameterIndex, float x);
	void setDouble(int parameterIndex, double x);
	void setBoolean(int parameterIndex, bool x);
	void setLong(int parameterIndex, long x);
	void setInt(int parameterIndex, int x);
	void setShort(int parameterIndex, short x);
	void setByte(int parameterIndex, byte x);
	void setBytes(int parameterIndex, byte[] x);
	void setUlong(int parameterIndex, ulong x);
	void setUint(int parameterIndex, uint x);
	void setUshort(int parameterIndex, ushort x);
	void setUbyte(int parameterIndex, ubyte x);
	void setUbytes(int parameterIndex, ubyte[] x);
	void setString(int parameterIndex, string x);
	void setDateTime(int parameterIndex, DateTime x);
	void setDate(int parameterIndex, Date x);
	void setTime(int parameterIndex, TimeOfDay x);
	void setVariant(int columnIndex, Variant x);

	void setNull(int parameterIndex);
	void setNull(int parameterIndex, int sqlType);
}

interface DataSetReader {
	bool getBoolean(int columnIndex);
	ubyte getUbyte(int columnIndex);
	ubyte[] getUbytes(int columnIndex);
	byte[] getBytes(int columnIndex);
	byte getByte(int columnIndex);
	short getShort(int columnIndex);
	ushort getUshort(int columnIndex);
	int getInt(int columnIndex);
	uint getUint(int columnIndex);
	long getLong(int columnIndex);
	ulong getUlong(int columnIndex);
	double getDouble(int columnIndex);
	float getFloat(int columnIndex);
	string getString(int columnIndex);
	DateTime getDateTime(int columnIndex);
	Date getDate(int columnIndex);
	TimeOfDay getTime(int columnIndex);
	Variant getVariant(int columnIndex);
	bool isNull(int columnIndex);
	bool wasNull();
}

