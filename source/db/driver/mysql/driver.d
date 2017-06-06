module db.driver.mysql.driver;

version(USE_MYSQL ):
version(MySQL_51) {
	// we good
} else version(Less_Than_MySQL_51) {
	// we good
} else {
pragma(msg, "NOTE: If you are using MySQL 5.1 or newer, specify -version=MySQL_51 to dmd to avoid segfaults. If you are on an older version, you can shut this message up with -version=Less_Than_MySQL_51");
}
version(Windows) {
	pragma(lib, "libmysql");
}
else {
	pragma(msg,"use mysqlclient in linux");
	pragma(lib, "mysqlclient");
}

import std.stdio;
import std.exception;
import std.string;
import std.conv;
import std.typecons;
import core.stdc.config;

///The MySQL server has gone away.
enum CR_SERVER_GONE_ERROR = 2006;
///The connection to the server was lost during the query.
enum CR_SERVER_LOST = 2013;



extern(System) {
	struct MYSQL;
	struct MYSQL_RES;
	struct MYSQL_STMT;
	/* typedef */ alias const(ubyte)* cstring;

	struct MYSQL_FIELD {
		cstring name;                 /* Name of column */
		cstring org_name;             /* Original column name, if an alias */ 
		cstring table;                /* Table of column if column was a field */
		cstring org_table;            /* Org table name, if table was an alias */
		cstring db;                   /* Database for table */
		cstring catalog;	      /* Catalog for table */
		cstring def;                  /* Default value (set by mysql_list_fields) */
		c_ulong length;       /* Width of column (create length) */
		c_ulong max_length;   /* Max width for selected set */
		uint name_length;
		uint org_name_length;
		uint table_length;
		uint org_table_length;
		uint db_length;
		uint catalog_length;
		uint def_length;
		uint flags;         /* Div flags */
		uint decimals;      /* Number of decimals in field */
		uint charsetnr;     /* Character set */
		uint type; /* Type of field. See mysql_com.h for types */
		// type is actually an enum btw

		version(MySQL_51) {
			void* extension;
		}
	}

	enum mysql_option   
	{  
		MYSQL_OPT_CONNECT_TIMEOUT, MYSQL_OPT_COMPRESS, MYSQL_OPT_NAMED_PIPE,  
		MYSQL_INIT_COMMAND, MYSQL_READ_DEFAULT_FILE, MYSQL_READ_DEFAULT_GROUP,  
		MYSQL_SET_CHARSET_DIR, MYSQL_SET_CHARSET_NAME, MYSQL_OPT_LOCAL_INFILE,  
		MYSQL_OPT_PROTOCOL, MYSQL_SHARED_MEMORY_BASE_NAME, MYSQL_OPT_READ_TIMEOUT,  
		MYSQL_OPT_WRITE_TIMEOUT, MYSQL_OPT_USE_RESULT,  
		MYSQL_OPT_USE_REMOTE_CONNECTION, MYSQL_OPT_USE_EMBEDDED_CONNECTION,  
		MYSQL_OPT_GUESS_CONNECTION, MYSQL_SET_CLIENT_IP, MYSQL_SECURE_AUTH,  
		MYSQL_REPORT_DATA_TRUNCATION, MYSQL_OPT_RECONNECT  
	}; 

	/* typedef */ 
	alias cstring* MYSQL_ROW;

	cstring mysql_get_client_info();
	MYSQL* mysql_init(MYSQL*);
	uint mysql_errno(MYSQL*);
	cstring mysql_error(MYSQL*);

	MYSQL* mysql_real_connect(MYSQL*, cstring, cstring, cstring, cstring, uint, cstring, c_ulong);

	int mysql_options(MYSQL *mysql, mysql_option option, const void *arg);

	int mysql_query(MYSQL*, cstring);
	int mysql_ping(MYSQL*);


	void mysql_close(MYSQL*);

	ulong mysql_num_rows(MYSQL_RES*);
	uint mysql_num_fields(MYSQL_RES*);
	bool mysql_eof(MYSQL_RES*);

	ulong mysql_affected_rows(MYSQL*);
	ulong mysql_insert_id(MYSQL*);

	MYSQL_RES* mysql_store_result(MYSQL*);
	MYSQL_RES* mysql_use_result(MYSQL*);

	MYSQL_ROW mysql_fetch_row(MYSQL_RES *);
	c_ulong* mysql_fetch_lengths(MYSQL_RES*);
	MYSQL_FIELD* mysql_fetch_field(MYSQL_RES*);
	MYSQL_FIELD* mysql_fetch_fields(MYSQL_RES*);

	uint mysql_real_escape_string(MYSQL*, ubyte* to, cstring from, c_ulong length);

	void mysql_free_result(MYSQL_RES*);
	size_t mysql_thread_id(MYSQL* mysql);

	/*
	MYSQL_STMT* mysql_stmt_init(MYSQL*);
	void mysql_stmt_close(MYSQL_STMT*);
	int mysql_stmt_prepare(MYSQL_STMT*,cstring str,c_ulong length);
	*/
}


