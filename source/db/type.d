module db.type;

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
