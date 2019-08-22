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

module test.pgclient.PgClientTestBase;

import test.pgclient.PgTestBase;

import hunt.database.base;
import hunt.database.postgresql;

import hunt.Assert;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.collection;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */

abstract class PgClientTestBase(C) : PgTestBase if(is(C : SqlClient)) {

    // Vertx vertx;
    
    Consumer!(AsyncResultHandler!(C)) connector;

    @Before
    override void setup() {
        super.setup();
        // vertx = Vertx.vertx();
    }

    @After
    void teardown() {
        // vertx.close(ctx.asyncAssertSuccess());
    }

    @Test
    void testConnectNonSSLServer() {
        // options.setSslMode(SslMode.REQUIRE).setTrustAll(true);
        // connector.accept(ctx.asyncAssertFailure(err -> {
        //     ctx.assertEquals("Postgres Server does not handle SSL connection", err.getMessage());
        //     async.complete();
        // }));
    }

    // @Test
    // void testMultipleQuery() {
    //     Async async = ctx.async();
    //     connector.accept(ctx.asyncAssertSuccess(conn -> {
    //         conn.query("SELECT id, message from FORTUNE LIMIT 1;SELECT message, id from FORTUNE LIMIT 1", ctx.asyncAssertSuccess(result1 -> {
    //             ctx.assertEquals(1, result1.size());
    //             ctx.assertEquals(Arrays.asList("id", "message"), result1.columnsNames());
    //             Tuple row1 = result1.iterator().next();
    //             ctx.assertTrue(row1.getValue(0) instanceof Integer);
    //             ctx.assertTrue(row1.getValue(1) instanceof String);
    //             RowSet result2 = result1.next();
    //             ctx.assertNotNull(result2);
    //             ctx.assertEquals(1, result2.size());
    //             ctx.assertEquals(Arrays.asList("message", "id"), result2.columnsNames());
    //             Tuple row2 = result2.iterator().next();
    //             ctx.assertTrue(row2.getValue(0) instanceof String);
    //             ctx.assertTrue(row2.getValue(1) instanceof Integer);
    //             ctx.assertNull(result2.next());
    //             async.complete();
    //         }));
    //     }));
    // }

    // @Test
    // void testInsertReturning() {
    //     Async async = ctx.async();
    //     connector.accept(ctx.asyncAssertSuccess(client -> {
    //         deleteFromTestTable(ctx, client, () -> {
    //             client.preparedQuery("INSERT INTO Test (id, val) VALUES ($1, $2) RETURNING id", Tuple.of(14, "SomeMessage"), ctx.asyncAssertSuccess(result -> {
    //                 ctx.assertEquals(14, result.iterator().next().getInteger("id"));
    //                 async.complete();
    //             }));
    //         });
    //     }));
    // }

    // @Test
    // void testInsertReturningError() {
    //     Async async = ctx.async();
    //     connector.accept(ctx.asyncAssertSuccess(client -> {
    //         deleteFromTestTable(ctx, client, () -> {
    //             client.preparedQuery("INSERT INTO Test (id, val) VALUES ($1, $2) RETURNING id", Tuple.of(15, "SomeMessage"), ctx.asyncAssertSuccess(result -> {
    //                 ctx.assertEquals(15, result.iterator().next().getInteger("id"));
    //                 client.preparedQuery("INSERT INTO Test (id, val) VALUES ($1, $2) RETURNING id", Tuple.of(15, "SomeMessage"), ctx.asyncAssertFailure(err -> {
    //                     ctx.assertEquals("23505", ((PgException) err).getCode());
    //                     async.complete();
    //                 }));
    //             }));
    //         });
    //     }));
    // }

    // static int randomWorld() {
    //     return 1 + ThreadLocalRandom.current().nextInt(10000);
    // }

    // @Test
    // void testBatchSelect() {
    //     Async async = ctx.async();
    //     connector.accept(ctx.asyncAssertSuccess(conn -> {
    //         List!(Tuple) batch = new ArrayList<>();
    //         batch.add(Tuple.tuple());
    //         batch.add(Tuple.tuple());
    //         conn.preparedBatch("SELECT count(id) FROM World", batch, ctx.asyncAssertSuccess(result -> {
    //             ctx.assertEquals(result.size(), result.next().size());
    //             async.complete();
    //         }));
    //     }));
    // }

    // @Test
    // void testDisconnectAbruptlyDuringStartup() {
    //     Async async = ctx.async();
    //     ProxyServer proxy = ProxyServer.create(vertx, options.getPort(), options.getHost());
    //     proxy.proxyHandler(conn -> {
    //         NetSocket clientSo = conn.clientSocket();
    //         clientSo.handler(buff -> {
    //             clientSo.close();
    //         });
    //         clientSo.resume();
    //     });
    //     proxy.listen(8080, "localhost", ctx.asyncAssertSuccess(v1 -> {
    //         options.setPort(8080).setHost("localhost");
    //         connector.accept(ctx.asyncAssertFailure(err -> async.complete()));
    //     }));
    // }

    // @Test
    // void testTx() {
    //     Async async = ctx.async();
    //     connector.accept(ctx.asyncAssertSuccess(conn -> {
    //         conn.query("BEGIN", ctx.asyncAssertSuccess(result1 -> {
    //             ctx.assertEquals(0, result1.size());
    //             ctx.assertNotNull(result1.iterator());
    //             conn.query("COMMIT", ctx.asyncAssertSuccess(result2 -> {
    //                 ctx.assertEquals(0, result2.size());
    //                 async.complete();
    //             }));
    //         }));
    //     }));
    // }
}
