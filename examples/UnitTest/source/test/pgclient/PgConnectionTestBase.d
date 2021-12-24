/*
 * Copyright (C) 2017 Julien Viet
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

module test.pgclient.PgConnectionTestBase;

import test.pgclient.PgClientTestBase;

import hunt.database.base;
import hunt.database.driver.postgresql;

// import java.util.ArrayList;
// import java.util.List;
// import java.util.concurrent.CompletableFuture;
// import java.util.concurrent.Executor;
// import java.util.concurrent.atomic.AtomicInteger;
// import java.util.concurrent.atomic.AtomicReference;

import hunt.Assert;
import hunt.Exceptions;
import hunt.logging;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.collection;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */

abstract class PgConnectionTestBase : PgClientTestBase!(SqlConnection) {

//     @Test
//     void testDisconnectAbruptly() {
//         Async async = ctx.async();
//         ProxyServer proxy = ProxyServer.create(vertx, options.getPort(), options.getHost());
//         proxy.proxyHandler(conn -> {
//             vertx.setTimer(200, id -> {
//                 conn.close();
//             });
//             conn.connect();
//         });
//         proxy.listen(8080, "localhost", ctx.asyncAssertSuccess(v1 -> {
//             options.setPort(8080).setHost("localhost");
//             connector.accept(ctx.asyncAssertSuccess(conn -> {
//                 conn.closeHandler(v2 -> {
//                     async.complete();
//                 });
//             }));
//         }));
//     }

//     @Test
//     void testProtocolError() {
//         Async async = ctx.async();
//         ProxyServer proxy = ProxyServer.create(vertx, options.getPort(), options.getHost());
//         CompletableFuture!(Void) connected = new CompletableFuture<>();
//         proxy.proxyHandler(conn -> {
//             connected.thenAccept(v -> {
//                 System.out.println("send bogus");
//                 Buffer bogusMsg = Buffer.buffer();
//                 bogusMsg.appendByte((byte) 'R'); // Authentication
//                 bogusMsg.appendInt(0);
//                 bogusMsg.appendInt(1);
//                 bogusMsg.setInt(1, bogusMsg.length() - 1);
//                 conn.clientSocket().write(bogusMsg);
//             });
//             conn.connect();
//         });
//         proxy.listen(8080, "localhost", ctx.asyncAssertSuccess(v1 -> {
//             options.setPort(8080).setHost("localhost");
//             connector.accept(ctx.asyncAssertSuccess(conn -> {
//                 AtomicInteger count = new AtomicInteger();
//                 conn.exceptionHandler(err -> {
//                     ctx.assertEquals(err.getClass(), UnsupportedOperationException.class);
//                     count.incrementAndGet();
//                 });
//                 conn.closeHandler(v -> {
//                     ctx.assertEquals(1, count.get());
//                     async.complete();
//                 });
//                 connected.complete(null);
//             }));
//         }));
//     }

    // @Test
    // void testTx() {
    //     connector((SqlConnection conn) {
    //         conn.query("BEGIN", (AsyncResult!RowSet ar) {
    //            if(ar.succeeded()) {
    //                RowSet result1 = ar.result();
    //                 assert(0 == result1.size());
    //                 assert(result1.iterator() !is null);
             
    //                 conn.query("COMMIT", (AsyncResult!RowSet ar) {
    //                     if(ar.succeeded()) {
    //                         RowSet result2 = ar.result();
    //                         assert(0 == result2.size());
    //                     } else {
    //                         warning(ar.cause().msg);
    //                     }
    //                     conn.close();
    //                 });

    //             } else {
    //                 warning(ar.cause().msg);
    //             }
    //         });
    //     });
    // }
    
// /*
    // @Test
    // void testSQLConnection() {
    //     connector((SqlConnection conn) {
    //          conn.query("SELECT 1", (AsyncResult!RowSet ar) {
    //             if(ar.succeeded()) {
    //                 RowSet result = ar.result();
    //                 assert(1 == result.rowCount());
    //             } else {
    //                 warning(ar.cause().msg);
    //             }

    //             conn.close();
    //         });
    //     });
    // }

    @Test
    void testSelectForQueryWithParams() {

        connector((SqlConnection conn) {
            trace("testing preparedQuery...");
            conn.preparedQuery("SELECT * FROM Fortune WHERE id=$1", Tuple.of(12), (AsyncResult!RowSet ar) {
                if(ar.succeeded()) {
                    RowSet result = ar.result();
                    assert(1 == result.rowCount());
                    Row r = result.iterator.front();
                    tracef("id: %d, message: %s", r.getValue("id").get!int(), r.getValue("message"));
                } else {
                    warning(ar.cause().msg);
                }

                // conn.close();
            });
        });
    }


//     @Test
//     void testUpdateError() {
//         Async async = ctx.async();
//         connector.accept(ctx.asyncAssertSuccess(conn -> {
//             conn.query("INSERT INTO Fortune (id, message) VALUES (1, 'Duplicate')", ctx.asyncAssertFailure(err -> {
//                 ctx.assertEquals("23505", ((PgException) err).getCode());
//                 conn.query("SELECT 1000", ctx.asyncAssertSuccess(result -> {
//                     ctx.assertEquals(1, result.size());
//                     ctx.assertEquals(1000, result.iterator().next().getInteger(0));
//                     async.complete();
//                 }));
//             }));
//         }));
//     }

//     @Test
//     void testBatchInsertError() {
//         Async async = ctx.async();
//         connector.accept(ctx.asyncAssertSuccess(conn -> {
//             int id = randomWorld();
//             List!(Tuple) batch = new ArrayList<>();
//             batch.add(Tuple.of(id, 3));
//             conn.preparedBatch("INSERT INTO World (id, randomnumber) VALUES ($1, $2)", batch, ctx.asyncAssertFailure(err -> {
//                 ctx.assertEquals("23505", ((PgException) err).getCode());
//                 conn.query("SELECT 1000", ctx.asyncAssertSuccess(result -> {
//                     ctx.assertEquals(1, result.size());
//                     ctx.assertEquals(1000, result.iterator().next().getInteger(0));
//                     async.complete();
//                 }));
//             }));
//         }));
//     }

//     @Test
//     void testCloseOnUndeploy() {
//         Async done = ctx.async();
//         vertx.deployVerticle(new AbstractVerticle() {
//             override
//             void start(Promise!(Void) startPromise) {
//                 connector.accept(ctx.asyncAssertSuccess(conn -> {
//                     conn.closeHandler(v -> {
//                         done.complete();
//                     });
//                     startPromise.complete();
//                 }));
//             }
//         }, ctx.asyncAssertSuccess(id -> {
//             vertx.undeploy(id);
//         }));
//     }

//     @Test
//     void testTransactionCommit() {
//         testTransactionCommit(ctx, Runnable::run);
//     }

//     @Test
//     void testTransactionCommitFromAnotherThread() {
//         testTransactionCommit(ctx, t -> new Thread(t).start());
//     }

//     private void testTransactionCommit(, Executor exec) {
//         Async done = ctx.async();
//         connector.accept(ctx.asyncAssertSuccess(conn -> {
//             deleteFromTestTable(ctx, conn, () -> {
//                 exec.execute(() -> {
//                     Transaction tx = conn.begin();
//                     AtomicInteger u1 = new AtomicInteger();
//                     AtomicInteger u2 = new AtomicInteger();
//                     conn.query("INSERT INTO Test (id, val) VALUES (1, 'val-1')", ctx.asyncAssertSuccess(res1 -> {
//                         u1.addAndGet(res1.rowCount());
//                         exec.execute(() -> {
//                             conn.query("INSERT INTO Test (id, val) VALUES (2, 'val-2')", ctx.asyncAssertSuccess(res2 -> {
//                                 u2.addAndGet(res2.rowCount());
//                                 exec.execute(() -> {
//                                     tx.commit(ctx.asyncAssertSuccess(v -> {
//                                         ctx.assertEquals(1, u1.get());
//                                         ctx.assertEquals(1, u2.get());
//                                         conn.query("SELECT id FROM Test WHERE id=1 OR id=2", ctx.asyncAssertSuccess(result -> {
//                                             ctx.assertEquals(2, result.size());
//                                             done.complete();
//                                         }));
//                                     }));
//                                 });
//                             }));
//                         });
//                     }));
//                 });
//             });
//         }));
//     }

//     @Test
//     void testTransactionRollback() {
//         testTransactionRollback(ctx, Runnable::run);
//     }

//     @Test
//     void testTransactionRollbackFromAnotherThread() {
//         testTransactionRollback(ctx, t -> new Thread(t).start());
//     }

//     private void testTransactionRollback(, Executor exec) {
//         Async done = ctx.async();
//         connector.accept(ctx.asyncAssertSuccess(conn -> {
//             deleteFromTestTable(ctx, conn, () -> {
//                 exec.execute(() -> {
//                     Transaction tx = conn.begin();
//                     AtomicInteger u1 = new AtomicInteger();
//                     AtomicInteger u2 = new AtomicInteger();
//                     conn.query("INSERT INTO Test (id, val) VALUES (1, 'val-1')", ctx.asyncAssertSuccess(res1 -> {
//                         u1.addAndGet(res1.rowCount());
//                         exec.execute(() -> {

//                         });
//                         conn.query("INSERT INTO Test (id, val) VALUES (2, 'val-2')", ctx.asyncAssertSuccess(res2 -> {
//                             u2.addAndGet(res2.rowCount());
//                             exec.execute(() -> {
//                                 tx.rollback(ctx.asyncAssertSuccess(v -> {
//                                     ctx.assertEquals(1, u1.get());
//                                     ctx.assertEquals(1, u2.get());
//                                     conn.query("SELECT id FROM Test WHERE id=1 OR id=2", ctx.asyncAssertSuccess(result -> {
//                                         ctx.assertEquals(0, result.size());
//                                         done.complete();
//                                     }));
//                                 }));
//                             });
//                         }));
//                     }));
//                 });
//             });
//         }));
//     }

//     @Test
//     void testTransactionAbort() {
//         Async done = ctx.async();
//         connector.accept(ctx.asyncAssertSuccess(conn -> {
//             deleteFromTestTable(ctx, conn, () -> {
//                 Transaction tx = conn.begin();
//                 AtomicInteger failures = new AtomicInteger();
//                 tx.abortHandler(v -> ctx.assertEquals(0, failures.getAndIncrement()));
//                 AtomicReference!(AsyncResult!(RowSet)) queryAfterFailed = new AtomicReference<>();
//                 AtomicReference!(AsyncResult!(Void)) commit = new AtomicReference<>();
//                 conn.query("INSERT INTO Test (id, val) VALUES (1, 'val-1')", ar1 -> { });
//                 conn.query("INSERT INTO Test (id, val) VALUES (1, 'val-2')", ar2 -> {
//                     ctx.assertNotNull(queryAfterFailed.get());
//                     ctx.assertTrue(queryAfterFailed.get().failed());
//                     ctx.assertNotNull(commit.get());
//                     ctx.assertTrue(commit.get().failed());
//                     ctx.assertTrue(ar2.failed());
//                     ctx.assertEquals(1, failures.get());
//                     // This query won't be made in the same TX
//                     conn.query("SELECT id FROM Test WHERE id=1", ctx.asyncAssertSuccess(result -> {
//                         ctx.assertEquals(0, result.size());
//                         done.complete();
//                     }));
//                 });
//                 conn.query("SELECT id FROM Test", queryAfterFailed::set);
//                 tx.commit(commit::set);
//             });
//         }));
//     }
}
