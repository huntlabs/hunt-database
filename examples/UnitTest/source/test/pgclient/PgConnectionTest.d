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

module test.pgclient.PgConnectionTest;

import test.pgclient.PgConnectionTestBase;

import hunt.database.base;
import hunt.database.driver.postgresql;

import hunt.database.driver.postgresql.impl;

import hunt.Assert;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.collection;

/**
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class PgConnectionTest : PgConnectionTestBase {

    this() {
        connector = (handler) {
            trace("Initializing connect ...");
            PgConnectionImpl.connect(options, (AsyncResult!PgConnection ar) {
                // mapping PgConnection to SqlConnection
                // handler(ar.map!(SqlConnection)( p => p));

                if(ar.succeeded()) {
                    handler(ar.result());
                } else {
                    warning(ar.cause().msg);
                }
            });
        };
    }

    @Test
    void testSettingSchema() {
        options.addProperty("search_path", "myschema");
        connector((SqlConnection conn) {
            trace(typeid(conn));
            conn.query("SHOW search_path;", (AsyncResult!RowSet ar) {
                assert(ar !is null);
                if(ar.succeeded()) {
                    RowSet pgRowSet = ar.result();
                    trace(typeid(cast(Object)pgRowSet));

                    RowIterator iterator = pgRowSet.iterator();
                    assert(!iterator.empty());
                    Row row = iterator.front();
                    // Object value = row.getValue("search_path");
                    // trace(typeid(value));
                    // string v = value.toString();
                    
                    string v = row.getString("search_path");
                    assert(v == "myschema");
                    info("test done");
                } else {
                    warning(ar.cause().msg);
                }
            });

        });
    }

//     @Test
//     void testBatchUpdate() {
//         Async async = ctx.async();
//         connector.accept(ctx.asyncAssertSuccess(conn -> {
//             deleteFromTestTable(ctx, conn, () -> {
//                 insertIntoTestTable(ctx, conn, 10, () -> {
//                     conn.prepare("UPDATE Test SET val=$1 WHERE id=$2", ctx.asyncAssertSuccess(ps -> {
//                         List!(Tuple) batch = new ArrayList<>();
//                         batch.add(Tuple.of("val0", 0));
//                         batch.add(Tuple.of("val1", 1));
//                         ps.batch(batch, ctx.asyncAssertSuccess(result -> {
//                             for (int i = 0;i < 2;i++) {
//                                 ctx.assertEquals(1, result.rowCount());
//                                 result = result.next();
//                             }
//                             ctx.assertNull(result);
//                             ps.close(ctx.asyncAssertSuccess(v -> {
//                                 async.complete();
//                             }));
//                         }));
//                     }));
//                 });
//             });
//         }));
//     }

//     @Test
//     void testQueueQueries() {
//         int num = 1000;
//         Async async = ctx.async(num + 1);
//         connector.accept(ctx.asyncAssertSuccess(conn -> {
//             for (int i = 0;i < num;i++) {
//                 conn.query("SELECT id, randomnumber from WORLD", ar -> {
//                     if (ar.succeeded()) {
//                         SqlResult result = ar.result();
//                         ctx.assertEquals(10000, result.size());
//                     } else {
//                         ctx.assertEquals("closed", ar.cause().getMessage());
//                     }
//                     async.countDown();
//                 });
//             }
//             conn.closeHandler(v -> {
//                 ctx.assertEquals(1, async.count());
//                 async.countDown();
//             });
//             conn.close();
//         }));
//     }

//     @Test
//     void testCancelRequest() {
//         Async async = ctx.async(2);
//         connector.accept(ctx.asyncAssertSuccess(conn -> {
//             conn.query("SELECT pg_sleep(10)", ctx.asyncAssertFailure(error -> {
//                 ctx.assertEquals("canceling statement due to user request", error.getMessage());
//                 async.countDown();
//             }));
//             ((PgConnection)conn).cancelRequest(ctx.asyncAssertSuccess());

//             conn.closeHandler(v -> {
//                 ctx.assertEquals(1, async.count());
//                 async.countDown();
//             });
//             conn.close();
//         }));
//     }
}
