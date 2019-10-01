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
	testUnits!(PgPreparedQueryTest);
	// testUnits!(PgPoolTest);
	// testUnits!(PgSimpleQueryTest);
	// testUnits!(PgTransactionTest);

	// testUnits!(UtilTest);


	getchar();
}
