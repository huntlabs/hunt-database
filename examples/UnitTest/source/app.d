import std.stdio;

import hunt.util.UnitTest;

import test.pgclient.PgConnectionTest;


void main()
{
	testUnits!(PgConnectionTest);

	getchar();
}
