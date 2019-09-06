module test.mysqlclient.MySQLTestBase;

import hunt.database.base.SqlConnection;

import hunt.Functions;

abstract class MySQLTestBase {

    Consumer!(Action1!SqlConnection) connector;

    protected void initConnector();   
    protected void closeConnector(); 
}
