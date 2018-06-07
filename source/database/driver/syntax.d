module database.driver.syntax;

import database;

interface SqlSyntax
{
    string toString();
	string selectExpr();
	string whereExpr();
	string joinExpr();
	string groupByExpr();
	string havingExpr();
	string orderExpr();
	string limitExpr();
	string offsetExpr();
	string setExpr();
	string insertExpr();
	string autoIncreaseExpr();
	string showTables();
}

