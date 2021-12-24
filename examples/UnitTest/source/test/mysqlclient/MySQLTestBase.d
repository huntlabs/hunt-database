module test.mysqlclient.MySQLTestBase;

import hunt.database.base;
import hunt.database.base.SqlConnection;

import hunt.Functions;
import hunt.logging;

abstract class MySQLTestBase {

    Consumer!(Action1!SqlConnection) connector;

    protected void initConnector();   
    protected void closeConnector(); 

    static void deleteFromMutableTable(SqlClient client, Action completionHandler) {
        client.query("TRUNCATE TABLE mutable", (RowSetAsyncResult ar)  {
            if(ar.failed()) {
                warning(ar.cause().msg);
            } else if(completionHandler !is null) {
                completionHandler();
            }                
        });
    }
}
