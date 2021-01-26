import std.stdio;

import hunt.util.UnitTest;

import test.mysqlclient.MySQLQueryTest;
import test.mysqlclient.MySQLSimpleQueryTest;
import test.mysqlclient.Native41AuthenticatorTest;
import test.mysqlclient.MySQLPreparedQueryTest;
import test.mysqlclient.MySQLPoolTest;
import test.mysqlclient.MySQLTransactionTest;

import test.pgclient.PgConnectionTest;
import test.pgclient.PgSimpleQueryTest;
import test.pgclient.PgPreparedQueryTest;
import test.pgclient.PgPoolTest;
import test.pgclient.PgTransactionTest;
import test.pgclient.UtilTest;

import test.RowBindingTest;


/**
 * https://blog.csdn.net/wangdaoyin2010/article/details/82770988
 * 
 * update dj_data SET data_content='\175\175'::bytea where terminal_id='321'; 
 * 
 * insert into userinfo(nickname, age, image) VALUES('image', 12, '\x010203')
 */

void main()
{

/* ------------------------------- MySQL Tests ------------------------------ */
	// testUnits!(MySQLQueryTest);
	// testUnits!(MySQLSimpleQueryTest);
	// testUnits!(MySQLPreparedQueryTest);
	// testUnits!(Native41AuthenticatorTest);
	// testUnits!(MySQLPoolTest);
	// testUnits!(MySQLTransactionTest);

/* ---------------------------- PostgreSQL tests ---------------------------- */

	// testUnits!(PgConnectionTest);
	// testUnits!(PgPreparedQueryTest);
	// testUnits!(PgPoolTest);
	// testUnits!(PgSimpleQueryTest);
	// testUnits!(PgTransactionTest);

	// testUnits!(UtilTest);

/* ------------------------------- Row binding ------------------------------ */
	// testUnits!(RowBindingTest);

	getchar();
}
