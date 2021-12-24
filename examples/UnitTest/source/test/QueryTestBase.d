module test.QueryTestBase;


import hunt.database.base;

import hunt.Assert;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging;
import hunt.util.Common;
import hunt.util.UnitTest;

import core.atomic;
import std.conv;

alias SqlConnectionHandler = Action1!SqlConnection;

abstract class QueryTestBase {

    Consumer!(SqlConnectionHandler) connector;

    static void insertIntoTestTable(SqlClient client, int amount, Action completionHandler) {
        shared int count = 0;
        for (int i = 0; i < 10; i++) {
            string sql = "INSERT INTO mutable (id, val) VALUES (" ~ i.to!string() ~ 
                ", 'Whatever-" ~ i.to!string() ~ "')";

            client.query(sql, 
            
                (AsyncResult!RowSet ar) {
                    if(ar.succeeded()) {
                        RowSet result = ar.result();

                        assert(1 == result.rowCount());
                        if (atomicOp!"+="(count, 1) == amount) {
                            completionHandler();
                        }
                    } else {
                        warning(ar.cause().msg);
                    }
                }
            );
        }
    }

    protected abstract void initConnector();
    protected abstract void closeConnector();

    protected void connect(SqlConnectionHandler handler) {
        connector(handler);
    }

    @Before
    void setUp() {
        initConnector();
        cleanTestTable();
    }

    @After
    void tearDown() {
        // closeConnector();
    }    


    private void cleanTestTable() {
        connect((SqlConnection conn) {
            conn.query("TRUNCATE TABLE mutable;", (RowSetAsyncResult ar)  {
                if(ar.failed()) {
                    warning(ar.cause().msg);
                }                
                // conn.close();
            });
        });
    }    
}