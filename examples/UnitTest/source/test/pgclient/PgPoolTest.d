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

module test.pgclient.PgPoolTest;

import test.pgclient.PgPoolTestBase;

import hunt.database.base;
import hunt.database.driver.postgresql;

import hunt.Assert;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging;
import hunt.util.Common;
import hunt.util.UnitTest;

import core.atomic;
import std.conv;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class PgPoolTest : PgPoolTestBase {

    override
    protected PgPool createPool(PgConnectOptions options, int size) {
        return PgPool.pool(options, new PoolOptions().setMaxSize(size));
    }

    // @Test
    // void testReconnectQueued() {
    //     Async async = ctx.async();
    //     ProxyServer proxy = ProxyServer.create(vertx, options.getPort(), options.getHost());
    //     AtomicReference<ProxyServer.Connection> proxyConn = new AtomicReference<>();
    //     proxy.proxyHandler(conn -> {
    //         proxyConn.set(conn);
    //         conn.connect();
    //     });
    //     proxy.listen(8080, "localhost", ctx.asyncAssertSuccess(v1 -> {
    //         PgPool pool = createPool(new PgConnectOptions(options).setPort(8080).setHost("localhost"), 1);
    //         pool.getConnection(ctx.asyncAssertSuccess(conn -> {
    //             proxyConn.get().close();
    //         }));
    //         pool.getConnection(ctx.asyncAssertSuccess(conn -> {
    //             conn.query("SELECT id, randomnumber from WORLD", ctx.asyncAssertSuccess(v2 -> {
    //                 async.complete();
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testAuthFailure() {
    //     Async async = ctx.async();
    //     PgPool pool = createPool(new PgConnectOptions(options).setPassword("wrong"), 1);
    //     pool.query("SELECT id, randomnumber from WORLD", ctx.asyncAssertFailure(v2 -> {
    //         async.complete();
    //     }));
    // }

    // @Test
    // void testConnectionFailure() {
    //     Async async = ctx.async();
    //     ProxyServer proxy = ProxyServer.create(vertx, options.getPort(), options.getHost());
    //     AtomicReference<ProxyServer.Connection> proxyConn = new AtomicReference<>();
    //     proxy.proxyHandler(conn -> {
    //         proxyConn.set(conn);
    //         conn.connect();
    //     });
    //     PgPool pool = PgPool.pool(vertx, new PgConnectOptions(options).setPort(8080).setHost("localhost"),
    //         new PoolOptions()
    //             .setMaxSize(1)
    //             .setMaxWaitQueueSize(0)
    //     );
    //     pool.getConnection(ctx.asyncAssertFailure(err -> {
    //         proxy.listen(8080, "localhost", ctx.asyncAssertSuccess(v1 -> {
    //             pool.getConnection(ctx.asyncAssertSuccess(conn -> {
    //                 async.complete();
    //             }));
    //         }));
    //     }));
    // }

    // @Test
    // void testRunWithExisting() {
    //     Async async = ctx.async();
    //     vertx.runOnContext(v -> {
    //         try {
    //             PgPool.pool(new PoolOptions());
    //             ctx.fail();
    //         } catch (IllegalStateException ignore) {
    //             async.complete();
    //         }
    //     });
    // }

    // @Test
    // void testRunStandalone() {
    //     Async async = ctx.async();
    //     PgPool pool = PgPool.pool(options, new PoolOptions());
    //     try {
    //         pool.query("SELECT id, randomnumber from WORLD", ctx.asyncAssertSuccess(v -> {
    //             async.complete();
    //         }));
    //         async.await(4000);
    //     } finally {
    //         pool.close();
    //     }
    // }

    // @Test
    // void testMaxWaitQueueSize() {
    //     Async async = ctx.async();
    //     PgPool pool = PgPool.pool(options, new PoolOptions().setMaxSize(1).setMaxWaitQueueSize(0));
    //     try {
    //         pool.getConnection(ctx.asyncAssertSuccess(v -> {
    //             pool.getConnection(ctx.asyncAssertFailure(err -> {
    //                 async.complete();
    //             }));
    //         }));
    //         async.await(4000000);
    //     } finally {
    //         pool.close();
    //     }
    // }

    // // This test check that when using pooled connections, the preparedQuery pool operation
    // // will actually use the same connection for the prepare and the query commands
    // @Test
    // void testConcurrentMultipleConnection() {
    //     PoolOptions poolOptions = new PoolOptions().setMaxSize(2);
    //     PgPool pool = PgPool.pool(vertx, new PgConnectOptions(this.options).setCachePreparedStatements(true), poolOptions);
    //     int numRequests = 2;
    //     Async async = ctx.async(numRequests);
    //     for (int i = 0;i < numRequests;i++) {
    //         pool.preparedQuery("SELECT * FROM Fortune WHERE id=$1", Tuple.of(1), ctx.asyncAssertSuccess(results -> {
    //             ctx.assertEquals(1, results.size());
    //             Tuple row = results.iterator().next();
    //             ctx.assertEquals(1, row.getInteger(0));
    //             ctx.assertEquals("fortune: No such file or directory", row.getString(1));
    //             async.countDown();
    //         }));
    //     }
    // }
}
