import std.stdio;

import hunt.util.UnitTest;

import test.pgclient.PgConnectionTest;
import test.pgclient.UtilTest;


void main()
{
	testUnits!(PgConnectionTest);
	// testUnits!(UtilTest);


	getchar();
}
