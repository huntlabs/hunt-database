module test.mysqlclient.MySQLTransactionTest;

import test.Common;
import test.mysqlclient.Common;
import test.mysqlclient.MySQLTestBase;

import hunt.database.base;
import hunt.database.base.impl;
import hunt.database.driver.mysql;
import hunt.database.driver.mysql.impl;

import hunt.Assert;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging;
import hunt.Object;
import hunt.util.Common;
import hunt.util.UnitTest;

import core.atomic;
import std.conv;

/**
 * 
 * See_Also:
 *     https://dev.mysql.com/doc/refman/8.0/en/sql-syntax-transactions.html
 */
class MySQLTransactionTest : MySQLTestBase {

    mixin TestSettingTemplate;

    MySQLPool pool;
    
    // Consumer!(Action1!Transaction) transactionConnector;

    // this() {
    //     connector = handler -> {
    //         if (pool == null) {
    //             pool = MySQLPool.pool(vertx, options, new PoolOptions().setMaxSize(1));
    //         }
            // pool.begin(handler);
    //     };
    // }

    @Before
    void setup() {
        initConnector();
    }

    @After
    void teardown() {
    }

    // @Test
    // void testReleaseConnectionOnCommit() {
    //     connector((SqlConnection conn) {
    //         Transaction transaction = conn.begin();
    //         deleteFromMutableTable(transaction, () {
    //             string sql = "INSERT INTO mutable (id, val) VALUES (9, 'Whatever');";
    //             transaction.query(sql, (RowSetAsyncResult ar) {
    //                 trace("running here");
    //                 RowSet result = asyncAssertSuccess(ar);
    //                 assert(1  == result.rowCount());
    //                 transaction.commit((VoidAsyncResult ar2) {
    //                     trace("running here");
    //                     Void v = asyncAssertSuccess!Void(ar2);
    //                     trace("running here: ", v is null);
    //                     // transaction.close();
    //                     // Try acquire a connection
    //                     // pool.getConnection(ctx.asyncAssertSuccess(v2 -> {
    //                     //     async.complete();
    //                     // }));
    //                 });
    //             });
    //         });
    //     });
    // }

//     @Test
//     void testReleaseConnectionOnRollback() {
// /*
// SET autocommit=0;
// BEGIN;
// INSERT INTO mutable (val) VALUES ('Whatever');
// ROLLBACK;

// INSERT INTO mutable (val) VALUES ('success');
// COMMIT;
// */
//         connector((SqlConnection conn) {
//             Transaction transaction = conn.begin();
//             deleteFromMutableTable(transaction, () {
//                 // SET autocommit=1; 
//                 string sql = "INSERT INTO mutable (id, val) VALUES (9, 'Whatever');";
//                 transaction.query(sql, (RowSetAsyncResult ar) {
//                     trace("running here");
//                     RowSet result = asyncAssertSuccess(ar);
//                     assert(1  == result.rowCount());
//                     transaction.rollback((VoidAsyncResult ar2) {
//                         trace("running here");
//                         Void v = asyncAssertSuccess!Void(ar2);
//                         trace("running here: ", v is null);
//                         // // Try acquire a connection
//                         // pool.getConnection(ctx.asyncAssertSuccess(v2 -> {
//                         //     async.complete();
//                         // }));
//                     });
//                 });
//             });
//         });
//     }

    // @Test
    // void testReleaseConnectionOnSetRollback() {
    //     Async async = ctx.async();
    //     connector.accept(ctx.asyncAssertSuccess(conn -> {
    //         conn.abortHandler(v -> {
    //             // Try acquire the same connection on rollback
    //             pool.getConnection(ctx.asyncAssertSuccess(v2 -> {
    //                 async.complete();
    //             }));
    //         });
    //         // Failure will abort
    //         conn.query("SELECT whatever from DOES_NOT_EXIST", ctx.asyncAssertFailure(result -> { }));
    //     }));
    // }

    // @Test
    // void testCommitWithPreparedQuery() {
    //     Async async = ctx.async();
    //     connector.accept(ctx.asyncAssertSuccess(transaction -> {
    //         deleteFromMutableTable(transaction, () -> {
    //             transaction.preparedQuery("INSERT INTO mutable (id, val) VALUES (?, ?)", Tuple.of(13, "test message1"), ctx.asyncAssertSuccess(result -> {
    //                 assert(1, result.rowCount());
    //                 transaction.commit(ctx.asyncAssertSuccess(v1 -> {
    //                     pool.query("SELECT id, val from mutable where id = 13", ctx.asyncAssertSuccess(rowSet -> {
    //                         assert(1, rowSet.size());
    //                         Row row = rowSet.iterator().next();
    //                         assert(13, row.getInteger("id"));
    //                         assert("test message1", row.getString("val"));
    //                         async.complete();
    //                     }));
    //                 }));
    //             }));
    //         });
    //     }));
    // }

    @Test
    void testCommitWithQuery() {
        connector((SqlConnection conn) {
            Transaction transaction = conn.begin();
            deleteFromMutableTable(transaction, () {
                string sql = "INSERT INTO mutable (id, val) VALUES (14, 'test message2');";
                transaction.query(sql, (RowSetAsyncResult ar) {
                    trace("running here");
                    RowSet result = asyncAssertSuccess(ar);
                    assert(1 == result.rowCount());
                    transaction.commit((VoidAsyncResult vr) {
                        Void v = asyncAssertSuccess!Void(vr);
                        trace("running here: ", v is null);
                        string sql2 = "SELECT id, val from mutable where id = 14";
                        conn.query(sql2, (RowSetAsyncResult ar2) {
                            trace("running here");
                            RowSet rowSet = asyncAssertSuccess(ar2);
                            assert(1 == rowSet.size());
                            Row row = rowSet.iterator().front();
                            assert(14 == row.getInteger("id"));
                            assert("test message2" == row.getString("val"));
                            warning("Done...");
                        });
                    });
                });
            });
        });
    }
}