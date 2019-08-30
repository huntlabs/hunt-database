import std.stdio;

import hunt.util.UnitTest;

import test.pgclient.PgConnectionTest;
import test.pgclient.PgSimpleQueryTest;
import test.pgclient.PgPreparedQueryTest;
import test.pgclient.UtilTest;


void main()
{
	// testUnits!(PgConnectionTest);
	testUnits!(PgPreparedQueryTest);
	// testUnits!(PgSimpleQueryTest);
	// testUnits!(UtilTest);


	getchar();
}
