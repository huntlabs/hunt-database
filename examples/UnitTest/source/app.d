import std.stdio;

import hunt.util.UnitTest;

import test.mysqlclient.MySQLQueryTest;
import test.mysqlclient.MySQLSimpleQueryTest;
import test.mysqlclient.Native41AuthenticatorTest;

import test.pgclient.PgConnectionTest;
import test.pgclient.PgSimpleQueryTest;
import test.pgclient.PgPreparedQueryTest;
import test.pgclient.PgTransactionTest;
import test.pgclient.UtilTest;


void main()
{

/* ------------------------------- MySQL Tests ------------------------------ */
	// testUnits!(MySQLQueryTest);
	testUnits!(MySQLSimpleQueryTest);
	// testUnits!(Native41AuthenticatorTest);

/* ---------------------------- PostgreSQL tests ---------------------------- */

	// testUnits!(PgConnectionTest);
	// testUnits!(PgPreparedQueryTest);
	// testUnits!(PgSimpleQueryTest);
	// testUnits!(PgTransactionTest);
	// testUnits!(UtilTest);


	getchar();
}
