import std.stdio;

import hunt.util.UnitTest;

import test.pgclient.PgConnectionTest;
import test.pgclient.PgSimpleQueryTest;
import test.pgclient.PgPreparedQueryTest;
import test.pgclient.PgTransactionTest;
import test.pgclient.UtilTest;

import test.mysqlclient.Native41AuthenticatorTest;


void main()
{

/* ------------------------------- MySQL Tests ------------------------------ */
	testUnits!(Native41AuthenticatorTest);

/* ---------------------------- PostgreSQL tests ---------------------------- */

	// testUnits!(PgConnectionTest);
	// testUnits!(PgPreparedQueryTest);
	// testUnits!(PgSimpleQueryTest);
	// testUnits!(PgTransactionTest);
	// testUnits!(UtilTest);


	getchar();
}
