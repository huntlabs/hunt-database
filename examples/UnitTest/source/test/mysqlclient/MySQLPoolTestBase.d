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

module test.mysqlclient.MySQLPoolTestBase;

import test.mysqlclient.MySQLTestBase;
import test.mysqlclient.Common;
import test.Common;

import hunt.database.base;
import hunt.database.mysql;

import hunt.Assert;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import core.atomic;
import std.conv;


/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
abstract class MySQLPoolTestBase : MySQLTestBase {


    mixin TestSettingTemplate;

    @Before
    void setup() {
    }

    @After
    void teardown() {
    }

    protected abstract MySQLPool createPool(MySQLConnectOptions options, int size);

    @Test
    void testPool() {
        int num = 10;
        shared int count = 0;
        MySQLPool pool = createPool(options, 4);
        for (int i = 0;i < num;i++) {
            pool.getConnection((SqlConnectionAsyncResult ar1) {
                warning("running here");
                SqlConnection conn = asyncAssertSuccess(ar1);
                conn.query("SELECT id, randomnumber from WORLD", (AsyncResult!RowSet ar) {
                    atomicOp!"+="(count, 1);
                    tracef("%d ===> Done.", count);
                    if (ar.succeeded()) {
                        RowSet result = ar.result();
                        assert(10000 == result.size(), result.size().to!string());
                    } else {
                        assert("closed" == ar.cause().message());
                    }
                    conn.close();
                });
            });
        }
    }

    // @Test
    // void testQuery() {
    //     int num = 1;
    //     MySQLPool pool = createPool(options, 4);
    //     for (int i = 0;i < num;i++) {
    //         pool.query("SELECT id, randomnumber from WORLD", (AsyncResult!RowSet ar) {
    //             if (ar.succeeded()) {
    //                 RowSet result = ar.result();
    //                 tracef("index: %d, size: %d", i, result.size());
    //                 assert(10000 == result.size());
    //             } else {
    //                 assert("closed" == ar.cause().message());
    //             }
    //         });
    //     }
    // }

    // @Test
    // void testQueryWithParams() {
    //     int num = 1000;
    //     Async async = ctx.async(num);
    //     MySQLPool pool = createPool(options, 4);
    //     for (int i = 0;i < num;i++) {
    //         pool.preparedQuery("SELECT id, randomnumber from WORLD where id=$1", Tuple.of(i + 1), ar -> {
    //             if (ar.succeeded()) {
    //                 SqlResult result = ar.result();
    //                 assert(1, result.size());
    //             } else {
    //                 ar.cause().printStackTrace();
    //                 assert("closed", ar.cause().getMessage());
    //             }
    //             async.countDown();
    //         });
    //     }
    // }

    // @Test
    // void testUpdate() {
    //     int num = 1000;
    //     Async async = ctx.async(num);
    //     MySQLPool pool = createPool(options, 4);
    //     for (int i = 0;i < num;i++) {
    //         pool.query("UPDATE Fortune SET message = 'Whatever' WHERE id = 9", ar -> {
    //             if (ar.succeeded()) {
    //                 SqlResult result = ar.result();
    //                 assert(1, result.rowCount());
    //             } else {
    //                 assert("closed", ar.cause().getMessage());
    //             }
    //             async.countDown();
    //         });
    //     }
    // }

    // @Test
    // void testUpdateWithParams() {
    //     int num = 1000;
    //     Async async = ctx.async(num);
    //     MySQLPool pool = createPool(options, 4);
    //     for (int i = 0;i < num;i++) {
    //         pool.preparedQuery("UPDATE Fortune SET message = 'Whatever' WHERE id = $1", Tuple.of(9), ar -> {
    //             if (ar.succeeded()) {
    //                 SqlResult result = ar.result();
    //                 assert(1, result.rowCount());
    //             } else {
    //                 assert("closed", ar.cause().getMessage());
    //             }
    //             async.countDown();
    //         });
    //     }
    // }

    // @Test
    // void testReconnect() {
    //     Async async = ctx.async();
    //     ProxyServer proxy = ProxyServer.create(vertx, options.getPort(), options.getHost());
    //     AtomicReference<ProxyServer.Connection> proxyConn = new AtomicReference<>();
    //     proxy.proxyHandler(conn -> {
    //         proxyConn.set(conn);
    //         conn.connect();
    //     });
    //     proxy.listen(8080, "localhost", ctx.asyncAssertSuccess(v1 -> {
    //         MySQLPool pool = createPool(new MySQLConnectOptions(options).setPort(8080).setHost("localhost"), 1);
    //         pool.getConnection(ctx.asyncAssertSuccess(conn1 -> {
    //             proxyConn.get().close();
    //             conn1.closeHandler(v2 -> {
    //                 conn1.query("never-read", ctx.asyncAssertFailure(err -> {
    //                     pool.getConnection(ctx.asyncAssertSuccess(conn2 -> {
    //                         conn2.query("SELECT id, randomnumber from WORLD", ctx.asyncAssertSuccess(v3 -> {
    //                             async.complete();
    //                         }));
    //                     }));
    //                 }));
    //             });
    //         }));
    //     }));
    // }

    // @Test
    // void testCancelRequest() {
    //     Async async = ctx.async();
    //     MySQLPool pool = createPool(options, 4);
    //     pool.getConnection(ctx.asyncAssertSuccess(conn -> {
    //         conn.query("SELECT pg_sleep(10)", ctx.asyncAssertFailure(error -> {
    //             assert("canceling statement due to user request", error.getMessage());
    //             conn.close();
    //             async.complete();
    //         }));
    //         ((PgConnection)conn).cancelRequest(ctx.asyncAssertSuccess());
    //     }));
    // }
}
